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

	Void defineServices(RegistryBuilder defs) {
		defs.addService(Pages#)
		defs.addService(PillowPrinter#)
		defs.addService(ContentTypeResolver#)
		defs.addService(PageUrlResolver#)
		defs.addService(PageFinder#)
	}

	internal Void onRegistryStartup(Configuration conf, PillowPrinter pillowPrinter) {
		conf.remove("afEfanXtra.logLibraries")
		conf.set("afPillow.logLibraries", |->| { pillowPrinter.logLibraries }).after("afIoc.logServices")
	}

	@Override
	ComponentFinder overrideComponentFinder() {
		ComponentFinderImpl()
	}
	
	@Override
	TemplateDirectories overrideTemplateDirectories(File[] templateDirs) {
		// if no configuration is given, default to etc/web-pages/ and etc/web-components/ 
		if (templateDirs.isEmpty) {
			`etc/web-pages/`	 .toFile.walk { if (it.isDir) templateDirs.add(it) }
			`etc/web-components/`.toFile.walk { if (it.isDir) templateDirs.add(it) }
		}
		return TemplateDirectoriesImpl(templateDirs)
	}
	
	@Contribute { serviceType=DependencyProviders# }
	internal Void contributeDependencyProviders(Configuration config) {
		config["afPillow.pageMetaProvider"] = config.build(PageMetaProvider#)
	}
	
	@Contribute { serviceType=EfanLibraries# }
	Void contributeEfanLibraries(Configuration config, BedSheetServer bedServer) {
		if (bedServer.appPod != null)
			config["app"] = bedServer.appPod
	}

	@Contribute { serviceType=ComponentCompiler# }
	Void contributeComponentCompilerCallbacks(Configuration config) {
		pageCompiler := (PageCompiler) config.build(PageCompiler#)
		config.add(pageCompiler.callback)
	}

	@Contribute { serviceType=Routes# }
	Void contributeRoutes(Configuration config) {
		routeFactory := (PillowRouteFactory) config.build(PillowRouteFactory#)		
		config["afPillow.pageRoutes"] = routeFactory.pillowPageRoutes
	}

	@Contribute { serviceType=PageUrlResolver# } 
	Void contributePageUrlResolvers(Configuration config) {
		config["afPillow.fromPageFacet"]	= ResolvePageUrlFromPageFacet()
		config["afPillow.fromTypeName"]		= ResolvePageUrlFromTypeName()
	}
	
	@Contribute { serviceType=ContentTypeResolver# } 
	Void contributeContentTypeResolvers(Configuration config) {
		config["afPillow.fromPageFacet"]			= ResolveContentTypeFromPageFacet()
		config["afPillow.fromTemplateExtension"]	= config.build(ResolveContentTypeFromTemplateExtension#)
	}

	@Contribute { serviceType=ResponseProcessors# }
	Void contributeResponseProcessors(Configuration config) {
		config[PageMeta#] = config.build(PageMetaResponseProcessor#)
	}
	
	@Contribute { serviceType=TemplateFinders# }
	Void contributeTemplateFinders(Configuration config) {
		config["afPillow.findByPageFacetValue"]	= config.build(FindEfanByPageFacetValue#)
	}

	@Contribute { serviceType=FactoryDefaults# }
	Void contributeFactoryDefaults(Configuration config) {
		config[PillowConfigIds.defaultContentType]	= MimeType("text/html; charset=utf-8")
		config[PillowConfigIds.welcomePageName]		= "index"
		config[PillowConfigIds.welcomePageStrategy]	= WelcomePageStrategy.onWithRedirects
		config[PillowConfigIds.cacheControl]		= "max-age=0, no-cache"
	}

	@Contribute { serviceType=NotFoundPrinterHtml# }
	internal Void contributeNotFoundPrinterHtml(Configuration config, PillowPrinter printer) {
		config.set("afPillow.pillowPages",	|WebOutStream out| { printer.printPillowPages(out) }).after("afBedSheet.routeCode").before("afBedSheet.routes")
	}

	@Contribute { serviceType=ErrPrinterHtml# }
	internal Void contributeErrPrinterHtml(Configuration config, PillowPrinter printer) {
		config.set("afPillow.pillowPages",	|WebOutStream out, Err? err| { printer.printPillowPages(out) }).after("afBedSheet.iocConfig").before("afBedSheet.routes")
	}
	
	@Contribute { serviceType=StackFrameFilter# }
	Void contributeStackFrameFilter(Configuration config) {
		// remove boring Alien-Factory stack frames
		config.add("^afEfan::.*\$")
		config.add("^afEfanXtra::.*\$")
		config.add("^afPillow::.*\$")
	}
}
