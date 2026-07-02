window.GameBridge = window.GameBridge || {};
GameBridge.keyControlHandlers = GameBridge.keyControlHandlers || {};
GameBridge.keyControlActions = GameBridge.keyControlActions || {};
GameBridge.keyControlLastRun = GameBridge.keyControlLastRun || {};
GameBridge.forcedAnimations = GameBridge.forcedAnimations || {};
GameBridge.pendingCameraFollow = GameBridge.pendingCameraFollow || {};
GameBridge.pendingScrollFactor = GameBridge.pendingScrollFactor || {};


function resolveFrameCount(textureKey, frameWidth, frameHeight, frameCount) {
  if (Number.isFinite(frameCount) && frameCount > 0) {
    return Math.floor(frameCount);
  }

  const texture = scene.textures.get(textureKey);
  const sourceImage = texture && texture.source && texture.source[0] && texture.source[0].image;
  if (!sourceImage || frameWidth <= 0 || frameHeight <= 0) {
    return 1;
  }

  const cols = Math.floor(sourceImage.width / frameWidth);
  const rows = Math.floor(sourceImage.height / frameHeight);
  const detected = cols * rows;
  return detected > 0 ? detected : 1;
}

function addSprite(name, url, x, y, frameWidth, frameHeight, frameCount, frameRate) {
  scene.load.spritesheet(name, url, {
    frameWidth: frameWidth,
    frameHeight: frameHeight
  });

  scene.load.once('complete', () => {
    const resolvedFrameCount = resolveFrameCount(name, frameWidth, frameHeight, frameCount);

    scene.anims.create({
      key: name + '_idle',
      frames: scene.anims.generateFrameNumbers(name, {
        start: 0,
        end: resolvedFrameCount - 1
      }),
      frameRate: frameRate,
      repeat: -1
    });

    const sprite = scene.physics.add.sprite(x, y, name).setName(name);
    sprite.setCollideWorldBounds(true);
    sprite.play(name + '_idle');

    scene[name] = sprite;

    if (typeof applyPendingCameraFollows === "function") {
      applyPendingCameraFollows();
    }
    if (typeof applyPendingScrollFactors === "function") {
      applyPendingScrollFactors();
    }
    if (typeof applyPendingTerrainColliders === "function") {
      applyPendingTerrainColliders();
    }
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

    if (typeof applyPendingCameraFollows === "function") {
      applyPendingCameraFollows();
    }
    if (typeof applyPendingScrollFactors === "function") {
      applyPendingScrollFactors();
    }
    if (typeof applyPendingTerrainColliders === "function") {
      applyPendingTerrainColliders();
    }
  });
  scene.load.start();
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
    const resolvedFrameCount = resolveFrameCount(animKey, frameWidth, frameHeight, frameCount);

    scene.anims.create({
      key: animKey,
      frames: scene.anims.generateFrameNumbers(animKey, {
        start: 0,
        end: resolvedFrameCount - 1
      }),
      frameRate: frameRate,
      repeat: -1
    });
  });
  scene.load.start();
}


function getSpriteByName(name, caller) {
  const sprite = scene && scene[name];
  if (!sprite) {
    console.warn(`${caller}: sprite "${name}" not found`);
    return null;
  }
  return sprite;
}

function playAnimation(name, animName) {
  const sprite = getSpriteByName(name, "playAnimation()");
  if (!sprite) return;
  GameBridge.forcedAnimations[name] = { key: animName, until: null };
  sprite.play(animName, true);
}

function playAnimationForDuration(name, animName, duration) {
  const sprite = getSpriteByName(name, "playAnimationForDuration()");
  if (!sprite) return;
  const until = scene && scene.time ? scene.time.now + duration : null;
  GameBridge.forcedAnimations[name] = { key: animName, until };
  sprite.play(animName, true);
  scene.time.delayedCall(duration, () => {
    delete GameBridge.forcedAnimations[name];
    if (scene.anims.exists(name + "_idle")) {
      sprite.play(name + "_idle", true);
    } else {
      sprite.anims.stop();
    }
  });
}

function setGravity(name, x, y) {
  const sprite = scene[name];
  sprite.body.setGravity(x, y);
}

function setVelocityX(name, x) {
  const sprite = scene[name];
  sprite.body.setVelocityX(x);
}

function setVelocityY(name, x) {
  const sprite = scene[name];
  sprite.body.setVelocityY(x);
}

function setBounce(name, x) {
  const sprite = scene[name];
  sprite.setBounce(x);
}

function destroySprite(name) {
  const sprite = getSpriteByName(name, "destroySprite()");
  if (!sprite) return;
  sprite.destroy();
  if (scene && scene[name] === sprite) {
    delete scene[name];
  }
}

function getClientObject(name) {
  return scene && scene.children && scene.children.getByName(name);
}

