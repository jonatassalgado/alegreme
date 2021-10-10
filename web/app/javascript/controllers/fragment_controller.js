import ApplicationController from "./application_controller"

export default class FragmentController extends ApplicationController {
    static targets = [];

    connect() {
        super.connect();
        this.setup();
    }

    setup() {

    }

    teardown() {
        this.element.classList.add("hidden");
    }

    beforeCache() {
        super.beforeCache();
    }

    disconnect() {
        super.disconnect();
        this.teardown()
    }

    async load() {
        const morphdom = await import('morphdom')

        fetch(`${location.origin}${this.path}`, {
            method:  "get",
            headers: {
                "X-Requested-With": "XMLHttpRequest",
                "Content-type":     "application/json; charset=UTF-8",
                "Accept":           "text/html; charset=utf-8",
                "X-CSRF-Token":     document.querySelector("meta[name=csrf-token]").content
            },
            // body:        JSON.stringify({}),
            credentials: "same-origin"
        }).then(response => {
                    response.text().then(html => {
                        const fragment = document.createRange().createContextualFragment(html);

                        morphdom(document.querySelector(this.selector), fragment)
                    });
                }
        ).catch(err => {

        });
    }

    get selector() {
        return this.data.get("selector");
    }

    get path() {
        return this.data.get("path");
    }

}
