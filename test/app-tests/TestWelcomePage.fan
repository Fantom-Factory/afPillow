using afBedSheet

internal class TestWelcomePage : EfanTest {

	// TODO: welcome page redirects
//	Void testWelcomePageRediretsToDirectory() {
//		res := client.get(`/WelcomePage`)
//		verifyEq(res.statusCode, 307)
//		verifyEq(res.headers["Location"], "/")
//	}

	Void testWelcomePageRendersCorrectClientUri() {
		res := client.get(`/`)
		verifyEq(res.statusCode, 200)
		verifyEq(res.asStr, "WelcomePage ClientUri: /")
	}
}
