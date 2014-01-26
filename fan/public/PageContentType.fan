
** Place on a `Page` mixin to define the explicit 'Content-Type' it should be serverd with. 
** This sets the 'Content-Type' in the HTTP response header.   
** 
** pre>
** using afPillow
** 
** @PageContentType { contentType=MimeType("text/plain") }
** const mixin Matrix : Page { ... }
** <pre
@FacetMeta { inherited = true }
facet class PageContentType {
	const MimeType contentType
}
