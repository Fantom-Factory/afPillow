using afIoc

** (Service) - Returns details about the page that is currently being rendered.
const mixin RenderingPageMeta {
	
	** Returns the current rendering page.
	abstract Page page()

	** Returns the component type of the currently rendering page. 
	** Note this is NOT the generated implementation type as returned by 'page().typeof'. 
	abstract Type pageType()

}

internal const class RenderingPageMetaImpl : RenderingPageMeta {
	
	private static const Str stackId	:= "afPillow.activePageType"
	
	override Page page() {
		state := (RenderingPageMetaState) (ThreadStack.peek(stackId, false) ?: throw PillowErr(ErrMsgs.renderingPageMetaNotRendering)) 
		return state.page
	}

	override Type pageType() {
		state := (RenderingPageMetaState) (ThreadStack.peek(stackId, false) ?: throw PillowErr(ErrMsgs.renderingPageMetaNotRendering)) 
		return state.type
	}

	static Obj? pushRenderingPage(Page page, Type pageType, |->Obj?| f) {
		state := RenderingPageMetaState() { it.page = page; it.type = pageType}
		return ThreadStack.pushAndRun(stackId, state, f)
	}
	
	static RenderingPageMetaState? peek() {
		ThreadStack.peek(stackId, false)
	}
}

internal const class RenderingPageMetaState {
	const Page page
	const Type type
	new make(|This|in) { in(this) }
}