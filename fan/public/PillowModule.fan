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
		binder.bind(PageRenderMeta#).withScope(ServiceScope.perThread)

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
	internal static Void contributeComponentCompilerCallbacks(OrderedConfig config, BedSheetMetaData meta) {
		config.add(|Type comType, PlasticClassModel model| {
			// let every component (& page) use the pod it was defined in.
			// TODO: is this needed? If so, move to the compiler and use the pod it was defined in.
			if (meta.appPod != null)
				model.usingPod(meta.appPod)
		})
		
		pageCompiler := (PageCompiler) config.autobuild(PageCompiler#)
		config.add(pageCompiler.callback)
	}

//	@Contribute { serviceId="PillowRoutes" }
	@Contribute { serviceId="Routes" }
	internal static Void contributeRoutes(OrderedConfig config, Pages pages, ComponentMeta componentMeta) {

		pages.pageTypes.each |pageType| {		
			serverUri	:= pages.serverUri(pageType)
			initTypes	:= pages.initTypes(pageType)
			
			// allow the file system to trump pillow pages
			config.addOrdered(pageType.qname, Route(serverUri, PageRenderFactory(pageType, initTypes)), ["after: FileHandlerEnd"])
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
		// segments is RO and (internally) needs to be a Str, so we create a new list
		MethodCall(Pages#renderPageToText, [pageType, segments])
	}
}

