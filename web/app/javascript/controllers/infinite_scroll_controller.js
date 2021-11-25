import ApplicationController from "./application_controller"

export default class extends ApplicationController {
    static targets = ['pagination'];
    static values  = {}

    initialize() {
        let options = {
            rootMargin: '600px',
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

        document.dispatchEvent(new Event('feed#load-more:loading'))

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
              document.dispatchEvent(new Event('feed#load-more:loaded'));
              (window.adsbygoogle = window.adsbygoogle || []).push({});
          })
            // .then(_ => history.replaceState(history.state, "", href))
          .catch(err => {

          });
    }

}
