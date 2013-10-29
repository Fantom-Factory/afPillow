using afEfanExtra::Component

@Component
const mixin Page {
	
//	abstract Uri clientUri
	
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
