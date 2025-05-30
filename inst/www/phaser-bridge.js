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

        if (cursors.left.isDown) {
          sprite.body.setVelocityX(-opts.speed);
          sprite.anims.play(name + '_move', true);
        } else if (cursors.right.isDown) {
          sprite.body.setVelocityX(opts.speed);
          sprite.anims.play(name + '_move', true);
        } else {
          sprite.body.setVelocityX(0);
          sprite.anims.play(name + '_anim', true);
        }
      });
    }
}

function addPlayerMoveAnimation(name, url, frameCount, frameRate) {
  animName = name + '_move';
  scene.load.spritesheet(animName, url, {
    frameWidth: 100,
    frameHeight: 100
  });
  scene.load.once('complete', () => {
    scene.anims.create({
      key: name + '_move',
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

function addPlayerSprite(name, url, x, y, frameCount, frameRate) {
  scene.load.spritesheet(name, url, {
    frameWidth: x,
    frameHeight: y
  });

  scene.load.once('complete', () => {
    scene.anims.create({
      key: name + '_anim',
      frames: scene.anims.generateFrameNumbers(name, {
        start: 0,
        end: frameCount - 1
      }),
      frameRate: frameRate,
      repeat: -1
    });

    const sprite = scene.physics.add.sprite(x, y, name).setName(name);
    sprite.setCollideWorldBounds(true);
    sprite.play(name + '_anim');

    controlledSprite = sprite;
    scene[name] = sprite;
  });

  scene.load.start();
}

window.addPlayerControls = function(name, speed) {
  GameBridge.playerControls[name] = { speed };
};

Shiny.addCustomMessageHandler("phaser", function (message) {
  eval(message.js);
});

