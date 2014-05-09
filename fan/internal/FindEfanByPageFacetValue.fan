using afIoc
using afEfanXtra

internal const class FindEfanByPageFacetValue : TemplateFinder {
	@Inject	private const Registry	registry

	new make(|This|in) { in(this) }

	override TemplateSource? findTemplate(Type componentType) {
		if (!componentType.hasFacet(Page#))
			return null
		
		pageFacet := (Page) Type#.method("facet").callOn(componentType, [Page#])	// Stoopid F4
		templateFile := FindEfanByFacetValue.findFile(componentType, pageFacet.template)
		return templateFile == null ? null : registry.autobuild(TemplateSourceFile#, [templateFile])
	}

	override Uri[] templates(Type componentType) {
		// let FindEfanByTypeNameInPod return the pod files 
		Uri#.emptyList
	}
}
