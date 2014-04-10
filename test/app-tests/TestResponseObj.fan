using afButter
using afBounce

internal class TestResponseObj : PillowTest {
	
	// TODO: make BedSheet ReProcessErr take a non-const obj
	Void testResponseObj() {
		res := client.get(`/responseObj`)
		verifyEq(res.asStr, "WelcomePage ClientUri: /welcome")
	}
	
}
