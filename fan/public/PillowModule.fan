using afIoc
using afIocConfig
using afBedSheet
using afEfanXtra
using afPlastic

** The [afIoc]`http://repo.status302.com/doc/afIoc/#overview` module class.
** 
** This class is public so it may be referenced explicitly in tests.
class PillowModule {

	internal static Void bind(ServiceBinder binder) {
		binder.bind(Pages#)
		binder.bind(PillowPrinter#)
		binder.bind(ContentTypeResolver#)
		binder.bind(ClientUriResolver#)
		binder.bind(PageMeta#, PageMetaProxy#).withoutProxy	// we supply our own proxy!

//		binder.bindImpl(Routes#).withId("PillowRoutes")
	}
	
	// TODO: afIoc-1.5
//	@Contribute { serviceType=HttpPipeline# }
//	internal static Void contributeHttpPipeline(OrderedConfig config, Registry reg) {
//		pillowRoutes := reg.serviceById("PillowRoutes")
//		config.addOrdered("PillowRoutes", pillowRoutes, ["after: Routes"])
//	}

	@Contribute { serviceType=EfanLibraries# }
	internal static Void contributeEfanLibraries(MappedConfig config, BedSheetMetaData meta) {
		if (meta.appPod != null)
			config["app"] = meta.appPod
	}

	@Contribute { serviceType=ComponentCompiler# }
	internal static Void contributeComponentCompilerCallbacks(OrderedConfig config) {
		pageCompiler := (PageCompiler) config.autobuild(PageCompiler#)
		config.add(pageCompiler.callback)
	}

//	@Contribute { serviceId="PillowRoutes" }
	@Contribute { serviceId="Routes" }
	internal static Void contributeRoutes(OrderedConfig config, Pages pages, Registry registry) {

		config.addPlaceholder("PillowStart", ["after: FileHandlerEnd"])
		config.addPlaceholder("PillowEnd", 	 ["after: PillowStart"])
		
		pages.pageTypes.each |pageType| {
			pageMeta 	:= pages.pageMeta(pageType, null)
			serverUri	:= pageMeta.serverGlob
			initTypes	:= pageMeta.contextTypes
			
			// allow the file system to trump pillow pages
			config.addOrdered(pageType.qname, Route(serverUri, PageRenderFactory(pageType, initTypes), pageMeta.httpMethod), ["after: PillowStart", "before: PillowEnd"])
			
			pageType.methods.findAll { it.hasFacet(PageEvent#) }.each |eventMethod| {
				pageEvent	:= (PageEvent) Method#.method("facet").callOn(eventMethod, [PageEvent#])	// Stoopid F4 	
				eventUri 	:= serverUri.plusSlash + pageMeta.eventGlob(eventMethod)
				qname	 	:= "${pageType.qname}/${eventMethod.name}"
				config.addOrdered(qname, Route(eventUri, EventCallerFactory(pageType, initTypes, eventMethod), pageEvent.httpMethod), ["after: PillowStart", "before: PillowEnd"])
			}
		}

		// TODO: should we? redirect welcome pages to directory
//		if (!url.isDir && pages.isWelcomePage(pageType)) {
//			redirect := Redirect.movedTemporarily(url.parent)
//			responseProcessors.processResponse(redirect)
//			return true
//		}
	}

	@Contribute { serviceType=ResponseProcessors# }
	static Void contributeResponseProcessors(MappedConfig config) {
		config[PageMeta#] = config.autobuild(PageMetaResponseProcessor#)
	}
	
	@Contribute { serviceType=EfanTemplateFinders# }
	internal static Void contributeEfanTemplateFinders(OrderedConfig config) {
		config.addOrdered("FindByPageFacetValue", FindEfanByPageFacetValue())
	}

	@Contribute { serviceType=ApplicationDefaults# }
	internal static Void contributeApplicationDefaults(MappedConfig config) {
		// we'll do our own logging thanks!
		config[EfanXtraConfigIds.supressStartupLogging]	= true
	}

	@Contribute { serviceType=FactoryDefaults# }
	internal static Void contributeFactoryDefaults(MappedConfig config) {
		config[PillowConfigIds.welcomePage]			= "index"
		config[PillowConfigIds.defaultContentType]	= MimeType("text/plain")
	}

	@Contribute { serviceType=RegistryStartup# }
	internal static Void contributeRegistryStartup(OrderedConfig conf, PillowPrinter efanPrinter) {
		conf.add |->| {
			efanPrinter.logLibraries
		}
	}	
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

	// TODO: afBedSheet-1.3.2, kill this matchesParams()
	static Bool matchesParams(Type[] params, Str?[] segments) {
		if (segments.size > params.size)
			return false
		return params.all |Type param, i->Bool| {
			if (i >= segments.size)
				return false
			return (segments[i] == null) ? param.isNullable : true
		}
	}
	
	override Obj? createResponse(Str?[] segments) {
		// segments is RO and (internally) needs to be a Str, so we can't just append pageType to the start of segments.
		MethodCall(Pages#renderPage, [pageType, segments])
	}
}

** Copied from 'afBedSheet.MethodCallFactory'
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

	// TODO: afBedSheet-1.3.2, kill this matchesMethod()
	static Bool matchesMethod(Method method, Str?[] segments) {
		if (segments.size > method.params.size)
			return false
		return method.params.all |Param param, i->Bool| {
			if (i >= segments.size)
				return param.hasDefault
			return (segments[i] == null) ? param.type.isNullable : true
		}
	}

	// TODO: afBedSheet-1.3.2, kill this matchesParams()
	static Bool matchesParams(Type[] params, Str?[] segments) {
		if (segments.size > params.size)
			return false
		return params.all |Type param, i->Bool| {
			if (i >= segments.size)
				return false
			return (segments[i] == null) ? param.isNullable : true
		}
	}

	override Obj? createResponse(Str?[] segments) {
		initSegs  := segments[0..<initParams.size]
		eventSegs := segments[initParams.size..-1]
		return MethodCall(Pages#callPageEvent, [pageType, initSegs, eventMethod, eventSegs])
	}
}

