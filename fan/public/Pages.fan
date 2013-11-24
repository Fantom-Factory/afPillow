using afIoc::Inject
using afEfanExtra::EfanExtra

** (Service) - Holds a collection of known pages.
const class Pages {

	@Inject	private const EfanExtra	efanExtra
			private const Uri:Type	pages
	
	new make(|This| in) {
		in(this) 

		pages := Utils.makeMap(Uri#, Type#)

		efanExtra.libraries.each |libName| {
			efanExtra.componentTypes(libName).findAll { it.fits(Page#) }.each {
				pages[clientUri(it)] = it 
			}
		}
		this.pages = pages
	}
	
	** Returns the page instance associated with the given type. 
	@Operator
	Page get(Type pageType) {
		(Page) efanExtra.component(pageType)
	}
	
	Type? getTypeByUri(Uri uri) {
		return pages[uri]
		// TODO: throw err if not found (checked?)
	}
	
	Uri clientUri(Type pageType) {
		if (pageType.hasFacet(PageRoute#)) {
			// TODO: Stoopid F4 facet()
			return ((PageRoute) pageType.facets.find { it.typeof == PageRoute# }).uri
		} else {
			return toUriFromTypeName(pageType)
		}
	}

	// ---- Private Methods --------------------------------------------------------------------------------------------	

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
