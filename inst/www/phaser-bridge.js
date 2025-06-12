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

      if (this.enemies) {
        this.enemies.getChildren().forEach(enemy => {
          if (enemy.hasMotionStarted) {
            const dx = enemy.x - enemy.originX;
            const dy = enemy.y - enemy.originY;
            const traveled = Math.sqrt(dx*dx + dy*dy);
            console.log(traveled)
            console.log(enemy.motionDistance)
            if (traveled >= enemy.motionDistance) {
              enemy.body.setVelocity(0, 0);
              delete enemy.originX;
              delete enemy.originY;
              delete enemy.motionDirX;
              delete enemy.motionDirY;
              delete enemy.motionSpeed;
              delete enemy.motionDistance;
              delete enemy.hasMotionStarted;
            }
          }
        });
      }
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

function addPlayerControls(name, directions, speed) {
  GameBridge.playerControls[name] = { speed, directions };
};

function addImage(imageName, imageUrl, x = null, y = null) {
  scene.load.image(imageName, imageUrl);

  scene.load.once('complete', () => {
    const px = x !== null
      ? x
      : scene.cameras.main.width  / 2;
    const py = y !== null
      ? y
      : scene.cameras.main.height / 2;

    scene.add.image(px, py, imageName);
  });

  scene.load.start();
}

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

function addSpriteAnimation(name, suffix, url, frameWidth, frameHeight, frameCount, frameRate) {
  if (!scene) {
    console.warn(`addSpriteAnimation("${name}", "${suffix}"): scene not ready`);
    return;
  }
  const animKey = name + "_" + suffix;
  scene.load.spritesheet(animKey, url, {
    frameWidth:  frameWidth,
    frameHeight: frameHeight
  });
  scene.load.once("complete", () => {
    scene.anims.create({
      key: animKey,
      frames: scene.anims.generateFrameNumbers(animKey, {
        start: 0,
        end: frameCount - 1
      }),
      frameRate: frameRate,
      repeat: -1
    });
  });
  scene.load.start();
}

function addStaticSprite(name, url, x, y) {
  scene.load.image(name, url);
  scene.load.once('complete', () => {
    const staticSprite = scene.physics.add.staticSprite(x, y, name).setName(name);
    if (scene.terrainLayer) {
      scene.physics.add.collider(staticSprite, scene.terrainLayer);
    }
    scene[name] = staticSprite;
  });
  scene.load.start();
}

function addCollider(objectOneName, objectTwoName) {
  const objectOne = scene.children.getByName(objectOneName);
  const objectTwo = scene.children.getByName(objectTwoName);
  scene.physics.add.collider(objectOne, objectTwo);
}

function addSprite(name, url, x, y, frameWidth, frameHeight, frameCount, frameRate) {
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

    scene[name] = sprite;
  });

  scene.load.start();
}

function setSpriteInMotion(name, dirX, dirY, speed, distance) {
  if (speed <= 0 || distance <= 0) {
    console.warn("setSpriteInMotion(): speed and distance must be > 0");
    return;
  }
  const all = scene.children.getChildren();
  const matches = all.filter(e => e.name === name);
  if (matches.length === 0) {
    console.warn(`setSpriteInMotion(): no sprites found with name="${name}"`);
    return;
  }

  matches.forEach(sprite => {
    const originX = sprite.x;
    const originY = sprite.y;

    const endX = originX + dirX * distance;
    const endY = originY + dirY * distance;

    const duration = (distance / speed) * 1000;

    scene.tweens.add({
      targets: sprite,
      x: endX,
      y: endY,
      duration: duration,
      ease: 'Linear',
      onStart: () => {
        if (dirX < 0 && scene.anims.exists(name + "_move_left")) {
          sprite.play(name + "_move_left", true);
        } else if (dirX > 0 && scene.anims.exists(name + "_move_right")) {
          sprite.play(name + "_move_right", true);
        } else if (scene.anims.exists(name + "_move")) {
          sprite.play(name + "_move", true);
        } else if (scene.anims.exists(name + "_idle")) {
          sprite.play(name + "_idle", true);
        }
      },
      onComplete: () => {
        playTypeAnim(sprite, name, "idle");
      }
    });
  });
}

Shiny.addCustomMessageHandler("phaser", function (message) {
  eval(message.js);
});
