
internal class TestOptionalInitParams : PillowTest {

	Void testOptionalInitParams() {
		client.errOn4xx.enabled = false

		// ... Optional ...
		res := client.get(`/initParamOptional/`)
		verifyEq(res.statusCode, 200)
		verifyEq(res.body.str, "null")

		res = client.get(`/initParamOptional`)
		verifyEq(res.statusCode, 200)
		verifyEq(res.body.str, "null")
	}

	Void testOptionalPageCtx() {
		client.errOn4xx.enabled = false

		// ... Optional ...
		res := client.get(`/pageCtxOptional/`)
		verifyEq(res.statusCode, 200)
		verifyEq(res.body.str, "null")

		res = client.get(`/pageCtxOptional`)
		verifyEq(res.statusCode, 200)
		verifyEq(res.body.str, "null")
	}
}
