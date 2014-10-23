using afIoc
using afBedSheet
using afBeanUtils
using web::WebUtil

** (Service) - Returns details about the Pillow page currently being rendered.
** 
** 'PageMeta' objects may also be created by the `Pages` service.
mixin PageMeta {

	** Returns the page that this Meta object wraps.
	abstract Type pageType()

	** Returns the context used to initialise this page.
	abstract Obj?[] pageContext()

	** Returns a client URL that can be used to render the given page. 
	** The URL takes into account:
	**  - Any welcome URL -> home page conversions
	**  - The context used to render this page
	**  - Any parent 'WebMods'
	abstract Uri pageUrl()

	** Returns the 'Content-Type' produced by this page.
	** 
	** Returns `PillowConfigIds#defaultContentType` if it can not be determined.
	abstract MimeType contentType()
	
	** Returns 'true' if the page is a welcome page.
	abstract Bool isWelcomePage()

	** Returns the HTTP method this page responds to.
	abstract Str httpMethod()

	** Returns 'true' if BedSheet route generation has been disabled for this page.
	abstract Bool disableRoutes()

	** Returns a client URL for a given event - use to create client side URIs to call the event.
	** 
	** 'event' may be either a: 
	**  - 'Str' - the name of the event (*not* the name of the method)
	**  - 'Method' - the event method itself 
	abstract Uri eventUrl(Obj event, Obj?[]? eventContext := null)

	** Returns a new 'PageMeta' with the given page context.
	abstract PageMeta withContext(Obj?[]? pageContext)
	
	** Returns all the event methods on the page.
	abstract Method[] eventMethods()

	@NoDoc
	abstract Uri pageGlob()
	
	@NoDoc
	abstract Uri eventGlob(Method eventMethod)

	@NoDoc
	abstract InitRenderMethod initRender()	
}

internal class PageMetaImpl : PageMeta {

	internal 		BedSheetServer	bedServer
	internal 		HttpRequest		httpRequest
	internal 		ValueEncoders	valueEncoders
	private const 	PageMetaState	pageState
	override 		Obj?[]			pageContext
	
	internal new make(PageMetaState pageState, Obj?[]? pageContext, |This|in) {
		in(this)
		this.pageState		= pageState
		this.pageContext 	= pageContext ?: Obj#.emptyList
	}
	
	override Type pageType() {
		pageState.pageType
	}

	override Uri pageUrl() {
		clientUrl := pageState.pageBaseUri

		// add extra WebMod path info
		clientUrl = bedServer.toClientUrl(clientUrl)

		// validate args
		if (pageContext.size < initRender.minNoOfArgs || pageContext.size > initRender.paramTypes.size)
			throw ArgErr(ErrMsgs.invalidNumberOfPageArgs(pageType, initRender.minNoOfArgs, initRender.paramTypes.size, pageContext))		

		// append page context
		if (!pageContext.isEmpty)
			clientUrl = clientUrl.plusSlash + ctxToUri(pageContext)

		return clientUrl
	}
	
	override MimeType contentType() {
		pageState.contentType
	}
	
	override Bool isWelcomePage() {
		pageState.isWelcomePage
	}

	override Str httpMethod() {
		pageState.httpMethod
	}

	override Bool disableRoutes() {
		pageState.disableRoutes
	}
	
