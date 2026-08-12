let game, scene, cursors;
let controlledSprite = null;

window.GameBridge = window.GameBridge || {};
GameBridge.playerControls = {};
GameBridge.overlapEndWatchers = {};
GameBridge.forcedAnimations = GameBridge.forcedAnimations || {};
GameBridge.pendingCameraFollow = GameBridge.pendingCameraFollow || {};
GameBridge.pendingScrollFactor = GameBridge.pendingScrollFactor || {};
GameBridge.pendingWorldBounds = GameBridge.pendingWorldBounds || null;
GameBridge.pendingTerrainColliders = GameBridge.pendingTerrainColliders || [];
GameBridge.terrainColliderSprites = GameBridge.terrainColliderSprites || [];
GameBridge.terrainColliders = GameBridge.terrainColliders || {};
GameBridge.maps = GameBridge.maps || {};
GameBridge.activeMapKey = GameBridge.activeMapKey || null;
GameBridge.pendingActiveMap = GameBridge.pendingActiveMap || null;
GameBridge.mapLoadQueue = GameBridge.mapLoadQueue || [];
GameBridge.mapLoading = GameBridge.mapLoading || false;
GameBridge.proximityTriggers = GameBridge.proximityTriggers || {};
GameBridge.proximityElementVisibility = GameBridge.proximityElementVisibility || {};
GameBridge.realmObjectVisibility = GameBridge.realmObjectVisibility || {};
GameBridge.navigationOverlayVisible = GameBridge.navigationOverlayVisible || false;
GameBridge.lastHeroOverlapState = GameBridge.lastHeroOverlapState || "";
GameBridge.nextHeroOverlapSendAt = GameBridge.nextHeroOverlapSendAt || 0;
GameBridge.sounds = GameBridge.sounds || {};
GameBridge.pendingSoundActions = GameBridge.pendingSoundActions || {};
GameBridge.directionalAttackMemory = 1500;

function rememberMovementDirection(sprite, direction, time) {
  if (!sprite || !["left", "right", "up", "down"].includes(direction)) return;
  sprite.setData("lastMovementDirection", direction);
  sprite.setData("lastMovedAt", time);
}

function recentDirectionalAnimation(sprite, animationKey, time) {
  if (!sprite || !animationKey || !scene) return animationKey;

  const direction = sprite.getData("lastMovementDirection");
  const movedAt = sprite.getData("lastMovedAt");
  const movedRecently = ["left", "right", "up", "down"].includes(direction) &&
    Number.isFinite(movedAt) &&
    time - movedAt <= GameBridge.directionalAttackMemory;
  const directionalKey = animationKey + "_" + direction;

  return movedRecently && scene.anims.exists(directionalKey)
    ? directionalKey
    : animationKey;
}

function forcedAnimationForMovement(sprite, forcedKey, movementKey, time) {
  const directionalKey = recentDirectionalAnimation(sprite, forcedKey, time);
  if (directionalKey !== forcedKey || !movementKey) return directionalKey;

  const movementSuffix = movementKey.slice((sprite.name + "_").length);
  const forcedMovementKey = forcedKey + "_" + movementSuffix;
  return scene.anims.exists(forcedMovementKey) ? forcedMovementKey : forcedKey;
}

function sendPhaserEvent(target, payload) {
  // jsonlite represented an absent R event target as an empty object in older
  // messages. Shiny input names must be strings; passing that object reaches
  // Shiny's input-name splitter and throws `e.split is not a function`, which
  // aborts Phaser's game loop on the first collision.
  if (typeof target !== "string" || target.length === 0) return;
  if ((/^https?:/.test(target) || target.includes("/")) && window.fetch) {
    window.fetch(target, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
      keepalive: true
    }).catch((error) => {
      console.error("Failed to send Phaser event", error);
    });
    return;
  }

  if (window.Shiny && typeof Shiny.setInputValue === "function") {
    Shiny.setInputValue(target, payload, { priority: "event" });
  }
}

function phaserCollisionPayload(obj1, obj2) {
  return {
    name1: obj1.name, x1: obj1.x, y1: obj1.y,
    name2: obj2.name, x2: obj2.x, y2: obj2.y,
    evt_nonce: Date.now() + Math.random()
  };
}

