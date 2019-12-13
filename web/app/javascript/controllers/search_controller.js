import {Controller}     from "stimulus"

export default class SearchController extends Controller {
	static targets = ['search', 'input', 'submit'];

	initialize() {

		this.destroy = () => {

		};

		document.addEventListener('turbolinks:before-cache', this.destroy, false);
	}

	disconnect() {
		document.removeEventListener('turbolinks:before-cache', this.destroy, false);
	}

  searching() {
    this.inputTarget.attr('readonly', 'readonly');
    this.inputTarget.attr('disabled', 'true');
    setTimeout(function() {
        this.inputTarget.blur();
        this.inputTarget.removeAttr('readonly');
        this.inputTarget.removeAttr('disabled');
    }, 100);
  }

}
