using afIoc::Inject
using afBedSheet::RouteMatch
using afBedSheet::ResponseProcessor

internal const class PageResponseProcessor : ResponseProcessor {
	@Inject private const Pages				pages
	@Inject	private const |->RouteMatch|	routeMatchFn

	new make(|This|in) { in(this)}

	override Obj process(Obj response) {
		pillowRes	:= (PageResponse) response
		pageMeta	:= pages.pageMeta(pillowRes.pageType).withContext(routeMatch.wildcards)
		return pageMeta
	}
	
	private RouteMatch routeMatch() { routeMatchFn() }
}
