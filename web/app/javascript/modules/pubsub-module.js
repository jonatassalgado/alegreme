import NanoEvents from "nanoevents";

const PubSubModule = (() => {
	const module = {};

	module.init = () => {
		module.activePubSub();
		console.log("[PUBSUB]: started");
	};

	module.activePubSub = () => {
		window.PubSubModule = new NanoEvents();
	};

	return module;
})();

export {PubSubModule};


