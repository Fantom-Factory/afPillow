using afIoc
using afBounce

internal abstract class PillowTest : Test {
	BedClient? client
	
	override Void setup() {
		disableLogs
		server := BedServer(T_AppModule#).startup
		server.inject(this)
		client = server.makeClient
	}

	Void disableLogs() {		
		Log.get("afIoc").level 		= LogLevel.warn
		Log.get("afIocEnv").level 	= LogLevel.warn
		Log.get("afBedSheet").level	= LogLevel.warn
//		Log.get("afPillow").level	= LogLevel.warn
	}
	
	override Void teardown() {
		client?.shutdown
	}	
}
