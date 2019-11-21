import {Controller}     from "stimulus";
import {MDCSwitch}      from '@material/switch';
import {SnackBarModule} from "../modules/snackbar-module";

export default class NotificationController extends Controller {
	static targets = ["switch", "label", "input"];

	initialize() {
		this.MDCSwitch = new MDCSwitch(this.switchTarget);

		if (this.data.get('active') === 'true') {
			Pushy.validateDeviceCredentials().then((response) => {
				this.MDCSwitch.checked = true;
			}, (error) => {
				this.MDCSwitch.checked = false;
				this.status            = false;
			})
		} else {
			this.MDCSwitch.checked = false;
		}
	}

	disconnect() {
		this.MDCSwitch.destroy();
	}

	change(event) {
		this.status = this.MDCSwitch.checked;
	}

	set status(status) {
		Pushy.register({appId: '5db4abb3c5e2e11635961378'}).then(deviceToken => {
			const params = {
				user: {
					notifications_devices: deviceToken,
					notifications_topics : {
						all: {
							requested: true,
							active   : status
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
							if (status) {
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
		}).catch(function (err) {
			console.error(err);
			SnackBarModule.show('Algo deu errado');
		});
	}
}
