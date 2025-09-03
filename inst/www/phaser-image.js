function addImage(imageName, imageUrl, x = null, y = null, visible = true, clickable = true) {
  scene.load.image(imageName, imageUrl);

  scene.load.once('complete', () => {
    const px = x !== null
      ? x
      : scene.cameras.main.width  / 2;
    const py = y !== null
      ? y
      : scene.cameras.main.height / 2;

    scene[imageName] = scene.add.image(px, py, imageName);
    if (clickable) {
      scene[imageName].setInteractive();
    }
    scene[imageName].setVisible(visible);
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
  scene[imageName].on('pointerdown', () => {
    console.log(imageName + ' clicked!');
    Shiny.setInputValue(
      imageName + '_click',
      true
    )
  });
}
