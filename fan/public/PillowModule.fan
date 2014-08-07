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
	static Void contributeRoutes(Configuration config, Pages pages) {
		routeFactory := (PillowRouteFactory) config.autobuild(PillowRouteFactory#)
		routeFactory.addPillowRoutes(config)
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
		config[PillowConfigIds.enableRouting]		= true
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

	@Contribute { serviceType=RegistryStartup# }
	internal static Void contributeRegistryStartup(Configuration conf, PillowPrinter pillowPrinter) {
		conf.remove("afEfanXtra.logLibraries")
		conf["afPillow.logLibraries"] = |->| { pillowPrinter.logLibraries }
	}
	
	@Contribute { serviceType=StackFrameFilter# }
	static Void contributeStackFrameFilter(Configuration config) {
		// remove boring Alien-Factory stack frames
		config.add("^afEfan::.*\$")
		config.add("^afEfanXtra::.*\$")
		config.add("^afPillow::.*\$")
	}
}


