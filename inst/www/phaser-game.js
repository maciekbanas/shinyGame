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
GameBridge.mapExits = GameBridge.mapExits || {};
GameBridge.realmExitVisible = GameBridge.realmExitVisible || false;
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
      updateMapExitVisibility();
      sendHeroOverlapState(time);

      Object.entries(GameBridge.playerControls).forEach(([name, opts]) => {
          const sprite = this.children.getByName(name);
          if (!sprite) return;

          const { speed, directionMap } = opts;

          if (directionMap.left || directionMap.right) {
            sprite.body.setVelocityX(0);
          }
          if (directionMap.up || directionMap.down) {
            sprite.body.setVelocityY(0);
          }

          let targetAnim = name + '_idle';

          if (cursors.left.isDown && directionMap.left) {
            sprite.body.setVelocityX(-speed);
            targetAnim = name + '_move_left';
            rememberMovementDirection(sprite, "left", time);
          } else if (cursors.right.isDown && directionMap.right) {
            sprite.body.setVelocityX(speed);
            targetAnim = name + '_move_right';
            rememberMovementDirection(sprite, "right", time);
          } else if (cursors.up.isDown && directionMap.up) {
            sprite.body.setVelocityY(-speed);
            targetAnim = name + '_move_up';
            rememberMovementDirection(sprite, "up", time);
          } else if (cursors.down.isDown && directionMap.down) {
            sprite.body.setVelocityY(speed);
            targetAnim = name + '_move_down';
            rememberMovementDirection(sprite, "down", time);
          }

          const forced = GameBridge.forcedAnimations[name];
          if (forced) {
            if (forced.until === null || time <= forced.until) {
              const movementKey = targetAnim !== name + '_idle' ? targetAnim : null;
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
    directionMap: {
      left: directions.includes("left"),
      right: directions.includes("right"),
      up: directions.includes("up"),
      down: directions.includes("down")
    }
  };
};

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
    const object = scene.children.getByName(name);
    if (!object) return;
    object.setVisible(visible).setActive(visible);
    if (object.body) object.body.enable = visible;
  });

  const player = playerName && scene.children.getByName(playerName);
  if (player && Number.isFinite(x) && Number.isFinite(y)) {
    player.setPosition(x, y);
    if (player.body) player.body.reset(x, y);
  }

  applyPendingTerrainColliders();
  updateMapExitVisibility();
}

function setMapExit(mapKey, playerName, x, y, radius, elementId) {
  GameBridge.mapExits[mapKey] = { playerName, x, y, radius, elementId };
  updateMapExitVisibility();
}

function updateMapExitVisibility() {
  const exit = GameBridge.mapExits[GameBridge.activeMapKey];
  const player = exit && scene && scene.children.getByName(exit.playerName);
  const nearby = Boolean(player && Phaser.Math.Distance.Between(
    player.x, player.y, exit.x, exit.y
  ) <= exit.radius);
  const element = exit && document.getElementById(exit.elementId);

  if (element && nearby !== GameBridge.realmExitVisible) {
    element.style.display = nearby ? "block" : "none";
  }
  GameBridge.realmExitVisible = nearby;
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

Shiny.addCustomMessageHandler("phaser", function (message) {
  eval(message.js);
});
