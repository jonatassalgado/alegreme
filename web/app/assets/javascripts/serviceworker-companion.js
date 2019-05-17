  if (navigator.serviceWorker) {
    // navigator.serviceWorker
    //   .register("/service-worker.js", { scope: "./" })
    //   .then(function(reg) {
    //     console.log("[Companion]", "Service worker registered!");
    //   });

    navigator.serviceWorker.addEventListener("message", function(event) {
      console.log("Got reply from service worker: " + event.data);
    });

    if (navigator.serviceWorker.controller) {
      console.log("Sending 'hi' to controller");
      document.addEventListener("turbolinks:load", () => {
        navigator.serviceWorker.controller.postMessage(
          'turbolinks:load'
        );
      });
      document.addEventListener("turbolinks:before-cache", () => {
        navigator.serviceWorker.controller.postMessage(
          'turbolinks:before-cache'
        );
      });
    } else {
      navigator.serviceWorker
        .register("/service-worker.js", { scope: "./" })
        .then(function(registration) {
          console.log(
            "Service worker registered, scope: " + registration.scope
          );
          if (navigator.serviceWorker.controller) {
            document.addEventListener("turbolinks:load", () => {
              navigator.serviceWorker.controller.postMessage("turbolinks:load");
            });
            document.addEventListener("turbolinks:before-cache", () => {
              navigator.serviceWorker.controller.postMessage(
                "turbolinks:before-cache"
              );
            });
          }
        })
        .catch(function(error) {
          console.log("Service worker registration failed: " + error.message);
        });
    }
  }
