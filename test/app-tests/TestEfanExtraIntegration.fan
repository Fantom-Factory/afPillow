using afIoc
using afPlastic::PlasticCompiler
using afBedSheet
using afIocConfig::ApplicationDefaults

internal class TestEfanXtraIntegration : Test {

	BedClient? client
	
	override Void setup() {
		server := BedServer(T_AppModule#).startup
		server.injectIntoFields(this)
		client = server.makeClient
	}

	override Void teardown() {
		client?.shutdown
	}	

	Void testPageMapping404() {
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
