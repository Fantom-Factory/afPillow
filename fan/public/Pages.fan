using afIoc::Inject
using afEfanExtra::EfanExtra

** (Service) - Holds a collection of known pages.
const class Pages {

	@Inject	private const EfanExtra	efanExtra
	
	internal new make(|This|in) { in(this) }
	
	** Returns the page instance associated with the given type. 
	@Operator
	Page get(Type pageType) {
		(Page) efanExtra.component(pageType)
	}	
}
