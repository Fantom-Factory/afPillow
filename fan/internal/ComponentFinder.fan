using afIoc::Inject
using afEfanXtra::Abstract
using afEfanXtra::EfanComponent
using afEfanXtra::ComponentFinder

internal const class ComponentFinderImpl : ComponentFinder {
	override Type[] findComponentTypes(Pod pod) {
		components := pod.types.findAll { it.fits(EfanComponent#) && !it.hasFacet(Abstract#) }
		
		// we filter out pillow pages so they don't appear as app.renderXXXX() methods 
		return components.exclude { it.hasFacet(Page#) }
	}
}

internal const class PageFinder {
	Type[] findPageTypes(Pod pod) {
		components := pod.types.findAll { it.fits(EfanComponent#) && !it.hasFacet(Abstract#) }
		return components.findAll { it.hasFacet(Page#) }
	}
}
