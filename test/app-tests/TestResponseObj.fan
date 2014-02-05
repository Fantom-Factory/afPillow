using afButter
using afBounce

internal class TestResponseObj : PillowTest {
	
	Void testResponseObj() {
		res := client.get(`/responseObj`)
		verifyEq(res.asStr, "WelcomePage ClientUri: /")
	}
	
}
