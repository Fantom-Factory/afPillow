using afIoc
using afIocConfig
using afBedSheet
using afEfanXtra
using afPlastic

** The [afIoc]`http://repo.status302.com/doc/afIoc/#overview` module class.
** 
** This class is public so it may be referenced explicitly in tests.
class PillowModule {

	static Void bind(ServiceBinder binder) {
		binder.bind(Pages#)
		binder.bind(PillowPrinter#)
		binder.bind(ContentTypeResolver#)
		binder.bind(PageUriResolver#)
		binder.bind(PageMetaStateFactory#)
	}

	@Build { scope=ServiceScope.perThread }
	static PageMeta buildPageMeta() {
		PageMeta.peek(true)
	}
	
	@Contribute { serviceType=EfanLibraries# }
	static Void contributeEfanLibraries(MappedConfig config, BedSheetMetaData meta) {
		if (meta.appPod != null)
			config["app"] = meta.appPod
	}

	@Contribute { serviceType=ComponentCompiler# }
	static Void contributeComponentCompilerCallbacks(OrderedConfig config) {
		pageCompiler := (PageCompiler) config.autobuild(PageCompiler#)
		config.add(pageCompiler.callback)
	}

	@Contribute { serviceId="Routes" }
	static Void contributeRoutes(OrderedConfig config, Pages pages, IocConfigSource icoConfigSrc) {
		routeFactory := (PillowRouteFactory) config.autobuild(PillowRouteFactory#)
		routeFactory.addPillowRoutes(config)
	}

	@Contribute { serviceType=PageUriResolver# } 
	static Void contributePageUriResolvers(OrderedConfig config) {
		config.addOrdered("FromPageFacet", 	ResolvePageUriFromPageFacet())
		config.addOrdered("FromTypeName", 	ResolvePageUriFromTypeName())
	}
	
	@Contribute { serviceType=ContentTypeResolver# } 
	static Void contributeContentTypeResolvers(OrderedConfig config) {
		config.addOrdered("FromPageFacet", 			ResolveContentTypeFromPageFacet())
		config.addOrdered("FromTemplateExtension",	config.autobuild(ResolveContentTypeFromTemplateExtension#))
	}

	@Contribute { serviceType=ResponseProcessors# }
	static Void contributeResponseProcessors(MappedConfig config) {
		config[PageMeta#] = config.autobuild(PageMetaResponseProcessor#)
	}
	
	@Contribute { serviceType=EfanTemplateFinders# }
	static Void contributeEfanTemplateFinders(OrderedConfig config) {
		config.addOrdered("FindByPageFacetValue", FindEfanByPageFacetValue())
	}

	@Contribute { serviceType=ApplicationDefaults# }
	static Void contributeApplicationDefaults(MappedConfig config) {
		// we'll do our own logging thanks!
		config[EfanXtraConfigIds.supressStartupLogging]	= true
	}

	@Contribute { serviceType=FactoryDefaults# }
	static Void contributeFactoryDefaults(MappedConfig config) {
		config[PillowConfigIds.welcomePageName]		= "index"
		config[PillowConfigIds.defaultContentType]	= MimeType("text/plain")
		config[PillowConfigIds.enableRouting]		= true
		config[PillowConfigIds.welcomePageStrategy]	= WelcomePageStrategy.onWithRedirects
	}

	@Contribute { serviceType=RegistryStartup# }
	internal static Void contributeRegistryStartup(OrderedConfig conf, PillowPrinter efanPrinter) {
		conf.add |->| {
			efanPrinter.logLibraries
		}
	}	
}


