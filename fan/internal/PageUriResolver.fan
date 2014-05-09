using afIoc::Inject
using afIocConfig::Config

@NoDoc
const mixin PageUriResolver {
	abstract Uri? pageUri(Type pageType)
}

internal const class PageUriResolverImpl : PageUriResolver {
	private const PageUriResolver[] resolvers
	
	new make(PageUriResolver[] resolvers, |This| in) { 
		in(this) 
		this.resolvers = resolvers
	} 
	
	override Uri? pageUri(Type pageType) {
		resolvers.eachWhile { it.pageUri(pageType) } ?: throw PillowErr(ErrMsgs.couldNotFindPageUri(pageType))
	}
}

internal const class ResolvePageUriFromPageFacet : PageUriResolver {
	override Uri? pageUri(Type pageType) {
		page := (Page) Type#.method("facet").callOn(pageType, [Page#])	// Stoopid F4
		uri	 := page.uri
		if (uri == null)
			return null
	    if (uri.scheme != null || uri.host != null || uri.port!= null )
			throw PillowErr(ErrMsgs.pageRouteShouldBePathOnly(pageType, uri))
	    if (!uri.isPathAbs)
			throw PillowErr(ErrMsgs.pageRouteShouldStartWithSlash(pageType, uri))
		return uri		
	}
}

internal const class ResolvePageUriFromTypeName : PageUriResolver {
	override Uri? pageUri(Type pageType) {
		pageName := pageType.name

		// TODO: contribute page name endings?
		if (pageName.endsWith("Impl"))
			pageName = pageName[0..-5]
		
		if (pageName.endsWith("Page"))
			pageName = pageName[0..-5]
		
		pageUri := pageName.toDisplayName.replace(" ", "/").lower
	
		return ("/" + pageUri).toUri
	}
}
