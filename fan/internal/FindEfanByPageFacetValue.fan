using afIoc::Inject
using afIoc::Scope
using afEfanXtra::TemplateFinder
using afEfanXtra::TemplateSource
using afEfanXtra::TemplateSourceFile
using afEfanXtra::FindEfanByFacetValue

internal const class FindEfanByPageFacetValue : TemplateFinder {
	@Inject	private const Scope	scope

	new make(|This|in) { in(this) }

	override TemplateSource? findTemplate(Type componentType) {
		if (!componentType.hasFacet(Page#))
			return null
		
		pageFacet := (Page) componentType.facet(Page#)
		templateFile := FindEfanByFacetValue.findFile(componentType, pageFacet.template)
		return templateFile == null ? null : scope.build(TemplateSourceFile#, [templateFile])
	}

	override Uri[] templates(Type componentType) {
		// let FindEfanByTypeNameInPod return the pod files 
		Uri#.emptyList
	}
}
