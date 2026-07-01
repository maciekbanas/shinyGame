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
GameBridge.sounds = GameBridge.sounds || {};
GameBridge.pendingSoundActions = GameBridge.pendingSoundActions || {};

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
    physics: { default: 'arcade' },
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
  }

  function update(time, delta) {
      applyPendingCameraFollows();
      applyPendingScrollFactors();

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
          } else if (cursors.right.isDown && directionMap.right) {
            sprite.body.setVelocityX(speed);
            targetAnim = name + '_move_right';
          } else if (cursors.up.isDown && directionMap.up) {
            sprite.body.setVelocityY(-speed);
            targetAnim = name + '_move_up';
          } else if (cursors.down.isDown && directionMap.down) {
            sprite.body.setVelocityY(speed);
            targetAnim = name + '_move_down';
          }

          const forced = GameBridge.forcedAnimations[name];
          if (forced) {
            if (forced.until === null || time <= forced.until) {
              const directionSuffix = targetAnim.startsWith(name + '_')
                ? targetAnim.slice((name + '_').length)
                : 'idle';

              const directionalForcedKey = forced.key + '_' + directionSuffix;
              const forcedAnimKey = scene.anims.exists(directionalForcedKey)
                ? directionalForcedKey
                : forced.key;

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
  scene.load.once('complete', () => {
    if (GameBridge.sounds[name]) return;

    GameBridge.sounds[name] = scene.sound.add(name, { volume, loop });
    applyPendingSoundActions(name);
  });
  scene.load.start();
}

function playSound(name, volume = null, loop = null) {
  withSound(name, (sound) => {
    const config = {};
    if (volume !== null) config.volume = volume;
    if (loop !== null) config.loop = loop;
    sound.play(config);
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

    scene.physics.world.bounds.width  = map.widthInPixels;
    scene.physics.world.bounds.height = map.heightInPixels;
    scene.cameras.main.setBounds(0, 0, map.widthInPixels, map.heightInPixels);

    scene.terrainLayer = groundLayer;
    applyPendingTerrainColliders();
  });

  scene.load.start();
}

function applyPendingTerrainColliders() {
  if (!scene || !scene.terrainLayer) return;

  GameBridge.pendingTerrainColliders = GameBridge.pendingTerrainColliders.filter((spriteName) => {
    const sprite = scene.children.getByName(spriteName);
    if (!sprite) return true;
    scene.physics.add.collider(sprite, scene.terrainLayer);
    return false;
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
  scene.physics.add.collider(sprite, scene.terrainLayer);
}

function addCollider(objectOneName, objectTwoName, inputId) {
  const objectOne = scene.children.getByName(objectOneName);
  const objectTwo = scene.children.getByName(objectTwoName);
  scene.physics.add.collider(
    objectOne, objectTwo,
    function(obj1, obj2) {
      Shiny.setInputValue(
        inputId,
        {
          name1: obj1.name, x1: obj1.x, y1: obj1.y,
          name2: obj2.name, x2: obj2.x, y2: obj2.y,
          evt_nonce: Date.now() + Math.random()
        },
        { priority: "event" }
      );
    }
  );
}

function addGroupCollider(objectName, groupName, inputId) {
  const objectOne = scene.children.getByName(objectName);
  const objectTwo = scene[groupName];
  scene.physics.add.collider(
    objectOne, objectTwo,
    function(obj1, obj2) {
      Shiny.setInputValue(
        inputId,
        {
          name1: obj1.name, x1: obj1.x, y1: obj1.y,
          name2: obj2.name, x2: obj2.x, y2: obj2.y,
          evt_nonce: Date.now() + Math.random()
        },
        { priority: "event" }
      );
    }
  );
}

function retryWhenMissingObjects(fn, objectNames) {
  const missingObject = objectNames.some((name) => !scene.children.getByName(name));
  if (!missingObject) return false;

  window.setTimeout(fn, 100);
  return true;
}

function addOverlap(objectOneName, objectTwoName, inputId, clientActions = []) {
  if (retryWhenMissingObjects(() => addOverlap(objectOneName, objectTwoName, inputId, clientActions), [objectOneName, objectTwoName])) return;

  const objectOne = scene.children.getByName(objectOneName);
  const objectTwo = scene.children.getByName(objectTwoName);
  scene.physics.add.overlap(
    objectOne, objectTwo,
    function(obj1, obj2) {
      runClientActionList(inputId, clientActions);
      Shiny.setInputValue(
        inputId,
        {
          name1: obj1.name, x1: obj1.x, y1: obj1.y,
          name2: obj2.name, x2: obj2.x, y2: obj2.y,
          evt_nonce: Date.now() + Math.random()
        },
        { priority: "event" }
      );
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

function addOverlapEnd(objectOneName, objectTwoName, inputId, clientActions = []) {
  if (retryWhenMissingObjects(() => addOverlapEnd(objectOneName, objectTwoName, inputId, clientActions), [objectOneName, objectTwoName])) return;

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
      runClientActionList(inputId, clientActions);
      Shiny.setInputValue(
        inputId,
        {
          name1: obj1.name, x1: obj1.x, y1: obj1.y,
          name2: obj2.name, x2: obj2.x, y2: obj2.y,
          evt_nonce: Date.now() + Math.random()
        },
        { priority: "event" }
      );
    }

    wasOverlapping = currentlyOverlapping;
  });
}

function addGroupOverlap(objectName, groupName, inputId, clientActions = []) {
  if (!scene.children.getByName(objectName) || !scene[groupName]) {
    window.setTimeout(() => addGroupOverlap(objectName, groupName, inputId, clientActions), 100);
    return;
  }

  const objectOne = scene.children.getByName(objectName);
  const objectTwo = scene[groupName];
  scene.physics.add.overlap(
    objectOne, objectTwo,
    function(obj1, obj2) {
      runClientActionList(inputId, clientActions);
      Shiny.setInputValue(
        inputId,
        {
          name1: obj1.name, x1: obj1.x, y1: obj1.y,
          name2: obj2.name, x2: obj2.x, y2: obj2.y,
          evt_nonce: Date.now() + Math.random()
        },
        { priority: "event" }
      );
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

Shiny.addCustomMessageHandler("phaser", function (message) {
  eval(message.js);
});
