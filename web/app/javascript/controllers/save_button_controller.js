import ApplicationController from "./application_controller"
import * as MobileDetect     from "mobile-detect";
import Flipping              from "flipping";

export default class SaveButtonController extends ApplicationController {
    static targets = ["button"];

    connect() {
        super.connect();

        // this.pubsub          = {};
        this.md = new MobileDetect(window.navigator.userAgent);

        // this.flipping = new Flipping({
        //                                  attribute: `data-collection-${this.sectionIdentifier}-flip-key`
        //                              });
        // this.adjustForDevice = this.md.mobile();

        // this.pubsub.savesUpdated = PubSubModule.on(`saves.updated`, (data) => {
        // 	if (data.detail.resourceId == this.resourceId) {
        // 		this.saveStatus = data.detail.currentResourceFavorited;
        // 		this.updateSaveButtonStyle(data.detail.resourceId, data.detail.currentResourceFavorited);
        // 	}
        // });
        this.updateButtonStyle(this.saveStatus);

        // this.destroy = () => {
            // this.pubsub.savesUpdated();
        // }

        // document.addEventListener('turbolinks:before-cache', this.destroy, false);
    }

    disconnect() {
        // document.removeEventListener('turbolinks:before-cache', this.destroy, false);
    }

    like(event) {
        this.updateButtonStyle(!this.saveStatus);

        this.stimulate("Taste#save", event.currentTarget, {
            id:       this.resourceId,
            action:   this.isSaved,
            resource: this.resourceName
        })
            .then(payload => {
                // const flipPromise = new Promise((resolve, reject) => {
                //     this.flipping.flip();
                //
                //     let delay   = 0.035;
                //     let counter = 0;
                //     let states  = Object.keys(this.flipping.states);
                //
                //     states.forEach((key) => {
                //         counter++;
                //
                //         const state = this.flipping.states[key];
                //         if (state.element === undefined) {
                //             return;
                //         }
                //
                //         if (states.length > 48 && counter < (states.length - 8)) {
                //             return;
                //         }
                //
                //         if (state.type === "MOVE" && state.delta) {
                //             state.element.style.transition = "";
                //             state.element.style.transform  = `translateY(${state.delta.top}px)
                // translateX(${state.delta.left}px)`; } if (state.type === "ENTER") { state.element.style.opacity   =
                // 0; state.element.style.transform = `scale(0.8)`; } requestAnimationFrame(() => { if (state.type ===
                // "MOVE" && state.delta) { state.element.style.transition = `transform 0.6s
                // cubic-bezier(.54,.01,.45,.99)`; state.element.style.transform  = ""; state.element.style.opacity
                // = 1; } if (state.type === "ENTER") { state.element.style.transition = `transform 0.4s
                // cubic-bezier(0,.16,.45,.99) ${delay}s, opacity 0.4s cubic-bezier(0,.16,.45,.99) ${delay}s`;
                // state.element.style.transform  = ""; state.element.style.opacity    = 1; } delay = delay + 0.035;
                // });  });  resolve(states) });  flipPromise.then((states) => { console.log(states) });

                CacheModule.clearCache();
            })
            .catch(payload => {

            })
        //
        // PubSubModule.emit('event.like');
        //
        // fetch(`/api/taste/${this.resourceName}/${this.resourceId}/${this.isSaved}`, {
        // 	method:      'post',
        // 	headers:     {
        // 		'X-Requested-With': 'XMLHttpRequest',
        // 		'Content-type':     'text/javascript; charset=UTF-8',
        // 		'X-CSRF-Token':     document.querySelector('meta[name=csrf-token]').content
        // 	},
        // 	credentials: 'same-origin'
        // })
        // 	.then(
        // 		response => {
        // 			response.text().then(data => {
        // 				eval(data);
        // 				CacheModule.clearCache(['feed-page', 'events-page'], {
        // 					event: {
        // 						identifier: this.resourceId
        // 					}
        // 				});
        // 			});
        // 		}
        // 	)
        // 	.catch(err => {
        // 		console.log('Fetch Error :-S', err);
        // 	});
    }

    updateButtonStyle(saveStatus) {
        if (this.hasButtonTarget) {
            if (saveStatus === true) {
                this.buttonTarget.style.display = "inline";
                this.buttonTarget.classList.add("mdc-icon-button--on")
            } else {
                this.buttonTarget.classList.remove("mdc-icon-button--on");
            }
        }
    };

    set adjustForDevice(isMobile) {
        const isSaved  = this.saveStatus === false;
        const isSingle = this.data.get("modifier") === "single";

        if (isMobile) {
        } else {
            if (isSaved && !isSingle) {
                this.buttonTarget.style.display = "none";
            }
        }
    }

    get isSaved() {
        if (this.saveStatus === true) {
            return "unsave";
        } else {
            return "save";
        }
    }

    get saveStatus() {
        return JSON.parse(this.data.get("saved"))
    }

    set saveStatus(status) {
        this.data.set("saved", status);
    }

    get resourceId() {
        return this.data.get("resourceId")
    }

    get resourceName() {
        return this.data.get("resourceName")
    }

    get isPreview() {
        return document.documentElement.hasAttribute("data-turbolinks-preview");
    }

    get sectionIdentifier() {
        const section = this.buttonTarget.closest("[data-controller=\"section\"]");

        if (this.hasButtonTarget && section) {
            return section.id;
        }
    }

}
