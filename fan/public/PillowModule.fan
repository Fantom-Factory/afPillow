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
		binder.bindImpl(PagePipeline#)
		binder.bindImpl(Pages#)
		binder.bindImpl(PillowPrinter#)
		binder.bindImpl(EfanPageMeta#).withScope(ServiceScope.perThread)
	}
	
	@Contribute { serviceType=HttpPipeline# }
	internal static Void contributeHttpPipeline(OrderedConfig config, PagePipeline pagePipeline) {
		config.addOrdered("PagePipeline", pagePipeline, ["after: BedSheetFilters"])
	}

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

	@Contribute { serviceType=Routes# }
	static Void contributeRoutes(OrderedConfig config, Pages pages, ComponentMeta componentMeta) {

		pages.pageTypes.each |pageType| {
			initMeth := componentMeta.findMethod(pageType, InitRender#)
			noOfParams := initMeth?.params?.size ?: 0
			regex := ""
			noOfParams.times { regex += "/*" }
			clientUri := pages.clientUri(pageType)
			config.add(Route(`${clientUri}${regex}`, PageRenderFactory(pageType)))
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
	}

	@Contribute { serviceType=RegistryStartup# }
	internal static Void contributeRegistryStartup(OrderedConfig conf, PillowPrinter efanPrinter) {
		conf.add |->| {
			efanPrinter.logLibraries
		}
	}	
}

internal const class PageRenderFactory : RouteResponseFactory {
	const Type pageType
	
	new make(Type pageType) {
		this.pageType = pageType
	}
	
	override Bool matchSegments(Str?[] segments) {
		return true
	}

	override Obj? createResponse(Str?[] segments) {
		// segments is RO and (internally) needs to be a Str, so we create a new list
		MethodCall(Pages#renderPageToText, [pageType, segments])
	}
}

