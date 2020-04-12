using afIoc::Inject
using afIocConfig::Config
using afBedSheet::HttpRedirect
using afBedSheet::Route

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

		pages.pageTypes.each |pageType| {
			pageMeta 	:= pages.pageMeta(pageType, null)
			if (pageMeta.routesDisabled)
				return
			
			initTypes	:= pageMeta.initRender.paramTypes
			routes		:= pageMeta.isWelcomePage ? welcomeRoutes : normalRoutes
			pageRes		:= PageResponse(pageMeta.pageType, pageMeta.initRender)
			pageRes.addRoutes(routes, pageMeta)
			
			if (strategy == WelcomePageStrategy.offWithRedirects && initTypes.isEmpty && pageMeta.eventMethods.isEmpty && pageMeta.isWelcomePage) {
				serverUri	:= pageMeta.pageGlob
				redirect := Route(serverUri.parent, HttpRedirect.movedTemporarily(serverUri), pageMeta.httpMethod)
				routes.add(redirect)
			}

			if (strategy == WelcomePageStrategy.onWithRedirects && initTypes.isEmpty && pageMeta.eventMethods.isEmpty && pageMeta.isWelcomePage) {
				serverUri	:= pageMeta.pageGlob
				// FIXME
				// route all file extensions too, e.g. index.html
				regex	 := ("(?i)^" + Regex.glob(serverUri.plusSlash.toStr).toStr + welcomePageName + "(?:\\..+)?").toRegex 
//				redirect := Route(regex, HttpRedirect.movedTemporarily(serverUri), pageMeta.httpMethod)
//				routes.add(redirect)
			}

			pageMeta.eventMethods.each |eventMethod| {
				pageEvent	:= (PageEvent) eventMethod.facet(PageEvent#)
				eventGlob 	:= pageMeta.eventGlob(eventMethod)
				qname	 	:= "${pageType.qname}/${eventMethod.name}"
				eventRoute	:= Route(eventGlob, EventResponse(pageType, initTypes, eventMethod), pageEvent.httpMethod)
				routes.add(eventRoute)
			}
		}
		
		// welcomeRoutes, i.e. /poo/ and /poo/index need to come before normalRoutes, 'cos normalRoutes may have a
		// capture all pageContext like /poo/* meaning the welcomeRoute would never get a look in!
		return welcomeRoutes.addAll(normalRoutes)
	}	
}

internal const class PageResponse {
	const Type				pageType	// thinking about inheritance, this may NOT be initRender.parent()
	const InitRenderMethod	initRender
	
	new make(Type pageType, InitRenderMethod initRender) {
		this.pageType	= pageType
		this.initRender = initRender
	}
	
	Void addRoutes(Route[] routes, PageMeta pageMeta) {
		urlGlob		:= pageMeta.pageGlob
		httpMethod	:= pageMeta.httpMethod
		
		if (pageMeta.initRender.hasOptionalParams) {
			path	:= urlGlob.path
			numArgs	:= pageMeta.initRender.minNumArgs
			numWild	:= 0
			for (i := 0; i < path.size; ++i) {
				if (path[i] == "*" || path[i] == "**") {
					if (numWild >= numArgs) {
						url := ``
						for (x := 0; x < i; ++x) {
							url = url.plusSlash.plusName(path[x])
						}
						routes.add(Route(url, this, httpMethod))
					}
					numWild++
				}
			}
		}
		
		routes.add(Route(urlGlob, this, httpMethod))
	}
	
	override Str toStr() {
		"Pillow Page  ${initRender.pageType.qname}" + (initRender.paramTypes.isEmpty ? "" : "(" + initRender.paramTypes.join(",").replace("sys::", "") + ")")
	}
}

internal const class EventResponse {
	const Type 		pageType
	const Type[]	initParams
	const Method 	eventMethod
	
	new make(Type pageType, Type[] initParams, Method eventMethod) {
		this.pageType 		= pageType
		this.initParams		= initParams
		this.eventMethod	= eventMethod
	}
	
	override Str toStr() {
		params := initParams.isEmpty ? "" : "(" + initParams.join(",").replace("sys::", "") + ")"
		return "Pillow Event ${pageType.qname}${params}.${eventMethod.name}"
	}
}

//internal const class PageRenderFactory : RouteResponseFactory {
//	const InitRenderMethod initRender
//	
//	new make(InitRenderMethod initRender) {
//		this.initRender = initRender
//	}
//	
//	override Bool matchSegments(Str?[] segments) {
//		initRender.argsMatch(segments)
//	}
//	
//	override Obj? createResponse(Str?[] segments) {
//		// segments is RO and (internally) needs to be a Str, so we can't just append pageType to the start of segments.
//		return MethodCall(Pages#renderPage, [initRender.pageType, segments])
//	}
//	
//	override Str toStr() {
//		"Pillow Page  ${initRender.pageType.qname}" + (initRender.paramTypes.isEmpty ? "" : "(" + initRender.paramTypes.join(",").replace("sys::", "") + ")")
//	}
//}

//internal const class EventCallerFactory : RouteResponseFactory {
//	const Type 		pageType
//	const Type[]	initParams
//	const Method 	eventMethod
//	
//	new make(Type pageType, Type[] initParams, Method eventMethod) {
//		this.pageType 		= pageType
//		this.initParams		= initParams
//		this.eventMethod	= eventMethod
//	}
//	
//	override Bool matchSegments(Str?[] segments) {
//		if (segments.size < initParams.size)
//			return false
//		initSegs := segments[0..<initParams.size]
//		if (!matchesParams(initParams, initSegs))
//			return false
//		eventSegs := segments[initParams.size..-1]
//		return matchesMethod(eventMethod, eventSegs)
//	}
//
//	override Obj? createResponse(Str?[] segments) {
//		pageSegs  := segments[0..<initParams.size]
//		eventSegs := segments[initParams.size..-1]
//		return MethodCall(Pages#callPageEvent, [pageType, pageSegs, eventMethod, eventSegs])
//	}
//	
//	override Str toStr() {
//		params := initParams.isEmpty ? "" : "(" + initParams.join(",").replace("sys::", "") + ")"
//		return "Pillow Event ${pageType.qname}${params}.${eventMethod.name}"
//	}	
//}
