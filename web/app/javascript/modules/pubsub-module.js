// import NanoEvents from "nanoevents";
//
// const PubSubModule = (() => {
//     const debug  = false;
//
//     const nanoEvents = new NanoEvents();
//     if (debug) console.log("[PUBSUB]: started");
//
//     return {
//         destroy: (subscriptions) => {
//             Object.entries(subscriptions).forEach(subscription => {
//                 if (typeof subscription[1] == "function") subscription[1]()
//             })
//         },
//         emit:    (e) => {
//             return nanoEvents.emit(e)
//         },
//         on: (e, cb) => {
//             return nanoEvents.on(e, cb)
//         }
//     };
// })();
//
// export {PubSubModule};
//
//
