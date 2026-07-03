window.GameBridge = window.GameBridge || {};
GameBridge.keyControlHandlers = GameBridge.keyControlHandlers || {};
GameBridge.keyControlActions = GameBridge.keyControlActions || {};
GameBridge.keyControlLastRun = GameBridge.keyControlLastRun || {};
GameBridge.forcedAnimations = GameBridge.forcedAnimations || {};
GameBridge.pendingCameraFollow = GameBridge.pendingCameraFollow || {};
GameBridge.pendingScrollFactor = GameBridge.pendingScrollFactor || {};
GameBridge.pendingSpriteActions = GameBridge.pendingSpriteActions || {};
GameBridge.clientState = GameBridge.clientState || {};



function applyPendingSpriteActions(name) {
  const sprite = scene && scene[name];
  const actions = GameBridge.pendingSpriteActions[name];
  if (!sprite || !actions) return;

  actions.forEach((action) => action(sprite));
  delete GameBridge.pendingSpriteActions[name];
}

function withSprite(name, action, caller) {
  const sprite = scene && scene[name];
  if (sprite) {
    action(sprite);
    return;
  }

  GameBridge.pendingSpriteActions[name] = GameBridge.pendingSpriteActions[name] || [];
  GameBridge.pendingSpriteActions[name].push(action);
  if (caller) {
    console.debug(`${caller}: queued until sprite "${name}" is ready`);
  }
}

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
    applyPendingSpriteActions(name);

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
  if (typeof sprite.play !== "function") {
    console.warn(`playAnimation(): sprite "${name}" cannot play animations`);
    return;
  }
  GameBridge.forcedAnimations[name] = { key: animName, until: null };
  sprite.play(animName, true);
}

function playAnimationForDuration(name, animName, duration) {
  const sprite = getSpriteByName(name, "playAnimationForDuration()");
  if (!sprite) return;
  if (typeof sprite.play !== "function") {
    console.warn(`playAnimationForDuration(): sprite "${name}" cannot play animations`);
    return;
  }
  const until = scene && scene.time ? scene.time.now + duration : null;
  GameBridge.forcedAnimations[name] = { key: animName, until };
  sprite.play(animName, true);
  scene.time.delayedCall(duration, () => {
    delete GameBridge.forcedAnimations[name];
    if (!sprite || !sprite.active || !sprite.play || !sprite.anims) return;
    if (scene.anims.exists(name + "_idle")) {
      sprite.play(name + "_idle", true);
    } else {
      sprite.anims.stop();
    }
  });
}

