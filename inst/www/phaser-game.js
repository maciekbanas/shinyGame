let game, scene, cursors;
let controlledSprite = null;

window.GameBridge = window.GameBridge || {};
GameBridge.playerControls = {};
GameBridge.overlapEndWatchers = {};
GameBridge.forcedAnimations = GameBridge.forcedAnimations || {};
GameBridge.pendingCameraFollow = GameBridge.pendingCameraFollow || {};

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
  }

  function update(time, delta) {

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

function addText(text, id, x, y, style, visible = true) {
  scene[id] = scene.add.text(x, y, text, style);
  scene[id].setVisible(visible);
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

function setWorldBounds(width, height) {
  if (!scene || !scene.physics || !scene.cameras) return;

  scene.physics.world.setBounds(0, 0, width, height);
  scene.cameras.main.setBounds(0, 0, width, height);
}

function followSpriteWithCamera(name, lerpX = 1, lerpY = 1, roundPixels = true) {
  GameBridge.pendingCameraFollow[name] = { lerpX, lerpY, roundPixels };

  const sprite = scene && scene.children.getByName(name);
  if (!sprite) return;

  scene.cameras.main.startFollow(sprite, roundPixels, lerpX, lerpY);
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
  });

  scene.load.start();
}

function addPlayerTerrainCollider(spriteName) {
  const sprite = scene.children.getByName(spriteName);
  if (!sprite || !scene.terrainLayer) return;
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

function addOverlap(objectOneName, objectTwoName, inputId) {
  const objectOne = scene.children.getByName(objectOneName);
  const objectTwo = scene.children.getByName(objectTwoName);
  scene.physics.add.overlap(
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

function addOverlapEnd(objectOneName, objectTwoName, inputId) {
  const obj1 = scene.children.getByName(objectOneName);
  const obj2 = scene.children.getByName(objectTwoName);
  if (!obj1 || !obj2) return;

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

function addGroupOverlap(objectName, groupName, inputId) {
  const objectOne = scene.children.getByName(objectName);
  const objectTwo = scene[groupName];
  scene.physics.add.overlap(
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

function addRectangle(name, x, y, width, height, fillColor, visible = true, clickable = true) {
  scene[name] = scene.add.rectangle(x, y, width, height, fillColor);
  if (clickable) {
    scene[name].setInteractive();
  }
  scene[name].setVisible(visible);
}

function addGraphics(name, x, y, width, height, fillColor) {
  scene[name] = scene.add.rectangle(x, y, width, height, fillColor);
}

Shiny.addCustomMessageHandler("phaser", function (message) {
  eval(message.js);
});
