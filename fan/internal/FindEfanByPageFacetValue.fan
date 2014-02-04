using afEfanXtra::EfanTemplateFinder
using afEfanXtra::FindEfanByFacetValue

internal const class FindEfanByPageFacetValue : EfanTemplateFinder {
	
	override File? findTemplate(Type componentType) {
		if (!componentType.hasFacet(Page#))
			return null
		
		pageFacet := (Page) Type#.method("facet").callOn(componentType, [Page#])	// Stoopid F4
		return FindEfanByFacetValue.findFile(componentType, pageFacet.template)
	}

	override File[] templateFiles(Type componentType) {
		// let FindEfanByTypeNameInPod return the pod files 
		File#.emptyList
	}
}
