using afBounce

internal class TestPageEvents : PillowTest {
	
	Void testPageEvent() {
		client.get(`/pageEvents`)
		plainEvent := Link("#plainEvent")
		verifyEq(plainEvent.href, "/pageEvents/plainEvent")

		res := plainEvent.click
		verifyEq(res.asStr, "Plain Event Fired!")
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
}
