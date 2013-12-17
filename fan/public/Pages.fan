using afIoc::Inject
using afIocConfig::Config
using afEfanXtra
using afBedSheet::Text
using afBedSheet::ValueEncoders

** (Service) - Methods for discovering and rendering pages.
const mixin Pages {

	** Returns the page instance for the given page type. 
	@Operator
	abstract Page get(Type pageType)
	
	** Returns all page types.
	abstract Type[] pageTypes()
	
	** Returns 'true' if the given page type is a welcome page.
	abstract Bool isWelcomePage(Type pageType)
	
	** Returns the uri that the given page type maps to.
	abstract Uri clientUri(Type pageType)

	** Renders the given page, passing the 'initParams' to the '@InitRender' method. 
	** 
	** Note that 'initParams' are converted their appropriate type via BedSheet's ValueEncoder service.
	abstract Obj? renderPage(Type pageType, Obj[]? initParams)

	@NoDoc
	abstract Obj? renderPageToText(Type pageType, Obj[]? initParams)
}

internal const class PagesImpl : Pages {

	@Config { id="afPillow.welcomePage" }
	@Inject private const Str 				welcomePage
	@Inject	private const PageRenderMeta	pageRenderMeta
	@Inject	private const ValueEncoders		valueEncoders
	@Inject	private const EfanXtra			efanXtra
	@Inject	private const ComponentMeta		comMeta
			private const Str:Type			pages	// use Str as key for case insensitivity

	new make(|This| in) {
		in(this) 

		pages := Utils.makeMap(Str#, Type#)

		efanXtra.libraries.each |libName| {
			efanXtra.componentTypes(libName).findAll { (it != Page#) && it.fits(Page#) }.each {
				pages[getRawClientUri(it).toStr] = it 
			}
		}
		this.pages = pages
	}
	
	** Returns the page instance associated with the given type. 
	override Page get(Type pageType) {
		(Page) efanXtra.component(pageType)
	}

	override Type[] pageTypes() {
		pages.vals
	}
	
	override Uri clientUri(Type pageType) {
		clientUri := getRawClientUri(pageType)
		return clientUri.name.equalsIgnoreCase(welcomePage) ? clientUri.parent : clientUri
	}
	
	override Bool isWelcomePage(Type pageType) {
		clientUri := getRawClientUri(pageType)
		return clientUri.name.equalsIgnoreCase(welcomePage)
	}

	override Obj? renderPage(Type pageType, Obj[]? initParams) {
		page := get(pageType)
		pageRenderMeta.setActivePage(page)
		return efanXtra.render(pageType, initParams)
	}

	override Obj? renderPageToText(Type pageType, Obj[]? initParams) {
		
		initMeth := comMeta.findMethod(pageType, InitRender#)
		
		convert := (initMeth != null && initParams != null)
		args 	:= convert ? convertArgs(initMeth, initParams) : Obj#.emptyList

		obj := renderPage(pageType, args)
		// FIXME: how dow we know it's HTML?
		if (obj != null && obj.typeof.fits(Str#))
			return Text.fromHtml(obj)
		return obj
	}

	// ---- Private Methods --------------------------------------------------------------------------------------------	

	** Convert the Str from Routes into real arg objs
	private Obj[] convertArgs(Method method, Obj?[] argsIn) {
		argsOut := argsIn.map |arg, i -> Obj?| {
			// guard against having more args than the method has params! 
			// Should never happen if the Routes do their job!
			paramType	:= method.params.getSafe(i)?.type
			if (paramType == null)
				return arg			
			convert		:= arg != null && arg.typeof.fits(Str#)
			value		:= convert ? valueEncoders.toValue(paramType, arg) : arg
			return value
		}
		return argsOut
	}

	private Uri getRawClientUri(Type pageType) {
		// TODO: maybe contribute ClientUriResolvers
		if (pageType.hasFacet(PageUri#)) {
			return toUriFromPageUri(pageType)
		} else {
			return toUriFromTypeName(pageType)
		}
	}
	
	private Uri toUriFromPageUri(Type pageType) {
		pageUri := (PageUri) Type#.method("facet").callOn(pageType, [PageUri#])	// Stoopid F4
		uri		:= pageUri.uri
	    if (uri.scheme != null || uri.host != null || uri.port!= null )
			throw PillowErr(ErrMsgs.pageRouteShouldBePathOnly(pageType, uri))
	    if (!uri.isPathAbs)
			throw PillowErr(ErrMsgs.pageRouteShouldStartWithSlash(pageType, uri))
		return uri
	}
	
	private Uri toUriFromTypeName(Type pageType) {
		pageName := pageType.name
		if (pageName.endsWith("Impl"))
			pageName = pageName[0..-5]
		if (pageName.endsWith("Page"))
			pageName = pageName[0..-5]
		pageUri := pageName.toDisplayName.replace(" ", "/").lower
	
		return ("/" + pageUri).toUri
	}	
}
