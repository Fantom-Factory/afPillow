using afIoc::Inject
using afIoc::Registry
using afEfanXtra::EfanXtra
using afEfanXtra::EfanLibraries
using afBedSheet::Text
using afBedSheet::ValueEncoders

** (Service) - Methods for discovering and rendering pages.
const mixin Pages {

	** Returns all page types.
	abstract Type[] pageTypes()
	
	abstract PageMeta pageMeta(Type pageType, Obj?[]? pageContext)
	
	// TODO: afBedSheet-1.3.2, rename Obj?[] to Str?[]
	@NoDoc
	abstract Text renderPageToText(Type pageType, Obj?[] pageContext)

	// TODO: afBedSheet-1.3.2, rename Obj?[] to Str?[]
	@NoDoc
	abstract Obj callPageEvent(Type pageType, Obj?[] pageContext, Method eventMethod, Obj?[] eventContext)
	
}

internal const class PagesImpl : Pages {

	@Inject	private const ValueEncoders			valueEncoders
	@Inject	private const Registry				registry
	@Inject	private const EfanXtra				efanXtra
	@Inject	private const ClientUriResolver		clientUriResolver
	@Inject	private const EfanLibraries 		efanLibraries
			private const Str:Type				pages	// use Str as key for case insensitivity

	new make(|This| in) {
		in(this) 

		pages := Utils.makeMap(Str#, Type#)

		efanXtra.libraries.each |libName| {
			efanXtra.componentTypes(libName).findAll { it.hasFacet(Page#) }.each {
				pages[clientUriResolver.clientUri(it).toStr] = it 
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

	override Text renderPageToText(Type pageType, Obj?[] pageContext) {
		meta	:= pageMeta(pageType, pageContext)
		args 	:= convertArgs(pageContext, meta.contextTypes)
		pageStr := meta.render(args)
		return Text.fromMimeType(pageStr, meta.contentType)
	}

	override Obj callPageEvent(Type pageType, Obj?[] pageContext, Method eventMethod, Obj?[] eventContext) {
		page 		:= efanXtra.component(pageType)
		pageMeta	:= pageMeta(pageType, pageContext)
		initArgs 	:= convertArgs(pageContext, pageMeta.contextTypes)
		eventArgs 	:= convertArgs(eventContext, eventMethod.params.map { it.type })
		
		return efanLibraries.library(pageType).callMethod(pageType, initArgs) |->Obj?| {
			return eventMethod.callOn(page, eventArgs)
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
