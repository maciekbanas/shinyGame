let game, scene, cursors;
let controlledSprite = null;

window.GameBridge = window.GameBridge || {};
GameBridge.playerControls = {};

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

          sprite.body.setVelocity(0);

          const { speed, directions } = opts;
          const dir = directions;

          if (cursors.left.isDown && dir.includes("left")) {
            sprite.body.setVelocityX(-speed);
            sprite.anims.play(name + '_move_left', true);
          } else if (cursors.right.isDown && dir.includes("right")) {
            sprite.body.setVelocityX(speed);
            sprite.anims.play(name + '_move_right', true);
          } else if (cursors.up.isDown && dir.includes("up")) {
            sprite.body.setVelocityY(-speed);
            sprite.anims.play(name + '_move_up', true);
          } else if (cursors.down.isDown && dir.includes("down")) {
            sprite.body.setVelocityY(speed);
            sprite.anims.play(name + '_move_down', true);
          } else {
            sprite.anims.play(name + '_idle', true);
          }
        });
  }
}

function addText(text, id, x, y, style) {
  scene[id] = scene.add.text(x, y, text, style);
}

function setText(text, id) {
  scene[id].setText(text);
}

function addPlayerControls(name, directions, speed) {
  GameBridge.playerControls[name] = { speed, directions };
};

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
          name2: obj2.name, x2: obj2.x, y2: obj2.y
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
          name2: obj2.name, x2: obj2.x, y2: obj2.y
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
          name2: obj2.name, x2: obj2.x, y2: obj2.y
        },
        { priority: "event" }
      );
    }
  );
}

function addOverlapEnd(objectOneName, objectTwoName, inputId) {
  const obj1 = scene.children.getByName(objectOneName);
  const obj2 = scene.children.getByName(objectTwoName);

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
          name2: obj2.name, x2: obj2.x, y2: obj2.y
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
          name2: obj2.name, x2: obj2.x, y2: obj2.y
        },
        { priority: "event" }
      );
    }
  );
}

Shiny.addCustomMessageHandler("phaser", function (message) {
  eval(message.js);
});
