using afIoc::Inject
using afEfanExtra::EfanExtra

internal const class PageFinder {
		
	@Inject	private const EfanExtra	efanExtra

	new make(|This|in) { in(this) }
	
	Type? findPage(Uri url) {
		pageType := efanExtra.libraries.eachWhile |Str libName->Type?| {
			efanExtra.componentTypes(libName).eachWhile |Type comType->Type?| {
				if (!comType.fits(Page#))
					return null
				
				if (match(url, comType))
					return comType
				
				return null
			}
		}
		return pageType
	}

	
	internal Bool match(Uri uri, Type pageType) {
		pageName := pageType.name
		if (pageName.endsWith("Page"))
			pageName = pageName[0..-5]
		pageUri := pageName.toDisplayName.replace(" ", "/").lower
		return pageUri == uri.toStr
	}
	
	** Returns null if the given uri does not match the uri regex
//	internal Str?[]? matchUri(Uri uri) {
//		matcher := routeRegex.matcher(uri.pathOnly.toStr)
//		find := matcher.find 
//		if (!find)
//			return null
//		
//		groups := Str[,]
//		
//		// use find as supplied Regex may not have ^...$
//		while (find) {
//			groupCunt := matcher.groupCount
//			if (groupCunt == 0)
//				return Str#.emptyList
//			
//			(1..groupCunt).each |i| {
//				g := matcher.group(i)
//				groups.add(g)
//			}
//		
//			find = matcher.find
//		}
//
//		if (matchAllArgs && !groups.isEmpty) {
//			last := groups.removeAt(-1)
//			groups.addAll(last.split('/'))
//		}
//		
//		if (isGlob && !matchToEnd && !matchAllArgs && groups[-1].contains("/"))
//			return null
//
//		// convert empty Strs to nulls
//		// see http://fantom.org/sidewalk/topic/2178#c14077
//		return groups.map { it.isEmpty ? null : it }
//	}	

}


//class RouteHandler {
//	const Method	method
//		  Obj?[]	args
//	
//	new make(Method method, Obj?[] args) {
//		this.method	= method
//		this.args	= args
//	}
//	
//	Obj? invokeOn(Obj handlerInst) {
//		handlerInst.trap(method.name, args)
//	}
//}

