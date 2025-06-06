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

/**
 * General helper to load & create one spritesheet‐based animation.
 *
 * @param {string} name        Base key for the sprite (e.g. "hero" or "basic_enemy").
 * @param {string} suffix      Animation suffix (e.g. "move_left", "move_right", "move").
 * @param {string} url         URL (relative to www/) for the spritesheet image.
 * @param {number} frameWidth  Width of each frame in px.
 * @param {number} frameHeight Height of each frame in px.
 * @param {number} frameCount  Number of frames in that spritesheet.
 * @param {number} frameRate   FPS at which to play (e.g. 8, 10, etc).
 */
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

function enableObstacleCollision(spriteName, obstacleName) {
  const sprite = scene.children.getByName(spriteName);
  const obstacle = scene.children.getByName(obstacleName);
  if (!sprite || !obstacle) {
    console.warn(`Nie znaleziono obiektu o nazwie '${spriteName}' lub '${obstacleName}'`);
    return;
  }
  scene.physics.add.collider(sprite, obstacle);
}

function initEnemiesGroup() {
  if (!scene) {
    console.warn("initEnemiesGroup(): scene is not ready yet");
    return;
  }
  scene.enemies = scene.physics.add.group({
    runChildUpdate: true
  });
}

function addEnemySprite(name, url, frameWidth, frameHeight, frameCount, frameRate) {
  if (!scene) {
    console.warn("addEnemySprite(): scene is not ready");
    return;
  }
  scene.load.spritesheet(name, url, {
    frameWidth: frameWidth,
    frameHeight: frameHeight
  });

  scene.load.once("complete", () => {
    scene.anims.create({
      key: name + "_idle",
      frames: scene.anims.generateFrameNumbers(name, {
        start: 0,
        end: frameCount - 1
      }),
      frameRate: frameRate,
      repeat: -1
    });
  });

  scene.load.start();
}

function spawnEnemyCustom(x, y, type) {
  if (!scene || !scene.enemies) {
    console.warn("spawnEnemyCustom(): call initEnemiesGroup() first.");
    return;
  }
  const enemy = scene.physics.add.sprite(x, y, type).setName(type);

  playTypeAnim(enemy, type, "idle");
  scene.enemies.add(enemy);
}

// ─────────────────────────────────────────────────────────────────────────────
// setEnemyTweenByType(type, dirX, dirY, speed, distance)
//   For every sprite in scene.enemies whose .name === type:
//     1) Compute originX = enemy.x, originY = enemy.y
//     2) Compute endX = originX + dirX * distance
//               endY = originY + dirY * distance
//     3) Compute duration = (distance / speed) * 1000   (ms)
//     4) Kick off a Phaser tween that moves (x,y) → (endX,endY) over `duration`
//        using a linear ease.
//   If speed=0 or distance=0, this does nothing.
function setEnemyTweenByType(type, dirX, dirY, speed, distance) {
  if (!scene || !scene.enemies) {
    console.warn("setEnemyTweenByType(): call initEnemiesGroup() first");
    return;
  }
  if (speed <= 0 || distance <= 0) {
    console.warn("setEnemyTweenByType(): speed and distance must be > 0");
    return;
  }
  const all = scene.enemies.getChildren();
  const matches = all.filter(e => e.name === type);
  if (matches.length === 0) {
    console.warn(`setEnemyTweenByType(): no enemies found with name="${type}"`);
    return;
  }

  matches.forEach(enemy => {
    const originX = enemy.x;
    const originY = enemy.y;

    const endX = originX + dirX * distance;
    const endY = originY + dirY * distance;

    const duration = (distance / speed) * 1000;

    scene.tweens.add({
      targets: enemy,
      x: endX,
      y: endY,
      duration: duration,
      ease: 'Linear',
      onStart: () => {
        if (dirX < 0 && scene.anims.exists(type + "_move_left")) {
          enemy.play(type + "_move_left", true);
        } else if (dirX > 0 && scene.anims.exists(type + "_move_right")) {
          enemy.play(type + "_move_right", true);
        } else if (scene.anims.exists(type + "_move")) {
          enemy.play(type + "_move", true);
        } else if (scene.anims.exists(type + "_idle")) {
          enemy.play(type + "_idle", true);
        }
      },
      onComplete: () => {
        playTypeAnim(enemy, type, "idle");
      }
    });
  });
}

Shiny.addCustomMessageHandler("phaser", function (message) {
  eval(message.js);
});
