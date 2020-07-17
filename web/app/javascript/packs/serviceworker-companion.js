  if (navigator.serviceWorker) {
    if (navigator.serviceWorker.controller) {

    } else {
      navigator.serviceWorker
        .register("/service-worker.js", { scope: "/" })
        .then(function(registration) {
          console.log(
            "Service worker registered, scope: " + registration.scope
          );
        })
        .catch(function(error) {
          console.log("Service worker registration failed: " + error.message);
        });
    }
  }
