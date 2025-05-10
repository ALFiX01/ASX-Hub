const screenshot = document.getElementById('screenshot');

screenshot.addEventListener('mousemove', (e) => {
  const rect = screenshot.getBoundingClientRect();
  const x = e.clientX - rect.left;
  const y = e.clientY - rect.top;
  const centerX = rect.width / 2;
  const centerY = rect.height / 2;

  const rotateX = -(y - centerY) / 20;
  const rotateY = (x - centerX) / 20;

  screenshot.style.transform = `rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale(1.03)`;
});

screenshot.addEventListener('mouseleave', () => {
  screenshot.style.transform = 'rotateX(0) rotateY(0) scale(1)';
});
