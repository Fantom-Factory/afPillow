using afIoc
using afBedSheet
using afEfanExtra
using afPlastic

class BedSheetEfanExtraModule {

	static Void bind(ServiceBinder binder) {
		binder.bindImpl(PagePipeline#)
		binder.bindImpl(PageFinder#)
		binder.bindImpl(Pages#)		
	}
	
	@Contribute { serviceType=HttpPipeline# }
	static Void contributeHttpPipeline(OrderedConfig config, PagePipeline pagePipeline) {
		config.addOrdered("PagePipeline", pagePipeline, ["after: BedSheetFilters"])
	}

	@Contribute { serviceType=EfanLibraries# }
	internal static Void contributeEfanLibraries(MappedConfig config, BedSheetMetaData meta) {
		config["app"] = meta.appPod
	}
	
	@Contribute { serviceType=ComponentCompiler# }
	internal static Void contributeComponentCompilerCallbacks(OrderedConfig config, BedSheetMetaData meta) {
		config.add(|PlasticClassModel model| {
			model.usingPod(meta.appPod)
		})
	}	
}
