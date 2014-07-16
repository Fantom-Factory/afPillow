using afIoc
using afIocConfig
using afBedSheet
using afEfanXtra
using afPlastic
using web

** The [IoC]`http://www.fantomfactory.org/pods/afIoc` module class.
** 
** This class is public so it may be referenced explicitly in test code.
@NoDoc
const class PillowModule {

	static Void bind(ServiceBinder binder) {
		binder.bind(Pages#)
		binder.bind(PillowPrinter#)
		binder.bind(ContentTypeResolver#)
		binder.bind(PageUrlResolver#)
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

	@Contribute { serviceType=PageUrlResolver# } 
	static Void contributePageUrlResolvers(OrderedConfig config) {
		config.addOrdered("FromPageFacet", 	ResolvePageUrlFromPageFacet())
		config.addOrdered("FromTypeName", 	ResolvePageUrlFromTypeName())
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
	
	@Contribute { serviceType=TemplateFinders# }
	static Void contributeTemplateFinders(OrderedConfig config) {
		config.addOrdered("FindByPageFacetValue", config.autobuild(FindEfanByPageFacetValue#))
	}

	@Contribute { serviceType=FactoryDefaults# }
	static Void contributeFactoryDefaults(MappedConfig config) {
		config[PillowConfigIds.defaultContentType]	= MimeType("text/plain")
		config[PillowConfigIds.enableRouting]		= true
		config[PillowConfigIds.welcomePageName]		= "index"
		config[PillowConfigIds.welcomePageStrategy]	= WelcomePageStrategy.onWithRedirects
		config[PillowConfigIds.cacheControl]		= "max-age=0, no-cache"
	}

	@Contribute { serviceType=ErrPrinterHtml# }
	internal static Void contributeErrPrinterHtml(OrderedConfig config, PillowPrinter printer) {
		config.addOrdered("PillowPages",	|WebOutStream out, Err? err| { printer.printPillowPages(out) }, ["after: IocConfig", "before: Routes"])
	}

	@Contribute { serviceType=NotFoundPrinterHtml# }
	internal static Void contributeNotFoundPrinterHtml(OrderedConfig config, PillowPrinter printer) {
		config.addOrdered("PillowPages",	|WebOutStream out| { printer.printPillowPages(out) }, ["after: RouteCode", "before: Routes"])
	}

	@Contribute { serviceType=RegistryStartup# }
	internal static Void contributeRegistryStartup(OrderedConfig conf, PillowPrinter pillowPrinter) {
		conf.remove  ("afEfanXtra.logLibraries")
		conf.addOrdered("afPillow.logLibraries") |->| { pillowPrinter.logLibraries }
	}
	
	@Contribute { serviceType=StackFrameFilter# }
	static Void contributeStackFrameFilter(OrderedConfig config) {
		// remove boring Alien-Factory stack frames
		config.add("^afEfan::.*\$")
		config.add("^afEfanXtra::.*\$")
		config.add("^afPillow::.*\$")
	}
}


