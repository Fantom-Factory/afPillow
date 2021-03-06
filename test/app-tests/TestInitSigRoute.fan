using afBedSheet

internal class TestInitSigRoute : PillowTest {

	Void testCorrectRoutes() {
		res := client.get(`/Init/Sig/Route/69/Dude!`)
		verifyEq(res.statusCode, 200)
		verifyEq(res.body.str, "Int X := 69; Str Y := Dude!")
	}

	Void testRoutingMismatch1() {
		client.errOn4xx.enabled = false
		res := client.get(`/Init/Sig/Route/69/Dude/tooMuch`)
		verifyEq(res.statusCode, 404)
	}

	Void testRoutingMismatch2() {
		client.errOn4xx.enabled = false
		res := client.get(`/Init/Sig/Route/Dude/69`)
		verifyEq(res.statusCode, 404)
	}

	Void testRoutingMismatch3() {
		client.errOn4xx.enabled = false
		res := client.get(`/Init/Sig/Route/69`)
		verifyEq(res.statusCode, 404)
	}
	
	Void testInitRenderReturnValue() {
		res := client.get(`/Initreturnvalue`)
		verifyEq(res.body.str, "Train trouble.")
	}
}
