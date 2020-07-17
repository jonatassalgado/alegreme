import ApplicationController from "./application_controller"
import {UserChannel}         from "../channels/user_channel";
import {SnackBarModule}      from "../modules/snackbar-module";

export default class SaveButtonController extends ApplicationController {
    static targets = ["button"];

    connect() {
        super.connect();
        this.setup();
    }

    disconnect() {
        super.disconnect()
    }

    setup() {
        this.updateButtonStyle(this.saveStatus);
    }

    teardown() {

    }

    like(event) {
        PubSubModule.emit("save-button.clicked");

        this.updateButtonStyle(!this.saveStatus);

        const send = UserChannel.send({
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
            CacheModule.clearCache();
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

}
