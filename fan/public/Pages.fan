using afIoc
using afIocEnv
using afIocConfig
using afEfanXtra
using afBedSheet
using afConcurrent

** (Service) - Methods for discovering Pillow pages and returning `PageMeta` instances.
const mixin Pages {

	** Returns all Pillow page types.
	abstract Type[] pageTypes()

	** Create 'PageMeta' for the given page type and context. 
	** 
	** (Note: 'pageContext' are the arguments to the '@InitRender' method, if any.) 
	abstract PageMeta pageMeta(Type pageType, Obj?[]? pageContext := null)

	** Create 'PageMeta' for the given page type and context.
	**  
	** Convenience / alias for 'pageMeta(...)'.
	@Operator
	abstract PageMeta get(Type pageType, Obj?[]? pageContext := null)

	** Renders the given page, using the 'pageContext' as arguments to '@InitRender'. 
	** 
	** Note that 'pageContext' items converted their appropriate type via BedSheet's 'ValueEncoder' service.
	@NoDoc	// Obj 'cos the method may be called manually (from ResponseProcessor)
	abstract Text renderPage(Type pageType, Obj?[]? pageContext := null)

	@NoDoc
	abstract Text renderPageMeta(PageMeta pageMeta)

	** Executes the page event in the given page context.
	@NoDoc	// Obj 'cos the method may be called manually (from ResponseProcessor)
	abstract Obj callPageEvent(Type pageType, Obj?[] pageContext, Method eventMethod, Obj?[] eventContext)
}

internal const class PagesImpl : Pages {
	
	@Inject	private const ValueEncoders			valueEncoders
	@Inject	private const EfanXtra 				efanXtra
	@Inject	private const EfanLibraries			efanLibs
	@Inject	private const IocEnv				iocEnv
	@Inject	private const BedSheetServer		bedServer			
	@Inject	private const HttpResponse			httpRes
	@Inject	private const HttpRequest			httpRequest
	@Inject	private const ComponentRenderer		componentRenderer
	@Inject private const ComponentMeta			componentMeta
	@Inject private const PageFinder			pageFinder
			private const Type:PageMetaState	pageCache 
			override const Type[] 				pageTypes
	@Config
	@Inject private const Str					cacheControl


	new make(PageMetaStateFactory metaFactory, |This| in) {
		in(this)
		cache := Type:PageMetaState[:] { ordered = true }
		efanXtra.libraryNames.each |libName| {
			pod := efanLibs.pod(libName)
			pageFinder.findPageTypes(pod).each {
				cache[it] =  metaFactory.toPageMetaState(it)
			}
		}
		this.pageCache = cache
		this.pageTypes = pageCache.keys.sort
	}
	
	override PageMeta pageMeta(Type pageType, Obj?[]? pageContext := null) {
		pageState := pageCache[pageType] ?: throw PageNotFoundErr(ErrMsgs.couldNotFindPage(pageType), pageCache.keys) 
		return PageMetaImpl(pageState, pageContext) {
			it.bedServer		= this.bedServer
			it.httpRequest		= this.httpRequest
			it.valueEncoders	= this.valueEncoders
		}
	}

	override PageMeta get(Type pageType, Obj?[]? pageContext := null) {
		pageMeta(pageType, pageContext)
	}
	
	override Text renderPage(Type pageType, Obj?[]? pageContext := null) {
		renderPageMeta(pageMeta(pageType, pageContext))
	}

	override Text renderPageMeta(PageMeta pageMeta) {
		if (!iocEnv.isProd)
			httpRes.headers["X-afPillow-renderedPage"] = pageMeta.pageType.qname
		
		if (iocEnv.isProd)
			// set the default cache headers
			httpRes.headers.cacheControl = cacheControl		
		
		pageArgs := convertArgs(pageMeta.pageContext, pageMeta.initRender.paramTypes)
		pageStr	 := PageMetaImpl.push(pageMeta) |->Str| {
			return efanXtra.component(pageMeta.pageType).render(pageArgs)
		}
		return Text.fromContentType(pageStr, pageMeta.contentType)
	}

	override Obj callPageEvent(Type pageType, Obj?[] pageContext, Method eventMethod, Obj?[] eventContext) {
		if (!iocEnv.isProd) 
			httpRes.headers["X-afPillow-calledEvent"] = eventMethod.qname

		page 		:= efanXtra.component(pageType)
		pageMeta	:= pageMeta(pageType, pageContext)
		initArgs 	:= convertArgs(pageContext, pageMeta.initRender.paramTypes)
		eventArgs 	:= convertArgs(eventContext, eventMethod.params.map { it.type })
		
		return PageMetaImpl.push(pageMeta) |->Obj| {
			return componentRenderer.runInCtx(page) |->Obj| {
				// TODO: what if InitRender returns false?
				componentMeta.callMethod(InitRender#, page, initArgs)
				
				eventValue := eventMethod.callOn(page, eventArgs)
				if (eventValue != null)
					return eventValue
				if (!iocEnv.isProd)
					httpRes.headers["X-afPillow-renderedPage"] = pageMeta.pageType.qname

				if (iocEnv.isProd)
					// set the default cache headers
					httpRes.headers.cacheControl = cacheControl		

				pageArgs := convertArgs(pageMeta.pageContext, pageMeta.initRender.paramTypes)
				componentRenderer.doRenderLoop(page)
				return Text.fromContentType(componentRenderer.renderResult, pageMeta.contentType)
			}
		}
	}
	
	// ---- Private Methods --------------------------------------------------------------------------------------------
	
	** Convert the Str from Routes into real arg objs
	private Obj[] convertArgs(Str?[] argsIn, Type[] convertTo) {
		argsOut := argsIn.map |arg, i -> Obj?| {
			// guard against having more args than the method has params! 
			// Should never happen if the Routes do their job!
			paramType := convertTo.getSafe(i)
			if (paramType == null)
				return arg			
			convert		:= arg != null && arg.typeof.fits(Str#)
			value		:= convert ? valueEncoders.toValue(paramType, arg) : arg
			return value
		}
		return argsOut
	}
}


