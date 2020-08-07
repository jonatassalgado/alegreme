// import ApplicationController from './application_controller'
// import {MDCTextField}        from "@material/textfield";
// import {MDCDialog}           from "@material/dialog";
// import {stringify}           from "query-string";
//
//
// export default class TagsController extends ApplicationController {
// 	static targets = ["dialog", "tags"];
//
// 	initialize() {
// 		const self = this;
// 	}
//
// 	openDialog() {
// 		const self        = this;
// 		self.dialog       = new MDCDialog(self.dialogTarget);
// 		self.chipsetInput = new MDCTextField(self.chipController.inputContainerTarget);
// 		self.dialog.open();
// 	}
//
// 	saveTagsSelected() {
// 		const self = this;
// 		if (self.hasTagsTarget) {
// 			const selectedTagsValues = new Promise((resolve, reject) => {
// 				const result = self.chipController.MDCChipSet.selectedChipIds.map(function (chipId) {
// 					const chipElement = self.chipController.chipsetTarget.querySelector(`#${chipId}`);
// 					return chipElement.innerText.toLowerCase();
// 				});
//
// 				resolve(result);
// 			});
//
// 			selectedTagsValues
// 				.then(function (result) {
// 					const urlWithFilters = stringify({tags:        JSON.stringify(result),
// 						                                 feature:  'tags',
// 						                                 type:     self.data.get('type'),
// 						                                 event_id: self.data.get('identifier')
// 					                                 }, {arrayFormat: 'bracket'});
//
// 					fetch(`/retrain?${urlWithFilters}`, {
// 						method:      'get',
// 						headers:     {
// 							'X-Requested-With': 'XMLHttpRequest',
// 							'Content-type':     'application/javascript; charset=UTF-8',
// 							'X-CSRF-Token':     document.querySelector('meta[name=csrf-token]').content
// 						},
// 						credentials: 'same-origin'
// 					})
// 						.then(
// 							function (response) {
// 								if (response.status !== 200) {
// 									console.log('Looks like there was a problem. Status Code: ' + response.status);
// 									return;
// 								}
//
// 								response.text().then(function (data) {
// 									eval(data);
// 								});
// 							}
// 						)
// 						.catch(function (err) {
// 							console.log('Fetch Error :-S', err);
// 						});
// 				})
// 				.catch(function (err) {
// 					console.log(err);
// 				});
// 		}
//
// 	}
//
// 	get chipController() {
// 		const self = this;
// 		return self.application.getControllerForElementAndIdentifier(
// 			self.tagsTarget,
// 			"chip"
// 		);
// 	}
// }
