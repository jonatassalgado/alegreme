//= require mobile-detect/mobile-detect.js
//= require lazysizes/lazysizes.min.js
//= require serviceworker-companion.js

lazySizes.cfg.expand = 10;

window.addEventListener('beforeinstallprompt', (e) => {
	e.preventDefault();
	deferredPrompt = e;
	const btnAdd   = document.querySelector(".demo__pwaBanner");

	if(btnAdd) {
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
	}
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

	window.dataLayer = window.dataLayer || [];

	WebFont.load({
		google: {
			families: ['Montserrat:800,900', 'Roboto:400,500,700']
		}
	});

	const md = new MobileDetect(window.navigator.userAgent);

	const brandLogoEls       = document.querySelectorAll('.js-logo');
	const pimbaEls           = document.querySelectorAll('.js-pimba');
	const peopleEl           = document.querySelector('.people');
	const peopleEls          = document.querySelectorAll('.people__person-face');
	const answerEl           = document.querySelector('.answer');
	const shareBtns          = document.querySelectorAll('.shareBtn');
	const inviteEl           = document.querySelector('.invite');
	const inviteCtaEl        = document.querySelector('.invite__cta');
	const inviteLoginBtnsEl  = document.querySelector('.invite__loginButtons');
	const inviteLoginFbEl    = document.querySelector('.invite__loginButtons-facebook');
	const inviteLoginGmailEl = document.querySelector('.invite__loginButtons-gmail');
	const inviteDetailsEl    = document.querySelector('.invite__details');
	const inviteCounterEl    = document.querySelector('.invite__counter');
	const inviteStatusEl     = document.querySelector('.invite__status');
	const firstPersonFaceEl  = document.querySelector('.people__person-face');
	const iosBannerEl        = document.querySelector('.demo__iosBanner');
	const pwaBannerEl        = document.querySelector('.demo__pwaBanner');

	if (md.is('iOS')) {
		iosBannerEl.style.display = 'block';
		pwaBannerEl.style.display = 'none';
	}

	setTimeout(() => {
		requestAnimationFrame(() => {
			if(peopleEl) {
				peopleEl.style.opacity = 1;
			}
		}, 2500);
	});

	const videos   = document.querySelectorAll('video');

	if ('IntersectionObserver' in window) {
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
	} else {
		videos.forEach((video) => {
			video.play();
		});
	}


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
				const distance = 21;
				if (index > 0) {
					person.style.transform = `translateX(${distance * index}px)`;
					person.style.zIndex    = `${index * -1}`;
				}
			} else {
				const distance = 30;
				if (index > 0) {
					person.style.transform = `translateX(${distance * index}px)`;
					person.style.zIndex    = `${index * -1}`;
				}
			}

			index = index + 1;
		})
	});

	if(answerEl) {
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
	}


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


	const startGoogleAuth = function () {
		gapi.load('auth2', function () {
			auth2 = gapi.auth2.init({
				client_id   : '859257966270-bklt50keg5qsjjda0qv34dnki47olthj.apps.googleusercontent.com',
				scope       : 'https://www.googleapis.com/auth/userinfo.email',
				cookiepolicy: 'single_host_origin'
			});

			// attachSignin(inviteLoginGmailEl);
		});
	};

	function createInvite(userData) {
		const frontData = userData;

		fetch(`/invite`, {
			method     : 'PATCH',
			headers    : {
				'Content-type'    : 'application/json; charset=UTF-8',
				'Accept'          : 'application/json',
				'X-Requested-With': 'XMLHttpRequest',
				'X-CSRF-Token'    : document.querySelector('meta[name=csrf-token]').content
			},
			credentials: 'same-origin',
			body       : JSON.stringify(frontData)
		}).then(
			response => {
				response.text().then(data => {
					const backendData = JSON.parse(data);
					const userName = `${frontData.name.split(" ")[0]}`;

					setTimeout(() => {
						// inviteCtaEl.style.display = "flex";
						inviteLoginBtnsEl.style.display = "flex";
					}, 400)

					if (backendData.invitationCreated) {
						inviteStatusEl.style.transform = 'translate(0px, 50px)';
						inviteEl.classList.add('is-invited');


						inviteCounterEl.innerText               = `Pronto ${userName}, convite solicitado com sucesso!`
						inviteDetailsEl.innerText               = `Agora é só aguardar que te enviaremos um email quando chegar a sua vez. Aproveita e avisa a galera`;
						firstPersonFaceEl.style.backgroundImage = `url("${frontData.picture}")`;

						fbq('track', 'CompleteRegistration');

						window.dataLayer.push({
							'event': 'completeRegistration'
						});
					}

					if (backendData.invitationAlreadyRequested) {
						inviteStatusEl.style.transform = 'translate(0px, 50px)';
						inviteEl.classList.add('is-invited');


						inviteCounterEl.innerText               = `${userName}, você e outras ${backendData.invitesCount} pessoas já estão na fila`;
						inviteDetailsEl.innerText               = `Agora é só aguardar que te enviaremos um email quando chegar a sua vez. Aproveita e avisa a galera`;
						firstPersonFaceEl.style.backgroundImage = `url("${frontData.picture}")`;
					}

					setTimeout(() => {
						inviteCtaEl.style.display = "none";
						inviteLoginBtnsEl.style.display = "none";
					}, 400)
				});
			}
		).catch(err => {
			console.log('Fetch Error :-S', err);
		});
	}


	startGoogleAuth();


	window.loginWithGmail = function loginWithGmail() {
		auth2.signIn().then(function (googleUser) {
			var profile          = googleUser.getBasicProfile();
			const googleUserData = {
				googleId : profile.getId(),
				name     : profile.getName(),
				email    : profile.getEmail(),
				picture  : profile.getImageUrl()
			};

			createInvite(googleUserData);
		})
	}

	window.loginWithFacebook = function loginWithFacebook() {
		FB.login(function(response) {
		  if (response.status === 'connected') {
				FB.api('/me', {fields: 'name, email, picture'}, function(response) {
					const fbUserData = {
						fbId   : response.id,
						name   : response.name,
						email  : response.email,
						picture: response.picture.data.url
					};

					createInvite(fbUserData);
		    });
		  } else {

		  }
		}, {scope: 'public_profile,email'});
	}

	window.showLoginButtons = function showLoginButtons() {
		inviteLoginBtnsEl.style.display = "flex";
		inviteCtaEl.style.display = "none";
		inviteCtaEl.style.opacity = 0;

		setTimeout(() => {
			inviteLoginBtnsEl.style.opacity = 1;
		}, 150)
	}

});
