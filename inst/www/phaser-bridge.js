let game, scene, cursors;
let controlledSprite = null;

function initPhaserGame(containerId, config) {
  game = new Phaser.Game({
    type: Phaser.AUTO,
    width: config.width,
    height: config.height,
    parent: containerId,
    physics: {
      default: 'arcade',
      arcade: { gravity: { y: 0 }, debug: false }
    },
    scene: {
      preload: function () { scene = this; },
      create: function () {
        cursors = this.input.keyboard.createCursorKeys();
      },
      update: function () {
        if (!controlledSprite || !cursors) return;

        controlledSprite.setVelocity(0);
        if (cursors.left.isDown) controlledSprite.setVelocityX(-200);
        else if (cursors.right.isDown) controlledSprite.setVelocityX(200);

        if (cursors.up.isDown) controlledSprite.setVelocityY(-200);
        else if (cursors.down.isDown) controlledSprite.setVelocityY(200);
      }
    }
  });
}

function addPlayerSprite(name, url, x, y, frameCount = 2) {
  scene.load.spritesheet(name, url, {
    frameWidth: 100,
    frameHeight: 100
  });

  scene.load.once('complete', () => {
    scene.anims.create({
      key: name + '_anim',
      frames: scene.anims.generateFrameNumbers(name, {
        start: 0,
        end: frameCount - 1
      }),
      frameRate: 4,
      repeat: -1
    });

    const sprite = scene.physics.add.sprite(x, y, name);
    sprite.setCollideWorldBounds(true);
    sprite.play(name + '_anim');

    controlledSprite = sprite;
    scene[name] = sprite;
  });

  scene.load.start();
}


Shiny.addCustomMessageHandler("phaser", function (message) {
  eval(message.js);
});

