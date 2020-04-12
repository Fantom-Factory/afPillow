using afIoc::Inject
using afBedSheet::RouteMatch
using afBedSheet::ResponseProcessor

internal const class EventResponseProcessor : ResponseProcessor {
	@Inject private const Pages				pages
	@Inject	private const |->RouteMatch|	routeMatchFn

	new make(|This|in) { in(this)}

	override Obj process(Obj response) {
		eventRes	:= (EventResponse) response
		wildcards	:= routeMatch.wildcards
		pageCtx		:= wildcards[0..<eventRes.initParams.size]
		eventCtx	:= wildcards[eventRes.initParams.size..-1]
		pageMeta	:= pages.pageMeta(eventRes.pageType).withContext(pageCtx)
		eventMeta	:= EventMeta {
			it.pageMeta		= pageMeta
			it.eventMethod	= eventRes.eventMethod
			it.eventContext	= eventCtx 
		}
		return eventMeta
	}
	
	private RouteMatch routeMatch() { routeMatchFn() }
}
