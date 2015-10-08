using afIoc
using afIocConfig
using afBedSheet
using afBounce

internal class TestDisableRouting : PillowTest {

	override Void setup() {
		server := BedServer(T_AppModule#).addModule(T_AppModule02#).startup
		client = server.makeClient
	}

	Void testDisableRouting() {
		client.errOn4xx.enabled = false
		res := client.get(`/contentTypeExplicit`)
		verifyEq(res.statusCode, 404)
	}
}

internal class TestDisableRouting2 : PillowTest {
	Void testDisableRouting() {
		client.errOn4xx.enabled = false
		res := client.get(`/disableRoutes`)
		verifyEq(res.statusCode, 404)
	}
}

internal const class T_AppModule02 {
	@Contribute { serviceType=Routes# }
	static Void contributeRoutes(Configuration config) {
		config.remove("afPillow.pageRoutes")
	}
}