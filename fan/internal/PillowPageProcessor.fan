using afIoc::Inject
using afBedSheet::HttpStatus
using afBedSheet::RouteMatch
using afBedSheet::ResponseProcessor
using afBedSheet::ValueEncoders
using afBedSheet::ValueEncodingErr

internal const class PillowPageProcessor : ResponseProcessor {
	@Inject private const Pages				pages
	@Inject	private const ValueEncoders		valueEncoders
	@Inject	private const |->RouteMatch|	routeMatchFn

	new make(|This|in) { in(this)}

	override Obj process(Obj response) {
		pillowRes	:= (PillowPageResponse) response
//		methodArgs 	:= convertArgs(pillowRes.initRender.pageType, routeMatch.wildcards)
		// FIXME do we need to convert the args here?
		pageMeta	:= pages.pageMeta(pillowRes.pageType).withContext(routeMatch.wildcards)
		return pageMeta
	}

	** Convert the Str from Routes into real arg objs
	private Obj?[] convertArgs(Method method, Obj?[] argsIn) {
		try
			return argsIn.map |arg, i -> Obj?| {
				// guard against having more args than the method has params! 
				// Should never happen if the Routes do their job!
				paramType	:= method.params.getSafe(i)?.type
				if (paramType == null)
					return arg
				return arg is Str ? valueEncoders.toValue(paramType, arg) : arg
			}

		// if the args can't be converted then clearly the URL doesn't exist!
		catch (ValueEncodingErr valEncErr)
			throw HttpStatus.makeErr(404, valEncErr.msg, valEncErr)
	}
	
	private RouteMatch routeMatch() { routeMatchFn() }
}
