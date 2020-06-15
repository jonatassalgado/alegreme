import {Controller} from "stimulus";
import {MDCChipSet} from '@material/chips';


export default class FormController extends Controller {
	static targets = ['form', 'chip-set'];

	initialize() {

    this.setInitialState = true;

		this.destroy = () => {

		};

	}

	disconnect() {
		this.destroy;
	}

  addField(e) {
    const actionButton = e.target;
    const list         = actionButton.closest(".me-form__list");
    const listGroup    = actionButton.closest(".me-form__list-group");
    const index        = Number.parseInt(listGroup.dataset.listGroupIndex);
    const next_index   = index + 1;

    list.querySelectorAll('.me-form__add-field-button').forEach((item, i) => {
      item.style.display = 'none';
    });

    const duplicatedListGroup                  = listGroup.cloneNode(true);
    duplicatedListGroup.dataset.listGroupIndex = duplicatedListGroup.dataset.listGroupIndex.replace(index, next_index);

    let promises = [];
    duplicatedListGroup.querySelectorAll('.me-form__list-item').forEach((item) => {
      promises.push(new Promise((resolve, reject) => {
        item.name  = item.name.replace(index, next_index);
        item.id    = item.id.replace(index, next_index);
        item.value = ''
        resolve(item)
      }))
    });

    Promise.all(promises).then((items) => {
      const promise = new Promise((resolve, reject) => {
        list.appendChild(duplicatedListGroup);
        resolve(list);
      })

      promise.then((list) => {
        list.lastElementChild.querySelector('.me-form__add-field-button').style.display = '';
      })
    });
  }

  removeField(e) {
    const actionButton = e.target;
    const list         = actionButton.closest(".me-form__list");
    const listGroup    = actionButton.closest(".me-form__list-group");

    const promise = new Promise((resolve, reject) => {
      listGroup.remove();
      resolve(list);
    })

    promise.then((list) => {
      list.lastElementChild.querySelector('.me-form__add-field-button').style.display = '';
    })
  }

  set setInitialState(value) {
    if (value) {
      if (this.hasFormTarget) {
        this.formTarget.querySelectorAll(".me-form__list").forEach((list, i) => {
          list.lastElementChild.querySelector('.me-form__add-field-button').style.display = '';
        });
      }
			if (this.hasChipSetTarget) {
				this.chipSetTargets.forEach((chipSet, i) => {
					this.chipSets = new MDCChipSet(chipSet);
				});
			}
    }
  }

}
