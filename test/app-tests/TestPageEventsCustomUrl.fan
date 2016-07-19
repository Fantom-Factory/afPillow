using afBounce

internal class TestPageEventsCustomUrl : PillowTest {
	
	Void testPageLink() {
		client.get(`/customUrl/peace/custom/out/url`)
		
		Element("#arg1").verifyTextEq("peace")
		Element("#arg2").verifyTextEq("out")
		
		Link("#pageLink").verifyHrefEq(`/customUrl/peace/custom/out/url`)
	}

	Void testPageEvent() {
		client.get(`/customUrl/peace/custom/out/url`)

		// we don't do anything special (yet) with the event ctx
		plainEvent := Link("#plainEvent")
		plainEvent.verifyHrefEq(`/customUrl/peace/custom/out/url/plainEvent`)

		res := plainEvent.click
		verifyEq(res.body.str, "Plain Event Fired!")
	}

	Void testPageEventWithCtx() {
		client.get(`/customUrl/peace/custom/out/url`)

//		echo(client.lastResponse.body.str)

		// we don't do anything special (yet) with the event ctx
		event := Link("#ctxEvent")
		verifyEq(event.href, `/customUrl/peace/custom/out/url/ctxEvent/Emma/69`)

		res := event.click
		verifyEq(res.body.str, "Event Ctx: name=Emma, iq=69")
	}
}
