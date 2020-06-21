import ApplicationController from './application_controller'
import {MDCRipple}           from '@material/ripple';

export default class BottonController extends ApplicationController {
	static targets = ['button'];

	initialize() {

		if (this.hasButtonTarget) {
			this.buttonRipple = new MDCRipple(this.buttonTarget);
		}

		this.destroy = () => {
			if (this.hasButtonTarget) {
				this.buttonRipple.destroy();
			}
		};

	}

	disconnect() {
		this.destroy;
	}

}
