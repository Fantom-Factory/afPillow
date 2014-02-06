using afIoc
using afIocConfig
using afIocEnv
using afBedSheet
using afBounce
using afEfanXtra

internal class TestHeaders : PillowTest {

	Void testHeadersInDev() {
		start(T_AppModule11#)

		client.get(`/headerRender/ctx`)
		verifyEq(client.lastResponse.headers.getFirst("X-Pillow-Rendered-Page"), T_HeaderRender#.qname)

		client.get(`/headerEvent/event/ctx`)
		verifyEq(client.lastResponse.headers.getFirst("X-Pillow-Called-Event"), T_HeaderEvent#event.qname)
	}

	Void testHeadersInProd() {
		start(T_AppModule12#)

		client.get(`/headerRender/ctx`)
		verifyNull(client.lastResponse.headers.getFirst("X-Pillow-Rendered-Page"))

		client.get(`/headerEvent/event/ctx`)
		verifyNull(client.lastResponse.headers.getFirst("X-Pillow-Rendered-Page"))
	}

	override Void setup() {	}
	private Void start(Type module) {
		server := BedServer(T_AppModule#).addModule(module).startup
		client = server.makeClient
	}
}

internal class T_AppModule11 {
	@Contribute { serviceType=ServiceOverride# }
	static Void contributeServiceOverride(MappedConfig config) {
		config["IocEnv"] = IocEnv.fromStr("Dev")
	}
}

internal class T_AppModule12 {
	@Contribute { serviceType=ServiceOverride# }
	static Void contributeServiceOverride(MappedConfig config) {
		config["IocEnv"] = IocEnv.fromStr("Prod")
	}
}

@NoDoc
@Page { uri=`/headerRender`; template=`fan://afEfanXtra/res/viaRenderMethod.efan` }
const mixin T_HeaderRender : EfanComponent {
	@Inject			abstract PageMeta	pageMeta
	@PageContext	abstract Str		context	
	Str render() { "pageUri:${pageMeta.pageUri} ctx:${context}" }
}

@NoDoc
@Page { uri=`/headerEvent`; template=`fan://afEfanXtra/res/viaRenderMethod.efan` }
const mixin T_HeaderEvent : EfanComponent {
	@Inject			abstract PageMeta	pageMeta
	@PageEvent
	Obj event(Str ctx) { Text.fromPlain("event pageUri:${pageMeta.pageUri} ctx:${ctx}") }
	Str render() { "wotever" }
}


