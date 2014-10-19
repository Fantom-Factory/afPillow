using afIoc::Inject
using afBedSheet::ValueEncoders
using afBedSheet::BedSheetServer
using afBedSheet::HttpRequest
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
	**  - 'Str' - the name of the event
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
			throw ArgErr(ErrMsgs.invalidNumberOfInitArgs(pageType, initRender.minNoOfArgs, pageContext))		

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
		eventName := Str.defVal
		if (event isnot Str && event isnot Method)
			throw ArgErr(ErrMsgs.eventTypeNotKnown(event))
		
		if (event is Method) {
			method := (Method) event
			if (!method.parent.fits(pageType) && !pageType.fits(method.parent))
				throw ArgErr(ErrMsgs.eventMethodNotInPage(pageType, method))
			eventName = method.name
			pageEvent	:= (PageEvent?) Method#.method("facet").callOn(method, [PageEvent#, false])	// Stoopid F4 	
			if (pageEvent?.name != null)
				eventName = pageEvent.name
		}

		if (event is Str) {
			eventName = event
			eventMethod(eventName) // verify event exists
		}
		
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
		pageEvent	:= (PageEvent?) Method#.method("facet").callOn(eventMethod, [PageEvent#, false])	// Stoopid F4 	
		if (pageEvent == null)
			throw ArgErr("WTF: Method '${eventMethod.qname}' does not have a @${PageEvent#.name} facet.")
		
		eventStr	:= pageEvent.name ?: eventMethod.name
		
		hasDefs := false
		eventMethod.params.each {
			if (!hasDefs)
				if (it.hasDefault) {
					eventStr += "/?**"
					hasDefs = true
				} else
					eventStr += "/*"
		}
		return eventStr.toUri.relTo(`/`)
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

	private Uri encodeObj(Obj? obj) {
		if (obj == null)
			return ``
		str := valueEncoders.toClient(obj.typeof, obj) ?: Str.defVal
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
}

