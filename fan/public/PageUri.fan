
** Place on a `Page` mixin to map it to a specific uri. Page uris should start with a leading /slash/. Example:
** 
** pre>
** using afPillow
** 
** @PageUri { uri=`/matrix_explained.html` }
** const mixin Matrix : Page { ... }
** <pre
@FacetMeta { inherited = true }
facet class PageUri {
	const Uri uri
}
