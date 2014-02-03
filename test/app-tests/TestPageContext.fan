
internal class TestPageContext : PillowTest {
	
	Void testPageContext() {
		res := client.get(`/pageContextStr/emma`)
		verifyEq(res.statusCode, 200)
		text := res.asStr.split
		verifyEq(text[0], "context=emma")
		verifyEq(text[1], "clientUri=/pageContextStr/emma")
		verifyEq(text[2], "clientUri=/pageContextStr/Dude")
	}
	

}
