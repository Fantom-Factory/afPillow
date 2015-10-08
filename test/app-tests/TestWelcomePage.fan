using afIoc
using afIocConfig
using afBedSheet
using afBounce

internal class TestWelcomePage : PillowTest {

	Void testWelcomePageOffPageUrl() {
		start(T_AppModule07#)
		res := client.get(`/welcome`)
		verifyEq(res.body.str, "WelcomePage ClientUri: /welcome")
	}

	Void testWelcomePageOnPageUrl() {
		start(T_AppModule08#)
		res := client.get(`/`)
		verifyEq(res.body.str, "WelcomePage ClientUri: /")
	}

	Void testWelcomePageOnWithContext() {
		start(T_AppModule09#)
		res := client.get(`/dude`)
		verifyEq(res.body.str, "pageUrl:/dude ctx:dude")

		res = client.get(`/welcome2`)
		verifyEq(res.body.str, "pageUrl:/welcome2 ctx:welcome2")

		// I have no say over the page ordering in the resulting Routes - I wanted the XX pillow page to appear before
		// welcome2 to make a failing test. The idea is that welcome pages with ctx (e.g. `/*`) are after normal page 
		// URIs (e.g. `/mypage`) so they act as a sweeper and don't interfere with normal pages. 
//		res = client.get(`/xxx`)
//		verifyEq(res.asStr, "XXX")
	}

	Void testWelcomePageOnWithEvent() {
		// events are less likely to conflict because they usually have a ctx 
		start(T_AppModule10#)
		res := client.get(`/xxx/vicky`)
		verifyEq(res.body.str, "xxx pageUrl:/ ctx:vicky")

		res = client.get(`/xxx`)
		verifyEq(res.body.str, "XXX")
	}

	override Void setup() {	}
	private Void start(Type module) {
		server := BedServer(T_AppModule#).addModule(module).startup
		client = server.makeClient
	}
}

internal const class T_AppModule07 {
	@Contribute { serviceType=ApplicationDefaults# }
	static Void contributeApplicationDefaults(Configuration config) {
		config[PillowConfigIds.welcomePageName] 	= "welcome"
		config[PillowConfigIds.welcomePageStrategy] = WelcomePageStrategy.off
	}
}

internal const class T_AppModule08 {
	@Contribute { serviceType=ApplicationDefaults# }
	static Void contributeApplicationDefaults(Configuration config) {
		config[PillowConfigIds.welcomePageName] 	= "welcome"
		config[PillowConfigIds.welcomePageStrategy] = WelcomePageStrategy.on
	}
}

internal const class T_AppModule09 {
	@Contribute { serviceType=ApplicationDefaults# }
	static Void contributeApplicationDefaults(Configuration config) {
		config[PillowConfigIds.welcomePageName] 	= "welcome2"
		config[PillowConfigIds.welcomePageStrategy] = WelcomePageStrategy.onWithRedirects
	}
	@Contribute { serviceType=Routes# }
	internal static Void contributeRoutes(Configuration config, Pages pages) {
		config.set("XXX", Route(`/xxx`, Text.fromPlain("XXX"))).after("afPillow.pageRoutes")
	}
}

internal const class T_AppModule10 {
	@Contribute { serviceType=ApplicationDefaults# }
	static Void contributeApplicationDefaults(Configuration config) {
		config[PillowConfigIds.welcomePageName] 	= "welcome3"
		config[PillowConfigIds.welcomePageStrategy] = WelcomePageStrategy.onWithRedirects
	}
	@Contribute { serviceType=Routes# }
	internal static Void contributeRoutes(Configuration config, Pages pages) {
		config.set("XXX", Route(`/xxx`, Text.fromPlain("XXX"))).after("afPillow.pageRoutes")
	}
}