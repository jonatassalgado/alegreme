// //= require mobile-detect/mobile-detect.js
// //= require lazysizes/lazysizes.min.js
// //= require packs/serviceworker-companion.js
//
// lazySizes.cfg.expand = 10;
//
// window.addEventListener('beforeinstallprompt', (e) => {
// 	e.preventDefault();
// 	deferredPrompt = e;
// 	const btnAdd   = document.querySelector(".demo__pwaBanner");
//
// 	if (btnAdd) {
// 		btnAdd.addEventListener('click', (e) => {
// 			deferredPrompt.prompt();
//
// 			deferredPrompt.userChoice
// 			              .then((choiceResult) => {
// 				              if (choiceResult.outcome === 'accepted') {
// 					              console.log('User accepted the A2HS prompt');
// 				              } else {
// 					              console.log('User dismissed the A2HS prompt');
// 				              }
// 				              deferredPrompt = null;
// 			              });
// 		});
// 	}
// });
//
// document.addEventListener('lazybeforeunveil', function (e) {
// 	requestAnimationFrame(() => {
// 		var bg = e.target.getAttribute('data-bg');
// 		if (bg) {
// 			e.target.style.backgroundImage = 'url(' + bg + ')';
// 		}
// 	});
// });
//
// document.addEventListener('DOMContentLoaded', function () {
//
// 	WebFont.load({
// 		google: {
// 			families: ['Montserrat:400,500,600,700', 'Roboto:400,500,700']
// 		}
// 	});
//
// 	const md = new MobileDetect(window.navigator.userAgent);
//
// 	const brandLogoEls       = document.querySelectorAll('.js-logo');
// 	const pimbaEls           = document.querySelectorAll('.js-pimba');
// 	const peopleEl           = document.querySelector('.people');
// 	const peopleEls          = document.querySelectorAll('.people__person-face');
// 	const answerEl           = document.querySelector('.answer');
// 	const shareBtn           = document.querySelector('.shareBtn');
// 	const inviteEl           = document.querySelector('.invite');
// 	const inviteCtaGroupEl   = document.querySelector('.invite__cta-group');
// 	const inviteLoginBtnsEl  = document.querySelector('.invite__loginButtons');
// 	const inviteLoginFbEl    = document.querySelector('.invite__loginButtons-facebook');
// 	const inviteLoginGmailEl = document.querySelector('.invite__loginButtons-gmail');
// 	const inviteDetailsEl    = document.querySelector('.invite__details');
// 	const inviteCounterEl    = document.querySelector('.invite__counter');
// 	const inviteStatusEl     = document.querySelector('.invite__status');
// 	const firstPersonFaceEl  = document.querySelector('.people__person-face');
// 	const iosBannerEl        = document.querySelector('.demo__iosBanner');
// 	const pwaBannerEl        = document.querySelector('.demo__pwaBanner');
// 	const inviteFloatEl      = document.querySelector('.invite-float');
// 	const androidEl          = document.querySelector('.android');
// 	const heroEl             = document.querySelector('.hero');
// 	const heroBannerEl       = document.querySelector('.hero__banner');
// 	const inviteEmailEl      = document.querySelector('.invite__email');
// 	const headlineEl         = document.querySelector('.headline');
// 	const headlineH1El       = document.querySelector('.headline h1');
// 	const headlineH2El       = document.querySelector('.headline h2');
//
// 	if (md.is('iOS')) {
// 		// iosBannerEl.style.display = 'block';
// 		// pwaBannerEl.style.display = 'none';
// 	}
//
// 	if (androidEl) {
// 		setTimeout(() => {
// 			requestAnimationFrame(() => {
// 				androidEl.style.transform  = "translateY(0)";
// 				heroBannerEl.style.opacity = 1;
// 			});
// 		}, 1000);
// 	}
//
// 	if (inviteFloatEl) {
// 		window.addEventListener('scroll', () => {
// 			if (window.scrollY > 500) {
// 				requestAnimationFrame(() => {
// 					inviteFloatEl.style.opacity    = 1;
// 					inviteFloatEl.style.transform  = 'translateY(0)';
// 					inviteFloatEl.style.visibility = 'visible';
// 				});
// 			} else {
// 				requestAnimationFrame(() => {
// 					inviteFloatEl.style.opacity    = 1;
// 					inviteFloatEl.style.transform  = 'translateY(150px)';
// 					inviteFloatEl.style.visibility = 'hidden';
// 				});
// 			}
// 		}, {capture: false, passive: true});
// 	}
//
// 	if (!md.mobile()) {
// 		setTimeout(() => {
// 			const scrollOptions = {capture: false, passive: true};
//
// 			const onScroll = target => {
// 				requestAnimationFrame(() => {
// 					document.querySelector('.how-works').style.setProperty('--y', `${window.scrollY}px`)
//
// 				});
// 			};
//
// 			document.querySelectorAll('.how-works__step').forEach((step) => {
// 				step.style.setProperty('--offsettop', `${step.offsetTop}px`);
// 			})
//
// 			window.addEventListener('scroll', onScroll, scrollOptions)
// 		}, 2000);
// 	}
//
// 	setTimeout(() => {
// 		requestAnimationFrame(() => {
// 			if (peopleEl) {
// 				peopleEl.style.opacity = 1;
// 			}
// 		}, 2500);
// 	});
//
// 	const videos = document.querySelectorAll('video');
//
// 	if ('IntersectionObserver' in window) {
// 		const observer = new IntersectionObserver((entries, observer) => {
// 				for (const entry of entries) {
// 					if (entry.isIntersecting) {
// 						requestIdleCallback(() => {
// 							entry.target.play();
// 						}, {timeout: 250});
// 					} else {
// 						requestIdleCallback(() => {
// 							entry.target.pause();
// 						}, {timeout: 250});
// 					}
// 				}
// 			},
// 			{
// 				threshold: [0.50]
// 			}
// 		);
//
// 		videos.forEach((video) => {
// 			observer.observe(video);
// 		});
// 	} else {
// 		videos.forEach((video) => {
// 			video.play();
// 		});
// 	}
//
//
// 	if (navigator.share) {
// 		shareBtn.onclick = () => {
// 			navigator.share({
// 				title: 'Alegreme - Aproveite a cidade de Porto Alegre',
// 				text : 'Atividades culturais, meetups, shows, rolês, feiras de rua, aquele filme no Mario Quintana...\n',
// 				url  : 'https://alegreme.com',
// 			})
// 			         .then(() => console.log('Valeu"'))
// 			         .catch((error) => console.log('Deu erro ai :(', error));
// 		};
// 	} else {
// 		shareBtn.style.display = "none";
// 	}
//
// 	// brandLogoEls.forEach((brandLogoEl) => {
// 	// 	['click', 'touchstart'].forEach((e) => {
// 	// 		brandLogoEl.addEventListener(e, () => {
// 	// 			pimbaEls.forEach((pimbaEl) => {
// 	// 				const promise = new Promise((resolve, reject) => {
// 	// 					pimbaEl.style.opacity    = '1';
// 	// 					pimbaEl.style.transition = '';
// 	// 					pimbaEl.style.color      = '#2192f6';
// 	//
// 	// 					const x                 = Math.random() * -20;
// 	// 					const y                 = Math.random() * 50;
// 	// 					pimbaEl.style.transform =
// 	// 						`translate(${x}px, ${y}px)`
// 	// 					;
// 	//
// 	// 					if (x !== undefined && y !== undefined) {
// 	// 						resolve();
// 	// 					}
// 	// 				});
// 	//
// 	// 				promise.then(() => {
// 	// 					requestAnimationFrame(() => {
// 	// 						pimbaEl.style.transition = 'opacity 0.5s linear, color 0.5s linear';
// 	// 						pimbaEl.style.opacity    = '0';
// 	// 						pimbaEl.style.color      = '#2dc877'
// 	// 					})
// 	// 				});
// 	//
// 	// 			});
// 	//
// 	// 		}, {passive: true});
// 	// 	})
// 	// });
//
//
// 	requestAnimationFrame(function () {
// 		var index = 0;
//
// 		peopleEls.forEach(function (person) {
// 			if (md.mobile()) {
// 				const distance = 15;
// 				if (index > 0) {
// 					person.style.transform =
// 						`translateX(${distance * index}px)`
// 					;
// 					person.style.zIndex    =
// 						`${index * -1}`
// 					;
// 				}
// 			} else {
// 				const distance = 18;
// 				if (index > 0) {
// 					person.style.transform =
// 						`translateX(${distance * index}px)`
// 					;
// 					person.style.zIndex    =
// 						`${index * -1}`
// 					;
// 				}
// 			}
//
// 			index = index + 1;
// 		})
// 	});
//
// 	if (answerEl) {
// 		answerEl.addEventListener('click', () => {
// 			answerEl.classList.add('is-showout');
//
// 			setTimeout(() => {
// 				answerEl.style.display = 'none';
// 				answerEl.classList.remove('is-showout');
// 				answerEl.querySelectorAll('[data-answer]').forEach((answer) => {
// 					answer.style.display = 'none';
//
// 				});
// 				document.body.style.overflow = 'auto';
//
// 				if (md.mobile()) {
// 				} else {
// 					document.body.style.paddingRight = '0';
// 				}
//
// 			}, 590);
// 		});
// 	}
//
//
// 	document.querySelectorAll('.questions__grid-item').forEach((item) => {
// 		item.addEventListener('click', (event) => {
// 			requestAnimationFrame(() => {
// 				answerEl.style.display = 'flex';
// 				answerEl.classList.add('is-showin');
// 				// answerEl.style.background = item.dataset.color;
// 				answerEl.style.background = '#ffffff';
//
// 				answerEl.querySelector(
// 					`[data-answer=${item.dataset.question}]`
// 				).style.display = 'block';
//
// 				document.body.style.overflow = 'hidden';
//
// 				if (md.mobile()) {
//
// 				} else {
// 					document.body.style.paddingRight = '16px';
// 				}
//
// 				setTimeout(() => {
// 					answerEl.classList.remove('is-showin');
// 				}, 590);
// 			})
// 		})
// 	});
//
// 	// var delay = 0;
// 	// featuresEl.forEach((feature) => {
// 	// 	setTimeout(() => {
// 	// 		requestAnimationFrame(() => {
// 	// 			feature.style.transform = '';
// 	// 			feature.style.opacity   = 1;
// 	// 		});
// 	// 	}, delay);
// 	// 	delay = delay + 100;
// 	// });
//
//
// 	const startGoogleAuth = function () {
// 		gapi.load('auth2', function () {
// 			auth2 = gapi.auth2.init({
// 				client_id   : '859257966270-bklt50keg5qsjjda0qv34dnki47olthj.apps.googleusercontent.com',
// 				scope       : 'https://www.googleapis.com/auth/userinfo.email',
// 				cookiepolicy: 'single_host_origin'
// 			});
//
// 			// attachSignin(inviteLoginGmailEl);
// 		});
// 	};
//
// 	function createInvite(userData) {
// 		const frontData = userData;
//
// 		fetch(
// 			`/invite`
// 			, {
// 				method     : 'PATCH',
// 				headers    : {
// 					'Content-type'    : 'application/json; charset=UTF-8',
// 					'Accept'          : 'application/json',
// 					'X-Requested-With': 'XMLHttpRequest',
// 					'X-CSRF-Token'    : document.querySelector('meta[name=csrf-token]').content
// 				},
// 				credentials: 'same-origin',
// 				body       : JSON.stringify(frontData)
// 			}).then(
// 			response => {
// 				response.text().then(data => {
// 					document.documentElement.style.scrollBehavior = "smooth";
// 					window.scrollTo(0, 0);
// 					document.documentElement.style.scrollBehavior = "";
//
// 					const backendData = JSON.parse(data);
// 					const userName    = `${frontData.name.split(" ")[0]}`;
//
// 					inviteCtaGroupEl.style.display  = "none";
// 					inviteLoginBtnsEl.style.display = "none";
//
// 					inviteEl.classList.add('is-invited');
// 					shareBtn.classList.add('is-invited');
//
// 					headlineH1El.innerText = `Somos ${backendData.invitesCount} pessoas aguardando o lançamento!`;
// 					headlineH2El.innerText = 'Vamos lançar em 1º de fevereiro ou quando chegarmos a 5 mil, então compartilha com teus amigos agora para lançarmos antes';
//
// 					if (backendData.invitationCreated) {
//
// 						inviteCounterEl.innerText = `Pronto ${userName}, convite solicitado com sucesso!`;
// 						inviteDetailsEl.innerHTML = `Agora é só aguardar que te enviaremos um email quando chegar a sua vez.`;
//
// 						if (frontData.picture) {
// 							firstPersonFaceEl.style.backgroundImage = `url("${frontData.picture}")`;
// 						}
//
// 					}
//
// 					if (backendData.invitationAlreadyRequested) {
//
// 						inviteCounterEl.innerText               =
// 							`${userName}, você e outras ${backendData.invitesCount} pessoas já estão na fila`
// 						;
// 						inviteDetailsEl.innerHTML               =
// 							`Agora é só aguardar que te enviaremos um email quando chegar a sua vez. <br> Aproveita e avisa a galera`
// 						;
// 						firstPersonFaceEl.style.backgroundImage =
// 							`url("${frontData.picture}")`
// 						;
// 					}
//
// 					// setTimeout(() => {
// 					// 	inviteCtaGroupEl.style.display = "none";
// 					// 	inviteLoginBtnsEl.style.display = "none";
// 					// }, 1000)
// 				});
// 			}
// 		).catch(err => {
// 			console.log('Fetch Error :-S', err);
// 		});
// 	}
//
//
// 	startGoogleAuth();
//
//
// 	window.loginWithEmail = function loginWithEmail() {
// 		const userName  = document.querySelector('.mdc-text-field__input.name');
// 		const userEmail = document.querySelector('.mdc-text-field__input.email');
//
// 		const emailUserData = {
// 			name : userName.value,
// 			email: userEmail.value
// 		};
//
// 		createInvite(emailUserData);
// 	};
//
// 	window.loginWithGmail = function loginWithGmail() {
// 		auth2.signIn().then(function (googleUser) {
// 			var profile          = googleUser.getBasicProfile();
// 			const googleUserData = {
// 				googleId: profile.getId(),
// 				name    : profile.getName(),
// 				email   : profile.getEmail(),
// 				picture : profile.getImageUrl()
// 			};
//
// 			createInvite(googleUserData);
// 		})
// 	};
//
// 	window.loginWithFacebook = function loginWithFacebook() {
// 		FB.login(function (response) {
// 			if (response.status === 'connected') {
// 				FB.api('/me', {fields: 'name, email, picture'}, function (response) {
// 					const fbUserData = {
// 						fbId   : response.id,
// 						name   : response.name,
// 						email  : response.email,
// 						picture: response.picture.data.url
// 					};
//
// 					createInvite(fbUserData);
// 				});
// 			} else {
//
// 			}
// 		}, {scope: 'public_profile,email'});
// 	};
//
// 	window.showLoginButtons = function showLoginButtons() {
// 		window.scrollTo(0, 0);
// 		inviteFloatEl.remove();
//
// 		headlineEl.classList.remove('is-initial-state');
//
// 		headlineH1El.innerText = 'Pegue seu convite';
// 		headlineH2El.innerText = 'Use seu email pessoal, conta do gmail ou facebook';
//
// 		inviteLoginBtnsEl.style.display = 'flex';
// 		inviteCtaGroupEl.style.display  = 'none';
// 		inviteEmailEl.style.display     = 'flex';
// 		heroEl.style.minHeight          = '830px';
//
// 		inviteEl.style.transform = 'translateY(75px)';
// 		setTimeout(() => {
//
// 			requestAnimationFrame(() => {
// 				inviteEl.style.transform        = 'translateY(0)';
// 				inviteCtaGroupEl.style.opacity  = 0;
// 				inviteEmailEl.style.opacity     = 1;
// 				inviteLoginBtnsEl.style.opacity = 1;
// 			});
// 		}, 150)
// 	}
//
// });
