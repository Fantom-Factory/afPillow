using afIoc::Inject
using afIocConfig::Config
using afEfanXtra::EfanXtra
using afEfanXtra::ComponentMeta
using afEfanXtra::InitRender
using afEfanXtra::EfanTemplateFinder
using afBedSheet::Text
using afBedSheet::ValueEncoders

** (Service) - Methods for discovering and rendering pages.
const mixin Pages {

	** Returns the page instance for the given page type. 
//	@Operator
//	abstract Page get(Type pageType)
	
	** Returns all page types.
	abstract Type[] pageTypes()
	
	** Returns 'true' if the given page type is a welcome page.
	abstract Bool isWelcomePage(Type pageType)
	
	** Returns the uri that the given page type maps to.
	abstract Uri clientUri(Type pageType)

	** Renders the given page, passing the 'initParams' to the '@InitRender' method. 
	** 
	** Note that 'initParams' are converted their appropriate type via BedSheet's ValueEncoder service.
	abstract Str renderPage(Type pageType, Obj[]? initParams)

	@NoDoc
	abstract Text renderPageToText(Type pageType, Obj[]? initParams)
	
	@NoDoc
	abstract Uri serverUri(Type pageType)
	
	@NoDoc
	abstract Type[] initTypes(Type pageType)
	
}

internal const class PagesImpl : Pages {

	@Config { id="afPillow.welcomePage" }
	@Inject private const Str 					welcomePage
	@Inject	private const PageRenderMeta		pageRenderMeta
	@Inject	private const ValueEncoders			valueEncoders
	@Inject	private const EfanXtra				efanXtra
	@Inject	private const ComponentMeta			comMeta
	@Inject	private const ContentTypeResolver	contentTypeResolver
	@Inject	private const ClientUriResolver		clientUriResolver
	@Inject	private const ComponentMeta			componentMeta
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
	
	** Returns the page instance associated with the given type. 
//	override Page get(Type pageType) {
//		(Page) efanXtra.component(pageType)
//	}

	override Type[] pageTypes() {
		pages.vals
	}
	
	override Uri clientUri(Type pageType) {
		clientUri := clientUriResolver.clientUri(pageType)
		// TODO: add webmod prefix if in a req
		return clientUri.name.equalsIgnoreCase(welcomePage) ? clientUri.parent : clientUri
	}
	
	override Bool isWelcomePage(Type pageType) {
		clientUri := clientUriResolver.clientUri(pageType)
		return clientUri.name.equalsIgnoreCase(welcomePage)
	}

	override Str renderPage(Type pageType, Obj[]? initParams) {
		page := (Page) efanXtra.component(pageType)
		pageRenderMeta.setActivePage(page)
		return efanXtra.render(pageType, initParams)
	}

	override Text renderPageToText(Type pageType, Obj[]? initArgs) {
		types	:= initTypes(pageType)
		args 	:= convertArgs(initArgs, types)
		pageStr := renderPage(pageType, args)
		cType	:= contentTypeResolver.contentType(pageType)
		return Text.fromMimeType(pageStr, cType)
	}

	override Uri serverUri(Type pageType) {
		clientUri := clientUri(pageType).toStr
		noOfParams := initTypes(pageType).size
		noOfParams.times { clientUri += "/*" }
		return `${clientUri}`
	}
	
	override Type[] initTypes(Type pageType) {
		fields 	 := pageType.fields.findAll { it.hasFacet(PageContext#) || it.name == PageContext#.name.decapitalize }
		initMeth := componentMeta.findMethod(pageType, InitRender#)
		
		if (!fields.isEmpty && initMeth != null)
			throw PillowErr(ErrMsgs.pageCanNotHaveInitRenderAndPageContext(pageType))

		if (!fields.isEmpty)
			return fields.map { it.type }
		if (initMeth != null)
			return initMeth.params.map { it.type }
		return Type#.emptyList
	}
	
	
	// ---- Private Methods --------------------------------------------------------------------------------------------	

	** Convert the Str from Routes into real arg objs
	private Obj[] convertArgs(Obj?[] argsIn, Type[] convertTo) {
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
