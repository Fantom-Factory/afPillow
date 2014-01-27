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
		config.add(|PlasticClassModel model| {
			if (meta.appPod != null)
				model.usingPod(meta.appPod)
		})
	}

//	@Contribute { serviceId="PillowRoutes" }
	@Contribute { serviceId="Routes" }
	internal static Void contributeRoutes(OrderedConfig config, Pages pages, ComponentMeta componentMeta) {

		pages.pageTypes.each |pageType| {
			initMeth := componentMeta.findMethod(pageType, InitRender#)
			noOfParams := initMeth?.params?.size ?: 0
			regex := ""
			noOfParams.times { regex += "/*" }
			clientUri := pages.clientUri(pageType)
			
			// allow the file system to trump pillow pages
			config.addOrdered(pageType.qname, Route(`${clientUri}${regex}`, PageRenderFactory(pageType, initMeth)), ["after: FileHandlerEnd"])
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
	const Method? 	method
	
	new make(Type pageType, Method? initMethod) {
		this.pageType 	= pageType
		this.method 	= initMethod
	}
	
	override Bool matchSegments(Str?[] segments) {
		if (method == null)
			return segments.isEmpty

		if (segments.size > method.params.size)
			return false
		
		match := method.params.all |Param param, i->Bool| {
			if (i >= segments.size)
				return param.hasDefault
			return (segments[i] == null) ? param.type.isNullable : true
		}
		
		return match
	}

	override Obj? createResponse(Str?[] segments) {
		// segments is RO and (internally) needs to be a Str, so we create a new list
		MethodCall(Pages#renderPageToText, [pageType, segments])
	}
}

