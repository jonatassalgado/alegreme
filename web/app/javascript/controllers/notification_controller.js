import {Controller}     from "stimulus";
import {MDCSwitch}      from '@material/switch';
import {SnackBarModule} from "../modules/snackbar-module";

export default class NotificationController extends Controller {
	static targets = ["switch", "label"];

	initialize() {
		this.MDCSwitch = new MDCSwitch(this.switchTarget);
	}

	disconnect() {
		this.MDCSwitch.destroy();
	}

	change(event) {
		Pushy.register({appId: '5db4abb3c5e2e11635961378'}).then(deviceToken => {
			const params = {
				user: {
					notifications_devices: deviceToken,
					notifications_topics : {
						all: {
							requested: true,
							active   : event.target.checked
						}
					}
				}
			};

			fetch(`${location.origin}/users/${gon.user_id}`, {
				method     : 'PATCH',
				headers    : {
					'Content-type'    : 'application/json; charset=UTF-8',
					'Accept'          : 'application/json',
					'X-Requested-With': 'XMLHttpRequest',
					'X-CSRF-Token'    : document.querySelector('meta[name=csrf-token]').content
				},
				credentials: 'same-origin',
				body       : JSON.stringify(params)
			})
				.then(
					response => {
						response.text().then(data => {
							if (event.target.checked) {
								SnackBarModule.show('Notificações ativadas com sucesso');
							} else {
								SnackBarModule.show('Notificações desativadas');
							}
						});
					}
				)
				.catch(err => {
					SnackBarModule.show('Não foi possível ativar as notificações!');
					console.log('Fetch Error :-S', err);
				});

			// Succeeded, optionally do something to alert the user
		}).catch(function (err) {
			console.error(err);
		});
	}
}
