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
		verifyEq(client.lastResponse.headers.getFirst("X-Pillow-renderedPage"), T_HeaderRender#.qname)

		client.get(`/headerEvent/event/ctx`)
		verifyEq(client.lastResponse.headers.getFirst("X-Pillow-calledEvent"), T_HeaderEvent#event.qname)
	}

	Void testHeadersInProd() {
		start(T_AppModule12#)

		client.get(`/headerRender/ctx`)
		verifyNull(client.lastResponse.headers.getFirst("X-Pillow-renderedPage"))

		client.get(`/headerEvent/event/ctx`)
		verifyNull(client.lastResponse.headers.getFirst("X-Pillow-calledEvent"))
	}

	override Void setup() {	}
	private Void start(Type module) {
		server := BedServer(T_AppModule#).addModule(module).startup
		client = server.makeClient
	}
}

internal class T_AppModule11 {
	@Contribute { serviceType=ServiceOverrides# }
	static Void contributeServiceOverride(MappedConfig config) {
		config["IocEnv"] = IocEnv.fromStr("Dev")
	}
}

internal class T_AppModule12 {
	@Contribute { serviceType=ServiceOverrides# }
	static Void contributeServiceOverride(MappedConfig config) {
		config["IocEnv"] = IocEnv.fromStr("Prod")
	}
}

@NoDoc
@Page { url=`/headerRender` }
const mixin T_HeaderRender : EfanComponent {
	@Inject			abstract PageMeta	pageMeta
	@PageContext	abstract Str		context	
	override Str renderTemplate() { "pageUri:${pageMeta.pageUri} ctx:${context}" }
}

@NoDoc
@Page { url=`/headerEvent` }
const mixin T_HeaderEvent : EfanComponent {
	@Inject			abstract PageMeta	pageMeta
	@PageEvent
	Obj event(Str ctx) { Text.fromPlain("event pageUri:${pageMeta.pageUri} ctx:${ctx}") }
	override Str renderTemplate() { "wotever" }
}


