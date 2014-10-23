
** Place on a page method to mark it as an Event.
** 
** If the method returns 'Void' or 'null' then the containing page is re-rendered.
** Otherwise the returned object is treated as a BedSheet response object.
facet class PageEvent { 
	
	** The name of the event. This appears in client URLs.
	** 
	** Defaults to the event method name (minus any 'on' prefix).
	const Str? name

	** The HTTP method the page event should respond to.
	** 
	** Defaults to 'GET'
	const Str httpMethod	:= "GET"

}
