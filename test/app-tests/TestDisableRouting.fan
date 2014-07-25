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

internal class T_AppModule02 {
	@Contribute { serviceType=ApplicationDefaults# }
	static Void contributeApplicationDefaults(Configuration config) {
		config[PillowConfigIds.enableRouting] = false
	}
}