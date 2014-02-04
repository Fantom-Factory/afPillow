using afIoc::Inject
using afEfanXtra::EfanComponent

// TODO: kill me and replace with a facet
** Extend to define a web page.
const mixin Page : EfanComponent {
	
	@NoDoc
	@Inject abstract Pages _af_pages

	** Returns the Uri that is used to route requests to your page.
	** Use it to print links to your page:
	** 
	** Efan snippet:
	** pre>
	** <a href="<% pages[MyPage#].clientUri %>"> My Awesome Page </a>
	** <pre  
//	Uri clientUri() {
//		_af_pages.pageMeta(typeof).clientUri
//	}
	
}
