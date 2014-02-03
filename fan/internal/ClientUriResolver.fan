using afIoc::Inject
using afIocConfig::Config
using afEfanXtra::EfanTemplateFinders

@NoDoc
const mixin ClientUriResolver {
	abstract Uri clientUri(Type pageType)
}

internal const class ClientUriResolverImpl : ClientUriResolver {

	new make(|This| in) { in(this) } 
	
	override Uri clientUri(Type pageType) {
		// TODO: make configurable
		if (pageType.hasFacet(PageUri#)) {
			return toUriFromPageUri(pageType)
		} else {
			return toUriFromTypeName(pageType)
		}
	}
	
	private Uri toUriFromPageUri(Type pageType) {
		pageUri := (PageUri) Type#.method("facet").callOn(pageType, [PageUri#])	// Stoopid F4
		uri		:= pageUri.uri
	    if (uri.scheme != null || uri.host != null || uri.port!= null )
			throw PillowErr(ErrMsgs.pageRouteShouldBePathOnly(pageType, uri))
	    if (!uri.isPathAbs)
			throw PillowErr(ErrMsgs.pageRouteShouldStartWithSlash(pageType, uri))
		return uri
	}
	
	private Uri toUriFromTypeName(Type pageType) {
		pageName := pageType.name
		if (pageName.endsWith("Impl"))
			pageName = pageName[0..-5]
		if (pageName.endsWith("Page"))
			pageName = pageName[0..-5]
		pageUri := pageName.toDisplayName.replace(" ", "/").lower
	
		return ("/" + pageUri).toUri
	}		
}
