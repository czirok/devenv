import { BackToTop } from './BackToTop.js'
import { OffcanvasSwipe } from './OffcanvasSwipe.js'
import { ScrollAnim } from './ScrollAnim.js'

export class BlazorBody {
	OffcanvasSwipe: OffcanvasSwipe
	BackToTop: BackToTop
	ScrollAnim: ScrollAnim
	constructor() {
		this.OffcanvasSwipe = new OffcanvasSwipe()
		this.BackToTop = new BackToTop()
		this.ScrollAnim = new ScrollAnim()
	}
}

(window as any).BlazorBody = new BlazorBody()
