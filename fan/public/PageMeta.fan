using afIoc::Inject
using afBedSheet::ValueEncoders
using afBedSheet::HttpRequest
using concurrent::Actor

** (Service) - Returns details about the Pillow page currently being rendered.
** 
** 'PageMeta' objects may also be created by the `Pages` service.
class PageMeta {

	internal 		HttpRequest		httpRequest
	internal 		ValueEncoders	valueEncoders
	private const 	PageMetaState	pageState
	private 		Obj?[]			pageCtx
	
	internal new make(PageMetaState pageState, Obj?[]? pageContext, |This|in) {
		in(this)
		this.pageState	= pageState
		this.pageCtx 	= pageContext ?: Obj#.emptyList
	}
	
	** Returns the page that this Meta object wraps.
	Type pageType() {
		pageState.pageType
	}

	** Returns the context used to initialise this page.
	Obj?[] pageContext() {
		pageCtx
	}

	** Returns a URI that can be used to render the given page. 
	** The URI takes into account:
	**  - Any welcome URI -> home page conversions
	**  - The context used to render this page
	**  - Any parent 'WebMods'
	Uri pageUri() {
		clientUri := pageState.pageBaseUri

		// add extra WebMod paths - but only if we're part of a web request!
		if (Actor.locals["web.req"] != null && httpRequest.modBase != `/`)
			clientUri = httpRequest.modBase + clientUri.toStr[1..-1].toUri

		// append page context
		contextTypes := contextTypes
		if (contextTypes.size != pageContext.size)
			throw Err(ErrMsgs.invalidNumberOfInitArgs(pageType, contextTypes, pageContext))
		if (!contextTypes.isEmpty)
			clientUri = clientUri.plusSlash + ctxToUri(pageContext)

		return clientUri
	}
	
	** Returns the 'Content-Type' produced by this page.
	** 
	** Returns `PillowConfigIds#defaultContextType` if it can not be determined.
	MimeType contentType() {
		pageState.contentType
	}
	
	** Returns 'true' if the page is a welcome page.
	Bool isWelcomePage() {
		pageState.isWelcomePage
	}

	** Returns a URI for a given event - use to create client side URIs to call the event.
	Uri eventUri(Str eventName, Obj?[]? eventContext) {
		eventMethod(eventName)		
		eventUri 	:= pageUri.plusSlash + `${eventName}`
		if (eventContext != null)
			eventUri = eventUri.plusSlash + ctxToUri(eventContext)
		return eventUri		
	}

	** Returns a new 'PageMeta' with the given page context.
	PageMeta withContext(Obj?[]? pageContext) {
		PageMeta(pageState, pageContext) {
			it.httpRequest 	 = this.httpRequest
			it.valueEncoders = this.valueEncoders
		}
	}
	
	Str httpMethod() {
		pageState.httpMethod
	}
	
	@NoDoc
	Uri serverGlob() {
		pageState.serverGlob
	}
	
	@NoDoc
	Uri eventGlob(Method eventMethod) {
		eventStr	:= eventMethod.name
		noOfParams 	:= 	eventMethod.params.size
		noOfParams.times { eventStr += "/*" }
		return eventStr.toUri
	}
	
	@NoDoc
	Type[] contextTypes() {
		pageState.contextTypes
	}
	
	** Returns 'pageUri'.
	override Str toStr() {
		pageUri.toStr
	}
	
	private Uri ctxToUri(Obj?[] context) {
		context.map { valueEncoders.toClient(it.typeof, it) ?: "" }.join("/").toUri		
	}
	
	private Method eventMethod(Str eventName) {
		pageType.methods.find { it.hasFacet(PageEvent#) && it.name.equalsIgnoreCase(eventName) } ?: throw PillowErr(ErrMsgs.eventNotFound(pageType, eventName))		
	}

	internal static Obj? push(PageMeta pageMeta, |->Obj?| f) {
		ThreadStack.pushAndRun("afPillow.renderingPageMeta", pageMeta, f)
	}
	
	internal static PageMeta? peek(Bool checked) {
		ThreadStack.peek("afPillow.renderingPageMeta", false) ?: (checked ? throw PillowErr(ErrMsgs.renderingPageMetaNotRendering) : null)
	}
}

