using afIoc::Inject
using afEfanXtra

internal const class ComponentFinderImpl : ComponentFinder {
	override Type[] findComponentTypes(Pod pod) {
		components := pod.types.findAll { it.fits(EfanComponent#) && !it.hasFacet(Abstract#) }
		components.each { if (!it.isMixin) { throw Err(ErrMsgs.componentNotMixin(it)) } } 
		components.each { if (!it.isConst) { throw Err(ErrMsgs.componentNotConst(it)) } }
		
		// we filter out pillow pages so they don't appear as app.renderXXXX() methods 
		return components.exclude { it.hasFacet(Page#) }
	}
}

internal const class PageFinder {
	Type[] findPageTypes(Pod pod) {
		components := pod.types.findAll { it.fits(EfanComponent#) && !it.hasFacet(Abstract#) }
		components.each { if (!it.isMixin) { throw Err(ErrMsgs.componentNotMixin(it)) } } 
		components.each { if (!it.isConst) { throw Err(ErrMsgs.componentNotConst(it)) } }
		return components.findAll { it.hasFacet(Page#) }
	}
}
