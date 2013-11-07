using afEfanExtra::Component

** Your web pages should extend this!
@Component
const mixin Page {
	
	** Returns the Uri that is used to route requests to your page.
	** Use it to print links to your page:
	** 
	** Efan snippet:
	** pre>
	** <a href="<% pages[MyPage#].clientUri %>"> My Awesome Page </a>
	** <pre  
	Uri clientUri() {
		// TODO: get PageMeta this from a service
		
		pageType := typeof
		pageName := pageType.name
		if (pageName.endsWith("Impl"))
			pageName = pageName[0..-5]
		if (pageName.endsWith("Page"))
			pageName = pageName[0..-5]
		pageUri := pageName.toDisplayName.replace(" ", "/").lower
	
		// TODO: add extra mod path to uris
		// TODO: add passivate info to uris
		return ("/" + pageUri).toUri
	}
	
}
