using afIoc::Inject
using afBedSheet::ValueEncoders
using afBedSheet::BedSheetServer
using afBedSheet::HttpRequest

** (Service) - Returns details about the Pillow page currently being rendered.
** 
** 'PageMeta' objects may also be created by the `Pages` service.
class PageMeta {

	internal 		BedSheetServer	bedServer
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

	@NoDoc @Deprecated { msg="Use 'pageUrl' instead" }
	Uri pageUri() {
		pageUrl
	}

	** Returns a URI that can be used to render the given page. 
	** The URI takes into account:
	**  - Any welcome URI -> home page conversions
	**  - The context used to render this page
	**  - Any parent 'WebMods'
	Uri pageUrl() {
		clientUrl := pageState.pageBaseUri

		// add extra WebMod path info
		clientUrl = bedServer.toClientUrl(clientUrl)

		// append page context
		contextTypes := contextTypes
		if (contextTypes.size != pageContext.size)
			throw Err(ErrMsgs.invalidNumberOfInitArgs(pageType, contextTypes, pageContext))
		if (!contextTypes.isEmpty)
			clientUrl = clientUrl.plusSlash + ctxToUri(pageContext)

		return clientUrl
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

	** Returns the HTTP method this page responds to.
	Str httpMethod() {
		pageState.httpMethod
	}

	@NoDoc @Deprecated { msg="Use 'eventUrl' instead" }
	Uri eventUri(Str eventName, Obj?[]? eventContext := null) {
		eventUrl(eventName, eventContext)
	}

	** Returns a URI for a given event - use to create client side URIs to call the event.
	Uri eventUrl(Str eventName, Obj?[]? eventContext := null) {
		eventMethod(eventName)		
		eventUrl 	:= pageUrl.plusSlash + `${eventName}`
		if (eventContext != null)
			eventUrl = eventUrl.plusSlash + ctxToUri(eventContext)
		return eventUrl		
	}

	** Returns a new 'PageMeta' with the given page context.
	PageMeta withContext(Obj?[]? pageContext) {
		PageMeta(pageState, pageContext) {
			it.httpRequest 	 = this.httpRequest
			it.valueEncoders = this.valueEncoders
		}
	}
	
	** Returns all the event methods on the page.
	Method[] eventMethods() {
		pageType.methods.findAll { it.hasFacet(PageEvent#) }		
	}

	@NoDoc
	Uri serverGlob() {
		pageState.serverGlob
	}
	
	@NoDoc
	Uri eventGlob(Method eventMethod) {
		pageEvent	:= (PageEvent?) Method#.method("facet").callOn(eventMethod, [PageEvent#, false])	// Stoopid F4 	
		if (pageEvent == null)
			throw ArgErr("WTF: Method '${eventMethod.qname}' does not have a @${PageEvent#.name} facet.")
		
		eventStr	:= pageEvent.name ?: eventMethod.name
		noOfParams 	:= eventMethod.params.size
		noOfParams.times { eventStr += "/*" }
		return eventStr.toUri
	}
	
	@NoDoc
	Type[] contextTypes() {
		pageState.contextTypes
	}
	
	** Returns 'pageUrl'.
	override Str toStr() {
		pageUrl.toStr
	}
	
	private Uri ctxToUri(Obj?[] context) {
		context.map { valueEncoders.toClient(it.typeof, it) ?: "" }.join("/").toUri		
	}
	
	private Method eventMethod(Str eventName) {
		eventMethods.find |method->Bool| {
			pageEvent := (PageEvent) Method#.method("facet").callOn(method, [PageEvent#])	// Stoopid F4 	
			return eventName.equalsIgnoreCase(pageEvent.name ?: Str.defVal) || eventName.equalsIgnoreCase(method.name)  
		} ?: throw PillowErr(ErrMsgs.eventNotFound(pageType, eventName))		
	}

	internal static Obj? push(PageMeta pageMeta, |->Obj?| f) {
		ThreadStack.pushAndRun("afPillow.renderingPageMeta", pageMeta, f)
	}
	
	internal static PageMeta? peek(Bool checked) {
		ThreadStack.peek("afPillow.renderingPageMeta", false) ?: (checked ? throw PillowErr(ErrMsgs.renderingPageMetaNotRendering) : null)
	}
}

