using afIoc
using afBounce

internal abstract class PillowTest : Test {
	BedClient? client
	
	override Void setup() {
		Log.get("afIoc").level 		= LogLevel.warn
		Log.get("afIocEnv").level 	= LogLevel.warn
		Log.get("afBedSheet").level	= LogLevel.warn
		Log.get("afPillow").level	= LogLevel.warn
		
		server := BedServer(T_AppModule#).startup
		server.injectIntoFields(this)
		client = server.makeClient
	}

	override Void teardown() {
		client?.shutdown
	}	
}
