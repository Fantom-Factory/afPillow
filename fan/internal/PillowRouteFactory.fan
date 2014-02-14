using afIoc
using afIocConfig
using afBedSheet

internal const class PillowRouteFactory {
	
	@Config { id="afPillow.enableRouting" }
	@Inject private const Bool	enableRouting

	@Config { id="afPillow.welcomePageName" }
	@Inject private const Str 	welcomePageName
	
	@Config { id="afPillow.welcomePageStrategy" }
	@Inject private const WelcomePageStrategy	strategy
	
	@Inject	private const Pages	pages

	new make(|This| in) { in(this) }
	
	Void addPillowRoutes(OrderedConfig config) {
		// allow the file system to trump pillow pages
		config.addPlaceholder("PillowStart", 		["after: FileHandlerEnd"])
		config.addPlaceholder("PillowEnd", 	 		["after: PillowStart"])
		config.addPlaceholder("PillowWelcomePages", ["after: PillowStart", "before: PillowEnd"])

		// Keep the placeholders
		if (!enableRouting)	return
		
		pages.pageTypes.sort.each |pageType| {
			pageMeta 	:= pages.pageMeta(pageType, null)
			serverUri	:= pageMeta.serverGlob
			initTypes	:= pageMeta.contextTypes
			events		:= pageType.methods.findAll { it.hasFacet(PageEvent#) }
			pageRoute	:= Route(serverUri, PageRenderFactory(pageType, initTypes), pageMeta.httpMethod)
			constraints	:= pageMeta.isWelcomePage ? welcomePageConstraints : normalPageConstraints
			
			config.addOrdered(pageType.qname, pageRoute, constraints)
			
			if (strategy == WelcomePageStrategy.offWithRedirects && initTypes.isEmpty && events.isEmpty && pageMeta.isWelcomePage) {
				redirect := Route(serverUri.parent, Redirect.movedPermanently(serverUri), pageMeta.httpMethod)
				config.addOrdered(pageType.qname + "-redirect", redirect, constraints)
			}

			if (strategy == WelcomePageStrategy.onWithRedirects && initTypes.isEmpty && events.isEmpty && pageMeta.isWelcomePage) {
				// route all file extensions too, e.g. index.html
				regex	 := ("(?i)^" + Regex.glob(serverUri.plusSlash.toStr).toStr + welcomePageName + "(?:\\..+)?").toRegex 
				redirect := Route(regex, Redirect.movedPermanently(serverUri), pageMeta.httpMethod)
				config.addOrdered(pageType.qname + "-redirect", redirect, constraints)				
			}

			pageType.methods.findAll { it.hasFacet(PageEvent#) }.each |eventMethod| {
				pageEvent	:= (PageEvent) Method#.method("facet").callOn(eventMethod, [PageEvent#])	// Stoopid F4 	
				eventUri 	:= serverUri.plusSlash + pageMeta.eventGlob(eventMethod)
				qname	 	:= "${pageType.qname}/${eventMethod.name}"
				eventRoute	:= Route(eventUri, EventCallerFactory(pageType, initTypes, eventMethod), pageEvent.httpMethod)
				config.addOrdered(qname, eventRoute, constraints)
			}
		}
	}
	
	private static const Str[]	normalPageConstraints	:= ["after: PillowStart", "before: PillowWelcomePages"]
	private static const Str[]	welcomePageConstraints	:= ["after: PillowWelcomePages", "before: PillowEnd"]
}

internal const class PageRenderFactory : RouteResponseFactory {
	const Type 		pageType
	const Type[]	initParams
	
	new make(Type pageType, Type[] initParams) {
		this.pageType 	= pageType
		this.initParams	= initParams
	}
	
	override Bool matchSegments(Str?[] segments) {
		matchesParams(initParams, segments)
	}
	
	override Obj? createResponse(Str?[] segments) {
		// segments is RO and (internally) needs to be a Str, so we can't just append pageType to the start of segments.
		MethodCall(Pages#renderPage, [pageType, segments])
	}
	
	override Str toStr() {
		"Pillow Page ${pageType.qname}" + (initParams.isEmpty ? "" : "(" + initParams.join(",").replace("sys::", "") + ")")
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
