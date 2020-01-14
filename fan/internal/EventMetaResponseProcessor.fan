using afIoc
using afBedSheet

internal const class EventMetaResponseProcessor : ResponseProcessor {
	@Inject private const Pages pages
	
	new make(|This|in) { in(this) }
	
	override Obj process(Obj response) {
		eventMeta := (EventMeta) response
		return pages.callPageEvent(eventMeta.pageMeta.pageType, eventMeta.pageMeta.pageContext, eventMeta.eventMethod, eventMeta.eventContext)
	}
}
