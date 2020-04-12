using afIoc::Inject
using afIoc::Scope
using afIocEnv::IocEnv
using afIocConfig::Config
using afEfanXtra::EfanXtra
using afEfanXtra::EfanLibraries
using afEfanXtra::ComponentRenderer
using afEfanXtra::ComponentMeta
using afEfanXtra::InitRender
using afBedSheet::HttpRequest
using afBedSheet::HttpResponse
using afBedSheet::HttpStatus
using afBedSheet::BedSheetServer
using afBedSheet::ValueEncoders
using afBedSheet::ValueEncodingErr
using afBedSheet::Text

** (Service) - Methods for discovering Pillow pages and returning `PageMeta` instances.
const mixin Pages {

	** Returns all Pillow page types.
	abstract Type[] pageTypes()

	** Create 'PageMeta' for the given page type and context. 
	** 
	** (Note: 'pageContext' are the arguments to the '@InitRender' method, if any.) 
	abstract PageMeta pageMeta(Type pageType, Obj[]? pageContext := null)

	** Create 'PageMeta' for the given page type and context.
	**  
	** Convenience / alias for 'pageMeta(...)'.
	@Operator
	abstract PageMeta get(Type pageType, Obj[]? pageContext := null)

	** Manually renders the given page using 'pageContext' as arguments to '@InitRender'. 
	** 
	** Note that 'pageContext' Strs are converted to their appropriate type via BedSheet's 'ValueEncoder' service.
	// Obj 'cos the method may be called manually (from ResponseProcessor)
	abstract Obj renderPage(Type pageType, Obj[]? pageContext := null)

	** Manually renders the given 'pageMeta'. 
	** 
	** There should be no need to call this in normal Pillow usage.
	abstract Obj renderPageMeta(PageMeta pageMeta)

	** Manually executes the page event in the given page context.
	** 
	** Note this may be used to call *any* method on a page, not just ones annotated with the '@PageEvent' facet.
	// Obj 'cos the method may be called manually (from ResponseProcessor)
	abstract Obj callPageEvent(Type pageType, Obj[]? pageContext, Method eventMethod, Obj[]? eventContext)

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
	@Inject	private const HttpRequest			httpReq
	@Inject	private const ComponentRenderer		componentRenderer
	@Inject private const ComponentMeta			componentMeta
	@Inject private const PageFinder			pageFinder
			private const Type:PageMetaState	pageCache 
			override const Type[] 				pageTypes
	@Config
	@Inject private const Str					cacheControl


	new make(Scope scope, |This| in) {
		in(this)
		metaFactory := (PageMetaStateFactory) scope.build(PageMetaStateFactory#)
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
	
	override PageMeta pageMeta(Type pageType, Obj[]? pageContext := null) {
		pageState := pageCache[pageType] ?: throw PageNotFoundErr(ErrMsgs.couldNotFindPage(pageType), pageCache.keys) 
		return PageMetaImpl(pageState, pageContext) {
			it.bedServer		= this.bedServer
			it.httpRequest		= this.httpReq
			it.valueEncoders	= this.valueEncoders
		}
	}

	override PageMeta get(Type pageType, Obj[]? pageContext := null) {
		pageMeta(pageType, pageContext)
	}
	
	override Obj renderPage(Type pageType, Obj[]? pageContext := null) {
		renderPageMeta(pageMeta(pageType, pageContext))
	}

	override Obj renderPageMeta(PageMeta pageMeta) {
		page 	 := efanXtra.component(pageMeta.pageType)
		initArgs := convertArgs(pageMeta.pageContext, pageMeta.initRender.paramTypes)
		pageMeta = pageMeta.withContext(initArgs)

		// todo - does this meta need to be stacked? -> see PageMetaCtx
		httpReq.stash["afPillow.pageMeta"]	= pageMeta
		try return PageMetaImpl.push(pageMeta) |->Obj| {
			retVal := null
			componentRenderer.runInCtx(page) |->| {  
				
				// call initRender() - process any non-null return value
				initValue := componentMeta.callMethod(InitRender#, page, initArgs)
				if (initValue != null) {
					retVal = initValue
					return

				} else {
					// re-render the page without re-calling @InitRender so event changes get picked up 
					if (!iocEnv.isProd)
						httpRes.headers["X-afPillow-renderedPage"] = pageMeta.pageType.qname
	
					if (iocEnv.isProd)
						// set the default cache headers
						httpRes.headers.cacheControl = cacheControl		
	
					renderBuf := componentRenderer.doRenderLoop(page)
					
					retVal = Text.fromContentType(renderBuf.toStr, pageMeta.contentType)	
				}
			}
			return retVal
		}
		finally httpReq.stash.remove("afPillow.pageMeta")
	}

	override Obj callPageEvent(Type pageType, Obj[]? pageContext, Method eventMethod, Obj[]? eventContext) {
		if (!iocEnv.isProd) 
			httpRes.headers["X-afPillow-calledEvent"] = eventMethod.qname

		page 		:= efanXtra.component(pageType)
		pageMeta	:= pageMeta(pageType, pageContext)
		initArgs 	:= convertArgs(pageContext  ?: Str#.emptyList, pageMeta.initRender.paramTypes)
		eventArgs 	:= convertArgs(eventContext ?: Str#.emptyList, eventMethod.params.map { it.type })
		
		// todo - does this meta need to be stacked? -> see PageMetaCtx
		httpReq.stash["afPillow.eventMeta"]	= EventMeta {
			it.pageMeta		= pageMeta.withContext(initArgs)
			it.eventMethod	= eventMethod
			it.eventContext	= eventArgs
		}
		
		try return PageMetaImpl.push(pageMeta) |->Obj| {
			retVal := null
			componentRenderer.runInCtx(page) |->| {  
				
				// call initRender() - process any non-null return value
				initValue := componentMeta.callMethod(InitRender#, page, initArgs)
				if (initValue != null) {
					retVal = initValue
					return

				} else {
					// call event method - process any non-null return value
					eventValue := eventMethod.callOn(page, eventArgs)
					if (eventValue != null) {
						retVal = eventValue
						return
					}
	
					// re-render the page without re-calling @InitRender so event changes get picked up 
					if (!iocEnv.isProd)
						httpRes.headers["X-afPillow-renderedPage"] = pageMeta.pageType.qname
	
					// set the default cache headers
					if (iocEnv.isProd)
						httpRes.headers.cacheControl = cacheControl		
	
					renderBuf := componentRenderer.doRenderLoop(page)
					
					retVal = Text.fromContentType(renderBuf.toStr, pageMeta.contentType)	
				}
			}
			return retVal
		}
		finally httpReq.stash.remove("afPillow.eventMeta")
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
	private Obj[] convertArgs(Obj[] argsIn, Type[] convertTo) {
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
			throw HttpStatus.makeErr(404, valEncErr.msg, valEncErr)
		}
	}
}


