using afBedSheet

internal class TestInitSigRoute : PillowTest {

	Void testCorrectRoutes() {
		res := client.get(`/Init/Sig/Route/69/Dude!`)
		verifyEq(res.statusCode, 200)
		verifyEq(res.asStr, "Int X := 69; Str Y := Dude!")
	}

	Void testRoutingMismatch1() {
		res := client.get(`/Init/Sig/Route/69/Dude/tooMuch`)
		verifyEq(res.statusCode, 404)
	}

	Void testRoutingMismatch2() {
		res := client.get(`/Init/Sig/Route/Dude/69`)
		verifyEq(res.statusCode, 404)
	}

	Void testRoutingMismatch3() {
		res := client.get(`/Init/Sig/Route/69`)
		verifyEq(res.statusCode, 404)
	}
	
	Void testInitRenderReturnValue() {
		res := client.get(`/Initreturnvalue`)
		verifyEq(res.asStr, "Train trouble.")
	}
}
