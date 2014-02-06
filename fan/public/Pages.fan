using afIoc::Inject
using afIoc::Registry
using afEfanXtra::EfanXtra
using afEfanXtra::EfanLibraries
using afBedSheet::Text
using afBedSheet::ValueEncoders

** (Service) - Methods for discovering Pillow pages.
const mixin Pages {
	
	** Returns all Pillow page types.
	abstract Type[] pageTypes()
	
	** Create 'PageMeta' for the given page type and context. 
	** 
	** (Note: 'pageContext' are the arguments to the '@InitRender' method, if any.) 
	abstract PageMeta pageMeta(Type pageType, Obj?[]? pageContext)
	
	** Renders the given page, using the 'pageContext' as arguments to '@InitRender'. 
	** 
	** Note that 'pageContext' items converted their appropriate type via BedSheet's 'ValueEncoder' service.
	@NoDoc
	abstract Text renderPage(Type pageType, Str?[] pageContext)

	@NoDoc
	abstract Text renderPageMeta(PageMeta pageMeta)

	** Executes the page event in the given page context.
	@NoDoc
	abstract Obj callPageEvent(Type pageType, Str?[] pageContext, Method eventMethod, Str?[] eventContext)
	
}

internal const class PagesImpl : Pages {

	@Inject	private const ValueEncoders			valueEncoders
	@Inject	private const Registry				registry
	@Inject	private const EfanXtra				efanXtra
	@Inject	private const PageUriResolver		pageUriResolver
	@Inject	private const EfanLibraries 		efanLibraries
			private const Str:Type				pages	// use Str as key for case insensitivity

	new make(|This| in) {
		in(this) 
		pages := Utils.makeMap(Str#, Type#)
		efanXtra.libraries.each |libName| {
			efanXtra.componentTypes(libName).findAll { it.hasFacet(Page#) }.each {
				pages[pageUriResolver.pageUri(it).toStr] = it 
			}
		}
		this.pages = pages
	}
	
	override Type[] pageTypes() {
		pages.vals
	}
	
	override PageMeta pageMeta(Type pageType, Obj?[]? pageContext) {
		registry.autobuild(PageMeta#, [pageType, pageContext])
	}

	override Text renderPage(Type pageType, Str?[] pageContext) {
		renderPageMeta(pageMeta(pageType, pageContext))
	}

	override Text renderPageMeta(PageMeta pageMeta) {
		pageArgs := convertArgs(pageMeta.pageContext, pageMeta.contextTypes)
		pageStr	 := PageMeta.push(pageMeta) |->Str| {
			return efanXtra.render(pageMeta.pageType, pageArgs)
		}
		return Text.fromMimeType(pageStr, pageMeta.contentType)
	}

	override Obj callPageEvent(Type pageType, Str?[] pageContext, Method eventMethod, Str?[] eventContext) {
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