function playIfChanged(sprite, animKey) {
  if (!sprite || !animKey) return;
  if (!sprite.anims || sprite.anims.currentAnim?.key !== animKey) {
    sprite.play(animKey, true);
  }
}

function playTypeAnim(sprite, type, suffix) {
  const key1 = type + "_" + suffix;
  const key2 = type + "_idle";
  if (scene.anims.exists(key1)) {
    sprite.play(key1, true);
  } else if (scene.anims.exists(key2)) {
    sprite.play(key2, true);
  }
}

function initPhaserGame(containerId, config) {
  GameBridge.overlapEndWatchers = {};

  window.game = new Phaser.Game({
    type: Phaser.AUTO,
    width: config.width,
    height: config.height,
    parent: containerId,
    physics: {
      default: 'arcade',
      arcade: {
        gravity: {
          x: Number(config.gravity_x) || 0,
          y: Number(config.gravity_y) || 0
        }
      }
    },
    scene: {
      preload: preload,
      create: create,
      update: update
    }
  });

  let cursors;

  function preload() {
    scene = this;
  }

  function create() {
    cursors = this.input.keyboard.createCursorKeys();
    applyWorldBounds(GameBridge.pendingWorldBounds);
    const unlockAudio = () => {
      const context = this.sound && this.sound.context;
      if (context && context.state === "suspended") context.resume();
    };
    this.input.keyboard.once("keydown", unlockAudio);
    this.input.once("pointerdown", unlockAudio);
  }

  function update(time, delta) {
      applyPendingCameraFollows();
      applyPendingScrollFactors();
      updateProximityTriggers();
      sendHeroOverlapState(time);

      Object.entries(GameBridge.playerControls).forEach(([name, opts]) => {
          const sprite = this.children.getByName(name);
          if (!sprite) return;

          const { speed, directionMap } = opts;
          const animationPrefix = opts.animationPrefix || name;

          if (directionMap.left || directionMap.right) {
            sprite.body.setVelocityX(0);
          }
          if (directionMap.up || directionMap.down) {
            sprite.body.setVelocityY(0);
          }

          let targetAnim = animationPrefix + '_idle';

          if (cursors.left.isDown && directionMap.left) {
            sprite.body.setVelocityX(-speed);
            targetAnim = animationPrefix + '_move_left';
            rememberMovementDirection(sprite, "left", time);
          } else if (cursors.right.isDown && directionMap.right) {
            sprite.body.setVelocityX(speed);
            targetAnim = animationPrefix + '_move_right';
            rememberMovementDirection(sprite, "right", time);
          } else if (cursors.up.isDown && directionMap.up) {
            sprite.body.setVelocityY(-speed);
            targetAnim = animationPrefix + '_move_up';
            rememberMovementDirection(sprite, "up", time);
          } else if (cursors.down.isDown && directionMap.down) {
            sprite.body.setVelocityY(speed);
            targetAnim = animationPrefix + '_move_down';
            rememberMovementDirection(sprite, "down", time);
          }

          const forced = GameBridge.forcedAnimations[name];
          if (forced) {
            if (forced.until === null || time <= forced.until) {
              const movementKey = targetAnim !== animationPrefix + '_idle' ? targetAnim : null;
              const forcedAnimKey = forcedAnimationForMovement(
                sprite, forced.key, movementKey, time
              );
              playIfChanged(sprite, forcedAnimKey);
              return;
            }
            delete GameBridge.forcedAnimations[name];
          }

          playIfChanged(sprite, targetAnim);
        });
  }
}


function applyPendingSoundActions(name) {
  const sound = GameBridge.sounds[name];
  const actions = GameBridge.pendingSoundActions[name];
  if (!sound || !actions) return;

  actions.forEach((action) => action(sound));
  delete GameBridge.pendingSoundActions[name];
}

function withSound(name, action) {
  const sound = GameBridge.sounds[name];
  if (sound) {
    action(sound);
    return;
  }

  GameBridge.pendingSoundActions[name] = GameBridge.pendingSoundActions[name] || [];
  GameBridge.pendingSoundActions[name].push(action);
}

function addSound(name, url, volume = 1, loop = false) {
  if (GameBridge.sounds[name]) {
    GameBridge.sounds[name].setVolume(volume);
    GameBridge.sounds[name].setLoop(loop);
    return;
  }

  scene.load.audio(name, url);
  scene.load.once(`filecomplete-audio-${name}`, () => {
    if (GameBridge.sounds[name]) return;

    GameBridge.sounds[name] = scene.sound.add(name, { volume, loop });
    applyPendingSoundActions(name);
  });
  if (!scene.load.isLoading()) scene.load.start();
}

