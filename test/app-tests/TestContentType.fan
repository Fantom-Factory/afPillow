using afButter
using afBounce

internal class TestContentType : PillowTest {
	
	Void testContentTypeExplicit() {
		res := client.get(`/contentTypeExplicit`)
		verifyEq(res.body.str, "ContentType = wot/ever")
		verifyEq(res.headers.contentType, MimeType("wot/ever"))		
	}
	
	Void testContentTypeHtml() {
		res := client.get(`/contentTypeHtml`)
		verifyEq(res.body.str, "ContentType = html")
		verifyEq(res.headers.contentType, MimeType.forExt("html"))
	}

	Void testContentTypeXhtml() {
		res := client.get(`/contentTypeXhtml`)
		verifyEq(res.body.str, "ContentType = xhtml")
		verifyEq(res.headers.contentType, MimeType("application/xhtml+xml; charset=utf-8"))
	}

	Void testContentTypeDefault() {
		res := client.get(`/contentTypeDefault`)
		verifyEq(res.body.str, "ContentType = default")
		verifyEq(res.headers.contentType, MimeType("text/plain"))
	}
}
