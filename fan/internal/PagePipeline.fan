using afIoc::Inject
using afIocConfig::Config
using afBedSheet::HttpPipeline
using afBedSheet::HttpPipelineFilter
using afBedSheet::HttpRequest
using afBedSheet::ResponseProcessors
using afBedSheet::Text
using afBedSheet::Redirect
using afEfanXtra::EfanXtra
using afIoc

// FIXME: PagePipeline -kill me!
internal const class PagePipeline : HttpPipelineFilter {
		
	@Inject	private const HttpRequest 			httpReq
	@Inject	private const EfanXtra				efanXtra
	@Inject	private const ResponseProcessors	responseProcessors
	@Inject	private const Pages					pages
	
	new make(|This|in) { in(this) }
	
	override Bool service(HttpPipeline handler) {
		url := httpReq.modRel.pathOnly
		pageType := pages.getTypeByUri(url) 
		if (pageType == null)
			return noHandle(handler)

		// redirect welcome pages to directory
		if (!url.isDir && pages.isWelcomePage(pageType)) {
			redirect := Redirect.movedTemporarily(url.parent)
			responseProcessors.processResponse(redirect)
			return true
		}

		html := pages.renderPage(pageType, Obj#.emptyList)
		text := Text.fromHtml(html)	// TODO: how do we know it's HTML? - check facet

		responseProcessors.processResponse(text)
		return true
	}

	private Bool noHandle(HttpPipeline handler) {
		handler.service
		return false
	}
}
