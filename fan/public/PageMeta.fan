using afIoc::Inject
using afIocConfig::Config
using afEfanXtra::EfanXtra
using afEfanXtra::ComponentMeta
using afEfanXtra::InitRender
using afBedSheet::ValueEncoders
using afBedSheet::HttpRequest
using concurrent::Actor

const class PageMeta {
	
	@Config { id="afPillow.welcomePage" }
	@Inject private const Str 					welcomePage
	@Inject	private const ContentTypeResolver	contentTypeResolver
	@Inject	private const ClientUriResolver		clientUriResolver
	@Inject	private const HttpRequest			httpRequest
	@Inject	private const ComponentMeta			componentMeta
	// TODO: afBedSheet-1.3.2, valueEnc sig change
	@Inject	private const ValueEncoders			valueEncoders
	@Inject	private const EfanXtra				efanXtra

	const Type pageType
	
	internal new make(Type pageType, |This|in) {
		in(this)
		this.pageType = pageType
	}
	
	** Returns a URI that can be used to render the given page and context.
	Uri clientUri(Obj[]? context := null) {
		clientUri := clientUriResolver.clientUri(pageType)

		// add extra WebMod paths - but only if we're part of a web request!
		if (Actor.locals["web.req"] != null && httpRequest.modBase != `/`)
			clientUri = httpRequest.modBase + clientUri.toStr[1..-1].toUri

		// convert welcome pages
		if (isWelcomeUri(clientUri))
			clientUri = clientUri.parent
		
		// append context
		if (context != null) {
			contextTypes := contextTypes
			if (contextTypes.size != context.size)
				throw Err(ErrMsgs.invalidNumberOfInitArgs(pageType, contextTypes, context))
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
	
	** Returns the 'Content-Type' produced by this page.
	MimeType contentType() {
		contentTypeResolver.contentType(pageType)
	}
	
	** Returns 'true' if the given page type is a welcome page.
	Bool isWelcomePage() {
		clientUri := clientUriResolver.clientUri(pageType)
		return isWelcomeUri(clientUri)
	}
	
	** Renders the given page, using the 'pageContext' as arguments to '@InitRender'. 
	** 
	** Note that 'pageContext' items converted their appropriate type () via BedSheet's 'ValueEncoder' service.
	Str render(Obj[]? pageContext) {
		page := (Page) efanXtra.component(pageType)
		return RenderingPageMetaImpl.pushRenderingPage(page, pageType) |->Str| {
			return efanXtra.render(pageType, pageContext)
		}
	}
	
	// ---- Internal Methods -------------------------------------------------------------------------------------------	

	internal Uri serverRegex() {
		clientStr 	:= clientUriResolver.clientUri(pageType).toStr
		noOfParams 	:= contextTypes.size
		noOfParams.times { clientStr += "/*" }
		clientUri	:= clientStr.toUri
		if (isWelcomeUri(clientUri))
			clientUri = clientUri.parent
		return clientUri
	}

	internal Type[] contextTypes() {
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
