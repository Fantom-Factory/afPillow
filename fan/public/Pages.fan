using afIoc::Inject
using afIoc::Registry
using afIoc::NotFoundErr
using afIocEnv::IocEnv
using afEfanXtra::EfanXtra
using afEfanXtra::EfanLibraries
using afBedSheet::Text
using afBedSheet::ValueEncoders
using afBedSheet::HttpRequest
using afBedSheet::HttpResponse

** (Service) - Methods for discovering Pillow pages and returning `PageMeta` instances.
const mixin Pages {
	
	** Returns all Pillow page types.
	abstract Type[] pageTypes()
	
	** Create 'PageMeta' for the given page type and context. 
	** 
	** (Note: 'pageContext' are the arguments to the '@InitRender' method, if any.) 
	abstract PageMeta pageMeta(Type pageType, Obj?[]? pageContext := null)
	
	** An alias for 'pageMeta()'.
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
	
	@Inject	private const ValueEncoders		valueEncoders
	@Inject	private const EfanXtra			efanXtra
	@Inject	private const EfanLibraries 	efanLibraries
	@Inject	private const IocEnv			iocEnv
	@Inject	private const HttpResponse		httpRes
	@Inject	private const HttpRequest		httpRequest
		private const Type:PageMetaState	pageCache 

	new make(PageMetaStateFactory metaFactory, |This| in) {
		in(this)
		cache := Utils.makeMap(Type#, PageMeta#)
		efanXtra.libraries.each |libName| {
			efanXtra.componentTypes(libName).findAll { it.hasFacet(Page#) }.each {
				cache[it] =  metaFactory.toPageMetaState(it)
			}
		}
		this.pageCache = cache
	}
	
	override Type[] pageTypes() {
		pageCache.keys.sort
	}
	
	override PageMeta pageMeta(Type pageType, Obj?[]? pageContext := null) {
		pageState := pageCache[pageType] ?: throw NotFoundErr(ErrMsgs.couldNotFindPage(pageType), pageCache.keys) 
		return PageMeta(pageState, pageContext) {
			it.httpRequest 	 = this.httpRequest
			it.valueEncoders = this.valueEncoders
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
			httpRes.headers["X-Pillow-Rendered-Page"] = pageMeta.pageType.qname
		
		pageArgs := convertArgs(pageMeta.pageContext, pageMeta.contextTypes)
		pageStr	 := PageMeta.push(pageMeta) |->Str| {
			return efanXtra.render(pageMeta.pageType, pageArgs)
		}
		return Text.fromMimeType(pageStr, pageMeta.contentType)
	}

	override Obj callPageEvent(Type pageType, Obj?[] pageContext, Method eventMethod, Obj?[] eventContext) {
		if (!iocEnv.isProd) 
			httpRes.headers["X-Pillow-Called-Event"] = eventMethod.qname

		page 		:= efanXtra.component(pageType)
		pageMeta	:= pageMeta(pageType, pageContext)
		initArgs 	:= convertArgs(pageContext, pageMeta.contextTypes)
		eventArgs 	:= convertArgs(eventContext, eventMethod.params.map { it.type })
		
		return PageMeta.push(pageMeta) |->Obj?| {
			return efanLibraries.library(pageType).callMethod(pageType, initArgs) |->Obj?| {
				return eventMethod.callOn(page, eventArgs)
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


internal const class PageMetaState {
	const Type 		pageType
	const Uri 		pageBaseUri
	const MimeType 	contentType
	const Bool 		isWelcomePage
	const Str 		httpMethod
	const Uri 		serverGlob
	const Type[]	contextTypes

	new make(|This|in) { in(this) }
}

