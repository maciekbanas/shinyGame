window.GameBridge = window.GameBridge || {};
GameBridge.pendingGroupMembers = GameBridge.pendingGroupMembers || {};

function addGroup(name) {
  if (!scene[name]) {
    scene[name] = scene.physics.add.group();
  }
}

function addGroupAnimation(groupName, suffix, url, w, h, totalFrames, rate) {
  scene.load.spritesheet(groupName, url, {
    frameWidth: w, frameHeight: h, endFrame: totalFrames - 1
  });

  scene.load.once(`filecomplete-spritesheet-${groupName}`, () => {
    scene.anims.create({
      key: `${groupName}_${suffix}`,
      frames: scene.anims.generateFrameNumbers(groupName, { start: 0, end: totalFrames - 1 }),
      frameRate: rate,
      repeat: -1
    });
  });
  if (!scene.load.isLoading()) scene.load.start();
}

function addToGroup(groupName, x, y) {
  if (!scene.textures.exists(groupName)) {
    GameBridge.pendingGroupMembers[groupName] = GameBridge.pendingGroupMembers[groupName] || [];
    GameBridge.pendingGroupMembers[groupName].push({ x, y });
    return;
  }
  const sprite = scene[groupName].create(x, y, groupName);
  playTypeAnim(sprite, groupName, "idle");
}

function addStaticGroup(name, url) {
  if (!scene[name]) {
    scene[name] = scene.physics.add.staticGroup();
  }
  scene.load.image(name, url);
  scene.load.once(`filecomplete-image-${name}`, () => {
    const pending = GameBridge.pendingGroupMembers[name] || [];
    pending.forEach(({ x, y }) => addToGroup(name, x, y));
    delete GameBridge.pendingGroupMembers[name];
  });
  if (!scene.load.isLoading()) scene.load.start();
}

function disableBody(groupName, x, y) {
  const group = scene[groupName];
  const children = group.getChildren();
  const target = children.find(child =>
    Math.abs(child.x - x) < 1 && Math.abs(child.y - y) < 1
  );
  if (target) {
    target.disableBody(true, true);
  } else {
    console.warn(`No object found in '${groupName}' at (${x},${y})`);
  }
}
