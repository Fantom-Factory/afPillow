using afIoc
using afBedSheet

const class PageMetaResponseProcessor : ResponseProcessor {
	@Inject private const Pages pages
	
	new make(|This|in) { in(this) }
	
	override Obj process(Obj response) {
		pageMeta := (PageMeta) response
		return pages.renderPageMeta(pageMeta)
	}
}