function playSound(name, volume = null, loop = null) {
  withSound(name, (sound) => {
    const config = {};
    if (volume !== null) config.volume = volume;
    if (loop !== null) config.loop = loop;
    const context = scene && scene.sound && scene.sound.context;
    if (context && context.state === "suspended") {
      context.resume().then(() => sound.play(config));
    } else {
      sound.play(config);
    }
  });
}

function pauseSound(name) {
  withSound(name, (sound) => sound.pause());
}

function resumeSound(name) {
  withSound(name, (sound) => sound.resume());
}

function stopSound(name) {
  withSound(name, (sound) => sound.stop());
}

function setSoundVolume(name, volume) {
  withSound(name, (sound) => sound.setVolume(volume));
}

function setSoundLoop(name, loop) {
  withSound(name, (sound) => sound.setLoop(loop));
}

function addText(text, id, x, y, style, visible = true) {
  scene[id] = scene.add.text(x, y, text, style).setName(id);
  scene[id].setVisible(visible);

  if (typeof applyPendingCameraFollows === "function") {
    applyPendingCameraFollows();
  }
  if (typeof applyPendingScrollFactors === "function") {
    applyPendingScrollFactors();
  }
}

function setText(text, id) {
  scene[id].setText(text);
}

function showText(id) {
  scene[id].setVisible(true);
}

function hideText(id) {
  scene[id].setVisible(false);
}

function addPlayerControls(name, directions, speed) {
  GameBridge.playerControls[name] = {
    speed,
    animationPrefix: name,
    directionMap: {
      left: directions.includes("left"),
      right: directions.includes("right"),
      up: directions.includes("up"),
      down: directions.includes("down")
    }
  };
};

function setPlayerAnimationPrefix(name, prefix) {
  if (!GameBridge.playerControls[name]) return;
  const animationPrefix = prefix || name;
  GameBridge.playerControls[name].animationPrefix = animationPrefix;
  delete GameBridge.forcedAnimations[name];

  const sprite = scene && scene.children.getByName(name);
  if (sprite) playIfChanged(sprite, animationPrefix + "_idle");
}

function setNavigationOverlayVisible(visible) {
  GameBridge.navigationOverlayVisible = Boolean(visible);
  const element = document.getElementById("leave_map");
  if (visible && element) {
    element.style.display = "none";
    GameBridge.proximityElementVisibility.leave_map = false;
  }

  const marker = document.getElementById("realm_character_marker");
  if (marker) {
    // Keep the realm marker in the same scrolling coordinate space as the
    // Phaser canvas instead of pinning it to the browser viewport.
    const container = game?.canvas?.parentElement;
    if (container && marker.parentElement !== container) {
      container.style.position = "relative";
      container.appendChild(marker);
    }
    marker.style.display = visible ? "block" : "none";
  }
  const realmLabel = document.getElementById("realm_name_label");
  if (realmLabel) {
    const container = game?.canvas?.parentElement;
    if (container && realmLabel.parentElement !== container) container.appendChild(realmLabel);
    realmLabel.style.display = visible ? "block" : "none";
  }
}

function applyWorldBounds(bounds) {
  if (!bounds || !scene || !scene.physics || !scene.cameras) return;

  scene.physics.world.setBounds(0, 0, bounds.width, bounds.height);
  scene.cameras.main.setBounds(0, 0, bounds.width, bounds.height);
}

function setWorldBounds(width, height) {
  GameBridge.pendingWorldBounds = { width, height };
  applyWorldBounds(GameBridge.pendingWorldBounds);
}

function applyPendingScrollFactors() {
  if (!scene) return;

  Object.entries(GameBridge.pendingScrollFactor).forEach(([name, scrollOpts]) => {
    const target = scene.children.getByName(name);
    if (!target || scrollOpts.applied || typeof target.setScrollFactor !== "function") return;

    target.setScrollFactor(scrollOpts.x, scrollOpts.y);
    scrollOpts.applied = true;
  });
}

