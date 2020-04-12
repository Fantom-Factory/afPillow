using concurrent::Actor

** FIXME killme! ThreadStack

internal class PageMetaCtx {
	private static const Str	localId		:= "afPillow.pageMetaCtx"

	PageMetaCtx?		parent		{ private set }
	PageMeta			pageMeta	{ private set }

	internal new make(PageMeta pageMeta) {
		this.pageMeta = pageMeta
	}
	
	Obj? runInCtx(|Obj->Obj?| func) {
		this.parent = peek(false)	// false 'cos we may be the first!
		Actor.locals[localId] = this
		try return func.call(this)
		finally {
			if (this.parent == null)
				Actor.locals.remove(localId)
			else
				Actor.locals[localId] = this.parent
			this.parent = null
		}
	}
	
	static PageMetaCtx? peek(Bool checked := true) {
		Actor.locals[localId] ?: (checked ? throw Err("Pillow is NOT currently rendering a page.") : null)		
	}
}
