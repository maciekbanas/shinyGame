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

function addPlayerSprite(name, url, x, y) {
  scene.load.image(name, url);
  scene.load.once('complete', () => {
    const sprite = scene.physics.add.sprite(x, y, name);
    sprite.setCollideWorldBounds(true);
    controlledSprite = sprite;
    scene[name] = sprite;
  });
  scene.load.start();
}

Shiny.addCustomMessageHandler("phaser", function (message) {
  eval(message.js);
});

