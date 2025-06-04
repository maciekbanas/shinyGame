let game, scene, cursors;
let controlledSprite = null;

window.GameBridge = window.GameBridge || {};
GameBridge.playerControls = {};

function initPhaserGame(containerId, config) {
  const game = new Phaser.Game({
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
        sprite.body.setVelocityX(0);
        sprite.body.setVelocityY(0);

        if (cursors.left.isDown) {
          sprite.body.setVelocityX(-opts.speed);
          sprite.anims.play(name + '_move_left', true);
        } else if (cursors.right.isDown) {
          sprite.body.setVelocityX(opts.speed);
          sprite.anims.play(name + '_move_right', true);
        } else if (cursors.down.isDown) {
          sprite.body.setVelocityY(opts.speed);
          sprite.anims.play(name + '_move_right', true);
        } else if (cursors.up.isDown) {
          sprite.body.setVelocityY(-opts.speed);
          sprite.anims.play(name + '_move_right', true);
        } else {
          sprite.body.setVelocityX(0);
          sprite.anims.play(name + '_idle', true);
        }
      });
    }
}


function addPlayerSprite(name, url, x, y, frameWidth, frameHeight, frameCount, frameRate) {
  scene.load.spritesheet(name, url, {
    frameWidth: frameWidth,
    frameHeight: frameHeight
  });

  scene.load.once('complete', () => {
    scene.anims.create({
      key: name + '_idle',
      frames: scene.anims.generateFrameNumbers(name, {
        start: 0,
        end: frameCount - 1
      }),
      frameRate: frameRate,
      repeat: -1
    });

    const sprite = scene.physics.add.sprite(x, y, name).setName(name);
    sprite.setCollideWorldBounds(true);
    sprite.play(name + '_idle');

    controlledSprite = sprite;
    scene[name] = sprite;
  });

  scene.load.start();
}

function addPlayerMoveRightAnimation(name, url, frameWidth, frameHeight, frameCount, frameRate) {
  var animName = name + '_move_right';
  scene.load.spritesheet(animName, url, {
    frameWidth: frameWidth,
    frameHeight: frameHeight
  });
  scene.load.once('complete', () => {
    scene.anims.create({
      key: animName,
      frames: scene.anims.generateFrameNumbers(animName, {
        start: 0,
        end: frameCount - 1
      }),
      frameRate: frameRate,
      repeat: -1
    });
  });
  scene.load.start();
}

function addPlayerMoveLeftAnimation(name, url, frameWidth, frameHeight, frameCount, frameRate) {
  var animName = name + '_move_left';
  scene.load.spritesheet(animName, url, {
    frameWidth: frameWidth,
    frameHeight: frameHeight
  });
  scene.load.once('complete', () => {
    scene.anims.create({
      key: animName,
      frames: scene.anims.generateFrameNumbers(animName, {
        start: 0,
        end: frameCount - 1
      }),
      frameRate: frameRate,
      repeat: -1
    });
  });
  scene.load.start();
}

window.addPlayerControls = function(name, speed) {
  GameBridge.playerControls[name] = { speed };
};

function addBackground(mapKey, mapUrl, tilesetUrls, tilesetNames, layerName) {
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

Shiny.addCustomMessageHandler("phaser", function (message) {
  eval(message.js);
});

function addObstacle(name, url, x, y) {
  scene.load.image(name, url);
  scene.load.once('complete', () => {
    const obstacle = scene.physics.add.staticSprite(x, y, name).setName(name);
    if (scene.terrainLayer) {
      scene.physics.add.collider(obstacle, scene.terrainLayer);
    }
    scene[name] = obstacle;
  });
  scene.load.start();
}
window.addObstacle = addObstacle;

function enableObstacleCollision(spriteName, obstacleName) {
  const sprite = scene.children.getByName(spriteName);
  const obstacle = scene.children.getByName(obstacleName);
  if (!sprite || !obstacle) {
    console.warn(`Nie znaleziono obiektu o nazwie '${spriteName}' lub '${obstacleName}'`);
    return;
  }
  scene.physics.add.collider(sprite, obstacle);
}
window.enableObstacleCollision = enableObstacleCollision;

