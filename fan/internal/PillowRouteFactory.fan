using afIoc
using afIocConfig
using afBedSheet

internal const class PillowRouteFactory {
	
	@Config { id="afPillow.welcomePageName" }
	@Inject private const Str 	welcomePageName
	
	@Config { id="afPillow.welcomePageStrategy" }
	@Inject private const WelcomePageStrategy	strategy
	
	@Inject	private const Pages	pages

	new make(|This| in) { in(this) }
	
	Route[] pillowPageRoutes() {
		normalRoutes 	:= Route[,]
		welcomeRoutes	:= Route[,]

		pages.pageTypes.sort.each |pageType| {
			pageMeta 	:= pages.pageMeta(pageType, null)
			if (pageMeta.disableRoutes)
				return
			
			serverUri	:= pageMeta.serverGlob
			initTypes	:= pageMeta.initRender.paramTypes
			events		:= pageType.methods.findAll { it.hasFacet(PageEvent#) }
			pageRoute	:= Route(serverUri, PageRenderFactory(pageMeta.initRender), pageMeta.httpMethod)
			routes		:= pageMeta.isWelcomePage ? welcomeRoutes : normalRoutes
			
			routes.add(pageRoute)
			
			if (strategy == WelcomePageStrategy.offWithRedirects && initTypes.isEmpty && events.isEmpty && pageMeta.isWelcomePage) {
				redirect := Route(serverUri.parent, Redirect.movedPermanently(serverUri), pageMeta.httpMethod)
				routes.add(redirect)
			}

			if (strategy == WelcomePageStrategy.onWithRedirects && initTypes.isEmpty && events.isEmpty && pageMeta.isWelcomePage) {
				// route all file extensions too, e.g. index.html
				regex	 := ("(?i)^" + Regex.glob(serverUri.plusSlash.toStr).toStr + welcomePageName + "(?:\\..+)?").toRegex 
				redirect := Route(regex, Redirect.movedPermanently(serverUri), pageMeta.httpMethod)
				routes.add(redirect)
			}

			pageMeta.eventMethods.each |eventMethod| {
				pageEvent	:= (PageEvent) Method#.method("facet").callOn(eventMethod, [PageEvent#])	// Stoopid F4 	
				eventUrl 	:= serverUri.plusSlash + pageMeta.eventGlob(eventMethod)
				qname	 	:= "${pageType.qname}/${eventMethod.name}"
				eventRoute	:= Route(eventUrl, EventCallerFactory(pageType, initTypes, eventMethod), pageEvent.httpMethod)
				routes.add(eventRoute)
			}
		}
		return normalRoutes.addAll(welcomeRoutes)
	}	
}

internal const class PageRenderFactory : RouteResponseFactory {
	const InitRenderMethod initRender
	
	new make(InitRenderMethod initRender) {
		this.initRender = initRender
	}
	
	override Bool matchSegments(Str?[] segments) {
		initRender.argsMatch(segments)
	}
	
	override Obj? createResponse(Str?[] segments) {
		// segments is RO and (internally) needs to be a Str, so we can't just append pageType to the start of segments.
		MethodCall(Pages#renderPage, [initRender.pageType, segments])
	}
	
	override Str toStr() {
		"Pillow Page ${initRender.pageType.qname}" + (initRender.paramTypes.isEmpty ? "" : "(" + initRender.paramTypes.join(",").replace("sys::", "") + ")")
	}
}

internal const class EventCallerFactory : RouteResponseFactory {
	const Type 		pageType
	const Type[]	initParams
	const Method 	eventMethod
	
	new make(Type pageType, Type[] initParams, Method eventMethod) {
		this.pageType 		= pageType
		this.initParams		= initParams
		this.eventMethod	= eventMethod
	}
	
	override Bool matchSegments(Str?[] segments) {
		if (segments.size < initParams.size)
			return false
		initSegs := segments[0..<initParams.size]
		if (!matchesParams(initParams, initSegs))
			return false
		eventSegs := segments[initParams.size..-1]
		return matchesMethod(eventMethod, eventSegs)
	}

	override Obj? createResponse(Str?[] segments) {
		initSegs  := segments[0..<initParams.size]
		eventSegs := segments[initParams.size..-1]
		return MethodCall(Pages#callPageEvent, [pageType, initSegs, eventMethod, eventSegs])
	}
	
	override Str toStr() {
		params := initParams.isEmpty ? "" : "(" + initParams.join(",").replace("sys::", "") + ")"
		return "Pillow Event ${pageType.qname}${params}:${eventMethod.name}"
	}
}
