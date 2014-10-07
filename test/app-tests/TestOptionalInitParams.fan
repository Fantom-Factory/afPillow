using afIoc
using afIocConfig
using afBedSheet
using afBounce

internal class TestOptionalInitParams : PillowTest {

	@Inject Pages? pages
	
	Void testOptionalInitParams() {
		url := pages[T_OptionalInitParams1#].withContext("a b c".split).pageUrl
		res := client.get(url)
		verifyEq(res.asStr, "a b c")

		url = pages[T_OptionalInitParams1#].withContext("a b".split).pageUrl
		res = client.get(url)
		verifyEq(res.asStr, "a b null")

		url = pages[T_OptionalInitParams1#].withContext("a".split).pageUrl
		res = client.get(url)
		verifyEq(res.asStr, "a dodaa null")

		verifyErrMsg(ArgErr#, ErrMsgs.invalidNumberOfInitArgs(T_OptionalInitParams1#, 1, [,])) {
			pages[T_OptionalInitParams1#].withContext(null).pageUrl
		}

		client.errOn4xx.enabled = false
		url = url.toStr[0..<-2].toUri
		res = client.get(url)
		verifyEq(res.statusCode, 404)
	}
}
