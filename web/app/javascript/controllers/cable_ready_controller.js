import ApplicationController from "./application_controller"
import {UserChannel}         from "../channels/user_channel";
import {SnackBarModule}      from "../modules/snackbar-module";
import {PubSubModule}        from "../modules/pubsub-module";

export default class CableReadyController extends ApplicationController {
    static targets = [];

    connect() {
        super.connect();
        this.setup();
    }

    disconnect() {
        super.disconnect()
    }

    setup() {

    }

    teardown() {

    }

    perform(event) {
        PubSubModule.emit(`${this.performMethod}->started`);

        const send = UserChannel.perform(this.performMethod, {
            sent_by: gon.user_id,
            body:    Object.fromEntries(Array.from(this.element.attributes).map((attr) => {
                return [attr.nodeName, attr.nodeValue]
            }))
        })

        if (send) {
            PubSubModule.emit(`${this.performMethod}->finished`);
            CacheModule.clearCache();
        } else {
            SnackBarModule.show("Não foi possível realizar esta ação");
        }
    }

    get performMethod() {
        return this.data.get("perform")
    }
}
