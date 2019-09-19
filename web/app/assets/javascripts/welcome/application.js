// require flipping/dist/flipping.js
// require rails-ujs
// require rellax/rellax.js
//= require mobile-detect/mobile-detect.js
//= require lazysizes/lazysizes.min.js
//= require serviceworker-companion.js
// require query-string/index.js

lazySizes.cfg.expand = 10;

window.addEventListener('beforeinstallprompt', (e) => {
	e.preventDefault();
	deferredPrompt = e;
	const btnAdd   = document.querySelector(".footer__logo-icon");
	btnAdd.addEventListener('click', (e) => {
		deferredPrompt.prompt();

		deferredPrompt.userChoice
		              .then((choiceResult) => {
			              if (choiceResult.outcome === 'accepted') {
				              console.log('User accepted the A2HS prompt');
			              } else {
				              console.log('User dismissed the A2HS prompt');
			              }
			              deferredPrompt = null;
		              });
	});
});

document.addEventListener('lazybeforeunveil', function (e) {
	requestAnimationFrame(() => {
		var bg = e.target.getAttribute('data-bg');
		if (bg) {
			e.target.style.backgroundImage = 'url(' + bg + ')';
		}
	});
});

document.addEventListener('DOMContentLoaded', function () {

	WebFont.load({
		google: {
			families: ['Montserrat:800,900', 'Roboto:400,500,700']
		}
	});

	const md = new MobileDetect(window.navigator.userAgent);

	const brandLogoEls      = document.querySelectorAll('.js-logo');
	const pimbaEls          = document.querySelectorAll('.js-pimba');
	const peopleEls         = document.querySelectorAll('.people__person-face');
	const answerEl          = document.querySelector('.answer');
	const shareBtns         = document.querySelectorAll('.shareBtn');
	const inviteEl          = document.querySelector('.invite');
	const inviteCtaEl       = document.querySelector('.invite__cta');
	const inviteDetailsEl   = document.querySelector('.invite__details');
	const inviteCounterEl   = document.querySelector('.invite__counter');
	const inviteStatusEl    = document.querySelector('.invite__status');
	const firstPersonFaceEl = document.querySelector('.people__person-face');

	const videos   = document.querySelectorAll('video');
	const observer = new IntersectionObserver((entries, observer) => {
			for (const entry of entries) {
				if (entry.isIntersecting) {
					requestIdleCallback(() => {
						entry.target.play();
					}, {timeout: 250});
				} else {
					requestIdleCallback(() => {
						entry.target.pause();
					}, {timeout: 250});
				}
			}
		},
		{
			threshold: [0.50]
		}
	);

	videos.forEach((video) => {
		observer.observe(video);
	});

	if (navigator.share) {
		shareBtns.forEach((shareBtn) => {
			shareBtn.onclick = () => {
				navigator.share({
					title: 'Alegreme - Aproveite a cidade de Porto Alegre',
					text : 'Atividades culturais, meetups, shows, rolês, feiras de rua, aquele filme no Mario Quintana...\n',
					url  : 'https://alegreme.com',
				})
				         .then(() => console.log('Valeu"'))
				         .catch((error) => console.log('Deu erro ai :(', error));
			};
		});
	} else {
		shareBtns.forEach((shareBtn) => {

			shareBtn.style.display = "none";
		});
	}

	brandLogoEls.forEach((brandLogoEl) => {
		['click', 'touchstart'].forEach((e) => {
			brandLogoEl.addEventListener(e, () => {
				pimbaEls.forEach((pimbaEl) => {
					const promise = new Promise((resolve, reject) => {
						pimbaEl.style.opacity    = '1';
						pimbaEl.style.transition = '';
						pimbaEl.style.color      = '#2192f6';

						const x                 = Math.random() * -20;
						const y                 = Math.random() * 50;
						pimbaEl.style.transform = `translate(${x}px, ${y}px)`;

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

			}, {passive: true});
		})
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
				// answerEl.style.background = item.dataset.color;
				answerEl.style.background = '#ffffff';

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
		inviteCtaEl.addEventListener('mouseover', () => {
			requestAnimationFrame(() => {
				document.querySelector('.skatista').style.transform = '';
			});
		});
	}


	// var delay = 0;
	// featuresEl.forEach((feature) => {
	// 	setTimeout(() => {
	// 		requestAnimationFrame(() => {
	// 			feature.style.transform = '';
	// 			feature.style.opacity   = 1;
	// 		});
	// 	}, delay);
	// 	delay = delay + 100;
	// });


	var startGoogleAuth = function () {
		gapi.load('auth2', function () {
			auth2 = gapi.auth2.init({
				client_id   : '859257966270-bklt50keg5qsjjda0qv34dnki47olthj.apps.googleusercontent.com',
				scope       : 'https://www.googleapis.com/auth/userinfo.email',
				cookiepolicy: 'single_host_origin'
			});

			attachSignin(inviteCtaEl);
		});
	};

	function attachSignin(element) {
		console.log('inside attachSignin');
		auth2.attachClickHandler(element, {},
			function (googleUser) {
				var profile          = googleUser.getBasicProfile();
				const googleUserData = {
					name   : profile.getName(),
					email  : profile.getEmail(),
					picture: profile.getImageUrl()
				};

				// const params = stringify(googleUserData, {
				// 	arrayFormat: 'bracket'
				// });

				fetch(`/invite?name=${googleUserData.name}&email=${googleUserData.email}&picture=${googleUserData.picture}`, {
					method     : 'GET',
					headers    : {
						'X-Requested-With': 'XMLHttpRequest',
						'Content-type'    : 'text/javascript; charset=UTF-8',
						'X-CSRF-Token'    : document.querySelector('meta[name=csrf-token]').content
					},
					credentials: 'same-origin'
				}).then(
					response => {
						response.text().then(data => {
							const backendData = JSON.parse(data);

							const userName = `${googleUserData.name.split(" ")[0]}`;

							if (backendData.invitationCreated) {
								inviteStatusEl.style.transform = 'translate(0px, 150px)';
								inviteEl.classList.add('is-invited');


								inviteCounterEl.innerText               = `Pronto ${userName}, convite solicitado com sucesso!`
								inviteDetailsEl.innerText               = `Agora é só aguardar que te enviaremos um email quando chegar a sua vez. Aproveita e avisa a galera`;
								firstPersonFaceEl.style.backgroundImage = `url("${googleUserData.picture}")`;

  							fbq('track', 'CompleteRegistration');
							}

							if (backendData.invitationAlreadyRequested) {
								inviteStatusEl.style.transform = 'translate(0px, 150px)';
								inviteEl.classList.add('is-invited');


								inviteCounterEl.innerText               = `${userName}, você e outras ${backendData.invitesCount} pessoas já estão na fila`;
								inviteDetailsEl.innerText               = `Agora é só aguardar que te enviaremos um email quando chegar a sua vez. Aproveita e avisa a galera`;
								firstPersonFaceEl.style.backgroundImage = `url("${googleUserData.picture}")`;
							}
						});
					}
				).catch(err => {
					console.log('Fetch Error :-S', err);
				});
			});
	}


	startGoogleAuth();


	function socialInit(access_token, flag) {
		// var socialLoginData = JSON.stringify({ token: access_token, social_type: flag });
		// var socialLoginUrl = $scope.baseUrl + '/users/login/social'
		// $http.post(socialLoginUrl, socialLoginData).success(function(response) {
		// })
	}


});
