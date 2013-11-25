using afIoc
using afBedSheet
using afEfanExtra

@SubModule { modules=[BedSheetEfanExtraModule#, EfanExtraModule#] }
internal const class T_AppModule {
	
	static Void bind(ServiceBinder binder) {
//		binder.bindImpl(Router#)
	}

	@Contribute { serviceType=Routes# }
	static Void contributeRoutes(OrderedConfig conf) {
		conf.add(Route(`/anything`, 	Str#toStr))
	}
}
