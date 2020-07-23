import ApplicationController from "./application_controller"
import {FlipperModule}       from "../modules/flipper-module";
import {PubSubModule}        from "../modules/pubsub-module";

export default class FlipController extends ApplicationController {
    static targets = [];

    connect() {
        super.connect();
        this.setup();
    }

    beforeCache() {
        super.beforeCache();
        // this.teardown();
    }

    disconnect() {
        super.disconnect();
        this.teardown();
    }

    setup() {
        this.pubsub  = {};
        this.flipper = FlipperModule(this.flipIdentifier);
        this.activeFlip();
    }

    teardown() {
        PubSubModule.destroy(this.pubsub);
        this.flipper.destroy();
        document.removeEventListener(this.finishedListener, this.flipper.flip);
    }

    activeFlip() {
        this.pubsub.savesStarted = PubSubModule.on(this.startedListener, (data) => {
            this.flipper.read()
            document.addEventListener(this.finishedListener, this.flipper.flip);
        });
    }

    flip() {
        console.log("alo", this.identifier);
        this.flipper.flip;
    }

    get flipIdentifier() {
        return this.data.get("identifier")
    }

    get startedListener() {
        return this.data.get("startedListener")
    }

    get finishedListener() {
        return this.data.get("finishedListener")
    }

}
