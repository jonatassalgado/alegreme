document.addEventListener('DOMContentLoaded', () => {
	const featuresEl = document.querySelectorAll('.feature');

	var delay = 0;
	featuresEl.forEach((feature) => {
		setTimeout(() => {
			requestAnimationFrame(() => {
				feature.style.transform = '';
				feature.style.opacity   = 1;
			});
		}, delay);
		delay = delay + 85;
	});
});
