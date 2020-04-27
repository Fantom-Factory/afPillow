using afBedSheet::BedSheetServer
using afBedSheet::HttpRequest
using afBedSheet::HttpRedirect
using afBedSheet::ValueEncoders
using afBeanUtils::ArgNotFoundErr
using web::WebUtil

** (Service) - Returns details about the Pillow page currently being rendered.
** 
** 'PageMeta' objects may also be created by the `Pages` service.
mixin PageMeta {

	** Returns the page that this Meta object wraps.
	abstract Type pageType()

	** Returns the context used to initialise this page.
	abstract Obj[] pageContext()

	** Returns a client URL that can be used to render the given page. 
	** The URL takes into account:
	**  - Any welcome URL -> home page conversions
	**  - The context used to render this page
	**  - Any parent 'WebMods'
	abstract Uri pageUrl()

	** Returns an *absolute* page URL that contains a scheme and host:
	** 
	**   http://eggbox.fantomfactory.org/pods/afPillow/
	** 
	** Convenience for:
	** 
	**   syntax: fantom
	**   bedSheetServer.toAbsoluteUrl(pageMeta.pageUrl())
	** 
	** See `afBedSheet::BedSheetServer`.
	abstract Uri pageUrlAbs()

	** Returns the 'Content-Type' produced by this page.
	** 
	** Returns `PillowConfigIds.defaultContentType` if it can not be determined.
	abstract MimeType contentType()
	
	** Returns 'true' if the page is a welcome page.
	abstract Bool isWelcomePage()

	** Returns the HTTP method this page responds to.
	abstract Str httpMethod()

	@NoDoc @Deprecated { msg = "Use 'routesDisabled()' instead" }
	virtual Bool disableRoutes() { routesDisabled }

	** Returns 'true' if BedSheet route generation has been disabled for this page.
	abstract Bool routesDisabled()

	** Returns a client URL for a given event - use to create client side URIs to call the event.
	** 
	** 'event' may be either a: 
	**  - 'Str' - the name of the event (*not* the name of the method)
	**  - 'Method' - the event method itself 
	abstract Uri eventUrl(Obj event, Obj[]? eventContext := null)

	** Returns a new 'PageMeta' with the given page context.
	abstract PageMeta withContext(Obj[]? pageContext)
	
	** Returns all the event methods on the page.
	abstract Method[] eventMethods()

	** Returns a 'HttpRedirect.movedTemporarily' to this page.
	abstract HttpRedirect redirect()

	** Returns a 'HttpRedirect.afterPost' to this page.
	abstract HttpRedirect redirectAfterPost()
	
	@NoDoc
	abstract Uri pageGlob()
	
	@NoDoc
	abstract Uri eventGlob(Method eventMethod)

	@NoDoc
	abstract InitRenderMethod initRender()	
}

** Returns details about the Pillow event currently being called.
** 
@NoDoc	// Advanced WIP - used by Mars to re-direct events to other pages
class EventMeta {
	
	PageMeta	pageMeta
	Method		eventMethod
	Obj[]		eventContext
	
	new make(|This| f) { f(this) }
}

internal const class PageMetaProxy : PageMeta {

	private PageMeta pageMeta() { PageMetaImpl.peek(true) }
	
	override Type pageType() {
		pageMeta.pageType
	}

	override Obj[] pageContext() {
		pageMeta.pageContext
	}

	override Uri pageUrl() {
		pageMeta.pageUrl
	}
	
	override Uri pageUrlAbs() {
		pageMeta.pageUrlAbs
	}
	
	override MimeType contentType() {
		pageMeta.contentType
	}
	
	override Bool isWelcomePage() {
		pageMeta.isWelcomePage
	}

	override Str httpMethod() {
		pageMeta.httpMethod
	}

	override Bool routesDisabled() {
		pageMeta.routesDisabled
	}
	
	override Uri eventUrl(Obj event, Obj[]? eventContext := null) {
		pageMeta.eventUrl(event, eventContext)
	}

	override PageMeta withContext(Obj[]? pageContext) {
		pageMeta.withContext(pageContext)
	}
	
	override Method[] eventMethods() {
		pageMeta.eventMethods
	}

	override Uri pageGlob() {
		pageMeta.pageGlob
	}
	
	override Uri eventGlob(Method eventMethod) {
		pageMeta.eventGlob(eventMethod)
	}
	
	override InitRenderMethod initRender() {
		pageMeta.initRender
	}

	override HttpRedirect redirect() {
		pageMeta.redirect
	}

	override HttpRedirect redirectAfterPost() {
		pageMeta.redirectAfterPost
	}

	override Str toStr() {
		pageMeta.toStr
	}	
}

internal class PageMetaImpl : PageMeta {

	internal 		BedSheetServer	bedServer
	internal 		HttpRequest		httpRequest
	internal 		ValueEncoders	valueEncoders
	private const 	PageMetaState	pageState
	override 		Obj[]			pageContext
	
