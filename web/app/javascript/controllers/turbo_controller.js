import ApplicationController from "./application_controller"

export default class extends ApplicationController {
    static targets = [];
    static values  = {
        url:           String,
        historyAction: String,
    }

    initialize() {
        if (this.historyActionValue == null) this.historyActionValue = 'replace'
    }

    connect() {
        super.connect()
        this.setup()
    }

    beforeCache() {
        super.beforeCache();
        this.teardown();
    }

    disconnect() {
        super.disconnect();
        this.teardown();
    }

    setup() {
    }

    teardown() {
    }


    stream(event) {
        event.preventDefault()
        const self          = this
        const currentTarget = event.currentTarget

        if (self.loading) return
        self.loading = true

        fetch(currentTarget.href, {
            method:      "get",
            headers:     {
                "Accept":       "text/vnd.turbo-stream.html",
                "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content
            },
            credentials: "same-origin"
        }).then(r => r.text())
          .then(html => {
              self.loading = false
              Turbo.renderStreamMessage(html);
              if (self.historyActionValue === 'replace') history.replaceState(history.state, "", currentTarget.href)
              if (self.historyActionValue === 'push') history.pushState(history.state, "", currentTarget.href)

              window.dataLayer = window.dataLayer || [];
              window.dataLayer.push({
                                        event:     "virtualPageview",
                                        pageUrl:   currentTarget.href,
                                        pageTitle: currentTarget.dataset.title
                                    });
          })
          .catch(err => {

          });
    }

}