function setScrollFactor(name, x = 1, y = x) {
  GameBridge.pendingScrollFactor[name] = { x, y, applied: false };
  applyPendingScrollFactors();
}

function applyPendingCameraFollows() {
  if (!scene || !scene.cameras) return;

  Object.entries(GameBridge.pendingCameraFollow).forEach(([name, followOpts]) => {
    const sprite = scene.children.getByName(name);
    if (!sprite || followOpts.applied) return;

    scene.cameras.main.startFollow(
      sprite,
      followOpts.roundPixels,
      followOpts.lerpX,
      followOpts.lerpY
    );
    followOpts.applied = true;
  });
}

function followSpriteWithCamera(name, lerpX = 1, lerpY = 1, roundPixels = true) {
  GameBridge.pendingCameraFollow[name] = { lerpX, lerpY, roundPixels, applied: false };
  applyPendingCameraFollows();
}

function stopCameraFollow(name) {
  const camera = scene && scene.cameras && scene.cameras.main;
  if (!camera) return;

  delete GameBridge.pendingCameraFollow[name];
  camera.stopFollow();
}

function addMap(mapKey, mapUrl, tilesetUrls, tilesetNames, layerName) {
  GameBridge.mapLoadQueue.push({ mapKey, mapUrl, tilesetUrls, tilesetNames, layerName });
  loadNextMap();
}

function loadNextMap() {
  if (GameBridge.mapLoading || GameBridge.mapLoadQueue.length === 0) return;
  GameBridge.mapLoading = true;
  const { mapKey, mapUrl, tilesetUrls, tilesetNames, layerName } =
    GameBridge.mapLoadQueue.shift();

  scene.load.tilemapTiledJSON(mapKey, mapUrl);
  for (let i = 0; i < tilesetNames.length; i++) {
    scene.load.image(tilesetNames[i], tilesetUrls[i]);
  }

  scene.load.once('complete', () => {
    const map = scene.make.tilemap({ key: mapKey });

    const phaserTilesets = [];
    for (let i = 0; i < tilesetNames.length; i++) {
      phaserTilesets.push(
        map.addTilesetImage(tilesetNames[i], tilesetNames[i])
      );
    }

    const groundLayer = map.createLayer(layerName, phaserTilesets, 0, 0);

    groundLayer.setCollisionByProperty({ collides: true });
    // Tilemaps are scenery. Keep them behind sprites and fixed HUD objects
    // regardless of which asynchronous asset happens to finish loading first.
    groundLayer.setDepth(-1);
    GameBridge.maps[mapKey] = { map, layer: groundLayer };
    groundLayer.setVisible(false).setActive(false);

    if (!GameBridge.activeMapKey) {
      activateMap(mapKey);
    } else if (GameBridge.pendingActiveMap?.mapKey === mapKey) {
      activateMap(...GameBridge.pendingActiveMap.args);
    }
    GameBridge.mapLoading = false;
    loadNextMap();
  });

  scene.load.start();
}

function activateMap(mapKey, playerName = null, x = null, y = null,
                     visibleObjects = [], hiddenObjects = []) {
  // R JSON serializers can simplify a one-item vector to a scalar. Normalize
  // both arguments so realm activation remains safe for zero, one, or many
  // objects, including messages produced by older shinyphaser versions.
  visibleObjects = Array.isArray(visibleObjects)
    ? visibleObjects
    : (visibleObjects == null ? [] : [visibleObjects]);
  hiddenObjects = Array.isArray(hiddenObjects)
    ? hiddenObjects
    : (hiddenObjects == null ? [] : [hiddenObjects]);

  const mapEntry = GameBridge.maps[mapKey];
  if (!mapEntry) {
    GameBridge.pendingActiveMap = {
      mapKey,
      args: [mapKey, playerName, x, y, visibleObjects, hiddenObjects]
    };
    return;
  }

  Object.entries(GameBridge.maps).forEach(([key, entry]) => {
    const active = key === mapKey;
    entry.layer.setVisible(active).setActive(active);
  });

  GameBridge.activeMapKey = mapKey;
  GameBridge.pendingActiveMap = null;
  scene.terrainLayer = mapEntry.layer;
  scene.physics.world.setBounds(0, 0, mapEntry.map.widthInPixels, mapEntry.map.heightInPixels);
  scene.cameras.main.setBounds(0, 0, mapEntry.map.widthInPixels, mapEntry.map.heightInPixels);

  [...visibleObjects.map((name) => [name, true]),
   ...hiddenObjects.map((name) => [name, false])].forEach(([name, visible]) => {
    setRealmObjectVisibility(name, visible);
  });

  const player = playerName && scene.children.getByName(playerName);
  if (player && Number.isFinite(x) && Number.isFinite(y)) {
    player.setPosition(x, y);
    if (player.body) player.body.reset(x, y);
  }

  applyPendingTerrainColliders();
  updateProximityTriggers();
}

