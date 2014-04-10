
internal class TestPageContext : PillowTest {
	
	Void testPageContextSingle() {
		res := client.get(`/pageContextStr/emma`)
		text := res.asStr.split
		verifyEq(text[0], "context=emma")
		verifyEq(text[1], "clientUri=/pageContextStr/emma")
		verifyEq(text[2], "clientUri=/pageContextStr/Dude")
	}

	Void testPageContextSingle404() {
		client.errOn4xx.enabled = false
		
		res := client.get(`/pageContextStr`)
		verifyEq(res.statusCode, 404)

		res = client.get(`/pageContextStr/6/9`)
		verifyEq(res.statusCode, 404)
	}

	Void testPageContextSingleErr() {
		res := client.get(`/pageContextStr/err`)
		verifyEq(res.asStr, ErrMsgs.invalidNumberOfInitArgs(T_PageContext#, [Str#], ["Muhaha", `/blah`]))
	}

	Void testPageContextMulti() {
		res := client.get(`/pageContextStrMulti/emma/69`)
		text := res.asStr.split
		verifyEq(text[0], "context=emma/69")
		verifyEq(text[1], "clientUri=/pageContextStrMulti/emma/69")
		verifyEq(text[2], "singleUri=/pageContextStr/Dude")
		verifyEq(text[3], "clientUri=/pageContextStrMulti/Dude/666")
	}

	Void testPageContextMulti404() {
		client.errOn4xx.enabled = false
		
		res := client.get(`/pageContextStrMulti/emma`)
		verifyEq(res.statusCode, 404)

		res = client.get(`/pageContextStrMulti/emma/wot/ever`)
		verifyEq(res.statusCode, 404)
	}

	Void testPageContextMultiErr() {
		res := client.get(`/pageContextStrMulti/err/666`)
		// Page afPillow::T_PageContextMulti requires 2 init parameters but 1 were given: [Muhaha]
		verifyEq(res.asStr, ErrMsgs.invalidNumberOfInitArgs(T_PageContextMulti#, [Str#, Str#], ["Muhaha"]))
	}

}
