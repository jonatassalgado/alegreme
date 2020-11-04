import ApplicationController from "./application_controller"
import SimpleScrollbar from 'simple-scrollbar'
import 'simple-scrollbar/simple-scrollbar.css'


export default class extends ApplicationController {
    static targets = [];

    connect() {
        super.connect();
        this.setup();
    }

    beforeCache() {
        super.beforeCache();
    }

    disconnect() {
        super.disconnect();
        this.teardown()
    }

    setup() {
        this.simpleScrollbarEl = SimpleScrollbar.initEl(this.element);
    }

    teardown() {

    }

}
