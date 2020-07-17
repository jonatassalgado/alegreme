import ApplicationController from "./application_controller"
import {MDCTabBar}           from "@material/tab-bar";

export default class TabBarController extends ApplicationController {
    static targets = ["tabBar", "scroller"];

    connect() {
        super.connect();
        this.setup();
    }

    beforeCache() {
        super.beforeCache();
        this.teardown();
    }

    disconnect() {
        super.disconnect();
        this.teardown();
    }

    setup() {
        this.MDCTabBar    = new MDCTabBar(this.tabBarTarget);
        this.setActiveTab = this.currentAction;
    }

    teardown() {
        this.MDCTabBar.tabList_.forEach((tab) => {
            tab.deactivate();
        })
        this.MDCTabBar.destroy();
    }

    open(event) {
        setTimeout(() => {
            Turbolinks.visit(event.target.parentElement.dataset.tabPath);
        }, 150)
    }

    set setActiveTab(value) {
        if (value) {
            const currentTab = this.MDCTabBar.tabList_.filter((tab) => {
                return tab.root_.attributes["data-section"].value == value;
            })[0]

            if (currentTab) {
                currentTab.activate()
            }
        }
    }

    get currentAction() {
        return `${document.body.dataset.controller}#${document.body.dataset.action}`
    }

    get isPreview() {
        return document.documentElement.hasAttribute("data-turbolinks-preview");
    }

}
