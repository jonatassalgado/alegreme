import {ProgressBarModule} from "./progressbar-module";

const SwipableModule = (() => {
    const debug  = false;
    const module = {};

    module.init = () => {
        if (debug) console.log("[SWIPABLE]: initied");
        const stackedOptions = "Top"; //Change stacked cards view from 'Bottom', 'Top' or 'None'.
        const rotate         = true; //Activate the elements' rotation for each move on stacked cards.
        let items            = 2; //Number of visible elements when the stacked options are bottom or top.
        const elementsMargin = 24; //Define the distance of each element when the stacked options are bottom
                                   // or top.
        const useOverlays             = true; //Enable or disable the overlays for swipe elements.
        let maxElements; //Total of stacked cards on DOM.
        let currentPosition           = 0; //Keep the position of active stacked card.
        let counter                   = 0;
        const velocity                = 0.5; //Minimum velocity allowed to trigger a swipe.
        const pixelsToMoveCardOnSwipe = window.innerWidth;
        const animationDuration       = 300;
        let isFirstTime               = true;
        let rightObj; //Keep the swipe right properties.
        let leftObj; //Keep the swipe left properties.
        let listElNodesObj; //Keep the list of nodes from stacked cards.
        let currentElementObj; //Keep the stacked card element to swipe.
        let stackedCardsObj;
        let elementHeight;
        let obj;
        let elTrans;
        let rotateElement;
        let addMargin;

        obj             = document.querySelector("[data-swipable-module=\"stacked-cards-block\"]");
        stackedCardsObj = obj.querySelector("[data-swipable-module=\"stackedcards-container\"]");
        listElNodesObj  = stackedCardsObj.children;

        rightObj = obj.querySelector("[data-swipable-module=\"stackedcards-overlay-right\"]");
        leftObj  = obj.querySelector("[data-swipable-module=\"stackedcards-overlay-left\"]");

        countElements();
        currentElement();
        currentElementObj = listElNodesObj[0];
        updateUi();

        //Prepare elements on DOM
        addMargin = elementsMargin * (items - 1) + "px";


        for (let i = items; i < maxElements; i++) {
            listElNodesObj[i].classList.add("origin-top");
        }
        elTrans = elementsMargin * (items - 1);

        stackedCardsObj.style.marginBottom = addMargin;

        for (let i = items; i < maxElements; i++) {
            listElNodesObj[i].style.zIndex          = 0;
            listElNodesObj[i].style.opacity         = 0;
            listElNodesObj[i].style.webkitTransform = "scale(" +
                                                      (1 - (items * 0.06)) +
                                                      ") translateX(0) translateY(" +
                                                      elTrans +
                                                      "px) translateZ(0)";
            listElNodesObj[i].style.transform       = "scale(" +
                                                      (1 - (items * 0.06)) +
                                                      ") translateX(0) translateY(" +
                                                      elTrans +
                                                      "px) translateZ(0)";
        }

        if (listElNodesObj[currentPosition]) {
            // listElNodesObj[currentPosition].classList.add("elevation-10");
        }

        if (useOverlays) {
            leftObj.style.transform       = "translateX(0px) translateY(" +
                                            elTrans +
                                            "px) translateZ(0px) rotate(0deg)";
            leftObj.style.webkitTransform = "translateX(0px) translateY(" +
                                            elTrans +
                                            "px) translateZ(0px) rotate(0deg)";

            rightObj.style.transform       = "translateX(0px) translateY(" +
                                             elTrans +
                                             "px) translateZ(0px) rotate(0deg)";
            rightObj.style.webkitTransform = "translateX(0px) translateY(" +
                                             elTrans +
                                             "px) translateZ(0px) rotate(0deg)";

        } else {
            leftObj.className  = "";
            rightObj.className = "";

            leftObj.classList.add("stackedcards-overlay-hidden");
            rightObj.classList.add("stackedcards-overlay-hidden");
        }


        function backToMiddle() {
            addTransitions();
            transformUi(0, 0, 1, currentElementObj);

            if (useOverlays) {
                transformUi(0, 0, 0, leftObj);
                transformUi(0, 0, 0, rightObj);
            }

            setZindex(5);

            //roll back the opacity of second element
            if (listElNodesObj.length > 1) {
                listElNodesObj[1].style.opacity = ".8";
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
                document.querySelector("[data-swipable-module=\"swipable-items\"]").style.display = "none";
                document.querySelector("[data-swipable-module=\"final-state\"]").style.display    = "flex";
                requestAnimationFrame(() => {
                    document.querySelector("[data-swipable-module=\"swipable-items\"]").style.opacity = 0;
                    setTimeout(() => {
                        document.querySelector("[data-swipable-module=\"final-state\"]").style.opacity = 1;
                        ProgressBarModule.show();
                        setTimeout(() => {
                            location.assign("/porto-alegre");
                        }, 1000)
                    }, 500);
                })
            }
        }

        //Functions to swipe left elements on logic external action.
        function onActionLeft() {
            if (counter < maxElements) {
                if (useOverlays) {
                    leftObj.classList.add("transition-all", `duration-${animationDuration}`);
                    leftObj.style.zIndex = "8";
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
                    rightObj.classList.add("transition-all", `duration-${animationDuration}`);
                    rightObj.style.zIndex = "8";
                    transformUi(0, 0, 1, rightObj);
                }

                setTimeout(function () {
                    onSwipeRight();
                    resetOverlayRight();
                }, 300);
            }
        }

        //Swipe active card to left.
        function onSwipeLeft() {
            fetch(`/api/taste/events/${currentElementObj.id}/dislike?swipable=true`, {
                method:      "post",
                headers:     {
                    "X-Requested-With": "XMLHttpRequest",
                    "Content-type":     "application/json; charset=UTF-8",
                    "Accept":           "application/json",
                    "X-CSRF-Token":     document.querySelector("meta[name=csrf-token]").content
                },
                credentials: "same-origin"
            }).then(
                response => {
                    response.text().then(data => {

                    });
                }
            ).catch(err => {
                console.log("Fetch Error :-S", err);
            });

            addTransitions();
            transformUi(-pixelsToMoveCardOnSwipe, 0, 0, currentElementObj);
            if (useOverlays) {
                transformUi(-pixelsToMoveCardOnSwipe, 0, 0, leftObj); //Move leftOverlay
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
            fetch(`/api/taste/events/${currentElementObj.id}/save?swipable=true`, {
                method:      "post",
                headers:     {
                    "X-Requested-With": "XMLHttpRequest",
                    "Content-type":     "application/json; charset=UTF-8",
                    "Accept":           "application/json",
                    "X-CSRF-Token":     document.querySelector("meta[name=csrf-token]").content
                },
                credentials: "same-origin"
            }).then(
                response => {
                    response.text().then(data => {
                        // CacheModule.clearCache();
                    });
                }
            ).catch(err => {
                console.log("Fetch Error :-S", err);
            });

            addTransitions();
            transformUi(pixelsToMoveCardOnSwipe, 0, 0, currentElementObj);
            if (useOverlays) {
                transformUi(pixelsToMoveCardOnSwipe, 0, 0, rightObj); //Move rightOverlay
                resetOverlayRight();
            }
            counter = counter + 1;
            removeElement();
            updateUi();
            currentElement();
            changeStages();
        }


        //Remove transitions from all elements to be moved in each swipe movement to improve perfomance of stacked
        // cards.
        function addTransitions() {
            if (listElNodesObj[currentPosition]) {

                if (useOverlays) {
                    leftObj.classList.add("transition-all", `duration-${animationDuration}`);
                    rightObj.classList.add("transition-all", `duration-${animationDuration}`);
                }

                listElNodesObj[currentPosition].classList.add("transition-all", `duration-${animationDuration}`);
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
                            leftObj.classList.remove("transition-all", `duration-${animationDuration}`);
                        }

                        requestAnimationFrame(function () {
                            leftObj.style.transform       = "translateX(0) translateY(" + elTrans + "px) translateZ(0)";
                            leftObj.style.webkitTransform = "translateX(0) translateY(" + elTrans + "px) translateZ(0)";
                            leftObj.style.opacity         = "0";
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
                            elTrans = elementsMargin * (items - 1);
                        } else if (stackedOptions === "Bottom" || stackedOptions === "None") {
                            elTrans = 0;
                        }

                        if (!isFirstTime) {
                            rightObj.classList.remove("transition-all", `duration-${animationDuration}`);
                        }

                        requestAnimationFrame(function () {

                            rightObj.style.transform       = "translateX(0) translateY(" +
                                                             elTrans +
                                                             "px) translateZ(0)";
                            rightObj.style.webkitTransform = "translateX(0) translateY(" +
                                                             elTrans +
                                                             "px) translateZ(0)";
                            rightObj.style.opacity         = "0";
                        });

                    }, 300);

                    isFirstTime = false;
                }
            }
        }

        //Set the new z-index for specific card.
        function setZindex(zIndex) {
            if (listElNodesObj[currentPosition]) {
                listElNodesObj[currentPosition].style.zIndex = zIndex;
            }
        }

        // Remove element from the DOM after swipe. To use this method you need to call this function in onSwipeLeft,
        // onSwipeRight and onSwipeTop and put the method just above the variable 'currentPosition = currentPosition +
        // 1'. On the actions onSwipeLeft, onSwipeRight and onSwipeTop you need to remove the currentPosition variable
        // (currentPosition = currentPosition + 1) and the function setActiveHidden

        function removeElement() {
            currentElementObj.remove();
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
                    if (value / 10 > 20) {
                        return 20;
                    } else if (value / 10 < -20) {
                        return -20;
                    }
                    return value / 10;
                }

                if (rotate) {
                    rotateElement = RotateRegulator(moveX);
                } else {
                    rotateElement = 0;
                }
                elTrans = elementsMargin * (items - 1);

                if (element) {
                    element.style.webkitTransform = "translateX(" +
                                                    moveX +
                                                    "px) translateY(" +
                                                    (moveY + elTrans) +
                                                    "px) translateZ(0) rotate(" +
                                                    rotateElement +
                                                    "deg)";
                    element.style.transform       = "translateX(" +
                                                    moveX +
                                                    "px) translateY(" +
                                                    (moveY + elTrans) +
                                                    "px) translateZ(0) rotate(" +
                                                    rotateElement +
                                                    "deg)";
                    element.style.opacity         = opacity;
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

                if (listElNodesObj[currentPosition]) {
                    // listElNodesObj[currentPosition].classList.add("elevation-10");
                }

                for (let i = currentPosition; i < (currentPosition + items); i++) {
                    if (listElNodesObj[i]) {
                        if (stackedOptions === "Top") {

                            listElNodesObj[i].classList.add("origin-top");

                            if (useOverlays) {
                                leftObj.classList.add("origin-top");
                                rightObj.classList.add("origin-top");
                            }

                            elTrans = elTransInc * elTransTop;
                            elTransTop--;

                        } else if (stackedOptions === "Bottom") {
                            listElNodesObj[i].classList.add("stackedcards-bottom", "stackedcards--animatable", "stackedcards-origin-bottom");

                            if (useOverlays) {
                                leftObj.classList.add("stackedcards-origin-bottom");
                                rightObj.classList.add("stackedcards-origin-bottom");
                            }

                            elTrans = elTrans + elTransInc;

                        } else if (stackedOptions === "None") {

                            listElNodesObj[i].classList.add("stackedcards-none", "stackedcards--animatable");
                            elTrans = elTrans + elTransInc;

                        }

                        listElNodesObj[i].style.transform       = "scale(" +
                                                                  elScale +
                                                                  ") translateX(0) translateY(" +
                                                                  (elTrans - elTransInc) +
                                                                  "px) translateZ(0)";
                        listElNodesObj[i].style.webkitTransform = "scale(" +
                                                                  elScale +
                                                                  ") translateX(0) translateY(" +
                                                                  (elTrans - elTransInc) +
                                                                  "px) translateZ(0)";
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
        let element         = obj;
        let startTime;
        let startX;
        let startY;
        let translateX;
        let translateY;
        let currentX;
        let currentY;
        let touchingElement = false;
        let timeTaken;
        let rightOpacity;
        let leftOpacity;

        function setOverlayOpacity() {
            rightOpacity = translateX / 200;
            leftOpacity  = ((translateX / 200) * -1);

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
                    listElNodesObj[currentPosition].classList.remove("transition-all", `duration-${animationDuration}`);
                    setZindex(6);

                    if (useOverlays) {
                        leftObj.classList.remove("transition-all", `duration-${animationDuration}`);
                        rightObj.classList.remove("transition-all", `duration-${animationDuration}`);
                    }

                    if ((currentPosition + 1) < maxElements && listElNodesObj[currentPosition + 1]) {
                        listElNodesObj[currentPosition + 1].style.opacity = "1";
                    }

                    elementHeight = listElNodesObj[currentPosition].offsetHeight / 3;
                }

            }

        }

        function gestureMove(evt) {
            currentX = evt.changedTouches[0].pageX;
            currentY = evt.changedTouches[0].pageY;

            translateX = currentX - startX;
            translateY = 0;
            // translateY = currentY - startY;

            setOverlayOpacity();

            if (!(currentPosition >= maxElements)) {
                evt.preventDefault();
                transformUi(translateX, translateY, 1, currentElementObj);

                if (useOverlays) {
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
                if (translateY <
                    (elementHeight * -1) &&
                    translateX >
                    ((currentElementObj.offsetWidth / 2) * -1) &&
                    translateX <
                    (currentElementObj.offsetWidth / 2)) {  //is Top?

                    backToMiddle();

                } else {
                    if (translateX < 0) {
                        if (translateX <
                            ((currentElementObj.offsetWidth / 2) * -1) ||
                            (Math.abs(translateX) / timeTaken > velocity)) { // Did It Move To Left?
                            onSwipeLeft();
                        } else {
                            backToMiddle();
                        }
                    } else if (translateX > 0) {

                        if (translateX > (currentElementObj.offsetWidth / 2) && (Math.abs(translateX) / timeTaken > velocity)) { // Did It Move To Right?
                            onSwipeRight();
                        } else {
                            backToMiddle();
                        }

                    }
                }
            }
        }

        element.addEventListener("touchstart", gestureStart, false);
        element.addEventListener("touchmove", gestureMove, false);
        element.addEventListener("touchend", gestureEnd, false);

        //Add listeners to call global action for swipe cards
        const buttonLeft  = document.querySelector("[data-swipable-module=\"left-action\"]");
        const buttonRight = document.querySelector("[data-swipable-module=\"right-action\"]");

        buttonLeft.addEventListener("click", onActionLeft, false);
        buttonRight.addEventListener("click", onActionRight, false);
    }

    module.destroy = () => {

    }

    return module;
})();

export {SwipableModule};