function setGravity(name, x, y) {
  withSprite(name, (sprite) => {
    if (sprite.body) sprite.body.setGravity(x, y);
  }, "setGravity()");
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

function disableSprite(name) {
  const sprite = getSpriteByName(name, "disableSprite()");
  if (!sprite) return;

  sprite.setVisible(false);
  sprite.setActive(false);
  if (sprite.body) {
    sprite.body.enable = false;
    if (typeof sprite.body.stop === "function") {
      sprite.body.stop();
    }
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


function normalizeStateKey(key) {
  return String(key || "");
}

function ensureClientState() {
  window.GameBridge = window.GameBridge || {};
  GameBridge.clientState = GameBridge.clientState || {};
  return GameBridge.clientState;
}

function getClientState(key) {
  return ensureClientState()[normalizeStateKey(key)];
}

function setClientState(key, value) {
  ensureClientState()[normalizeStateKey(key)] = value;
  return value;
}

function clampNumber(value, min, max) {
  let nextValue = Number(value);
  if (!Number.isFinite(nextValue)) nextValue = 0;
  if (Number.isFinite(Number(min))) nextValue = Math.max(Number(min), nextValue);
  if (Number.isFinite(Number(max))) nextValue = Math.min(Number(max), nextValue);
  return nextValue;
}

function applyStateAction(stateAction) {
  if (!stateAction || stateAction.key === undefined) return;

  const key = normalizeStateKey(stateAction.key);
  const op = stateAction.op || "set";
  const currentValue = Number(getClientState(key) ?? 0);
  const amount = Number(stateAction.amount ?? stateAction.value ?? 0);
  let nextValue;

  if (op === "initialize" || op === "init") {
    if (getClientState(key) !== undefined) return;
    nextValue = amount;
  } else if (op === "increment" || op === "add") {
    nextValue = currentValue + amount;
  } else if (op === "decrement" || op === "subtract") {
    nextValue = currentValue - amount;
  } else {
    nextValue = amount;
  }

  setClientState(key, clampNumber(nextValue, stateAction.min, stateAction.max));
}

function interpolateClientStateText(text) {
  return String(text || "").replace(/\{state\.([^}]+)\}/g, (_match, key) => {
    const value = getClientState(key);
    return value === undefined ? "" : String(value);
  });
}

function stateConditionPasses(condition) {
  if (!condition || condition.key === undefined) return true;

  const actual = Number(getClientState(condition.key) ?? 0);
  const value = Number(condition.value ?? 0);
  const op = condition.op || "eq";

  if (op === "lte") return actual <= value;
  if (op === "lt") return actual < value;
  if (op === "gte") return actual >= value;
  if (op === "gt") return actual > value;
  if (op === "neq") return actual !== value;
  return actual === value;
}

function actionConditionPasses(action) {
  if (action.when_overlap && !objectsOverlap(action.when_overlap)) return false;

  if (action.when_state && !stateConditionPasses(action.when_state)) return false;

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
  if (!objectOne || !objectTwo || !objectOne.getBounds || !objectTwo.getBounds) return false;
  return Phaser.Geom.Intersects.RectangleToRectangle(objectOne.getBounds(), objectTwo.getBounds());
}

function ensureClientState() {
  window.GameBridge = window.GameBridge || {};
  GameBridge.clientState = GameBridge.clientState || {};
  return GameBridge.clientState;
}

function getClientState(key) {
  return ensureClientState()[String(key || "")];
}

function setClientState(key, value) {
  ensureClientState()[String(key || "")] = value;
  return value;
}

function clampNumber(value, min, max) {
  let nextValue = Number(value);
  if (!Number.isFinite(nextValue)) nextValue = 0;
  if (Number.isFinite(Number(min))) nextValue = Math.max(Number(min), nextValue);
  if (Number.isFinite(Number(max))) nextValue = Math.min(Number(max), nextValue);
  return nextValue;
}

function applyStateAction(stateAction) {
  if (!stateAction || stateAction.key === undefined) return;
  const key = String(stateAction.key || "");
  const op = stateAction.op || "set";
  const currentValue = Number(getClientState(key) ?? 0);
  const amount = Number(stateAction.amount ?? stateAction.value ?? 0);
  let nextValue;
  if (op === "initialize" || op === "init") {
    if (getClientState(key) !== undefined) return;
    nextValue = amount;
  } else if (op === "increment" || op === "add") {
    nextValue = currentValue + amount;
  } else if (op === "decrement" || op === "subtract") {
    nextValue = currentValue - amount;
  } else {
    nextValue = amount;
  }
  setClientState(key, clampNumber(nextValue, stateAction.min, stateAction.max));
}

function interpolateClientStateText(text) {
  return String(text || "").replace(/\{state\.([^}]+)\}/g, (_match, key) => {
    const value = getClientState(key);
    return value === undefined ? "" : String(value);
  });
}

function stateConditionPasses(condition) {
  if (!condition || condition.key === undefined) return true;
  const actual = Number(getClientState(condition.key) ?? 0);
  const value = Number(condition.value ?? 0);
  const op = condition.op || "eq";
  if (op === "lte") return actual <= value;
  if (op === "lt") return actual < value;
  if (op === "gte") return actual >= value;
  if (op === "gt") return actual > value;
  if (op === "neq") return actual !== value;
  return actual === value;
}

function actionConditionPasses(action) {
  if (action.when_overlap && !objectsOverlap(action.when_overlap)) return false;
  if (action.when_state && !stateConditionPasses(action.when_state)) return false;
  if (action.when_exists) {
    const existsConditions = Array.isArray(action.when_exists) ? action.when_exists : [action.when_exists];
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
  if (!clientActions || (Array.isArray(clientActions) && clientActions.length === 0)) return [];
  return Array.isArray(clientActions) ? clientActions : [clientActions];
}

function showClientAlert(alertOptions) {
  const options = typeof alertOptions === "string" ? { title: alertOptions } : alertOptions || {};
  if (typeof swal === "function") { swal(options); return; }
  if (typeof sweetAlert === "function") { sweetAlert(options); return; }
  window.alert(options.title || options.text || "");
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

  if (action.set_state) {
    const stateActions = Array.isArray(action.set_state) ? action.set_state : [action.set_state];
    stateActions.forEach(applyStateAction);
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

  if (action.disable_sprite) {
    disableSprite(action.disable_sprite);
  }

  if (action.set_text && action.set_text.id !== undefined) {
    setText(interpolateClientStateText(action.set_text.text || ""), action.set_text.id);
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

  if (action.hide_when_state) {
    const checks = Array.isArray(action.hide_when_state) ? action.hide_when_state : [action.hide_when_state];
    checks.forEach((check) => {
      if (stateConditionPasses(check)) hideText(check.id || check.name);
    });
  }

  if (action.show_when_state) {
    const checks = Array.isArray(action.show_when_state) ? action.show_when_state : [action.show_when_state];
    checks.forEach((check) => {
      if (stateConditionPasses(check)) showText(check.id || check.name);
    });
  }

  if (action.destroy_when_state) {
    const checks = Array.isArray(action.destroy_when_state) ? action.destroy_when_state : [action.destroy_when_state];
    checks.forEach((check) => {
      if (stateConditionPasses(check)) destroySprite(check.name || check.id);
    });
  }

  if (action.disable_when_state) {
    const checks = Array.isArray(action.disable_when_state) ? action.disable_when_state : [action.disable_when_state];
    checks.forEach((check) => {
      if (stateConditionPasses(check)) disableSprite(check.name || check.id);
    });
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

function runClientActions(key) {
  runClientActionList(key, GameBridge.keyControlActions[key]);
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
        { code: e.code, evt_nonce: Date.now() + Math.random() },
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

    const endPoint = constrainedTerrainMotionEnd(sprite, dirX, dirY, distance);
    const endX = endPoint.x;
    const endY = endPoint.y;
    const adjustedDistance = Phaser.Math.Distance.Between(originX, originY, endX, endY);

    if (adjustedDistance <= 0) {
      if (sprite.body && typeof sprite.body.stop === "function") sprite.body.stop();
      return;
    }

    const duration = (adjustedDistance / speed) * 1000;

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

function constrainedTerrainMotionEnd(sprite, dirX, dirY, distance) {
  const originX = sprite.x;
  const originY = sprite.y;

  if (!scene || !scene.terrainLayer || (!dirX && !dirY)) {
    return {
      x: originX + dirX * distance,
      y: originY + dirY * distance
    };
  }

  const steps = Math.max(1, Math.ceil(distance / 4));
  let lastSafeX = originX;
  let lastSafeY = originY;

  for (let step = 1; step <= steps; step++) {
    const nextDistance = Math.min(distance, step * 4);
    const nextX = originX + dirX * nextDistance;
    const nextY = originY + dirY * nextDistance;

    if (spriteWouldTouchCollidingTerrain(sprite, nextX, nextY)) {
      break;
    }

    lastSafeX = nextX;
    lastSafeY = nextY;
  }

  return { x: lastSafeX, y: lastSafeY };
}

function spriteWouldTouchCollidingTerrain(sprite, x, y) {
  if (!scene || !scene.terrainLayer) return false;

  const bounds = sprite.getBounds();
  const offsetX = x - sprite.x;
  const offsetY = y - sprite.y;
  const left = bounds.left + offsetX;
  const right = bounds.right + offsetX;
  const top = bounds.top + offsetY;
  const bottom = bounds.bottom + offsetY;
  const centerX = (left + right) / 2;
  const centerY = (top + bottom) / 2;

  return [
    [left, top],
    [right, top],
    [left, bottom],
    [right, bottom],
    [centerX, centerY]
  ].some(([pointX, pointY]) => terrainCollidesAtWorldXY(pointX, pointY));
}

function terrainCollidesAtWorldXY(x, y) {
  const tile = scene.terrainLayer.getTileAtWorldXY(x, y, true);
  return Boolean(tile && (tile.collides || (tile.properties && tile.properties.collides)));
}
