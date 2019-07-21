// require flipping/dist/flipping.js
//= require rails-ujs
//= require rellax/rellax.js
//= require mobile-detect/mobile-detect.js
// require query-string/index.js

document.addEventListener('DOMContentLoaded', function () {

	const md = new MobileDetect(window.navigator.userAgent);

	const brandLogoEls          = document.querySelectorAll('.js-logo');
	const pimbaEls              = document.querySelectorAll('.js-pimba');
	const peopleEls             = document.querySelectorAll('.people__person-face');
	const answerEl              = document.querySelector('.answer');
	const featuresEl            = document.querySelectorAll('.feature');
	const inviteEl              = document.querySelector('.invite');
	const inviteCtaEl           = document.querySelector('.invite__cta');
	const inviteGoogleDetailsEl = document.querySelector('.invite__google-details');
	const inviteDetailsEl       = document.querySelector('.invite__details');
	const inviteCounterEl       = document.querySelector('.invite__counter');
	const inviteStatusEl        = document.querySelector('.invite__status');
	const firstPersonFaceEl     = document.querySelector('.people__person-face');


	brandLogoEls.forEach((brandLogoEl) => {
		['click', 'touchstart'].forEach((e) => {
			brandLogoEl.addEventListener(e, () => {
				pimbaEls.forEach((pimbaEl) => {
					const promise = new Promise((resolve, reject) => {
						pimbaEl.style.opacity    = '1';
						pimbaEl.style.transition = '';
						pimbaEl.style.color      = '#2192f6';

						const x = Math.random() * -20;
						const y = Math.random() * 50;
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


	var delay = 500;
	featuresEl.forEach((feature) => {
		setTimeout(() => {
			requestAnimationFrame(() => {
				feature.style.transform = '';
				feature.style.opacity   = 1;
			});
		}, delay);
		delay = delay + 100;
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
	}, 1000);

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
						'X-CSRF-Token'    : Rails.csrfToken()
					},
					credentials: 'same-origin'
				}).then(
					response => {
						response.text().then(data => {
							const backendData = JSON.parse(data);

							const userName = `${googleUserData.name.split(" ")[0]} ${googleUserData.name.split(" ")[1]}`;

							if (backendData.invitationCreated) {
								inviteStatusEl.style.transform = 'translate(0px, 150px)';
								inviteEl.classList.add('is-invited');


								inviteCounterEl.innerText          = `${backendData.invitesCount} pessoas e ${userName} solicitaram convite para o Alegreme!`
								inviteDetailsEl.innerText          = `Agora é só aguardar que te enviaremos um email quando chegar a sua vez. Aproveita e avisa a galera`;
								firstPersonFaceEl.style.background = `url("${googleUserData.picture}") no-repeat center center`;
							}

							if (backendData.invitationAlreadyRequested) {
								inviteStatusEl.style.transform = 'translate(0px, 150px)';
								inviteEl.classList.add('is-invited');


								inviteCounterEl.innerText          = `${userName}? Você e outras ${backendData.invitesCount} pessoas já estão na fila`;
								inviteDetailsEl.innerText          = `Agora é só aguardar que te enviaremos um email quando chegar a sua vez`;
								firstPersonFaceEl.style.background = `url("${googleUserData.picture}") no-repeat center center`;
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


