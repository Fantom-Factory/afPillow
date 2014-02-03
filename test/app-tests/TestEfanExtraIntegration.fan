using afBedSheet

internal class TestEfanXtraIntegration : PillowTest {	

	Void testPageMapping404() {
		client.errOn4xx.enabled = false
		res := client.get(`/oops`)
		verifyEq(res.statusCode, 404)
	}

	Void testPageMappingBasic() {
		res := client.get(`/basic`)
		verifyEq(res.asStr, "Basic Mapping Okay")
	}

	Void testPageMappingBasicNested() {
		res := client.get(`/basic/nested`)
		verifyEq(res.asStr, "Nested Mapping Okay")
	}

	Void testPageMappingFacet() {
		res := client.get(`/facetRemapped`)
		verifyEq(res.asStr, "Facet Mapping Okay")
	}
}
