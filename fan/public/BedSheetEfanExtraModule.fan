using afIoc
using afIocConfig
using afBedSheet
using afEfanExtra
using afPlastic

** The [afIoc]`http://repo.status302.com/doc/afIoc/#overview` module class.
** 
** This class is public so it may be referenced explicitly in tests.
class BedSheetEfanExtraModule {

	static Void bind(ServiceBinder binder) {
		binder.bindImpl(PagePipeline#)
		binder.bindImpl(Pages#)
		binder.bindImpl(BedSheetEfanExtraPrinter#)
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
	
	@Contribute { serviceType=ApplicationDefaults# }
	internal static Void contributeApplicationDefaults(MappedConfig config) {
		// we'll do our own logging thanks!
		config[EfanConfigIds.supressStartupLogging]	= true
	}
	
	@Contribute { serviceType=RegistryStartup# }
	internal static Void contributeRegistryStartup(OrderedConfig conf, BedSheetEfanExtraPrinter efanPrinter) {
		conf.add |->| {
			efanPrinter.logLibraries
		}
	}	
}