	internal new make(PageMetaState pageState, Obj[]? pageContext, |This|in) {
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
		if (pageContext.size < initRender.minNumArgs || pageContext.size > initRender.paramTypes.size)
			throw ArgErr(ErrMsgs.invalidNumberOfPageArgs(pageType, initRender.minNumArgs, initRender.paramTypes.size, pageContext))		

		// append page context
		if (pageContext.isEmpty)
			return clientUrl
		
		url	:= ``
		try {
			pageContext	:= pageContext.dup.rw
			clientPath	:= clientUrl.path
			
			for (i := 0; i < clientPath.size; ++i) {
				seg := clientPath[i]
				
				if (seg == "*") {
					val := pageContext.removeAt(0)
					seg = valueEncoders.toClient(val.typeof, val)
				}
				
				if (seg != "**")
					url = url.plusSlash.plusName(Uri.escapeToken(seg, Uri.sectionPath))
			}
			
			for (i := 0; i < pageContext.size; ++i) {
				val := pageContext[i]
				seg := valueEncoders.toClient(val.typeof, val)
				url = url.plusSlash.plusName(Uri.escapeToken(seg, Uri.sectionPath))
			}

		} catch (Err err)
			throw Err("Could not encode page ctx into URL: ${pageContext} into ${url}", err)
		
		return url
	}
	
	override Uri pageUrlAbs() {
		bedServer.toAbsoluteUrl(pageUrl)
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

	override Bool routesDisabled() {
		pageState.routesDisabled
	}
	
	override Uri eventUrl(Obj event, Obj[]? eventContext := null) {
		eventMethod := (Method?) null

		if (event isnot Str && event isnot Method)
			throw ArgErr(ErrMsgs.eventTypeNotKnown(event))
		
		if (event is Method) {
			eventMethod = (Method) event
			eventName := pageEventName(event)
			if (!eventMethods.any { eventName.equalsIgnoreCase(pageEventName(it)) })
				throw eventNotFound(eventMethod.name)
		}

		if (event is Str) {
			eventName := (Str) event
			eventMethod 
				= eventMethods.find { eventName.equalsIgnoreCase(pageEventName(it)) }
				?: throw eventNotFound(eventName)
		}
		
		// validate args
		evtCtxSize  := eventContext?.size ?: 0
		minNoOfArgs := eventMethod.params.reduce(0) |Int tot, param->Int| { param.hasDefault ? tot : tot++ }
		if (evtCtxSize < minNoOfArgs || evtCtxSize > eventMethod.params.size)
			throw ArgErr(ErrMsgs.invalidNumberOfEventArgs(eventMethod, minNoOfArgs, eventMethod.params.size, eventContext))		
		
		eventName := pageEventName(eventMethod)
		eventUrl := pageUrl
		if (!eventName.isEmpty)
			eventUrl = eventUrl.plusSlash.plusName(eventName)
		if (eventContext != null && !eventContext.isEmpty)
			for (i := 0; i < eventContext.size; ++i) {
				seg := encodeObj(eventContext[i])
				eventUrl = eventUrl.plusSlash.plusName(Uri.escapeToken(seg, Uri.sectionPath))
			}
		return eventUrl
	}

	override PageMeta withContext(Obj[]? pageContext) {
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
		eventGlob	:= pageGlob
		eventName	:= pageEventName(eventMethod)
		if (!eventName.isEmpty)
			eventGlob = eventGlob.plusSlash.plusName(eventName)

		for (i := 0; i < eventMethod.params.size; ++i) {
			eventGlob = eventGlob.plusSlash.plusName("*")			
		}

		return eventGlob
	}
	
	override InitRenderMethod initRender() {
		pageState.initRender
	}
	
	override HttpRedirect redirect() {
		HttpRedirect.movedTemporarily(pageUrl)
	}

	override HttpRedirect redirectAfterPost() {
		HttpRedirect.afterPost(pageUrl)
	}

	override Str toStr() {
		pageUrl.toStr
	}
	
	internal static Obj? push(PageMeta pageMeta, |->Obj?| fn) {
		PageMetaCtx(pageMeta).runInCtx(fn)
	}
	
	internal static PageMeta? peek(Bool checked) {
		PageMetaCtx.peek(checked)?.pageMeta
	}

	private Str encodeObj(Obj obj) {
		valueEncoders.toClient(obj.typeof, obj)
	}

	// removed '@' from delims 'cos it doesn't need to be escaped in paths - also Fantom Uri doesn't and we need to be consistent 
	private static const Int[] delims := ":/?#[]\\".chars

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
	
	private Str pageEventName(Method method) {
		pageEvent := (PageEvent?) method.facet(PageEvent#, false)
		
		if (pageEvent == null) {
			// 2nd chance - check for inheritance
			while (pageEvent == null && method.isOverride) {
				// this search isn't perfect as we may not follow the correct inheritance route
				newMethod := [method.parent.base].addAll(method.parent.mixins).eachWhile { it.method(method.name, false) }
				if (newMethod != null) {
					method 	  = newMethod
					pageEvent = method.facet(PageEvent#, false)
				}
			}
			// naa - still not found
			if (pageEvent == null)
				throw eventNotFound(method.name)
		}
		
		
		if (pageEvent.name != null)
			return pageEvent.name
		eventName := method.name
		if (eventName.startsWith("on"))
			eventName = eventName[2..-1].decapitalize
		return eventName
	}
	
	private Err eventNotFound(Str eventName) {
		ArgNotFoundErr(ErrMsgs.eventNotFound(pageType, eventName), eventMethods.map { pageEventName(it) })
	}
}

