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

Shiny.addCustomMessageHandler("phaser", function (message) {
  eval(message.js);
});

