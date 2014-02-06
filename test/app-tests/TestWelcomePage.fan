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

	Void testWelcomePageOnWithContext() {
		start(T_AppModule09#)
		res := client.get(`/dude`)
		verifyEq(res.asStr, "pageUri:/dude ctx:dude")

		res = client.get(`/welcome2`)
		verifyEq(res.asStr, "pageUri:/welcome2 ctx:welcome2")

		// I have no say over the page ordering in the resulting Routes - I wanted the XXX pillow page to appear before
		// welcome2 to make a failing test. The idea is that welcome pages with ctx (e.g. `/*`) are after normal page 
		// URIs (e.g. `/mypage`) so they act as a sweeper and don't interfere with normal pages. 
//		res = client.get(`/xxx`)
//		verifyEq(res.asStr, "XXX")
	}

	Void testWelcomePageOnWithEvent() {
		// events are less likely to conflict because they usually have a ctx 
		start(T_AppModule10#)
		res := client.get(`/xxx/vicky`)
		verifyEq(res.asStr, "xxx pageUri:/ ctx:vicky")

		res = client.get(`/xxx`)
		verifyEq(res.asStr, "XXX")
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

internal class T_AppModule09 {
	@Contribute { serviceType=ApplicationDefaults# }
	static Void contributeApplicationDefaults(MappedConfig config) {
		config[PillowConfigIds.welcomePageName] 	= "welcome2"
		config[PillowConfigIds.welcomePageStrategy] = WelcomePageStrategy.onWithRedirects
	}
	@Contribute { serviceId="Routes" }
	internal static Void contributeRoutes(OrderedConfig config, Pages pages, IocConfigSource icoConfigSrc) {
		config.addOrdered("XXX", Route(`/xxx`, Text.fromPlain("XXX")), ["after: PillowEnd"])
	}
}

internal class T_AppModule10 {
	@Contribute { serviceType=ApplicationDefaults# }
	static Void contributeApplicationDefaults(MappedConfig config) {
		config[PillowConfigIds.welcomePageName] 	= "welcome3"
		config[PillowConfigIds.welcomePageStrategy] = WelcomePageStrategy.onWithRedirects
	}
	@Contribute { serviceId="Routes" }
	internal static Void contributeRoutes(OrderedConfig config, Pages pages, IocConfigSource icoConfigSrc) {
		config.addOrdered("XXX", Route(`/xxx`, Text.fromPlain("XXX")), ["after: PillowEnd"])
	}
}