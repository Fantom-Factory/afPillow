using afIoc

** (Service) - Meta info about the current rendering page.
const mixin PageRenderMeta {
	
	** Returns the current rendering page.
	abstract Page activePage()

	// TODO: activePageType so we can find out which library it's from
//	abstract Page activePageType()

	@NoDoc
	abstract Void setActivePage(Page page)
}

internal const class PageRenderMetaImpl : PageRenderMeta {
	
	// FIXME: use a ThreadStack
	private const ThreadStash stash
	
	new make(ThreadStashManager stashManager) {
		stash = stashManager.createStash("afPillow.PageMeta")
	}
	
	override Page activePage() {
		// TODO: better err mesg
		stash["activePage"] ?: throw Err("Wot no Active Page?")
	}

	override Void setActivePage(Page page) {
		stash["activePage"] = page
	}	
}