function setRealmObjectVisibility(name, visible) {
  GameBridge.realmObjectVisibility[name] = Boolean(visible);
  applyRealmObjectVisibility(name);
}

function applyRealmObjectVisibility(name) {
  if (!Object.prototype.hasOwnProperty.call(GameBridge.realmObjectVisibility, name)) return;
  const object = scene && scene.children.getByName(name);
  if (!object) return;

  const visible = GameBridge.realmObjectVisibility[name];
  object.setVisible(visible).setActive(visible);
  if (object.body) object.body.enable = visible;
}

function addProximityTrigger(id, objectName, x, y, radius, elementId, context, inputId) {
  GameBridge.proximityTriggers[id] = {
    objectName, x, y, radius, elementId, context, inputId, active: false
  };
  updateProximityTriggers();
}

function updateProximityTriggers() {
  const elementVisibility = Object.fromEntries(
    Object.keys(GameBridge.proximityElementVisibility).map((elementId) => [elementId, false])
  );

  Object.entries(GameBridge.proximityTriggers).forEach(([id, trigger]) => {
    const contextActive = trigger.context === null ||
      trigger.context === GameBridge.activeMapKey;
    const object = contextActive && scene && scene.children.getByName(trigger.objectName);
    const active = Boolean(object && Phaser.Math.Distance.Between(
      object.x, object.y, trigger.x, trigger.y
    ) <= trigger.radius);

    if (trigger.elementId) {
      elementVisibility[trigger.elementId] = Boolean(
        elementVisibility[trigger.elementId] || active
      );
    }

    if (active !== trigger.active) {
      trigger.active = active;
      sendPhaserEvent(trigger.inputId, {
        id, active, objectName: trigger.objectName,
        x: object?.x, y: object?.y,
        evt_nonce: Date.now() + Math.random()
      });
    }
  });

  Object.entries(elementVisibility).forEach(([elementId, visible]) => {
    if (GameBridge.proximityElementVisibility[elementId] === visible) return;
    const element = document.getElementById(elementId);
    if (element) element.style.display = visible ? "block" : "none";
    GameBridge.proximityElementVisibility[elementId] = visible;
  });
}

function applyPendingTerrainColliders() {
  if (!scene || !scene.terrainLayer) return;

  GameBridge.pendingTerrainColliders.forEach((spriteName) => {
    if (!GameBridge.terrainColliderSprites.includes(spriteName)) {
      GameBridge.terrainColliderSprites.push(spriteName);
    }
  });
  GameBridge.pendingTerrainColliders = [];

  Object.values(GameBridge.terrainColliders).forEach((collider) => collider.destroy());
  GameBridge.terrainColliders = {};
  GameBridge.terrainColliderSprites.forEach((spriteName) => {
    const sprite = scene.children.getByName(spriteName);
    if (!sprite) return;
    GameBridge.terrainColliders[spriteName] = scene.physics.add.collider(
      sprite, scene.terrainLayer
    );
  });
}

function addPlayerTerrainCollider(spriteName) {
  const sprite = scene.children.getByName(spriteName);
  if (!sprite || !scene.terrainLayer) {
    if (!GameBridge.pendingTerrainColliders.includes(spriteName)) {
      GameBridge.pendingTerrainColliders.push(spriteName);
    }
    return;
  }
  if (!GameBridge.terrainColliderSprites.includes(spriteName)) {
    GameBridge.terrainColliderSprites.push(spriteName);
  }
  applyPendingTerrainColliders();
}

