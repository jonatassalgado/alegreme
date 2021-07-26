import ApplicationController from "./application_controller"

export default class extends ApplicationController {
    static targets = ['pagination'];
    static values  = {}

    initialize() {
        let options = {
            rootMargin: '200px',
        }

        this.intersectionObserver = new IntersectionObserver(entries => this.processIntersectionEntries(entries), options)
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
        if (this.hasPaginationTarget) this.intersectionObserver.observe(this.paginationTarget)
    }

    teardown() {
        if (this.hasPaginationTarget) this.intersectionObserver.unobserve(this.paginationTarget)
    }

    processIntersectionEntries(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                this.loadMore()
            }
        })
    }

    loadMore() {
        if (this.loading) return
        this.loading = true

        let next_page = this.paginationTarget.querySelector("a[rel='next']")
        if (!next_page) return
        let url = next_page.href

        fetch(url, {
            method:      "get",
            headers:     {
                "Accept":       "text/vnd.turbo-stream.html",
                "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content
            },
            credentials: "same-origin"
        }).then(r => r.text())
          .then(html => {
              this.loading = false
              Turbo.renderStreamMessage(html);
              setTimeout(() => {
                  document.dispatchEvent(new Event('feed#size-change:after'))
              }, 150)
          })
            // .then(_ => history.replaceState(history.state, "", href))
          .catch(err => {

          });
    }

}
