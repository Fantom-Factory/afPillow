
** Place on a 'EfanComponent' to define a Pillow web page.
@FacetMeta { inherited = true }
facet class Page {
	
	** Use to map the page to a specific URI. Page URIs should start with a leading /slash/. Example:
	** 
	** pre>
	** using afEfanXtra
	** using afPillow
	** 
	** @Page { uri=`/matrix_explained.html` }
	** const mixin Matrix : EfanComponent { ... }
	** <pre
	const Uri? uri
	
	** By default, 'pillow' looks for a template with the same name as the page class.
	**  
	** Use this to explicitly set the location of efan template. The URI may take several forms:
	**  - if fully qualified, the template is resolved, e.g. 'fan://acmePod/templates/Notice.efan' 
	**  - if relative, the template is assumed to be on the file system, e.g. 'etc/templates/Notice.efan' 
	**  - if absolute, the template is assumed to be a pod resource, e.g. '/templates/Notice.efan'
	const Uri? template
	
	** Use to set an explicit 'Content-Type' the page should be served with. 
	** The 'Content-Type' is set in the HTTP response header.   
	** 
	** pre>
	** using afPillow
	** using afEfanXtra
	** 
	** @Page { contentType=MimeType("text/plain") }
	** const mixin Matrix : EfanComponent { ... }
	** <pre
	const MimeType? contentType
	
	** The HTTP method the Page should respond to.
	** 
	** Defaults to 'GET'
	const Str httpMethod	:= "GET"
}