function addCollider(objectOneName, objectTwoName, inputId, browserActions = []) {
  if (retryWhenMissingObjects(
    () => addCollider(objectOneName, objectTwoName, inputId, browserActions),
    [objectOneName, objectTwoName]
  )) return;
  const objectOne = scene.children.getByName(objectOneName);
  const objectTwo = scene.children.getByName(objectTwoName);
  scene.physics.add.collider(
    objectOne, objectTwo,
    function(obj1, obj2) {
      runBrowserActionList(browserActions, obj1, obj2);
      sendPhaserEvent(inputId, phaserCollisionPayload(obj1, obj2));
    }
  );
}

function addGroupCollider(objectName, groupName, inputId, browserActions = []) {
  if (!scene.children.getByName(objectName) || !scene[groupName]) {
    window.setTimeout(() => addGroupCollider(objectName, groupName, inputId, browserActions), 100);
    return;
  }
  const objectOne = scene.children.getByName(objectName);
  const objectTwo = scene[groupName];
  scene.physics.add.collider(
    objectOne, objectTwo,
    function(obj1, obj2) {
      runBrowserActionList(browserActions, obj1, obj2);
      sendPhaserEvent(inputId, phaserCollisionPayload(obj1, obj2));
    }
  );
}

function retryWhenMissingObjects(fn, objectNames) {
  const missingObject = objectNames.some((name) => !scene.children.getByName(name));
  if (!missingObject) return false;

  window.setTimeout(fn, 100);
  return true;
}

function addOverlap(objectOneName, objectTwoName, inputId, browserActions = [], mode = "enter", interval = 0) {
  if (retryWhenMissingObjects(() => addOverlap(objectOneName, objectTwoName, inputId, browserActions, mode, interval), [objectOneName, objectTwoName])) return;

  const objectOne = scene.children.getByName(objectOneName);
  const objectTwo = scene.children.getByName(objectTwoName);
  let lastContact = -Infinity;
  let lastRun = -Infinity;
  scene.physics.add.overlap(
    objectOne, objectTwo,
    function(obj1, obj2) {
      const now = performance.now();
      const entering = now - lastContact > 50;
      lastContact = now;
      if ((mode === "enter" && entering) || (mode === "stay" && now - lastRun >= interval)) {
        lastRun = now;
        runBrowserActionList(browserActions, obj1, obj2);
        sendPhaserEvent(inputId, phaserCollisionPayload(obj1, obj2));
      }
    }
  );
}

function areOverlap(objectOneName, objectTwoName, inputId) {
  const objectOne = scene.children.getByName(objectOneName);
  const objectTwo = scene.children.getByName(objectTwoName);
  if (Phaser.Geom.Intersects.RectangleToRectangle(
      objectOne.getBounds(),
      objectTwo.getBounds()
  )) {
     Shiny.setInputValue(
        inputId,
        'true',
        { priority: "event" }
      );
  } else {
    Shiny.setInputValue(
        inputId,
        'false',
        { priority: "event" }
      );
  }
};

function addOverlapEnd(objectOneName, objectTwoName, inputId, browserActions = []) {
  if (retryWhenMissingObjects(() => addOverlapEnd(objectOneName, objectTwoName, inputId, browserActions), [objectOneName, objectTwoName])) return;

  const obj1 = scene.children.getByName(objectOneName);
  const obj2 = scene.children.getByName(objectTwoName);

  const watcherKey = `${objectOneName}::${objectTwoName}::${inputId}`;
  if (GameBridge.overlapEndWatchers[watcherKey]) return;
  GameBridge.overlapEndWatchers[watcherKey] = true;
  let wasOverlapping = false;

  scene.events.on("update", () => {
    const currentlyOverlapping = Phaser.Geom.Intersects.RectangleToRectangle(
      obj1.getBounds(),
      obj2.getBounds()
    );

    if (wasOverlapping && !currentlyOverlapping) {
      runBrowserActionList(browserActions, obj1, obj2);
      sendPhaserEvent(inputId, phaserCollisionPayload(obj1, obj2));
    }

    wasOverlapping = currentlyOverlapping;
  });
}

