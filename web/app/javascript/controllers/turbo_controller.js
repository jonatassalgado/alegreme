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
        const self = this
        const href = event.currentTarget.href

        if (self.loading) return
        self.loading = true

        fetch(href, {
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
              if (self.historyActionValue === 'replace') history.replaceState(history.state, "", href)
              if (self.historyActionValue === 'push') history.pushState(history.state, "", href)
          })
          .catch(err => {

          });
    }

}
