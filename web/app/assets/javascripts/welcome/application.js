// require flipping/dist/flipping.js
//= require rellax/rellax.js


document.addEventListener('DOMContentLoaded', function () {

	const pimbaEl     = document.querySelector('.brand__pimba');
	const brandLogoEl = document.querySelector('.brand__logo');
	const peopleEls   = document.querySelectorAll('.people__person-face');
	const answerEl    = document.querySelector('.answer');
	const featuresEl  = document.querySelectorAll('.feature');

	brandLogoEl.addEventListener('click', () => {


		const promise = new Promise((resolve, reject) => {
			pimbaEl.style.opacity    = '1';
			pimbaEl.style.transition = '';
			pimbaEl.style.color      = '#2192f6';
			pimbaEl.style.transform  = `translate(${Math.random() * -20}px, ${Math.random() * 50}px)`;

			if(pimbaEl.style.transform) {
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


	requestAnimationFrame(function () {
		var index = 0;

		peopleEls.forEach(function (person) {
			if (index > 0) {
				person.style.transform = `translateX(${34 * index}px)`;
				person.style.zIndex    = `${index * -1}`;
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
			document.body.style.paddingRight = '0';
			document.body.style.overflow     = 'auto';
		}, 590);
	});


	document.querySelectorAll('.questions__grid-item').forEach((item) => {
		item.addEventListener('click', (event) => {
			requestAnimationFrame(() => {
				answerEl.style.display = 'flex';
				answerEl.classList.add('is-showin');
				answerEl.style.background = item.dataset.color;

				answerEl.querySelector(`[data-answer=${item.dataset.question}]`).style.display = 'block';

				document.body.style.overflow     = 'hidden';
				document.body.style.paddingRight = '16px';

				setTimeout(() => {
					answerEl.classList.remove('is-showin');
				}, 590);
			})
		})
	});


	document.querySelector('.invite__cta').addEventListener('mouseover', () => {
		requestAnimationFrame(() => {
			document.querySelector('.skatista').style.transform = '';
		});
	});


	featuresEl.forEach((feature) => {
		setTimeout(() => {
			requestAnimationFrame(() => {
				feature.style.transform = '';
				feature.style.opacity   = 1;
			});
		}, 500);
	});

	setTimeout(() => {
		new Rellax('.rellax');
	}, 1000)


});


