
** Place on a 'EfanComponent' to define a Pillow web page.
@FacetMeta { inherited = true }
facet class Page {
	
	** By default, 'pillow' looks for a template with the same name as the page class.
	**  
	** Use this to explicitly set the location of efan template. The URI may take several forms:
	**  - if fully qualified, the template is resolved, e.g. 'fan://acmePod/templates/Notice.efan' 
	**  - if relative, the template is assumed to be on the file system, e.g. 'etc/templates/Notice.efan' 
	**  - if absolute, the template is assumed to be a pod resource, e.g. '/templates/Notice.efan'
	const Uri? template
	
}