function objectExists(name) {
  const object = getClientObject(name);
  return Boolean(object && object.active !== false);
}

function objectsOverlap(objectNames) {
  if (!Array.isArray(objectNames) || objectNames.length !== 2) return false;

  const objectOne = getClientObject(objectNames[0]);
  const objectTwo = getClientObject(objectNames[1]);
  if (!objectOne || !objectTwo || !objectOne.getBounds || !objectTwo.getBounds) {
    return false;
  }

  return Phaser.Geom.Intersects.RectangleToRectangle(
    objectOne.getBounds(),
    objectTwo.getBounds()
  );
}

function actionConditionPasses(action) {
  if (action.when_overlap && !objectsOverlap(action.when_overlap)) return false;

  if (action.when_exists) {
    const existsConditions = Array.isArray(action.when_exists)
      ? action.when_exists
      : [action.when_exists];

    const allExist = existsConditions.every((condition) => {
      if (typeof condition === "string") return objectExists(condition);
      if (condition && typeof condition === "object") {
        return objectExists(condition.name) === Boolean(condition.exists);
      }
      return false;
    });

    if (!allExist) return false;
  }

  return true;
}

function normalizeClientActions(clientActions) {
  if (!clientActions || (Array.isArray(clientActions) && clientActions.length === 0)) {
    return [];
  }
  return Array.isArray(clientActions) ? clientActions : [clientActions];
}

function runClientAction(key, action) {
  if (!actionConditionPasses(action)) return false;

  const cooldown = Number(action.cooldown || 0);
  if (cooldown > 0) {
    const cooldownKey = key + "::" + JSON.stringify(action);
    const now = performance.now();
    const lastRun = GameBridge.keyControlLastRun[cooldownKey];
    if (lastRun !== undefined && (now - lastRun) < cooldown) return false;
    GameBridge.keyControlLastRun[cooldownKey] = now;
  }

  if (action.raw_js) {
    const snippets = Array.isArray(action.raw_js) ? action.raw_js : [action.raw_js];
    for (const snippet of snippets) {
      eval(snippet);
    }
  }

  if (action.play_sound) {
    playSound(action.play_sound, action.volume ?? null, action.loop ?? null);
  }

  if (action.play_animation) {
    const spriteName = action.sprite || action.name;
    if (!spriteName) {
      console.warn("client action play_animation requires a sprite/name field");
    } else if (Number.isFinite(action.duration)) {
      playAnimationForDuration(spriteName, action.play_animation, action.duration);
    } else {
      playAnimation(spriteName, action.play_animation);
    }
  }

  if (action.destroy_sprite) {
    destroySprite(action.destroy_sprite);
  }

  if (action.set_text && action.set_text.id !== undefined) {
    setText(action.set_text.text || "", action.set_text.id);
  }

  if (action.show_text) {
    showText(action.show_text);
  }

  if (action.hide_text) {
    hideText(action.hide_text);
  }

  if (action.show_alert) {
    showClientAlert(action.show_alert);
  }

  return true;
}

function showClientAlert(alertOptions) {
  const options = typeof alertOptions === "string"
    ? { title: alertOptions }
    : alertOptions || {};

  if (typeof swal === "function") {
    swal(options);
    return;
  }

  if (typeof sweetAlert === "function") {
    sweetAlert(options);
    return;
  }

  window.alert(options.title || options.text || "");
}

function runClientActions(key) {
  runClientActionList(key, GameBridge.keyControlActions[key]);
}

function runClientActionList(key, actions) {
  for (const action of normalizeClientActions(actions)) {
    const didRun = runClientAction(key, action);
    if (didRun && action.stop_after_match) break;
  }
}

function currentHeroOverlaps() {
  const hero = getClientObject("hero");
  if (!hero || !hero.getBounds || !scene || !scene.children) return [];

  return scene.children.getChildren()
    .filter((object) => object && object.name && object.name !== "hero" && object.getBounds)
    .filter((object) => Phaser.Geom.Intersects.RectangleToRectangle(hero.getBounds(), object.getBounds()))
    .map((object) => object.name);
}

function addKeyControl(key, clientActions = []) {
  GameBridge.keyControlActions[key] = clientActions;

  if (GameBridge.keyControlHandlers[key]) {
    return;
  }

  const handler = function(e) {
    const inputId = key + "_action";
    if (key == e.code) {
      runClientActions(key);
      Shiny.setInputValue(
        inputId,
        { code: e.code, overlaps: currentHeroOverlaps(), evt_nonce: Date.now() + Math.random() },
        { priority: "event" }
      );
    }
  };

  GameBridge.keyControlHandlers[key] = handler;
  document.addEventListener('keydown', handler);
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
        if (!sprite || !sprite.active || !sprite.play) return;
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
        if (!sprite || !sprite.active) return;
        playTypeAnim(sprite, name, "idle");
      }
    });
  });
}
