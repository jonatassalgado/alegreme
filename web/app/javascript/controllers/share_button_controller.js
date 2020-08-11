import ApplicationController from "./application_controller"

export default class ShareButtonController extends ApplicationController {
    static targets = [];

    connect() {
        this.setup();
    }

    disconnect() {
        super.disconnect()
    }

    setup() {
        if (navigator.share) {
            this.element.classList.remove("hidden", "opacity-0")
        }
    }

    teardown() {

    }

    share() {
        navigator.share({
                            title: this.title,
                            text:  this.text,
                            url:   this.url,
                        }).then(() =>
                                    console.log("Successful share")
        ).catch(
            (error) => console.log("Error sharing", error));
    }

    get title() {
        return this.data.get("title");
    }

    get text() {
        return this.data.get("text");
    }

    get url() {
        return this.data.get("url");
    }

}
