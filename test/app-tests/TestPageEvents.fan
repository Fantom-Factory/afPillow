using afBounce

internal class TestPageEvents : PillowTest {
	
	Void testPageEvent() {
		client.get(`/pageEvents`)
		plainEvent := Link("#plainEvent")
		verifyEq(plainEvent.href, "/pageEvents/plainEvent")

		res := plainEvent.click
		verifyEq(res.asStr, "Plain Event Fired!")
	}

	Void testPageEventWithFacetName() {
		client.get(`/pageEvents`)
		plainEvent := Link("#namedEvent")
		verifyEq(plainEvent.href, "/pageEvents/dingdong")

		res := plainEvent.click
		verifyEq(res.asStr, "Ding Dong Event Fired!")
	}

	Void testVoidReturnValueRendersSamePage() {
		client.get(`/pageEvents`)
		plainEvent := Link("#defaultReturnValue")
		verifyEq(plainEvent.href, "/pageEvents/defaultReturnValue")

		res := plainEvent.click
		verifyEq(res.headers["X-afPillow-renderedPage"], T_PageEvents#.qname)
	}

	Void testPageEventWithCtx() {
		client.get(`/pageEvents`)
		event := Link("#ctxEvent")
		verifyEq(event.href, "/pageEvents/ctxEvent/Emma/69")

		res := event.click
		verifyEq(res.asStr, "Event Ctx: name=Emma, iq=69")
	}

	Void testPageCtxEvent() {
		client.get(`/pageCtxEvents/Debs/2`)
		event := Link("#plainEvent")
		verifyEq(event.href, "/pageCtxEvents/Debs/2/plainEvent")

		res := event.click.asStr.splitLines
		verifyEq(res[0], "Plain Event Fired!")
		verifyEq(res[1], "Page Ctx: name=Debs, iq=2")
	}

	Void testPageCtxEventWithCtx() {
		client.get(`/pageCtxEvents/Debs/2`)
		event := Link("#ctxEvent")
		verifyEq(event.href, "/pageCtxEvents/Debs/2/ctxEvent/Emma/69")

		res := event.click.asStr.splitLines
		verifyEq(res[0], "Page Ctx: name=Debs, iq=2")
		verifyEq(res[1], "Event Ctx: name=Emma, iq=69")
	}

	Void testPageCtxEventKeepsVarsThroughToRender() {
		client.get(`/pageCtxEvents/wotever/-1/setVars/Emma/69`)

		Element("#ctxName").verifyTextEq("Emma")
		Element("#ctxIq").verifyTextEq("69")
	}
}
