using afBounce

internal class TestMethod : PillowTest {
	
	Void testPageMethod() {
		client.errOn4xx.enabled = false
		res := client.get(`/pageMethod`)
		verifyEq(res.statusCode, 404)

		res = client.postStr(`/pageMethod`, "wotever")
		verifyEq(res.asStr, "POST Rendered")
	}

	Void testPageEventMethod() {
		client.errOn4xx.enabled = false
		res := client.get(`/pageMethod/getsome`)
		verifyEq(res.statusCode, 404)

		res = client.postStr(`/pageMethod/getsome`, "wotever")
		verifyEq(res.asStr, "POST Event Rendered")
	}

}
