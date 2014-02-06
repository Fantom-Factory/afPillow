using afIoc
using afIocConfig
using afBedSheet
using afBounce

internal class TestWelcomePage : PillowTest {

	Void testWelcomePageOffPageUri() {
		start(T_AppModule07#)
		res := client.get(`/welcome`)
		verifyEq(res.asStr, "WelcomePage ClientUri: /welcome")
	}

	Void testWelcomePageOnPageUri() {
		start(T_AppModule08#)
		res := client.get(`/`)
		verifyEq(res.asStr, "WelcomePage ClientUri: /")
	}

	override Void setup() {	}
	private Void start(Type module) {
		server := BedServer(T_AppModule#).addModule(module).startup
		client = server.makeClient
	}
}

internal class T_AppModule07 {
	@Contribute { serviceType=ApplicationDefaults# }
	static Void contributeApplicationDefaults(MappedConfig config) {
		config[PillowConfigIds.welcomePageName] 	= "welcome"
		config[PillowConfigIds.welcomePageStrategy] = WelcomePageStrategy.off
	}
}

internal class T_AppModule08 {
	@Contribute { serviceType=ApplicationDefaults# }
	static Void contributeApplicationDefaults(MappedConfig config) {
		config[PillowConfigIds.welcomePageName] 	= "welcome"
		config[PillowConfigIds.welcomePageStrategy] = WelcomePageStrategy.on
	}
}