function addGroupOverlap(objectName, groupName, inputId, browserActions = [], mode = "enter", interval = 0) {
  if (!scene.children.getByName(objectName) || !scene[groupName]) {
    window.setTimeout(() => addGroupOverlap(objectName, groupName, inputId, browserActions, mode, interval), 100);
    return;
  }
  const objectOne = scene.children.getByName(objectName);
  const objectTwo = scene[groupName];
  const contacts = new WeakMap();
  const runs = new WeakMap();
  scene.physics.add.overlap(
    objectOne, objectTwo,
    function(obj1, obj2) {
      const now = performance.now();
      const entering = now - (contacts.get(obj2) ?? -Infinity) > 50;
      contacts.set(obj2, now);
      if ((mode === "enter" && entering) ||
          (mode === "stay" && now - (runs.get(obj2) ?? -Infinity) >= interval)) {
        runs.set(obj2, now);
        runBrowserActionList(browserActions, obj1, obj2);
        sendPhaserEvent(inputId, phaserCollisionPayload(obj1, obj2));
      }
    }
  );
}

function addRectangle(name, x, y, width, height, fillColor, visible = true, clickable = true) {
  scene[name] = scene.add.rectangle(x, y, width, height, fillColor).setName(name);
  if (clickable) {
    scene[name].setInteractive();
  }
  scene[name].setVisible(visible);

  if (typeof applyPendingCameraFollows === "function") {
    applyPendingCameraFollows();
  }
  if (typeof applyPendingScrollFactors === "function") {
    applyPendingScrollFactors();
  }
}

function addCollisionRectangle(name, x, y, width, height) {
  const rectangle = scene.add.rectangle(x, y, width, height, 0x000000, 0)
    .setName(name);
  scene.physics.add.existing(rectangle, true);
  scene[name] = rectangle;

  if (typeof applyRealmObjectVisibility === "function") {
    applyRealmObjectVisibility(name);
  }
}

function addGraphics(name, x, y, width, height, fillColor) {
  scene[name] = scene.add.rectangle(x, y, width, height, fillColor);
}

function shinyInputReady() {
  return typeof Shiny !== "undefined" && typeof Shiny.setInputValue === "function";
}

function sendHeroOverlapState(time) {
  if (typeof currentHeroOverlaps !== "function" || !shinyInputReady()) return;
  if (time < GameBridge.nextHeroOverlapSendAt) return;

  const overlaps = currentHeroOverlaps();
  const state = JSON.stringify(overlaps);
  if (state === GameBridge.lastHeroOverlapState) return;

  GameBridge.lastHeroOverlapState = state;
  GameBridge.nextHeroOverlapSendAt = time + 250;
  Shiny.setInputValue(
    "hero_overlaps",
    { overlaps, evt_nonce: Date.now() + Math.random() },
    { priority: "event" }
  );
}

// Phaser owns the live transforms, so snapshot them at the instant a save is
// requested instead of relying on coordinates previously delivered to Shiny.
function capturePhaserGameState(inputId, requestId, name, options = {}) {
  if (!scene || !shinyInputReady()) return;
  const requested = Array.isArray(options.objects) ? new Set(options.objects) : null;
  const objects = {};
  scene.children.list.forEach((object) => {
    if (!object.name || (requested && !requested.has(object.name))) return;
    objects[object.name] = {
      x: object.x,
      y: object.y,
      visible: object.visible,
      active: object.active
    };
  });
  Shiny.setInputValue(inputId, {
    requestId,
    name,
    state: options.state || {},
    objects,
    evt_nonce: Date.now() + Math.random()
  }, { priority: "event" });
}

function restorePhaserGameState(snapshot, attempts = 40) {
  const pending = [];
  Object.entries(snapshot?.objects || {}).forEach(([name, saved]) => {
    const object = scene && scene.children.getByName(name);
    if (!object) { pending.push(name); return; }
    if (Number.isFinite(saved.x) && Number.isFinite(saved.y)) {
      object.setPosition(saved.x, saved.y);
      // Arcade bodies retain their own previous position; reset both values so
      // the next physics tick cannot snap the hero back to the old location.
      if (object.body && typeof object.body.reset === "function") {
        object.body.reset(saved.x, saved.y);
      }
    }
    if (typeof saved.visible === "boolean") object.setVisible(saved.visible);
    if (typeof saved.active === "boolean") object.setActive(saved.active);
  });
  if (pending.length && attempts > 0) {
    window.setTimeout(() => restorePhaserGameState(snapshot, attempts - 1), 100);
  }
}

Shiny.addCustomMessageHandler("phaser", function (message) {
  eval(message.js);
});

Shiny.addCustomMessageHandler("phaser-save-complete", function (save) {
  window.dispatchEvent(new CustomEvent("shinyphaser:saved", { detail: save }));
});
