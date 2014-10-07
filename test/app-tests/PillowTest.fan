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

	protected Void verifyErrMsg(Type errType, Str errMsg, |Obj| func) {
		try {
			func(4)
		} catch (Err e) {
			if (!e.typeof.fits(errType)) 
				throw Err("Expected $errType got $e.typeof", e)
			verifyEq(errMsg, e.msg)	// this gives the Str comparator in eclipse
			return
		}
		throw Err("$errType not thrown")
	}
}
