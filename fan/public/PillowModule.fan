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
		binder.bind(Pages#).withoutProxy	// default method values
		binder.bind(PillowPrinter#)
		binder.bind(ContentTypeResolver#)
		binder.bind(ClientUriResolver#)
		binder.bind(RenderingPageMeta#)

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
	internal static Void contributeRoutes(OrderedConfig config, Pages pages, ComponentMeta componentMeta) {

		pages.pageTypes.each |pageType| {
			pageMeta 	:= pages.pageMeta(pageType)
			serverUri	:= pageMeta.serverGlob
			initTypes	:= pageMeta.contextTypes
			
			// allow the file system to trump pillow pages
			config.addOrdered(pageType.qname, Route(serverUri, PageRenderFactory(pageType, initTypes)), ["after: FileHandlerEnd"])
			
			pageType.methods.findAll { it.hasFacet(PageEvent#) }.each |eventMethod| {
				eventUri := serverUri.plusSlash + pageMeta.eventGlob(eventMethod)
				qname	 := "${pageType.qname}/${eventMethod.name}"
				config.addOrdered(qname, Route(eventUri, EventCallerFactory(pageType, eventMethod)), ["after: FileHandlerEnd"])
			}
		}

		// TODO: should we? redirect welcome pages to directory
//		if (!url.isDir && pages.isWelcomePage(pageType)) {
//			redirect := Redirect.movedTemporarily(url.parent)
//			responseProcessors.processResponse(redirect)
//			return true
//		}
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
		if (initParams.isEmpty)
			return segments.isEmpty

		if (segments.size > initParams.size)
			return false
		
		match := initParams.all |Type type, i->Bool| {
			if (i >= segments.size)
//				return param.hasDefault	// default params currently not allowed (plastic issue)
				return false
			return (segments[i] == null) ? type.isNullable : true
		}
		
		return match
	}

	override Obj? createResponse(Str?[] segments) {
		// segments is RO and (internally) needs to be a Str, so can't just append pageType to the start of segments.
		MethodCall(Pages#renderPageToText, [pageType, segments])
	}
}

** Copied from 'afBedSheet.MethodCallFactory'
internal const class EventCallerFactory : RouteResponseFactory {
	const Type 		pageType
	const Method 	eventMethod
	
	new make(Type pageType, Method eventMethod) {
		this.pageType 		= pageType
		this.eventMethod	= eventMethod
	}
	
	override Bool matchSegments(Str?[] segments) {
		if (segments.size > eventMethod.params.size)
			return false
		match := eventMethod.params.all |Param param, i->Bool| {
			if (i >= segments.size)
				return param.hasDefault
			return (segments[i] == null) ? param.type.isNullable : true
		}
		return match
	}

	override Obj? createResponse(Str?[] segments) {
		// segments is RO and (internally) needs to be a Str, so can't just append pageType to the start of segments.
		MethodCall(Pages#callPageEvent, [pageType, [,], eventMethod, segments])
	}
}

