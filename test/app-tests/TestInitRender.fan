using afBedSheet
using afEfanXtra

internal class TestInitRender : PillowTest {
	
	Void testInitMethodResponse() {
		client.errOn4xx.enabled = false
		res := client.get(`/initRender1`)
		verifyEq(res.statusCode, 469)
	}

	Void testInitMethodEventResponse() {
		client.errOn4xx.enabled = false
		res := client.get(`/initRender2/stuff`)
		verifyEq(res.statusCode, 469)
	}
}


@NoDoc
@Page { url=`/initRender1` }
const mixin T_InitRender1 : EfanComponent {
	@InitRender
	Obj? initRender() {
		return HttpStatus(469, "Bad Ass!")
	}
	override Str renderTemplate() { "FAIL" }
}

@NoDoc
@Page { url=`/initRender2` }
const mixin T_InitRender2 : EfanComponent {
	@InitRender
	Obj? initRender() {
		return HttpStatus(469, "Bad Ass!")
	}
	@PageEvent { httpMethod="GET" }
	Void stuff() {}
	override Str renderTemplate() { "FAIL" }
}