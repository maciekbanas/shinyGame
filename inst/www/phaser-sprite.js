window.GameBridge = window.GameBridge || {};
GameBridge.keyControlHandlers = GameBridge.keyControlHandlers || {};
GameBridge.forcedAnimations = GameBridge.forcedAnimations || {};
GameBridge.pendingCameraFollow = GameBridge.pendingCameraFollow || {};
GameBridge.pendingScrollFactor = GameBridge.pendingScrollFactor || {};
GameBridge.pendingSpriteActions = GameBridge.pendingSpriteActions || {};
GameBridge.browserState = GameBridge.browserState || {};
GameBridge.cooldowns = GameBridge.cooldowns || {};



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

function setSpriteDepth(name, depth) {
  withSprite(name, (sprite) => sprite.setDepth(depth), "setSpriteDepth()");
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
    if (typeof applyRealmObjectVisibility === "function") {
      applyRealmObjectVisibility(name);
    }

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
    applyPendingSpriteActions(name);
    if (typeof applyRealmObjectVisibility === "function") {
      applyRealmObjectVisibility(name);
    }

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
  const now = scene && scene.time ? scene.time.now : 0;
  sprite.play(recentDirectionalAnimation(sprite, animName, now), true);
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
  const now = scene && scene.time ? scene.time.now : 0;
  sprite.play(recentDirectionalAnimation(sprite, animName, now), true);
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

function stopSpriteMotion(name) {
  const sprite = getSpriteByName(name, "stopSpriteMotion()");
  if (!sprite) return;
  scene.tweens.killTweensOf(sprite);
  if (sprite.body && typeof sprite.body.stop === "function") sprite.body.stop();
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

function normalizeBrowserActions(actions) {
  if (!actions || (Array.isArray(actions) && actions.length === 0)) return [];
  return Array.isArray(actions) ? actions : [actions];
}

function setBrowserState(key, value) { GameBridge.browserState[key] = value; }
function resolveBrowserValue(value) {
  return value && typeof value === "object" && value.state !== undefined
    ? GameBridge.browserState[value.state]
    : value;
}
function browserObject(name) { return scene && scene.children.getByName(name); }
function browserCondition(condition) {
  if (!condition) return true;
  if (condition.op === "&&") return browserCondition(condition.left) && browserCondition(condition.right);
  if (condition.op === "||") return browserCondition(condition.left) || browserCondition(condition.right);
  if (condition.op === "!") return !browserCondition(condition.value);
  if (condition.op === "exists") return Boolean(browserObject(condition.object)?.active);
  if (condition.op === "overlaps") {
    const a = browserObject(condition.objects[0]);
    const b = browserObject(condition.objects[1]);
    return Boolean(a && b && Phaser.Geom.Intersects.RectangleToRectangle(a.getBounds(), b.getBounds()));
  }
  if (condition.op === "is_true") return Boolean(GameBridge.browserState[condition.state]);
  if (condition.op === "is_false") return !GameBridge.browserState[condition.state];
  if (condition.op === "cooldown_ready") {
    return performance.now() - (GameBridge.cooldowns[condition.key] ?? -Infinity) >= condition.duration;
  }
  const left = resolveBrowserValue(condition.left);
  const right = resolveBrowserValue(condition.right);
  if (condition.op === "==") return left === right;
  if (condition.op === "!=") return left !== right;
  if (condition.op === "<") return left < right;
  if (condition.op === "<=") return left <= right;
  if (condition.op === ">") return left > right;
  if (condition.op === ">=") return left >= right;
  return false;
}

function runBrowserAction(action, overlapObjectOne, overlapObjectTwo) {
  if (action.after) {
    window.setTimeout(() => runBrowserActionList(
      action.after.actions, overlapObjectOne, overlapObjectTwo
    ), Number(resolveBrowserValue(action.after.delay)));
    return;
  }
  if (action.if) {
    runBrowserActionList(
      browserCondition(action.if.condition) ? action.if.then : action.if.else,
      overlapObjectOne, overlapObjectTwo
    );
    return;
  }
  if (action.state_action) {
    const state = action.state_action;
    const current = GameBridge.browserState[state.key];
    const value = resolveBrowserValue(state.value);
    if (state.op === "set") GameBridge.browserState[state.key] = value;
    else if (state.op === "increment" || state.op === "add") GameBridge.browserState[state.key] = Number(current || 0) + Number(value);
    else GameBridge.browserState[state.key] = Number(current || 0) - Number(value);
  }
  if (action.cooldown_trigger) GameBridge.cooldowns[action.cooldown_trigger] = performance.now();
  if (action.play_sound) playSound(action.play_sound, action.volume ?? null, action.loop ?? null);
  if (action.pause_sound) pauseSound(action.pause_sound);
  if (action.resume_sound) resumeSound(action.resume_sound);
  if (action.stop_sound) stopSound(action.stop_sound);

  if (action.play_animation) {
    const spriteName = action.sprite || action.name;
    if (Number.isFinite(action.duration)) {
      playAnimationForDuration(spriteName, action.play_animation, action.duration);
    } else {
      playAnimation(spriteName, action.play_animation);
    }
  }

  if (action.stop_motion) stopSpriteMotion(action.stop_motion);

  if (action.destroy_sprite) destroySprite(action.destroy_sprite);
  if (action.set_in_motion) {
    const motion = action.set_in_motion;
    setSpriteInMotion(motion.name, motion.dir_x, motion.dir_y, motion.speed, motion.distance);
  }
  if (action.set_velocity_x) setVelocityX(action.set_velocity_x.name, action.set_velocity_x.value);
  if (action.set_velocity_y) setVelocityY(action.set_velocity_y.name, action.set_velocity_y.value);
  if (action.player_controls) {
    addPlayerControls(action.player_controls.name, action.player_controls.directions, action.player_controls.speed);
  }
  if (action.disable_overlap_member && overlapObjectTwo) {
    disableBody(action.disable_overlap_member, overlapObjectTwo.x, overlapObjectTwo.y);
  }
  if (action.set_text && action.set_text.id !== undefined) {
    setText(String(resolveBrowserValue(action.set_text.text) ?? ""), action.set_text.id);
  }
  if (action.show_text) showText(action.show_text);
  if (action.hide_text) hideText(action.hide_text);
  if (action.show_alert) {
    if (typeof swal === "function") swal(action.show_alert);
    else window.alert(action.show_alert.title || action.show_alert.text || "");
  }
  if (action.emit) {
    Shiny.setInputValue("phaser_" + action.emit.name, action.emit.data || {}, { priority: "event" });
  }
}

function runBrowserActionList(actions, overlapObjectOne, overlapObjectTwo) {
  normalizeBrowserActions(actions).forEach((action) => {
    runBrowserAction(action, overlapObjectOne, overlapObjectTwo);
  });
}

function addKeyControl(key, browserActions = [], notifyServer = false) {
  if (GameBridge.keyControlHandlers[key]) return;

  const handler = function(e) {
    if (key === e.code) {
      runBrowserActionList(browserActions);
      if (notifyServer) {
        Shiny.setInputValue(key + "_action", { code: e.code, evt_nonce: Date.now() + Math.random() }, { priority: "event" });
      }
    }
  };

  GameBridge.keyControlHandlers[key] = handler;
  document.addEventListener("keydown", handler);
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
    scene.tweens.killTweensOf(sprite);

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
        const now = scene && scene.time ? scene.time.now : 0;
        const movementDirection = Math.abs(dirX) >= Math.abs(dirY)
          ? (dirX < 0 ? "left" : "right")
          : (dirY < 0 ? "up" : "down");
        rememberMovementDirection(sprite, movementDirection, now);
        const directionalAnim = name + "_move_" + movementDirection;

        if (directionalAnim && scene.anims.exists(directionalAnim)) {
          sprite.play(directionalAnim, true);
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

function setSpriteInMotionRandomOrToward(
  name,
  targetName,
  sightRange,
  dirX,
  dirY,
  speed,
  distance,
  approachSpeedMultiplier = 1,
  approachDistanceMultiplier = 1
) {
  const sprite = scene.children.getByName(name);
  const target = scene.children.getByName(targetName);
  if (!sprite || !target) {
    setSpriteInMotion(name, dirX, dirY, speed, distance);
    return;
  }

  const targetDistance = Phaser.Math.Distance.Between(sprite.x, sprite.y, target.x, target.y);
  if (targetDistance > 0 && targetDistance <= sightRange) {
    setSpriteInMotion(
      name,
      (target.x - sprite.x) / targetDistance,
      (target.y - sprite.y) / targetDistance,
      speed * approachSpeedMultiplier,
      Math.min(distance * approachDistanceMultiplier, targetDistance)
    );
    return;
  }

  setSpriteInMotion(name, dirX, dirY, speed, distance);
}

function startSpriteApproachOnSight(
  name,
  targetName,
  sightRange,
  speed,
  distance,
  checkInterval = 250,
  alertDuration = 1200,
  wanderInterval = 1500
) {
  if (!GameBridge.sightApproachIntervals) GameBridge.sightApproachIntervals = {};
  if (GameBridge.sightApproachIntervals[name]) {
    clearInterval(GameBridge.sightApproachIntervals[name]);
  }

  GameBridge.sightApproachIntervals[name] = setInterval(() => {
    const sprite = scene.children.getByName(name);
    const target = scene.children.getByName(targetName);
    if (!sprite || !sprite.active || !target || !target.active) return;

    const targetDistance = Phaser.Math.Distance.Between(sprite.x, sprite.y, target.x, target.y);
    if (targetDistance <= 0 || targetDistance > sightRange) {
      if (sprite.getData && sprite.getData("sightAlert")) {
        sprite.setData("sightAlert", null);
      }
      const lastWander = sprite.getData("lastWander") || 0;
      if (performance.now() - lastWander >= wanderInterval) {
        sprite.setData("lastWander", performance.now());
        const direction = Phaser.Math.RND.pick([[1, 0], [-1, 0], [0, 1], [0, -1]]);
        setSpriteInMotion(name, direction[0], direction[1], speed, distance);
      }
      return;
    }

    if (!sprite.getData("sightAlert")) {
      sprite.setData("sightAlert", true);
      scene.tweens.killTweensOf(sprite);
      if (sprite.body && typeof sprite.body.stop === "function") sprite.body.stop();

      const alertText = scene.add.text(sprite.x, sprite.y - sprite.displayHeight * 0.6, "!", {
        fontSize: "28px",
        color: "#ffeb3b",
        stroke: "#000000",
        strokeThickness: 4
      }).setOrigin(0.5).setDepth(10000);
      scene.tweens.add({
        targets: alertText,
        alpha: 0,
        duration: alertDuration,
        ease: "Cubic.easeOut",
        onUpdate: () => {
          if (!sprite || !sprite.active) return;
          alertText.setPosition(sprite.x, sprite.y - sprite.displayHeight * 0.6);
        },
        onComplete: () => alertText.destroy()
      });
    }

    if (GameBridge.forcedAnimations[name]) return;
    if (scene.tweens.isTweening(sprite)) return;

    setSpriteInMotion(
      name,
      (target.x - sprite.x) / targetDistance,
      (target.y - sprite.y) / targetDistance,
      speed,
      Math.min(distance, targetDistance)
    );
  }, checkInterval);
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
