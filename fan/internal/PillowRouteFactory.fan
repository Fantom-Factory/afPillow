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
				indexUrl	 := serverUri.plusSlash.plusName(welcomePageName) 
				redirect := Route(indexUrl, HttpRedirect.movedTemporarily(serverUri), pageMeta.httpMethod)
				routes.add(redirect)
			}

			pageMeta.eventMethods.each |eventMethod| {
				eventRes	:= EventResponse(pageType, initTypes, eventMethod)
				eventRes.addRoutes(routes, pageMeta)
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
	
	Void addRoutes(Route[] routes, PageMeta pageMeta) {
		pageEvent	:= (PageEvent) eventMethod.facet(PageEvent#)
		urlGlob 	:= pageMeta.eventGlob(eventMethod)
		httpMethod	:= pageEvent.httpMethod
		
		numArgs		:= 0
		for (i := 0; i < eventMethod.params.size; ++i) {
			if (!eventMethod.params[i].hasDefault)
				numArgs++
		}
		hasDefaults	:= numArgs != eventMethod.params.size
		
		if (hasDefaults) {
			path	:= urlGlob.path
			numArgs	+= pageMeta.initRender.maxNumArgs
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
		params := initParams.isEmpty ? "" : "(" + initParams.join(",").replace("sys::", "") + ")"
		return "Pillow Event ${pageType.qname}${params}.${eventMethod.name}"
	}
}
