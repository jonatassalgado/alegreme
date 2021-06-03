import ApplicationController from './application_controller'

export default class SearchController extends ApplicationController {
	static targets = ['search', 'input', 'submit'];

	initialize() {

		this.destroy = () => {

		};

		document.addEventListener('turbo:before-cache', this.destroy, false);
	}

	disconnect() {
		document.removeEventListener('turbo:before-cache', this.destroy, false);
	}

	searching() {
		// this.inputTarget.attr('readonly', 'readonly');
		// this.inputTarget.attr('disabled', 'true');
		// setTimeout(function () {
		// 	this.inputTarget.blur();
		// 	this.inputTarget.removeAttr('readonly');
		// 	this.inputTarget.removeAttr('disabled');
		// }, 100);
	}

}
