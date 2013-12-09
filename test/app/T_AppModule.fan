using afIoc
using afIocConfig
using afBedSheet
using afEfanXtra

@SubModule { modules=[PillowModule#, EfanXtraModule#] }
internal const class T_AppModule {
	
	static Void bind(ServiceBinder binder) {
//		binder.bindImpl(Router#)
	}

	@Contribute { serviceType=Routes# }
	static Void contributeRoutes(OrderedConfig config) {
		config.add(Route(`/anything`, 	Str#toStr))
	}
	
	@Contribute { serviceType=ApplicationDefaults# }
	static Void contributeAppDefaults(MappedConfig config) {
		config[afPillow::PillowConfigIds.welcomePage] = "welcomepage"
	}
	
}
