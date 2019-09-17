const UILandingBot = class UILandingBot {
	constructor(node) {
		this.domNode = node;
		this.domNode.classList.add('.is-bot');
	}

	createContainer({human, cssClass, delay, resolve}) {
		var container = document.createElement('div');

		container.className       = `me-bot__container ${
			human ? 'is-human' : 'is-bot'
		} ${cssClass}`;
		container.style.opacity   = 0;
		container.style.transform = `translateX(${human ? "" : "-"}8%)`;

		setTimeout(() => {
			this.domNode.appendChild(container);
		}, 50);

		setTimeout(() => {
			requestAnimationFrame(() => {
				container.style.opacity   = 1;
				container.style.transform = 'translateX(0)';
				if (resolve) {
					console.log(resolve);
					resolve(container);
				}
			});
		}, delay || 100);

		return container;
	}

	message({content, cssClass, delay, human}) {
		return new Promise((resolve, reject) => {
			var container = this.createContainer({human, cssClass, delay, resolve});

			var message       = document.createElement('div');
			message.className = `me-bot__message ${
				human ? 'is-human' : 'is-bot'
			} ${cssClass}`;

			requestAnimationFrame(() => {
				message.innerHTML = content;
				container.appendChild(message);

				this.scrollToEnd();
			});
		});
	}

	scrollToEnd() {
		setTimeout(() => {
			const onboardingEl = document.querySelector('.me-swipable__onboarding');
			document.documentElement.style.scrollBehavior = 'smooth';
			window.scrollTo(0, onboardingEl.scrollHeight);
			document.documentElement.style.scrollBehavior = '';
		}, 300);
	}

	action(obj) {
		return this[`${obj.type}Action`](obj);
	}

	buttonAction({items, delay, human, cssClass}) {
		return new Promise((resolve, reject) => {
			var container = this.createContainer({
				human,
				delay,
				cssClass: "no-icon"
			});
			// container.style.position = 'absolute';

			// var form       = document.createElement("form");
			// form.className = `me-bot__action ${human ? "human" : "bot"} ${cssClass}`;
			// form.addEventListener('submit', e => e.preventDefault);

			items.forEach(item => {
				var button       = document.createElement("button");
				button.className = `me-bot__button ${item.cssClass} me-button mdc-button mdc-button--raised`;
				button.type      = 'button';
				button.innerHTML = item.text;
				button.addEventListener("click", () => {
					resolve(item.value);
					container.style.opacity = 0;
					setTimeout(() => this.domNode.removeChild(container), 300);
				});
				container.appendChild(button);
				this.scrollToEnd();
			});

			// container.appendChild(form);
		});
	}
};

export {UILandingBot};