import {Controller}        from "stimulus";
import {UILandingBot}      from "../modules/bot-module";
import * as MobileDetect   from "mobile-detect";
import {ProgressBarModule} from "../modules/progressbar-module";


export default class SwipableController extends Controller {
	static targets = ["swipable", "onboarding", "items"];

	initialize() {
		this.md    = new MobileDetect(window.navigator.userAgent);
		this.uilb  = new UILandingBot(this.onboardingTarget);

		this.uilb
		    .message({
			    content: `Olá ${gon.user.features.demographic.name.split(" ")[0]} 👋`,
			    delay  : 150
		    })
		    .then(ok =>
			    this.uilb.message({
				    cssClass: "no-icon",
				    content :
					    "Vamos aproveitar a cidade de Porto Alegre juntos!",
				    delay   : 2000
			    })
		    )
		    .then(ok =>
			    this.uilb.message({
				    cssClass: "no-icon",
				    content :
					    "Inicialmente vamos te sugerir eventos, mas logo também iremos sugerir filmes no cinema, serviços e experiências",
				    delay   : 1500
			    }))
		    .then(ok =>
			    this.uilb.message({
				    cssClass: "no-icon",
				    content :
					    "Chega de papo, vamos começar!",
				    delay   : 4000
			    })
		    )
		    .then(ok =>
			    this.uilb.message({
				    cssClass: "no-icon",
				    content :
					    "Para sugerir eventos que tem a ver com você, primeiro me diga o que você gosta e não gosta",
				    delay   : 1000
			    })
		    )
		    .then(ok =>
			    this.uilb.message({
				    cssClass: "no-icon",
				    content : "Vamos lá?",
				    delay   : 4000
			    })
		    )
		    .then(ok =>
			    this.uilb.action({
				    type : "button",
				    delay: 500,
				    items: [
					    {
						    text : "Vamos!",
						    value: "Vamos!"
					    }
				    ]
			    })
		    )
		    .then(ok =>
			    this.uilb.message({
				    delay  : 250,
				    human  : true,
				    content: ok
			    })
		    )
		    .then(ok => {
			    this.uilb.message({
				    content: "Carregando opções...",
				    delay  : 1500
			    })
		    })
		    .then(ok => {
			    setTimeout(() => {
				    this.onboardingTarget.style.display = 'none';
				    this.itemsTarget.style.display      = '';

				    requestAnimationFrame(() => {
					    setTimeout(() => {
						    this.itemsTarget.style.opacity = '';
						    window.scrollTo(0, 0);
								if (this.hasSwipableTarget) {
									requestIdleCallback(() => {
										this.stackedCards();
										this.swipableTarget.style.minHeight = `${this.swipableTarget.offsetHeight}px`;
									}, {timeout: 250});
								}
					    }, 300);
				    });
			    }, 4000);
		    })
		    .catch(error => console.log('error', error));
	}

	disconnect() {

	}


