// require flipping/dist/flipping.js
//= require rellax/rellax.js
//= require mobile-detect/mobile-detect.js


document.addEventListener('DOMContentLoaded', function () {

	const md = new MobileDetect(window.navigator.userAgent);

	const brandLogoEls = document.querySelectorAll('.js-logo');
	const pimbaEls     = document.querySelectorAll('.js-pimba');
	const peopleEls    = document.querySelectorAll('.people__person-face');
	const answerEl     = document.querySelector('.answer');
	const featuresEl   = document.querySelectorAll('.feature');

	brandLogoEls.forEach((brandLogoEl) => {
		brandLogoEl.addEventListener('click', () => {
			pimbaEls.forEach((pimbaEl) => {
				const promise = new Promise((resolve, reject) => {
					const x                  = Math.random() * -20;
					const y                  = Math.random() * 50;

					pimbaEl.style.opacity    = '1';
					pimbaEl.style.transition = '';
					pimbaEl.style.color      = '#2192f6';
					pimbaEl.style.transform  = `translate(${x}px, ${y}px)`;

					if (x !== undefined && y !== undefined) {
						resolve();
					}
				});

				promise.then(() => {
					requestAnimationFrame(() => {
						pimbaEl.style.transition = 'opacity 0.5s linear, color 0.5s linear';
						pimbaEl.style.opacity    = '0';
						pimbaEl.style.color      = '#2dc877'
					})
				});

			});

		});
	});


	requestAnimationFrame(function () {
		var index = 0;

		peopleEls.forEach(function (person) {
			if (md.mobile()) {
				const distance = 20;
				if (index > 0) {
					person.style.transform = `translateX(${distance * index}px)`;
					person.style.zIndex    = `${index * -1}`;
				}
			} else {
				const distance = 34;
				if (index > 0) {
					person.style.transform = `translateX(${distance * index}px)`;
					person.style.zIndex    = `${index * -1}`;
				}
			}

			index = index + 1;
		})
	});

	answerEl.addEventListener('click', () => {
		answerEl.classList.add('is-showout');


		setTimeout(() => {
			answerEl.style.display = 'none';
			answerEl.classList.remove('is-showout');
			answerEl.querySelectorAll('[data-answer]').forEach((answer) => {
				answer.style.display = 'none';

			});
			document.body.style.overflow = 'auto';

			if (md.mobile()) {
			} else {
				document.body.style.paddingRight = '0';
			}

		}, 590);
	});


	document.querySelectorAll('.questions__grid-item').forEach((item) => {
		item.addEventListener('click', (event) => {
			requestAnimationFrame(() => {
				answerEl.style.display = 'flex';
				answerEl.classList.add('is-showin');
				answerEl.style.background = item.dataset.color;

				answerEl.querySelector(`[data-answer=${item.dataset.question}]`).style.display = 'block';

				document.body.style.overflow = 'hidden';

				if (md.mobile()) {

				} else {
					document.body.style.paddingRight = '16px';
				}

				setTimeout(() => {
					answerEl.classList.remove('is-showin');
				}, 590);
			})
		})
	});

	if (md.mobile()) {

	} else {
		document.querySelector('.invite__cta').addEventListener('mouseover', () => {
			requestAnimationFrame(() => {
				document.querySelector('.skatista').style.transform = '';
			});
		});
	}


	featuresEl.forEach((feature) => {
		setTimeout(() => {
			requestAnimationFrame(() => {
				feature.style.transform = '';
				feature.style.opacity   = 1;
			});
		}, 500);
	});

	setTimeout(() => {
		if (md.mobile()) {
			// new Rellax('.rellax', {
			// 	horizontal: true,
			// 	vertical: false
			// });
		} else {
			new Rellax('.rellax');
		}
	}, 1000)


});


