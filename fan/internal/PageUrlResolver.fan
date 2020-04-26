using afIoc::Inject
using afIocConfig::Config

@NoDoc
const mixin PageUrlResolver {
	abstract Uri? pageUrl(Type pageType)
}

internal const class PageUrlResolverImpl : PageUrlResolver {
	private const PageUrlResolver[] resolvers
	
	new make(PageUrlResolver[] resolvers, |This| in) { 
		in(this) 
		this.resolvers = resolvers
	} 
	
	override Uri? pageUrl(Type pageType) {
		resolvers.eachWhile { it.pageUrl(pageType) } ?: throw PillowErr(ErrMsgs.couldNotFindPageUrl(pageType))
	}
}

internal const class ResolvePageUrlFromPageFacet : PageUrlResolver {
	override Uri? pageUrl(Type pageType) {
		page := (Page) pageType.facet(Page#)
		url	 := page.url
		if (url == null)
			return null
	    if (url.scheme != null || url.host != null || url.port!= null )
			throw PillowErr(ErrMsgs.pageRouteShouldBePathOnly(pageType, url))
	    if (!url.isPathAbs)
			throw PillowErr(ErrMsgs.pageRouteShouldStartWithSlash(pageType, url))
		return url
	}
}

internal const class ResolvePageUrlFromTypeName : PageUrlResolver {
	override Uri? pageUrl(Type pageType) {
		pageName := pageType.name

		// TODO contribute page name endings?
		if (pageName.endsWith("Impl"))
			pageName = pageName[0..<-4]
		
		if (pageName.endsWith("Page"))
			pageName = pageName[0..<-4]
		
		pageUrl := pageName.toDisplayName.replace(" ", "/").lower
	
		return ("/" + pageUrl).toUri
	}
}
