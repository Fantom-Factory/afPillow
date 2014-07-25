
** Place on a page method to mark it as an Event.
facet class PageEvent { 
	
	** The name of the event. This appears in client URLs.
	** 
	** Defaults to the event method name.
	const Str? name

	** The HTTP method the page event should respond to.
	** 
	** Defaults to 'GET'
	const Str httpMethod	:= "GET"

}
