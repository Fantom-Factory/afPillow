using afIoc::Inject
using afBedSheet::HttpPipeline
using afBedSheet::HttpPipelineFilter
using afBedSheet::HttpRequest
using afBedSheet::ResponseProcessors
using afBedSheet::Text
using afEfanExtra::EfanExtra
using afIoc

internal const class PagePipeline : HttpPipelineFilter {
		
	@Inject	private const HttpRequest 			httpReq
	@Inject	private const EfanExtra				efanExtra
	@Inject	private const ResponseProcessors	responseProcessors
	@Inject	private const PageFinder			pageFinder
	@Inject	private const EfanPageMeta			efanPageMeta

	new make(|This|in) { in(this) }
	
	override Bool service(HttpPipeline handler) {
		url:=httpReq.modRel.pathOnly.toStr[1..-1].toUri
		pageType:= pageFinder.findPage(url) 
		if (pageType == null)
			return noHandle(handler)

		page := (Page) efanExtra.component(pageType)
		efanPageMeta.setActivePage(page)
		
		html := efanExtra.render(pageType)
		text := Text.fromHtml(html)	// TODO: how do we know it's HTML?

		responseProcessors.processResponse(text)
		return true
	}

	private Bool noHandle(HttpPipeline handler) {
		handler.service
		return false
	}
}
