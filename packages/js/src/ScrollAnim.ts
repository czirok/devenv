export class ScrollAnim {
	private isInitialized: boolean = false
	private observer: IntersectionObserver | null = null

	constructor() {
	}

	public initialize(): boolean {
		if (this.isInitialized) {
			return false
		}

		const elems: NodeListOf<HTMLElement> = document.querySelectorAll('.anim')

		this.observer = new IntersectionObserver((entries, obs) => {
			entries.forEach((entry) => {
				if (entry.isIntersecting && entry.target instanceof HTMLElement) {
					const side = entry.target.dataset.anim ?? 'b' // default: bottom
					entry.target.classList.add(`enable-${side}`)
					obs.unobserve(entry.target)
				}
			})
		}, { threshold: 0.2 })

		elems.forEach(el => this.observer!.observe(el))

		this.isInitialized = true
		return true
	}

	public dispose(): void {
		if (this.isInitialized && this.observer) {
			this.observer.disconnect()
			this.observer = null
			this.isInitialized = false
		}
	}
}
