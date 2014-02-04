using afIoc::Inject
using afIoc::Registry
using afEfanXtra::EfanXtra
using afBedSheet::Text
using afBedSheet::ValueEncoders

** (Service) - Methods for discovering and rendering pages.
const mixin Pages {

	** Returns all page types.
	abstract Type[] pageTypes()
	
	abstract PageMeta pageMeta(Type pageType)
	
	// TODO: afBedSheet-1.3.2, rename Obj?[] to Str?[]
	@NoDoc
	abstract Text renderPageToText(Type pageType, Obj?[] context)
	
}

internal const class PagesImpl : Pages {

	@Inject	private const ValueEncoders			valueEncoders
	@Inject	private const Registry				registry
	@Inject	private const EfanXtra				efanXtra
	@Inject	private const ClientUriResolver		clientUriResolver
			private const Str:Type				pages	// use Str as key for case insensitivity

	new make(|This| in) {
		in(this) 

		pages := Utils.makeMap(Str#, Type#)

		efanXtra.libraries.each |libName| {
			efanXtra.componentTypes(libName).findAll { (it != Page#) && it.fits(Page#) }.each {
				pages[clientUriResolver.clientUri(it).toStr] = it 
			}
		}
		this.pages = pages
	}
	
	override Type[] pageTypes() {
		pages.vals
	}
	
	override PageMeta pageMeta(Type pageType) {
		registry.autobuild(PageMeta#, [pageType])
	}

	override Text renderPageToText(Type pageType, Obj?[] context) {
		meta	:= pageMeta(pageType)
		args 	:= convertArgs(context, meta.contextTypes)
		pageStr := meta.render(args)
		return Text.fromMimeType(pageStr, meta.contentType)
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