	override Uri eventUrl(Obj event, Obj?[]? eventContext := null) {
		eventMethod := (Method?) null

		if (event isnot Str && event isnot Method)
			throw ArgErr(ErrMsgs.eventTypeNotKnown(event))
		
		if (event is Method) {
			eventMethod = (Method) event
			if (!eventMethods.contains(eventMethod))
				throw ArgNotFoundErr(ErrMsgs.eventNotFound(pageType, eventMethod.name), eventMethods.map { pageEventName(it) })
		}

		if (event is Str) {
			eventName := (Str) event
			eventMethod 
				= eventMethods.find { eventName.equalsIgnoreCase(pageEventName(it)) }
				?: throw ArgNotFoundErr(ErrMsgs.eventNotFound(pageType, eventName), eventMethods.map { pageEventName(it) })
		}
		
		// validate args
		evtCtxSize  := eventContext?.size ?: 0
		minNoOfArgs := eventMethod.params.reduce(0) |Int tot, param->Int| { param.hasDefault ? tot : tot++ }
		if (evtCtxSize < minNoOfArgs || evtCtxSize > eventMethod.params.size)
			throw ArgErr(ErrMsgs.invalidNumberOfEventArgs(eventMethod, minNoOfArgs, eventMethod.params.size, eventContext))		
		
		eventName := pageEventName(eventMethod)
		eventUrl := pageUrl
		if (!eventName.isEmpty)
			eventUrl = eventUrl.plusSlash + Uri.fromStr(encodeUri(eventName))
		if (eventContext != null && !eventContext.isEmpty)
			eventUrl = eventUrl.plusSlash + ctxToUri(eventContext)
		return eventUrl
	}

	override PageMeta withContext(Obj?[]? pageContext) {
		PageMetaImpl(pageState, pageContext) {
			it.bedServer 	 = this.bedServer
			it.httpRequest 	 = this.httpRequest
			it.valueEncoders = this.valueEncoders
		}
	}
	
	override Method[] eventMethods() {
		pageState.eventMethods
	}

	override Uri pageGlob() {
		pageState.pageGlob
	}
	
	override Uri eventGlob(Method eventMethod) {
		eventName	:= pageEventName(eventMethod)
		
		eventCtx := ""
		hasDefs := false
		eventMethod.params.each {
			if (!hasDefs)
				if (it.hasDefault) {
					eventCtx += "/?**"
					hasDefs = true
				} else
					eventCtx += "/*"
		}

		eventGlob := pageGlob
		if (!eventName.isEmpty)
			eventGlob = eventGlob.plusSlash + Uri.fromStr(encodeUri(eventName))
		if (!eventCtx.isEmpty)
			eventGlob = eventGlob.plusSlash + eventCtx.toUri.relTo(`/`)
		
		return eventGlob
	}
	
	override InitRenderMethod initRender() {
		pageState.initRender
	}
	
	override Str toStr() {
		pageUrl.toStr
	}
	
	private Uri ctxToUri(Obj?[] context) {
		((Uri) context.reduce(``) |Uri url, obj -> Uri| { url.plusSlash.plus(encodeObj(obj)) }).relTo(`/`)
	}
	
	internal static Obj? push(PageMeta pageMeta, |->Obj?| f) {
		ThreadStack.pushAndRun("afPillow.renderingPageMeta", pageMeta, f)
	}
	
	internal static PageMeta? peek(Bool checked) {
		ThreadStack.peek("afPillow.renderingPageMeta", false) ?: (checked ? throw PillowErr(ErrMsgs.renderingPageMetaNotRendering) : null)
	}

	private Uri encodeObj(Obj? obj) {
		if (obj == null)
			return ``	// null is usually represented by an empty string
		str := valueEncoders.toClient(obj.typeof, obj)
		return Uri.fromStr(encodeUri(str))
	}

	private static const Int[] delims := ":/?#[]@\\".chars

	// Encode the Str *to* URI standard form
	// see http://fantom.org/sidewalk/topic/2357
	private static Str encodeUri(Str str) {
		buf := StrBuf(str.size + 8) // allow for 8 escapes
		str.chars.each |char| {
			if (delims.contains(char))
				buf.addChar('\\')
			buf.addChar(char)
		}
		return buf.toStr
	}
	
	private static Str pageEventName(Method method) {
		pageEvent := (PageEvent) Method#.method("facet").callOn(method, [PageEvent#])	// Stoopid F4
		if (pageEvent.name != null)
			return pageEvent.name
		eventName := method.name
		if (eventName.startsWith("on"))
			eventName = eventName[2..-1].decapitalize
		return eventName
	}
}

