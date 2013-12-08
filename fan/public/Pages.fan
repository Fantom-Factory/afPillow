using afIoc::Inject
using afIocConfig::Config
using afEfanXtra::EfanXtra

** (Service) - Holds a collection of known pages.
const mixin Pages {

	** Returns the page instance associated with the given type. 
	@Operator
	abstract Page get(Type pageType)
	
	** Returns the page type associated with the given uri.
	abstract Type? getTypeByUri(Uri uri)

	** Returns all page types.
	abstract Type[] pageTypes()
	
	** Returns 'true' if the given page type is a welcome page.
	abstract Bool isWelcomePage(Type pageType)
	
	** Returns the uri that this page maps to
	abstract Uri clientUri(Type pageType)

}

const class PagesImpl : Pages {

	@Config { id="pillow.welcomePage" }
	@Inject private const Str 		welcomePage
	@Inject	private const EfanXtra	efanXtra
			private const Str:Type	pages	// use Str as key for case insensitivity

	new make(|This| in) {
		in(this) 

		pages := Utils.makeMap(Str#, Type#)

		efanXtra.libraries.each |libName| {
			efanXtra.componentTypes(libName).findAll { (it != Page#) && it.fits(Page#) }.each {
				pages[getRawClientUri(it).toStr] = it 
			}
		}
		this.pages = pages
	}
	
	** Returns the page instance associated with the given type. 
	override Page get(Type pageType) {
		(Page) efanXtra.component(pageType)
	}
	
	override Type? getTypeByUri(Uri uri) {
		if (uri.isDir)
			uri = uri.plusName(welcomePage)
		return pages[uri.toStr]
		// TODO: throw err if not found (checked?)
	}

	override Type[] pageTypes() {
		pages.vals
	}
	
	override Uri clientUri(Type pageType) {
		clientUri := getRawClientUri(pageType)
		return clientUri.name.equalsIgnoreCase(welcomePage) ? clientUri.parent : clientUri
	}
	
	override Bool isWelcomePage(Type pageType) {
		clientUri := getRawClientUri(pageType)
		return clientUri.name.equalsIgnoreCase(welcomePage)
	}


	// ---- Private Methods --------------------------------------------------------------------------------------------	

	private Uri getRawClientUri(Type pageType) {
		// TODO: maybe contribute ClientUriResolvers
		if (pageType.hasFacet(PageRoute#)) {
			return toUriFromPageRoute(pageType)
		} else {
			return toUriFromTypeName(pageType)
		}
	}
	
	private Uri toUriFromPageRoute(Type pageType) {
		// TODO: Stoopid F4 facet()
		pageRoute 	:= (PageRoute) pageType.facets.find { it.typeof == PageRoute# }
		uri			:= pageRoute.uri
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
