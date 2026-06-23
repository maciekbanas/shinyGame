(function () {
  const palette = [
    0xf26b4e,
    0xf6c951,
    0x5578d5,
    0x79b99d,
    0xf49b67,
    0x8b6fc7,
    0x64a9a0,
    0xe65e7a
  ];

  let wheelGroup = null;
  let currentAngle = 0;
  let spinning = false;
  let segmentCount = palette.length;

  function waitForScene(callback, attempts) {
    if (typeof scene !== "undefined" && scene.add && scene.tweens) {
      callback();
      return;
    }

    if (attempts > 0) {
      window.setTimeout(function () {
        waitForScene(callback, attempts - 1);
      }, 80);
    }
  }

  function drawWheel(labels) {
    const centerX = 260;
    const centerY = 270;
    const radius = 216;
    const segmentAngle = (Math.PI * 2) / labels.length;
    segmentCount = labels.length;

    if (wheelGroup) {
      wheelGroup.destroy(true);
    }

    wheelGroup = scene.add.container(centerX, centerY);

    const shadow = scene.add.graphics();
    shadow.fillStyle(0x1e2430, 0.12);
    shadow.fillCircle(7, 12, radius + 10);
    wheelGroup.add(shadow);

    const wheel = scene.add.graphics();
    labels.forEach(function (label, index) {
      const start = -Math.PI / 2 + index * segmentAngle;
      const end = start + segmentAngle;

      wheel.fillStyle(palette[index % palette.length], 1);
      wheel.beginPath();
      wheel.moveTo(0, 0);
      wheel.arc(0, 0, radius, start, end, false);
      wheel.closePath();
      wheel.fillPath();

      wheel.lineStyle(3, 0xf7f1e7, 0.9);
      wheel.beginPath();
      wheel.moveTo(0, 0);
      wheel.lineTo(Math.cos(start) * radius, Math.sin(start) * radius);
      wheel.strokePath();
    });

    wheel.lineStyle(8, 0x1e2430, 1);
    wheel.strokeCircle(0, 0, radius + 2);
    wheelGroup.add(wheel);

    labels.forEach(function (label, index) {
      const angle = -Math.PI / 2 + (index + 0.5) * segmentAngle;
      const distance = radius * 0.67;
      const text = scene.add.text(
        Math.cos(angle) * distance,
        Math.sin(angle) * distance,
        label,
        {
          fontFamily: "DM Sans, sans-serif",
          fontSize: "15px",
          fontStyle: "bold",
          color: "#ffffff",
          align: "center",
          stroke: "#1e2430",
          strokeThickness: 2
        }
      );

      text.setOrigin(0.5);
      text.setAngle((angle * 180) / Math.PI + 90);
      wheelGroup.add(text);
    });

    const hubOuter = scene.add.circle(0, 0, 48, 0xf7f1e7);
    hubOuter.setStrokeStyle(6, 0x1e2430);
    const hubInner = scene.add.circle(0, 0, 29, 0x1e2430);
    const hubText = scene.add.text(0, 0, "S", {
      fontFamily: "Manrope, sans-serif",
      fontSize: "27px",
      fontStyle: "bold",
      color: "#f7f1e7"
    });
    hubText.setOrigin(0.5);
    wheelGroup.add([hubOuter, hubInner, hubText]);

    const pointer = scene.add.triangle(
      centerX,
      38,
      0,
      0,
      42,
      0,
      21,
      49,
      0x1e2430
    );
    pointer.setOrigin(0.5, 0);
    pointer.setDepth(20);

    scene.add.circle(centerX, 35, 10, 0xf26b4e).setDepth(21);
  }

  function celebrate() {
    const colors = palette.concat([0xffffff]);

    for (let i = 0; i < 48; i += 1) {
      const piece = scene.add.rectangle(
        260 + Phaser.Math.Between(-55, 55),
        240 + Phaser.Math.Between(-30, 30),
        Phaser.Math.Between(5, 10),
        Phaser.Math.Between(10, 18),
        colors[Phaser.Math.Between(0, colors.length - 1)]
      );
      piece.setDepth(30);
      piece.setAngle(Phaser.Math.Between(0, 180));

      scene.tweens.add({
        targets: piece,
        x: piece.x + Phaser.Math.Between(-240, 240),
        y: 560 + Phaser.Math.Between(0, 100),
        angle: piece.angle + Phaser.Math.Between(180, 720),
        alpha: 0,
        duration: Phaser.Math.Between(1000, 1900),
        ease: "Cubic.easeOut",
        onComplete: function () {
          piece.destroy();
        }
      });
    }
  }

  function startSpin(index) {
    if (!wheelGroup || spinning) return;

    spinning = true;
    const segmentDegrees = 360 / segmentCount;
    const targetBase = -(index + 0.5) * segmentDegrees;
    const currentNormalized = ((currentAngle % 360) + 360) % 360;
    const targetNormalized = ((targetBase % 360) + 360) % 360;
    const alignment = (targetNormalized - currentNormalized + 360) % 360;
    const targetAngle = currentAngle + 6 * 360 + alignment;

    document.getElementById("spin").disabled = true;
    document.getElementById("spin_status").textContent = "Finding your reward...";

    scene.tweens.add({
      targets: wheelGroup,
      angle: targetAngle,
      duration: 5200,
      ease: "Cubic.easeOut",
      onUpdate: function () {
        currentAngle = wheelGroup.angle;
      },
      onComplete: function () {
        currentAngle = targetAngle;
        spinning = false;
        celebrate();
        document.getElementById("spin_status").textContent = "Reward unlocked";
        Shiny.setInputValue(
          "wheel_finished",
          { index: index, nonce: Date.now() },
          { priority: "event" }
        );
      }
    });
  }

  function registerHandlers() {
    Shiny.addCustomMessageHandler("spin-wheel-init", function (message) {
      waitForScene(function () {
        drawWheel(message.labels);
      }, 80);
    });

    Shiny.addCustomMessageHandler("spin-wheel-start", function (message) {
      startSpin(message.index);
    });

    Shiny.addCustomMessageHandler("copy-reward-code", function (message) {
      navigator.clipboard.writeText(message.code).then(function () {
        const button = document.getElementById("copy_code");
        if (!button) return;
        button.textContent = "COPIED";
        window.setTimeout(function () {
          button.textContent = "COPY CODE";
        }, 1600);
      });
    });
  }

  if (window.Shiny) {
    registerHandlers();
  } else {
    document.addEventListener("shiny:connected", registerHandlers, { once: true });
  }
})();
