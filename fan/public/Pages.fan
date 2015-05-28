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

	** Manually renders the given page using 'pageContext' as arguments to '@InitRender'. 
	** 
	** Note that 'pageContext' Strs are converted to their appropriate type via BedSheet's 'ValueEncoder' service.
	// Obj 'cos the method may be called manually (from ResponseProcessor)
	abstract Text renderPage(Type pageType, Obj?[]? pageContext := null)

	** Manually renders the given 'pageMeta'. 
	** 
	** There should be no need to call this in normal Pillow usage.
	abstract Text renderPageMeta(PageMeta pageMeta)

	** Manually executes the page event in the given page context.
	** 
	** Note this may be used to call *any* method on a page, not just ones annotated with the '@PageEvent' facet.
	// Obj 'cos the method may be called manually (from ResponseProcessor)
	abstract Obj callPageEvent(Type pageType, Obj?[]? pageContext, Method eventMethod, Obj?[]? eventContext)

	// moar thought needs to go into how to get / set the data ctx so the page can retrieve thread local data
//	** Returns the currently rendering page. Or 'null' if no page is being rendered.
//	abstract EfanComponent? getRenderingPage()
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
		page 	 := efanXtra.component(pageMeta.pageType)
		initArgs := convertArgs(pageMeta.pageContext, pageMeta.initRender.paramTypes)
		
		pageStr	 := PageMetaImpl.push(pageMeta) |->Str| {
			if (!iocEnv.isProd)
				httpRes.headers["X-afPillow-renderedPage"] = pageMeta.pageType.qname
			
			if (iocEnv.isProd)
				// set the default cache headers
				httpRes.headers.cacheControl = cacheControl		
		
			return componentRenderer.render(page, initArgs)
//			return efanXtra.component(pageMeta.pageType).render(initArgs)
		}
		return Text.fromContentType(pageStr, pageMeta.contentType)
	}

	override Obj callPageEvent(Type pageType, Obj?[]? pageContext, Method eventMethod, Obj?[]? eventContext) {
		if (!iocEnv.isProd) 
			httpRes.headers["X-afPillow-calledEvent"] = eventMethod.qname

		page 		:= efanXtra.component(pageType)
		pageMeta	:= pageMeta(pageType, pageContext)
		initArgs 	:= convertArgs(pageContext  ?: Str#.emptyList, pageMeta.initRender.paramTypes)
		eventArgs 	:= convertArgs(eventContext ?: Str#.emptyList, eventMethod.params.map { it.type })
		
		return PageMetaImpl.push(pageMeta) |->Obj| {
			return componentRenderer.runInCtx(page) |->Obj| {
				// TODO: what if InitRender returns false?
				componentMeta.callMethod(InitRender#, page, initArgs)

				eventValue := eventMethod.callOn(page, eventArgs)
				if (eventValue != null)
					return eventValue

				// re-render the page without re-calling @InitRender so event changes get picked up 
				
				if (!iocEnv.isProd)
					httpRes.headers["X-afPillow-renderedPage"] = pageMeta.pageType.qname

				if (iocEnv.isProd)
					// set the default cache headers
					httpRes.headers.cacheControl = cacheControl		

				componentRenderer.doRenderLoop(page)
				return Text.fromContentType(componentRenderer.renderResult, pageMeta.contentType)
			}
		}
	}
	
//	override EfanComponent? getRenderingPage() {
//		Efan.renderingStack.eachrWhile |element| {
//			element.templateInstance is EfanComponent && element.templateMeta.type.hasFacet(Page#)
//				? element.templateInstance
//				: null
//		}
//	}
	
	// ---- Private Methods --------------------------------------------------------------------------------------------
	
	** Convert the Str from Routes into real arg objs
	private Obj[] convertArgs(Obj?[] argsIn, Type[] convertTo) {
		try
			return argsIn.map |arg, i -> Obj?| {
				// guard against having more args than the method has params! 
				// Should never happen if the Routes do their job!
				paramType := convertTo.getSafe(i)
				if (paramType == null)
					return arg
				return arg is Str ? valueEncoders.toValue(paramType, arg) : arg
			}
		// if the args can't be converted then clearly the URL doesn't exist!
		catch (ValueEncodingErr valEncErr) {
			throw HttpStatusErr(404, valEncErr.msg, valEncErr)
		}
	}
}


