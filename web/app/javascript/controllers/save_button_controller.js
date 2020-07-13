import ApplicationController from "./application_controller"
import * as MobileDetect     from "mobile-detect";
import {FeedChannel}         from "../channels/feed_channel";
import {SnackBarModule}      from "../modules/snackbar-module";

export default class SaveButtonController extends ApplicationController {
    static targets = ["button"];

    connect() {
        super.connect();
        this.md = new MobileDetect(window.navigator.userAgent);

        this.updateButtonStyle(this.saveStatus);
    }

    disconnect() {

    }

    like(event) {
        PubSubModule.emit("save-button.clicked");
        this.updateButtonStyle(!this.saveStatus);

        const send = FeedChannel.send({
                                          sent_by: gon.user_id,
                                          body:    {
                                              id:       this.resourceId,
                                              selector: this.resourceSelector,
                                              action:   this.isSaved,
                                              resource: this.resourceName
                                          }
                                      })

        if (send) {
            this.saveStatus = !this.saveStatus;
        } else {
            this.updateButtonStyle(this.saveStatus);
            SnackBarModule.show("Não foi possível realizar esta ação");
        }
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
    }

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

    get resourceSelector() {
        return this.data.get("resourceSelector")
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
            return section.dataset.sectionIdentifier;
        }
    }

}
