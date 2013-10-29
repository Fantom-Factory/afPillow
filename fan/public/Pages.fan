using afIoc::Inject
using afEfanExtra::EfanExtra

** @Inject - 
const class Pages {

	@Inject	private const EfanExtra	efanExtra
	
	new make(|This|in) { in(this) }
	
	@Operator
	Page get(Type pageType) {
		(Page) efanExtra.component(pageType)
	}	
}
