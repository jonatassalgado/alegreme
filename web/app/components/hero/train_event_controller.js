import ApplicationController from "../../javascript/controllers/application_controller"

export default class extends ApplicationController {
    static targets = [];

    connect() {
        super.connect();
        this.setup();
    }

    async setup() {
        const Velocity = await import('velocity-animate');
    }

    teardown() {

    }

    beforeCache() {

    }

    disconnect() {
        super.disconnect();
        this.teardown()
    }

    beforeLike() {
        this._animateHide(this.element);
    }

    afterLike() {
        this._updateSwipable()
    }

    beforeDislike() {
        this._animateHide(this.element);
    }

    afterDislike() {
        this._updateSwipable()
    }

    _updateSwipable() {
        const swipable = document.querySelector('#swipable')
        if (swipable) {
            this.stimulate('Hero::SwipableComponent#update', swipable, {
                event_id: this.id
            })
                .then(payload => {

                })
                .catch(payload => {

                })
        }
    }

    _animateHide(element) {
        Velocity(element, {opacity: 0})
            .then(value => {
                setTimeout(() => {
                    element.classList.add('hidden')
                }, 250)
            }, reason => {

            })
    }

    get id() {
        return this.data.get('id')
    }

}
