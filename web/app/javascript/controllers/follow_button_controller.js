import ApplicationController from "./application_controller"
import morphdom              from "morphdom";

export default class FollowButtonController extends ApplicationController {
    static targets = [];

    initialize() {

    }

    disconnect() {

    }

    follow() {
        fetch(`${location.pathname}/${this.action}`, {
            method:      "post",
            headers:     {
                "X-Requested-With": "XMLHttpRequest",
                "Content-type":     "application/json; charset=UTF-8",
                "Accept":           "text/html; charset=utf-8",
                "X-CSRF-Token":     document.querySelector("meta[name=csrf-token]").content
            },
            credentials: "same-origin"
        }).then(response => {
                    response.text().then(html => {
                        const fragment = document.createRange().createContextualFragment(html);

                        morphdom(this.element, fragment)
                    });
                }
        ).catch(err => {

        });
    }

    get followable() {
        return this.data.get("followable");
    }

    get action() {
        return this.data.get("followed") === "true" ? "unfollow" : "follow";
    }

    get identifier() {
        return this.data.get("identifier");
    }

}