	stackedCards() {
		const HOST                    = gon.env == "development" ? `http://localhost:5000` : `https://${document.location.host}/ml`;
		const stackedOptions          = 'Top'; //Change stacked cards view from 'Bottom', 'Top' or 'None'.
		const rotate                  = true; //Activate the elements' rotation for each move on stacked cards.
		let items                     = 3; //Number of visible elements when the stacked options are bottom or top.
		const elementsMargin          = 12; //Define the distance of each element when the stacked options are bottom or top.
		const useOverlays             = true; //Enable or disable the overlays for swipe elements.
		let maxElements; //Total of stacked cards on DOM.
		let currentPosition           = 0; //Keep the position of active stacked card.
		let counter                   = 0;
		const velocity                = 0.25; //Minimum velocity allowed to trigger a swipe.
		const pixelsToMoveCardOnSwipe = this.md.mobile() ? 600 : 800;
		let answers                   = [];
		let isFirstTime               = true;
		let topObj; //Keep the swipe top properties.
		let rightObj; //Keep the swipe right properties.
		let leftObj; //Keep the swipe left properties.
		let listElNodesObj; //Keep the list of nodes from stacked cards.
		let listElNodesWidth; //Keep the stacked cards width.
		let currentElementObj; //Keep the stacked card element to swipe.
		let stackedCardsObj;
		let elementHeight;
		let obj;
		let elTrans;
		let rotateElement;
		let addMargin;

		obj             = document.getElementById('stacked-cards-block');
		stackedCardsObj = obj.querySelector('.stackedcards-container');
		listElNodesObj  = stackedCardsObj.children;

		topObj   = obj.querySelector('.stackedcards-overlay.top');
		rightObj = obj.querySelector('.stackedcards-overlay.right');
		leftObj  = obj.querySelector('.stackedcards-overlay.left');

		countElements();
		currentElement();
		listElNodesWidth  = stackedCardsObj.offsetWidth;
		currentElementObj = listElNodesObj[0];
		updateUi();

		//Prepare elements on DOM
		addMargin = elementsMargin * (items - 1) + 'px';

		if (stackedOptions === "Top") {

			for (let i = items; i < maxElements; i++) {
				listElNodesObj[i].classList.add('stackedcards-top', 'stackedcards--animatable', 'stackedcards-origin-top');
			}

			elTrans = elementsMargin * (items - 1);

			stackedCardsObj.style.marginBottom = addMargin;

		} else if (stackedOptions === "Bottom") {


			for (let i = items; i < maxElements; i++) {
				listElNodesObj[i].classList.add('stackedcards-bottom', 'stackedcards--animatable', 'stackedcards-origin-bottom');
			}

			elTrans = 0;

			stackedCardsObj.style.marginBottom = addMargin;

		} else if (stackedOptions === "None") {

			for (let i = items; i < maxElements; i++) {
				listElNodesObj[i].classList.add('stackedcards-none', 'stackedcards--animatable');
			}

			elTrans = 0;

		}

		for (let i = items; i < maxElements; i++) {
			listElNodesObj[i].style.zIndex          = 0;
			listElNodesObj[i].style.opacity         = 0;
			listElNodesObj[i].style.webkitTransform = 'scale(' + (1 - (items * 0.04)) + ') translateX(0) translateY(' + elTrans + 'px) translateZ(0)';
			listElNodesObj[i].style.transform       = 'scale(' + (1 - (items * 0.04)) + ') translateX(0) translateY(' + elTrans + 'px) translateZ(0)';
		}

		if (listElNodesObj[currentPosition]) {
			listElNodesObj[currentPosition].classList.add('stackedcards-active');
		}

		if (useOverlays) {
			leftObj.style.transform       = 'translateX(0px) translateY(' + elTrans + 'px) translateZ(0px) rotate(0deg)';
			leftObj.style.webkitTransform = 'translateX(0px) translateY(' + elTrans + 'px) translateZ(0px) rotate(0deg)';

			rightObj.style.transform       = 'translateX(0px) translateY(' + elTrans + 'px) translateZ(0px) rotate(0deg)';
			rightObj.style.webkitTransform = 'translateX(0px) translateY(' + elTrans + 'px) translateZ(0px) rotate(0deg)';

			topObj.style.transform       = 'translateX(0px) translateY(' + elTrans + 'px) translateZ(0px) rotate(0deg)';
			topObj.style.webkitTransform = 'translateX(0px) translateY(' + elTrans + 'px) translateZ(0px) rotate(0deg)';

		} else {
			leftObj.className  = '';
			rightObj.className = '';
			topObj.className   = '';

			leftObj.classList.add('stackedcards-overlay-hidden');
			rightObj.classList.add('stackedcards-overlay-hidden');
			topObj.classList.add('stackedcards-overlay-hidden');
		}

		//Remove class init
		setTimeout(function () {
			obj.classList.remove('init');
		}, 500);


		function backToMiddle() {

			removeNoTransition();
			transformUi(0, 0, 1, currentElementObj);

			if (useOverlays) {
				transformUi(0, 0, 0, leftObj);
				transformUi(0, 0, 0, rightObj);
				transformUi(0, 0, 0, topObj);
			}

			setZindex(5);

			if (!(currentPosition >= maxElements)) {
				//roll back the opacity of second element
				if ((currentPosition + 1) < maxElements) {
					listElNodesObj[currentPosition + 1].style.opacity = '.8';
				}
			}
		}

		// Usable functions
		function countElements() {
			maxElements = listElNodesObj.length;
			if (items > maxElements) {
				items = maxElements;
			}
		}

		//Keep the active card.
		function currentElement() {
			currentElementObj = listElNodesObj[currentPosition];
		}

		function changeStages() {
			if (counter === maxElements) {
				//Event listener created to know when transition ends and changes states

				fetch(`${HOST}/user/persona?query=${JSON.stringify(answers)}`, {
					method : 'GET',
					headers: {
						'Content-type': 'text/javascript; charset=UTF-8'
					}
				})
					.then(response => {
							response.json().then(data => {

								const params = {
									'user': {
										'personas_primary_name'          : data.classification.personas.primary.name,
										'personas_secondary_name'        : data.classification.personas.secondary.name,
										'personas_tertiary_name'         : data.classification.personas.tertiary.name,
										'personas_quartenary_name'       : data.classification.personas.quartenary.name,
										'personas_primary_score'         : data.classification.personas.primary.score,
										'personas_secondary_score'       : data.classification.personas.secondary.score,
										'personas_tertiary_score'        : data.classification.personas.tertiary.score,
										'personas_quartenary_score'      : data.classification.personas.quartenary.score,
										'personas_assortment_finished'   : true,
										'personas_assortment_finished_at': new Date().toJSON()

									}
								};

								fetch(`${location.origin}/users/${gon.user.id}`, {
									method     : 'PATCH',
									headers    : {
										'Content-type'    : 'application/json; charset=UTF-8',
										'Accept'          : 'application/json',
										'X-Requested-With': 'XMLHttpRequest',
										'X-CSRF-Token'    : document.querySelector('meta[name=csrf-token]').content
									},
									credentials: 'same-origin',
									body       : JSON.stringify(params)
								})
									.then(
										response => {
											response.text().then(data => {
												document.querySelector('.stackedcards').classList.add('hidden');
												document.querySelector('.global-actions').classList.add('hidden');
												document.querySelector('.me-swipable__question').classList.add('hidden');
												document.querySelector('.final-state').classList.remove('hidden');
												document.querySelector('.final-state').classList.add('active');
												ProgressBarModule.show();
												setTimeout(() => {
													ProgressBarModule.hide();
													Turbolinks.visit("/feed");
												}, 3500)
											});
										}
									)
									.catch(err => {
										console.log('Fetch Error :-S', err);
									});
							});
						}
					)
					.catch(err => {
						console.log('Fetch Error :-S', err);
					});
			}
		}

//Functions to swipe left elements on logic external action.
		function onActionLeft() {
			if (!(counter >= maxElements)) {
				if (useOverlays) {
					leftObj.classList.remove('no-transition');
					topObj.classList.remove('no-transition');
					leftObj.style.zIndex = '8';
					transformUi(0, 0, 1, leftObj);

				}

				setTimeout(function () {
					onSwipeLeft();
					resetOverlayLeft();
				}, 300);
			}
		}

//Functions to swipe right elements on logic external action.
		function onActionRight() {
			if (!(counter >= maxElements)) {
				if (useOverlays) {
					rightObj.classList.remove('no-transition');
					topObj.classList.remove('no-transition');
					rightObj.style.zIndex = '8';
					transformUi(0, 0, 1, rightObj);
				}

				setTimeout(function () {
					onSwipeRight();
					resetOverlayRight();
				}, 300);
			}
		}

//Functions to swipe top elements on logic external action.
		function onActionTop() {
			if (!(counter >= maxElements)) {
				if (useOverlays) {
					leftObj.classList.remove('no-transition');
					rightObj.classList.remove('no-transition');
					topObj.classList.remove('no-transition');
					topObj.style.zIndex = '8';
					transformUi(0, 0, 1, topObj);
				}

				setTimeout(function () {
					onSwipeTop();
					resetOverlays();
				}, 300); //wait animations end
			}
		}

//Swipe active card to left.
		function onSwipeLeft() {
			answers.push('-1');

			removeNoTransition();
			transformUi(-pixelsToMoveCardOnSwipe, 0, 0, currentElementObj);
			if (useOverlays) {
				transformUi(-pixelsToMoveCardOnSwipe, 0, 0, leftObj); //Move leftOverlay
				transformUi(-pixelsToMoveCardOnSwipe, 0, 0, topObj); //Move topOverlay
				resetOverlayLeft();
			}
			counter = counter + 1;
			removeElement();
			updateUi();
			currentElement();
			changeStages();
		}

//Swipe active card to right.
		function onSwipeRight() {
			answers.push('1');

			removeNoTransition();
			transformUi(pixelsToMoveCardOnSwipe, 0, 0, currentElementObj);
			if (useOverlays) {
				transformUi(pixelsToMoveCardOnSwipe, 0, 0, rightObj); //Move rightOverlay
				transformUi(pixelsToMoveCardOnSwipe, 0, 0, topObj); //Move topOverlay
				resetOverlayRight();
			}
			counter = counter + 1;
			removeElement();
			updateUi();
			currentElement();
			changeStages();
		}

//Swipe active card to top.
		function onSwipeTop() {
			answers.push('0');

			removeNoTransition();
			transformUi(0, -pixelsToMoveCardOnSwipe, 0, currentElementObj);
			if (useOverlays) {
				transformUi(0, -pixelsToMoveCardOnSwipe, 0, leftObj); //Move leftOverlay
				transformUi(0, -pixelsToMoveCardOnSwipe, 0, rightObj); //Move rightOverlay
				transformUi(0, -pixelsToMoveCardOnSwipe, 0, topObj); //Move topOverlay
				resetOverlays();
			}
			counter = counter + 1;
			removeElement();
			updateUi();
			currentElement();
			changeStages();
		}

//Remove transitions from all elements to be moved in each swipe movement to improve perfomance of stacked cards.
		function removeNoTransition() {
			if (listElNodesObj[currentPosition]) {

				if (useOverlays) {
					leftObj.classList.remove('no-transition');
					rightObj.classList.remove('no-transition');
					topObj.classList.remove('no-transition');
				}

				listElNodesObj[currentPosition].classList.remove('no-transition');
				listElNodesObj[currentPosition].style.zIndex = 6;
			}

		}

//Move the overlay left to initial position.
		function resetOverlayLeft() {
			if (!(currentPosition >= maxElements)) {
				if (useOverlays) {
					setTimeout(function () {

						if (stackedOptions === "Top") {

							elTrans = elementsMargin * (items - 1);

						} else if (stackedOptions === "Bottom" || stackedOptions === "None") {

							elTrans = 0;

						}

						if (!isFirstTime) {

							leftObj.classList.add('no-transition');
							topObj.classList.add('no-transition');

						}

						requestAnimationFrame(function () {

							leftObj.style.transform       = "translateX(0) translateY(" + elTrans + "px) translateZ(0)";
							leftObj.style.webkitTransform = "translateX(0) translateY(" + elTrans + "px) translateZ(0)";
							leftObj.style.opacity         = '0';

							topObj.style.transform       = "translateX(0) translateY(" + elTrans + "px) translateZ(0)";
							topObj.style.webkitTransform = "translateX(0) translateY(" + elTrans + "px) translateZ(0)";
							topObj.style.opacity         = '0';

						});

					}, 300);

					isFirstTime = false;
				}
			}
		}

//Move the overlay right to initial position.
		function resetOverlayRight() {
			if (!(currentPosition >= maxElements)) {
				if (useOverlays) {
					setTimeout(function () {

						if (stackedOptions === "Top") {
							+2;

							elTrans = elementsMargin * (items - 1);

						} else if (stackedOptions === "Bottom" || stackedOptions === "None") {

							elTrans = 0;

						}

						if (!isFirstTime) {

							rightObj.classList.add('no-transition');
							topObj.classList.add('no-transition');

						}

						requestAnimationFrame(function () {

							rightObj.style.transform       = "translateX(0) translateY(" + elTrans + "px) translateZ(0)";
							rightObj.style.webkitTransform = "translateX(0) translateY(" + elTrans + "px) translateZ(0)";
							rightObj.style.opacity         = '0';

							topObj.style.transform       = "translateX(0) translateY(" + elTrans + "px) translateZ(0)";
							topObj.style.webkitTransform = "translateX(0) translateY(" + elTrans + "px) translateZ(0)";
							topObj.style.opacity         = '0';

						});

					}, 300);

					isFirstTime = false;
				}
			}
		}

//Move the overlays to initial position.
		function resetOverlays() {
			if (!(currentPosition >= maxElements)) {
				if (useOverlays) {

					setTimeout(function () {
						if (stackedOptions === "Top") {

							elTrans = elementsMargin * (items - 1);

						} else if (stackedOptions === "Bottom" || stackedOptions === "None") {

							elTrans = 0;

						}

						if (!isFirstTime) {

							leftObj.classList.add('no-transition');
							rightObj.classList.add('no-transition');
							topObj.classList.add('no-transition');

						}

						requestAnimationFrame(function () {

							leftObj.style.transform       = "translateX(0) translateY(" + elTrans + "px) translateZ(0)";
							leftObj.style.webkitTransform = "translateX(0) translateY(" + elTrans + "px) translateZ(0)";
							leftObj.style.opacity         = '0';

							rightObj.style.transform       = "translateX(0) translateY(" + elTrans + "px) translateZ(0)";
							rightObj.style.webkitTransform = "translateX(0) translateY(" + elTrans + "px) translateZ(0)";
							rightObj.style.opacity         = '0';

							topObj.style.transform       = "translateX(0) translateY(" + elTrans + "px) translateZ(0)";
							topObj.style.webkitTransform = "translateX(0) translateY(" + elTrans + "px) translateZ(0)";
							topObj.style.opacity         = '0';

						});

					}, 300);	// wait for animations time

					isFirstTime = false;
				}
			}
		}

		function setActiveHidden() {
			if (!(currentPosition >= maxElements)) {
				listElNodesObj[currentPosition - 1].classList.remove('stackedcards-active');
				listElNodesObj[currentPosition - 1].classList.add('stackedcards-hidden');
				listElNodesObj[currentPosition].classList.add('stackedcards-active');
			}
		}

//Set the new z-index for specific card.
		function setZindex(zIndex) {
			if (listElNodesObj[currentPosition]) {
				listElNodesObj[currentPosition].style.zIndex = zIndex;
			}
		}

// Remove element from the DOM after swipe. To use this method you need to call this function in onSwipeLeft, onSwipeRight and onSwipeTop and put the method just above the variable 'currentPosition = currentPosition + 1'.
//On the actions onSwipeLeft, onSwipeRight and onSwipeTop you need to remove the currentPosition variable (currentPosition = currentPosition + 1) and the function setActiveHidden

		function removeElement() {
			currentElementObj.remove();
			// if (!(currentPosition >= maxElements)) {
			// 	listElNodesObj[currentPosition].classList.add('stackedcards-active');
			// }
		}

//Add translate X and Y to active card for each frame.
		function transformUi(moveX, moveY, opacity, elementObj) {
			requestAnimationFrame(function () {
				const element = elementObj;

				// Function to generate rotate value
				/**
				 * @return {number}
				 */
				function RotateRegulator(value) {
					if (value / 10 > 15) {
						return 15;
					} else if (value / 10 < -15) {
						return -15;
					}
					return value / 10;
				}

				if (rotate) {
					rotateElement = RotateRegulator(moveX);
				} else {
					rotateElement = 0;
				}

				if (stackedOptions === "Top") {
					elTrans = elementsMargin * (items - 1);
					if (element) {
						element.style.webkitTransform = "translateX(" + moveX + "px) translateY(" + (moveY + elTrans) + "px) translateZ(0) rotate(" + rotateElement + "deg)";
						element.style.transform       = "translateX(" + moveX + "px) translateY(" + (moveY + elTrans) + "px) translateZ(0) rotate(" + rotateElement + "deg)";
						element.style.opacity         = opacity;
					}
				} else if (stackedOptions === "Bottom" || stackedOptions === "None") {

					if (element) {
						element.style.webkitTransform = "translateX(" + moveX + "px) translateY(" + (moveY) + "px) translateZ(0) rotate(" + rotateElement + "deg)";
						element.style.transform       = "translateX(" + moveX + "px) translateY(" + (moveY) + "px) translateZ(0) rotate(" + rotateElement + "deg)";
						element.style.opacity         = opacity;
					}

				}
			});
		}

//Action to update all elements on the DOM for each stacked card.
		function updateUi() {
			requestAnimationFrame(function () {
				elTrans          = 0;
				let elZindex     = 5;
				let elScale      = 1;
				let elOpac       = 1;
				let elTransTop   = items;
				const elTransInc = elementsMargin;

				for (let i = currentPosition; i < (currentPosition + items); i++) {
					if (listElNodesObj[i]) {
						if (stackedOptions === "Top") {

							listElNodesObj[i].classList.add('stackedcards-top', 'stackedcards--animatable', 'stackedcards-origin-top');

							if (useOverlays) {
								leftObj.classList.add('stackedcards-origin-top');
								rightObj.classList.add('stackedcards-origin-top');
								topObj.classList.add('stackedcards-origin-top');
							}

							elTrans = elTransInc * elTransTop;
							elTransTop--;

						} else if (stackedOptions === "Bottom") {
							listElNodesObj[i].classList.add('stackedcards-bottom', 'stackedcards--animatable', 'stackedcards-origin-bottom');

							if (useOverlays) {
								leftObj.classList.add('stackedcards-origin-bottom');
								rightObj.classList.add('stackedcards-origin-bottom');
								topObj.classList.add('stackedcards-origin-bottom');
							}

							elTrans = elTrans + elTransInc;

						} else if (stackedOptions === "None") {

							listElNodesObj[i].classList.add('stackedcards-none', 'stackedcards--animatable');
							elTrans = elTrans + elTransInc;

						}

						listElNodesObj[i].style.transform       = 'scale(' + elScale + ') translateX(0) translateY(' + (elTrans - elTransInc) + 'px) translateZ(0)';
						listElNodesObj[i].style.webkitTransform = 'scale(' + elScale + ') translateX(0) translateY(' + (elTrans - elTransInc) + 'px) translateZ(0)';
						listElNodesObj[i].style.opacity         = elOpac;
						listElNodesObj[i].style.zIndex          = elZindex;

						elScale = elScale - 0.12;
						elOpac  = elOpac - (1 / items);
						elZindex--;
					}
				}

			});

		}

//Touch events block
		var element         = obj;
		let startTime;
		let startX;
		let startY;
		let translateX;
		let translateY;
		let currentX;
		let currentY;
		let touchingElement = false;
		let timeTaken;
		let topOpacity;
		let rightOpacity;
		let leftOpacity;

		function setOverlayOpacity() {

			topOpacity   = (((translateY + (elementHeight) / 2) / 100) * -1);
			rightOpacity = translateX / 100;
			leftOpacity  = ((translateX / 100) * -1);


			if (topOpacity > 1) {
				topOpacity = 1;
			}

			if (rightOpacity > 1) {
				rightOpacity = 1;
			}

			if (leftOpacity > 1) {
				leftOpacity = 1;
			}
		}

		function gestureStart(evt) {
			startTime = new Date().getTime();

			startX = evt.changedTouches[0].clientX;
			startY = evt.changedTouches[0].clientY;

			currentX = startX;
			currentY = startY;

			setOverlayOpacity();

			touchingElement = true;
			if (!(currentPosition >= maxElements)) {
				if (listElNodesObj[currentPosition]) {
					listElNodesObj[currentPosition].classList.add('no-transition');
					setZindex(6);

					if (useOverlays) {
						leftObj.classList.add('no-transition');
						rightObj.classList.add('no-transition');
						topObj.classList.add('no-transition');
					}

					if ((currentPosition + 1) < maxElements && listElNodesObj[currentPosition + 1]) {
						listElNodesObj[currentPosition + 1].style.opacity = '1';
					}

					elementHeight = listElNodesObj[currentPosition].offsetHeight / 3;
				}

			}

		}

		function gestureMove(evt) {
			currentX = evt.changedTouches[0].pageX;
			currentY = evt.changedTouches[0].pageY;

			translateX = currentX - startX;
			translateY = currentY - startY;

			setOverlayOpacity();

			if (!(currentPosition >= maxElements)) {
				evt.preventDefault();
				transformUi(translateX, translateY, 1, currentElementObj);

				if (useOverlays) {
					transformUi(translateX, translateY, topOpacity, topObj);

					if (translateX < 0) {
						transformUi(translateX, translateY, leftOpacity, leftObj);
						transformUi(0, 0, 0, rightObj);

					} else if (translateX > 0) {
						transformUi(translateX, translateY, rightOpacity, rightObj);
						transformUi(0, 0, 0, leftObj);
					}

					if (useOverlays) {
						leftObj.style.zIndex  = 8;
						rightObj.style.zIndex = 8;
						topObj.style.zIndex   = 7;
					}

				}

			}

		}

		function gestureEnd(evt) {

			if (!touchingElement) {
				return;
			}

			translateX = currentX - startX;
			translateY = currentY - startY;

			timeTaken = new Date().getTime() - startTime;

			touchingElement = false;

			if (!(currentPosition >= maxElements)) {
				if (translateY < (elementHeight * -1) && translateX > ((listElNodesWidth / 2) * -1) && translateX < (listElNodesWidth / 2)) {  //is Top?

					if (translateY < (elementHeight * -1) || (Math.abs(translateY) / timeTaken > velocity)) { // Did It Move To Top?
						onSwipeTop();
					} else {
						backToMiddle();
					}

				} else {

					if (translateX < 0) {
						if (translateX < ((listElNodesWidth / 2) * -1) || (Math.abs(translateX) / timeTaken > velocity)) { // Did It Move To Left?
							onSwipeLeft();
						} else {
							backToMiddle();
						}
					} else if (translateX > 0) {

						if (translateX > (listElNodesWidth / 2) && (Math.abs(translateX) / timeTaken > velocity)) { // Did It Move To Right?
							onSwipeRight();
						} else {
							backToMiddle();
						}

					}
				}
			}
		}

		element.addEventListener('touchstart', gestureStart, false);
		element.addEventListener('touchmove', gestureMove, false);
		element.addEventListener('touchend', gestureEnd, false);

//Add listeners to call global action for swipe cards
		const buttonLeft  = document.querySelector('.left-action');
		const buttonTop   = document.querySelector('.top-action');
		const buttonRight = document.querySelector('.right-action');

		buttonLeft.addEventListener('click', onActionLeft, false);
		if (buttonTop) {
			buttonTop.addEventListener('click', onActionTop, false);
		}
		buttonRight.addEventListener('click', onActionRight, false);


		return {
			answers: answers
		}
	}


}
