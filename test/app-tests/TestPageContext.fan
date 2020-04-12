using afIoc
using web

internal class TestPageContext : PillowTest {
	
	@Inject Pages? pages
	
	Void testBugFixEncodingPageCtx() {
		// this was an encoding bug with the Bushmasters contact page
		// see http://fantom.org/sidewalk/topic/2357

		// this tests the ENCODING
		url := pages[T_PageContext#].withContext(["venture:4x4"]).pageUrl
		verifyEq(url, `/pageContextStr/venture\:4x4`)
		verifyEq(url.encode, "/pageContextStr/venture%3A4x4")

		url = pages[T_PageContext#].withContext(["venture 4x4"]).pageUrl
		verifyEq(url, `/pageContextStr/venture 4x4`)
		verifyEq(url.encode, "/pageContextStr/venture%204x4")

		url = pages[T_PageContext#].withContext([null]).pageUrl
		verifyEq(url, `/pageContextStr/`)

		// Fantom Bug: see http://fantom.org/sidewalk/topic/2359
		url = pages[T_PageContext#].withContext([`foo/`]).pageUrl
		verifyEq(url, `foo/`)

		// this tests the DECODING
		res  := client.get(Uri.fromStr("/pageContextStr/em\\:ma"))
		text := res.body.str.split
		verifyEq(text[0], "context=em:ma")

		res  = client.get(Uri.fromStr("/pageContextStr/em\\\\ma"))
		text = res.body.str.split
		verifyEq(text[0], "context=em\\ma")

		res  = client.get(Uri.fromStr("/pageContextStr/em\\\\\\\\ma"))
		text = res.body.str.split
		verifyEq(text[0], "context=em\\\\ma")
	}
	
	Void testPageContextSingle() {
		res := client.get(`/pageContextStr/emma`)
		text := res.body.str.split
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
		verifyEq(res.body.str, ErrMsgs.invalidNumberOfPageArgs(T_PageContext#, 1, 1, ["Muhaha", `/blah`]))
	}

	Void testPageContextMulti() {
		res := client.get(`/pageContextStrMulti/emma/69`)
		text := res.body.str.split
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
		verifyEq(res.body.str, ErrMsgs.invalidNumberOfPageArgs(T_PageContextMulti#, 2, 2, ["Muhaha"]))
	}
}
