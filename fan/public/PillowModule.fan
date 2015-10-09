using afIoc
using afIocConfig
using afBedSheet
using afEfanXtra
using afPlastic
using web

** The [IoC]`pod:afIoc` module class.
** 
** This class is public so it may be referenced explicitly in test code.
@NoDoc
const class PillowModule {

	static Void defineServices(ServiceDefinitions defs) {
		defs.add(Pages#)
		defs.add(PillowPrinter#)
		defs.add(ContentTypeResolver#)
		defs.add(PageUrlResolver#)
		defs.add(PageFinder#)
	}

//	@Build { scopes=["request"] }
//	static PageMeta buildPageMeta() {
//		PageMetaImpl.peek(true)
//	}
	
	@Override
	static ComponentFinder overrideComponentFinder() {
		ComponentFinderImpl()
	}
	
	@Contribute { serviceType=DependencyProviders# }
	internal static Void contributeDependencyProviders(Configuration config) {
		config["afPilloe.pageMetaProvider"] = config.build(PageMetaProvider#)
	}
	
	@Contribute { serviceType=EfanLibraries# }
	static Void contributeEfanLibraries(Configuration config, BedSheetServer bedServer) {
		if (bedServer.appPod != null)
			config["app"] = bedServer.appPod
	}

	@Contribute { serviceType=ComponentCompiler# }
	static Void contributeComponentCompilerCallbacks(Configuration config) {
		pageCompiler := (PageCompiler) config.autobuild(PageCompiler#)
		config.add(pageCompiler.callback)
	}

	@Contribute { serviceType=Routes# }
	static Void contributeRoutes(Configuration config) {
		routeFactory := (PillowRouteFactory) config.autobuild(PillowRouteFactory#)		
		config["afPillow.pageRoutes"] = routeFactory.pillowPageRoutes
	}

	@Contribute { serviceType=PageUrlResolver# } 
	static Void contributePageUrlResolvers(Configuration config) {
		config["afPillow.fromPageFacet"]	= ResolvePageUrlFromPageFacet()
		config["afPillow.fromTypeName"]		= ResolvePageUrlFromTypeName()
	}
	
	@Contribute { serviceType=ContentTypeResolver# } 
	static Void contributeContentTypeResolvers(Configuration config) {
		config["afPillow.fromPageFacet"]			= ResolveContentTypeFromPageFacet()
		config["afPillow.fromTemplateExtension"]	= config.autobuild(ResolveContentTypeFromTemplateExtension#)
	}

	@Contribute { serviceType=ResponseProcessors# }
	static Void contributeResponseProcessors(Configuration config) {
		config[PageMeta#] = config.autobuild(PageMetaResponseProcessor#)
	}
	
	@Contribute { serviceType=TemplateFinders# }
	static Void contributeTemplateFinders(Configuration config) {
		config["afPillow.findByPageFacetValue"]	= config.autobuild(FindEfanByPageFacetValue#)
	}

	@Contribute { serviceType=FactoryDefaults# }
	static Void contributeFactoryDefaults(Configuration config) {
		config[PillowConfigIds.defaultContentType]	= MimeType("text/plain")
		config[PillowConfigIds.welcomePageName]		= "index"
		config[PillowConfigIds.welcomePageStrategy]	= WelcomePageStrategy.onWithRedirects
		config[PillowConfigIds.cacheControl]		= "max-age=0, no-cache"
	}

	@Contribute { serviceType=NotFoundPrinterHtml# }
	internal static Void contributeNotFoundPrinterHtml(Configuration config, PillowPrinter printer) {
		config.set("afPillow.pillowPages",	|WebOutStream out| { printer.printPillowPages(out) }).after("afBedSheet.routeCode").before("afBedSheet.routes")
	}

	@Contribute { serviceType=ErrPrinterHtml# }
	internal static Void contributeErrPrinterHtml(Configuration config, PillowPrinter printer) {
		config.set("afPillow.pillowPages",	|WebOutStream out, Err? err| { printer.printPillowPages(out) }).after("afBedSheet.iocConfig").before("afBedSheet.routes")
	}

//	internal static Void onRegistryStartup(Configuration conf, PillowPrinter pillowPrinter) {
//		conf.remove("afEfanXtra.logLibraries")
//		conf["afPillow.logLibraries"] = |->| { pillowPrinter.logLibraries }
//	}
	
	@Contribute { serviceType=StackFrameFilter# }
	static Void contributeStackFrameFilter(Configuration config) {
		// remove boring Alien-Factory stack frames
		config.add("^afEfan::.*\$")
		config.add("^afEfanXtra::.*\$")
		config.add("^afPillow::.*\$")
	}
}


