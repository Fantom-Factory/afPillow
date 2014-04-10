using afIoc
using afBounce

internal abstract class PillowTest : Test {
	BedClient? client
	
	override Void setup() {
		server := BedServer(T_AppModule#).startup
		server.injectIntoFields(this)
		client = server.makeClient
	}

	override Void teardown() {
		client?.shutdown
	}	
}
