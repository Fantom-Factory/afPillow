using afIoc::Inject
using afIocConfig::Config
using afEfanXtra::EfanXtra
using afEfanXtra::ComponentMeta
using afEfanXtra::InitRender
using afEfanXtra::EfanTemplateFinder
using afBedSheet::Text
using afBedSheet::ValueEncoders
using afBedSheet::HttpRequest
using concurrent::Actor

** (Service) - Methods for discovering and rendering pages.
const mixin Pages {

	** Returns all page types.
	abstract Type[] pageTypes()
	
	** Returns 'true' if the given page type is a welcome page.
	abstract Bool isWelcomePage(Type pageType)
	
	** Returns a URI that can be used to render the given page and context.
	abstract Uri clientUri(Type pageType, Obj[]? context := null)

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
	@Inject	private const RenderingPageMeta		renderingPage
	@Inject	private const ValueEncoders			valueEncoders
	@Inject	private const EfanXtra				efanXtra
	@Inject	private const ComponentMeta			comMeta
	@Inject	private const ContentTypeResolver	contentTypeResolver
	@Inject	private const ClientUriResolver		clientUriResolver
	@Inject	private const ComponentMeta			componentMeta
	@Inject	private const HttpRequest			httpRequest
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
	
	override Uri clientUri(Type pageType, Obj[]? context := null) {
		clientUri := clientUriResolver.clientUri(pageType)

		// add extra WebMod paths - but only if we're part of a web request!
		if (Actor.locals["web.req"] != null && httpRequest.modBase != `/`)
			clientUri = httpRequest.modBase + clientUri.toStr[1..-1].toUri

		// convert welcome pages
		if (isWelcomeUri(clientUri))
			clientUri = clientUri.parent
		
		// append context
		if (context != null) {
			initTypes := initTypes(pageType)
			if (initTypes.size != context.size)
				throw Err(ErrMsgs.invalidNumberOfInitArgs(pageType, initTypes, context))
			args := context.map { valueEncoders.toClient(Str#, it) ?: "" }.join("/")
			clientUri = clientUri.plusSlash + args.toUri			
		}

		// if rendering the given page, append PageContext params
		renderingType := RenderingPageMetaImpl.peek?.type
		if (context == null && renderingType == pageType) {
			page 	:= RenderingPageMetaImpl.peek.page
			fields	:= pageType.fields.findAll { it.hasFacet(PageContext#) || it.name == PageContext#.name.decapitalize }
			args	:= fields.map { it.get(page) }.map { valueEncoders.toClient(Str#, it) ?: "" }.join("/")
			clientUri = clientUri.plusSlash + args.toUri
		}

		return clientUri
	}
	
	override Bool isWelcomePage(Type pageType) {
		clientUri := clientUriResolver.clientUri(pageType)
		return isWelcomeUri(clientUri)
	}

	override Str renderPage(Type pageType, Obj[]? initParams) {
		page := (Page) efanXtra.component(pageType)
		return RenderingPageMetaImpl.pushRenderingPage(page, pageType) |->Str| {
			return efanXtra.render(pageType, initParams)
		}
	}

	override Text renderPageToText(Type pageType, Obj[]? initArgs) {
		types	:= initTypes(pageType)
		args 	:= convertArgs(initArgs, types)
		pageStr := renderPage(pageType, args)
		cType	:= contentTypeResolver.contentType(pageType)
		return Text.fromMimeType(pageStr, cType)
	}

	override Uri serverUri(Type pageType) {
		clientStr 	:= clientUriResolver.clientUri(pageType).toStr
		noOfParams 	:= initTypes(pageType).size
		noOfParams.times { clientStr += "/*" }
		clientUri	:= clientStr.toUri
		if (isWelcomeUri(clientUri))
			clientUri = clientUri.parent
		return clientUri
	}
	
	// move to PageMeta
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
	
	private Bool isWelcomeUri(Uri clientUri) {
		return clientUri.name.equalsIgnoreCase(welcomePage)
	}
}
