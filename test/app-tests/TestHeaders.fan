using afIoc
using afIocConfig
using afIocEnv
using afBedSheet
using afBounce
using afEfanXtra

internal class TestHeaders : PillowTest {

	Void testCacheHeadersInDev() {
		start(T_AppModule11#)

		res := client.get(`/headerRender/ctx`)
		verifyNull(res.headers.cacheControl)

		res = client.get(`/headerEvent/eventPage`)
		verifyNull(res.headers.cacheControl)
	}

	Void testCacheHeadersInProd() {
		start(T_AppModule12#)

		res := client.get(`/headerRender/ctx`)
		verifyEq(res.headers.cacheControl, "max-age=0, no-cache")

		res = client.get(`/headerEvent/eventPage`)
		verifyEq(res.headers.cacheControl, "max-age=0, no-cache")
	}

	Void testHeadersInDev() {
		start(T_AppModule11#)

		client.get(`/headerRender/ctx`)
		verifyEq(client.lastResponse.headers.getFirst("X-afPillow-renderedPage"), T_HeaderRender#.qname)

		client.get(`/headerEvent/event/ctx`)
		verifyEq(client.lastResponse.headers.getFirst("X-afPillow-calledEvent"), T_HeaderEvent#event.qname)
	}

	Void testHeadersInProd() {
		start(T_AppModule12#)

		client.get(`/headerRender/ctx`)
		verifyNull(client.lastResponse.headers.getFirst("X-afPillow-renderedPage"))

		client.get(`/headerEvent/event/ctx`)
		verifyNull(client.lastResponse.headers.getFirst("X-afPillow-calledEvent"))
	}

	override Void setup() {	}
	private Void start(Type module) {
		server := BedServer(T_AppModule#).addModule(module).startup
		client = server.makeClient
	}
}

internal class T_AppModule11 {
	@Override
	static IocEnv overrideIocEnv() {
		IocEnv.fromStr("Dev")
	}
}

internal class T_AppModule12 {
	@Override
	static IocEnv overrideIocEnv() {
		IocEnv.fromStr("Prod")
	}
}

@NoDoc
@Page { url=`/headerRender` }
const mixin T_HeaderRender : EfanComponent {
	@Inject			abstract PageMeta	pageMeta
	@PageContext	abstract Str		context	
	override Str renderTemplate() { "pageUrl:${pageMeta.pageUrl} ctx:${context}" }
}

@NoDoc
@Page { url=`/headerEvent` }
const mixin T_HeaderEvent : EfanComponent {
	@Inject			abstract PageMeta	pageMeta
	@PageEvent
	Obj event(Str ctx) { Text.fromPlain("event pageUrl:${pageMeta.pageUrl} ctx:${ctx}") }
	@PageEvent
	Void eventPage() { }
	override Str renderTemplate() { "wotever" }
}


