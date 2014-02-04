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
		verifyEq(res.asStr, "Ctx Event: name=Emma, iq=69")
	}

}
