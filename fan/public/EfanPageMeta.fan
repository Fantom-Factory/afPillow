using afIoc

// FIXME: rename to RenderMeta / PageRenderMeta?
** (Service) - Holds info about the current rendering page.
** This class name is likely to change.
const mixin EfanPageMeta {
	
	abstract Page activePage()

	abstract Void setActivePage(Page page)
}

const class EfanPageMetaImpl : EfanPageMeta {
	
	private const ThreadStash stash
	
	new make(ThreadStashManager stashManager) {
		stash = stashManager.createStash("PageMeta")
	}
	
	override Page activePage() {
		// TODO: better err mesg
		stash["activePage"] ?: throw Err("Wot no Active Page?")
	}

	override Void setActivePage(Page page) {
		stash["activePage"] = page
	}	
}
