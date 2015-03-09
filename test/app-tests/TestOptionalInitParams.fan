using afIoc
using afIocConfig
using afBedSheet
using afBounce

internal class TestOptionalInitParams : PillowTest {

	@Inject Pages? pages
	
//	Void testOptionalInitParams() {
//		url := pages[T_OptionalInitParams#].withContext("a b c".split).pageUrl
//		res := client.get(url)
//		verifyEq(res.asStr, "a b c")
//
//		url = pages[T_OptionalInitParams#].withContext("a b".split).pageUrl
//		res = client.get(url)
//		verifyEq(res.asStr, "a b null")
//
//		url = pages[T_OptionalInitParams#].withContext("a".split).pageUrl
//		res = client.get(url)
//		verifyEq(res.asStr, "a dodaa null")
//
//		verifyErrMsg(ArgErr#, ErrMsgs.invalidNumberOfInitArgs(T_OptionalInitParams#, 1, [,])) {
//			pages[T_OptionalInitParams#].withContext(null).pageUrl
//		}
//
//		client.errOn4xx.enabled = false
//		url = url.toStr[0..<-2].toUri
//		res = client.get(url)
//		verifyEq(res.statusCode, 404)
//	}
//
//	Void testOptionalPageCtxs() {
//		url := pages[T_OptionalPageCtxs#].withContext("a b c".split).pageUrl
//		res := client.get(url)
//		verifyEq(res.asStr, "a b c")
//
//		url = pages[T_OptionalPageCtxs#].withContext("a b".split).pageUrl
//		res = client.get(url)
//		verifyEq(res.asStr, "a b null")
//
//		url = pages[T_OptionalPageCtxs#].withContext("a".split).pageUrl
//		res = client.get(url)
//		verifyEq(res.asStr, "a null null")
//
//		verifyErrMsg(ArgErr#, ErrMsgs.invalidNumberOfInitArgs(T_OptionalPageCtxs#, 1, [,])) {
//			pages[T_OptionalPageCtxs#].withContext(null).pageUrl
//		}
//
//		client.errOn4xx.enabled = false
//		url = url.toStr[0..<-2].toUri
//		res = client.get(url)
//		verifyEq(res.statusCode, 404)
//	}
	
	Void testNullableVsOptionalInitParams() {
		client.errOn4xx.enabled = false

		// ... Nullable ...
		res := client.get(`/initParamNullable/`)
		verifyEq(res.statusCode, 200)
		verifyEq(res.body.str, "null")

		res = client.get(`/initParamNullable`)
		verifyEq(res.statusCode, 404)
		
		// ... vs Optional ...
		res = client.get(`/initParamOptional/`)
		verifyEq(res.statusCode, 200)
		verifyEq(res.body.str, "null")

		res = client.get(`/initParamOptional`)
		verifyEq(res.statusCode, 200)
		verifyEq(res.body.str, "null")
	}

	Void testNullableVsOptionalPageCtx() {
		client.errOn4xx.enabled = false

		// ... Nullable ...
		res := client.get(`/pageCtxNullable/`)
		verifyEq(res.statusCode, 200)
		verifyEq(res.body.str, "null")

		res = client.get(`/pageCtxNullable`)
		verifyEq(res.statusCode, 404)
		
		// ... vs Optional ...
		res = client.get(`/pageCtxOptional/`)
		verifyEq(res.statusCode, 200)
		verifyEq(res.body.str, "null")

		res = client.get(`/pageCtxOptional`)
		verifyEq(res.statusCode, 200)
		verifyEq(res.body.str, "null")
	}
}
