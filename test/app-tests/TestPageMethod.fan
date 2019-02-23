using afButter::ButterRequest

internal class TestMethod : PillowTest {
	
	Void testPageMethod() {
		client.errOn4xx.enabled = false
		res := client.get(`/pageMethod`)
		verifyEq(res.statusCode, 404)

		res = client.postStr(`/pageMethod`, "wotever")
		verifyEq(res.body.str, "POST Rendered")
	}

	Void testPageEventMethod() {
		client.errOn4xx.enabled = false
		res := client.get(`/pageMethod/getsome`)
		verifyEq(res.statusCode, 404)

		res = client.postStr(`/pageMethod/getsome`, "wotever")
		verifyEq(res.body.str, "POST Event Rendered")
	}

	Void testGetHead() {
		// test GET
		res := client.get(`/welcome`)
		verifyEq(res.headers.contentLength, 31)
		verifyEq(res.body.str, "WelcomePage ClientUri: /welcome")
		
		// test HEAD
		res = client.sendRequest(ButterRequest(`/welcome`) { it.method = "HEAD" })
		verifyEq(res.headers.contentLength, 31)
		verifyEq(res.body.str, "")
	}
}
