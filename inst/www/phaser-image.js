function addImage(imageName, imageUrl, x = null, y = null, visible = true, clickable = true) {
  scene.load.image(imageName, imageUrl);

  scene.load.once('complete', () => {
    const px = x !== null
      ? x
      : scene.cameras.main.width  / 2;
    const py = y !== null
      ? y
      : scene.cameras.main.height / 2;

    scene[imageName] = scene.add.image(px, py, imageName).setName(imageName);
    if (clickable) {
      scene[imageName].setInteractive();
    }
    applyPendingSpriteActions(imageName);
    scene[imageName].setVisible(visible);

    if (typeof applyPendingCameraFollows === "function") {
      applyPendingCameraFollows();
    }
    if (typeof applyPendingScrollFactors === "function") {
      applyPendingScrollFactors();
    }
  });

  scene.load.start();
}

function showImage(imageName) {
  scene[imageName].setVisible(true)
}

function hideImage(imageName) {
  scene[imageName].setVisible(false)
}

function clickImage(imageName) {
  withSprite(imageName, (image) => {
    if (image.shinyClickBound) return;

    if (!image.input) image.setInteractive();
    image.on('pointerdown', () => {
      console.log(imageName + ' clicked!');
      Shiny.setInputValue(
        imageName + '_click',
        true,
        { priority: 'event' }
      );
    });
    image.shinyClickBound = true;
  }, "clickImage()");
}
