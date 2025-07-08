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
