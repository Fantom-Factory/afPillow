using afButter
using afBounce

internal class TestContentType : PillowTest {
	
	Void testContentTypeExplicit() {
		res := client.get(`/contentTypeExplicit`)
		verifyEq(res.asStr, "ContentType = wot/ever")
		verifyEq(res.headers.contentType, MimeType("wot/ever"))		
	}
	
	Void testContentTypeHtml() {
		res := client.get(`/contentTypeHtml`)
		verifyEq(res.asStr, "ContentType = html")
		verifyEq(res.headers.contentType, MimeType.forExt("html"))
	}

	Void testContentTypeXhtml() {
		res := client.get(`/contentTypeXhtml`)
		verifyEq(res.asStr, "ContentType = xhtml")
		verifyEq(res.headers.contentType, MimeType("application/xhtml+xml; charset=utf-8"))
	}

	Void testContentTypeDefault() {
		res := client.get(`/contentTypeDefault`)
		verifyEq(res.asStr, "ContentType = default")
		verifyEq(res.headers.contentType, MimeType("text/plain"))
	}
}
