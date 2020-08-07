import ApplicationController from "./application_controller"
import {UserChannel}         from "../channels/user_channel";
import {SnackBarModule}      from "../modules/snackbar-module";
import {PubSubModule}        from "../modules/pubsub-module";

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
        // this.updateButtonStyle(this.saveStatus);
    }

    teardown() {

    }

    like(event) {
        PubSubModule.emit("save-button#like->started");

        // this.updateButtonStyle(!this.saveStatus);

        // fetch(`${this.resourceRoute}/${this.resourceId}/${this.action}`, {
        //     method:      "post",
        //     headers:     {
        //         "X-Requested-With": "XMLHttpRequest",
        //         "Content-type":     "application/json; charset=UTF-8",
        //         "Accept":           "text/html; charset=utf-8",
        //         "X-CSRF-Token":     document.querySelector("meta[name=csrf-token]").content
        //     },
        //     body:        JSON.stringify({elementId: this.resourceElementId}),
        //     credentials: "same-origin"
        // }).then(response => {
        //             response.text().then(html => {
        //                 const fragment = document.createRange().createContextualFragment(html);
        //                 const savesEl  = document.getElementById("events_saved");
        //                 this.status    = !this.status;
        //
        //                 morphdom(savesEl, fragment, {
        //                     childrenOnly: true
        //                 })
        //
        //                 PubSubModule.emit("save-button#like->finished");
        //                 CacheModule.clearCache();
        //             });
        //         }
        // ).catch(err => {
        //     SnackBarModule.show("Não foi possível realizar esta ação");
        // });

        const send = UserChannel.perform("taste", {
            sent_by: gon.user_id,
            body: Object.fromEntries(Array.from(this.element.attributes).map((attr) => { return [attr.nodeName, attr.nodeValue] }))
            // body:    {
            //     saveButtonHtmlId: this.saveButtonHtmlId,
            //     resourceHtmlId:   this.resourceHtmlId,
            //     savesHtmlId:      this.savesId,
            //     resourceId:       this.resourceId,
            //     resourceType:     this.resourceType,
            //     action:           this.action
            // }
        })

        if (send) {
            this.status = !this.status;
            PubSubModule.emit("save-button#like->finished");
            CacheModule.clearCache();
        } else {
            // this.updateButtonStyle(this.saveStatus);
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

    get action() {
        if (this.status === true) {
            return "unsave";
        } else {
            return "save";
        }
    }

    get status() {
        return JSON.parse(this.data.get("saved"))
    }

    set status(status) {
        this.data.set("saved", status);
    }

    get resourceId() {
        return this.data.get("resourceId")
    }

    get resourceHtmlId() {
        return this.data.get("resourceHtmlId")
    }

    get saveButtonHtmlId() {
        return this.element.id;
    }

    get savesId() {
        return this.data.get('savesHtmlId');
    }

    get resourceType() {
        return this.data.get("resourceType")
    }

    get isPreview() {
        return document.documentElement.hasAttribute("data-turbolinks-preview");
    }

}
