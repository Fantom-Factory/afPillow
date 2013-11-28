using afIoc::Inject
using afIocConfig::Config
using afBedSheet::HttpPipeline
using afBedSheet::HttpPipelineFilter
using afBedSheet::HttpRequest
using afBedSheet::ResponseProcessors
using afBedSheet::Text
using afBedSheet::Redirect
using afEfanExtra::EfanExtra
using afIoc

internal const class PagePipeline : HttpPipelineFilter {
		
	@Inject	private const HttpRequest 			httpReq
	@Inject	private const EfanExtra				efanExtra
	@Inject	private const ResponseProcessors	responseProcessors
	@Inject	private const Pages					pages
	@Inject	private const EfanPageMeta			efanPageMeta

//	Bool isWelcomePage(Type pageType) {
//		clientUri := clientUri(pageType)
//		if (clientUri.isDir)
//			return false
//		return clientUri.name.equalsIgnoreCase(welcomePage.name)
//	}
	
	// TODO: assert welcomepage does not start with /
//	@Config { id="afEfan.welcomePage" }
//	@Inject private const Str 		welcomePage

	
	new make(|This|in) { in(this) }
	
	override Bool service(HttpPipeline handler) {
		url := httpReq.modRel.pathOnly
		pageType := pages.getTypeByUri(url) 
		if (pageType == null)
			return noHandle(handler)

		
		// redirect welcome pages to directory
//		nameMatch := page.clientUri.name.equalsIgnoreCase(welcomePage)
		if (!url.isDir && pages.isWelcomePage(pageType)) {
			redirect := Redirect.movedTemporarily(url.parent)
			responseProcessors.processResponse(redirect)
			return true
		}

		page := pages[pageType]
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
