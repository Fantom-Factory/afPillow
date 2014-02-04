using afIoc::Inject
using afIocConfig::Config
using afEfanXtra::EfanXtra
using afEfanXtra::ComponentMeta
using afEfanXtra::InitRender
using afBedSheet::ValueEncoders
using afBedSheet::HttpRequest
using concurrent::Actor

** (Service) - Returns details about the page that is currently being rendered.
const mixin PageMeta {
	
	** Returns the page that this Meta object wraps.
	abstract Type pageType()
	
	** Returns the 'Content-Type' produced by this page.
	abstract MimeType contentType()
	
	** Returns 'true' if the given page type is a welcome page.
	abstract Bool isWelcomePage()

	** Returns a URI that can be used to render the given page and context.
	abstract Uri pageUri()

	** Returns a URI for a given event - use to create client side URIs to call the event.
	abstract Uri eventUri(Str eventName, Obj?[]? eventContext)

	** Renders the given page, using the 'pageContext' as arguments to '@InitRender'. 
	** 
	** Note that 'pageContext' items converted their appropriate type () via BedSheet's 'ValueEncoder' service.
	abstract Str render(Obj?[]? pageContext) 
	
	@NoDoc
	abstract Uri serverGlob()
	
	@NoDoc
	abstract Uri eventGlob(Method eventMethod)
	
	@NoDoc
	abstract Type[] contextTypes()
	
	@NoDoc
	abstract Uri ctxToUri(Obj?[] context)
	
	** Returns 'pageUri'.
	override Str toStr() {
		pageUri.toStr
	}
	
	internal static Obj? push(PageMeta pageMeta, |->Obj?| f) {
		ThreadStack.pushAndRun("afPillow.renderingPageMeta", pageMeta, f)
	}
	
	internal static PageMeta? peek(Bool checked) {
		ThreadStack.peek("afPillow.renderingPageMeta", false) ?: (checked ? throw PillowErr(ErrMsgs.renderingPageMetaNotRendering) : null)
	}
}

internal const class PageMetaImpl : PageMeta {
	
	@Config { id="afPillow.welcomePage" }
	@Inject private const Str 					welcomePage
	@Inject	private const ContentTypeResolver	contentTypeResolver
	@Inject	private const ClientUriResolver		clientUriResolver
	@Inject	private const HttpRequest			httpRequest
	@Inject	private const ComponentMeta			componentMeta
	@Inject	private const ValueEncoders			valueEncoders
	@Inject	private const EfanXtra				efanXtra

	override const Type pageType
	override const Uri 	pageUri
	
	internal new make(Type pageType, Obj?[]? pageContext, |This|in) {
		this.pageType 	= pageType
		in(this)
		this.pageUri	= clientUri(pageContext)
	}
	
	override MimeType contentType() {
		contentTypeResolver.contentType(pageType)
	}
	
	override Bool isWelcomePage() {
		clientUri := clientUriResolver.clientUri(pageType)
		return isWelcomeUri(clientUri)
	}
	
	override Str render(Obj?[]? pageContext) {
		return PageMeta.push(this) |->Str| {
			return efanXtra.render(pageType, pageContext)
		}
	}
	
	override Uri eventUri(Str eventName, Obj?[]? eventContext) {
		eventMethod(eventName)		
		eventUri 	:= pageUri.plusSlash + `${eventName}`
		if (eventContext != null)
			eventUri = eventUri.plusSlash + ctxToUri(eventContext)
		return eventUri
	}

	// ---- Internal Methods -------------------------------------------------------------------------------------------	

	override Uri serverGlob() {
		clientStr 	:= clientUriResolver.clientUri(pageType).toStr
		noOfParams 	:= contextTypes.size
		noOfParams.times { clientStr += "/*" }
		clientUri	:= clientStr.toUri
		if (isWelcomeUri(clientUri))
			clientUri = clientUri.parent
		return clientUri
	}

	override Uri eventGlob(Method eventMethod) {
		eventStr	:= eventMethod.name
		noOfParams 	:= 	eventMethod.params.size
		noOfParams.times { eventStr += "/*" }
		return eventStr.toUri
	}

	override Type[] contextTypes() {
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

	override Uri ctxToUri(Obj?[] context) {
		// TODO: afBedSheet-1.3.2, valueEnc sig change
		context.map { valueEncoders.toClient(Str#, it) ?: "" }.join("/").toUri
	}

	// ---- Private Methods --------------------------------------------------------------------------------------------	

	private Uri clientUri(Obj?[]? context) {
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
			clientUri = clientUri.plusSlash + ctxToUri(context)
		}

		// if rendering the given page, append PageContext params
		renderingType := PageMeta.peek(false)?.pageType
		if (context == null && renderingType == pageType) {
			page 	:= efanXtra.component(pageType)
			fields	:= pageType.fields.findAll { it.hasFacet(PageContext#) || it.name == PageContext#.name.decapitalize }
			args	:= fields.map { it.get(page) }
			clientUri = clientUri.plusSlash + ctxToUri(args)
		}

		return clientUri
	}
	
	private Bool isWelcomeUri(Uri clientUri) {
		return clientUri.name.equalsIgnoreCase(welcomePage)
	}
	
	private Method eventMethod(Str eventName) {
		pageType.methods.find { it.hasFacet(PageEvent#) && it.name.equalsIgnoreCase(eventName) } ?: throw PillowErr(ErrMsgs.eventNotFound(pageType, eventName))		
	}
}

internal const class PageMetaPeekABoo : PageMeta {
	
	override Type pageType() {
		PageMeta.peek(true).pageType
	}
	
	override Uri pageUri() {
		PageMeta.peek(true).pageUri
	}
	
	override MimeType contentType() {
		PageMeta.peek(true).contentType
	}
	
	override Bool isWelcomePage() {
		PageMeta.peek(true).isWelcomePage
	}

	override Str render(Obj?[]? pageContext) {
		PageMeta.peek(true).render(pageContext)
	}
	
	override Uri eventUri(Str eventName, Obj?[]? eventContext) {
		PageMeta.peek(true).eventUri(eventName, eventContext)
	}
	
	override Uri serverGlob() {
		PageMeta.peek(true).serverGlob
	}
	
	override Uri eventGlob(Method eventMethod) {
		PageMeta.peek(true).eventGlob(eventMethod)		
	}
	
	override Type[] contextTypes() {
		PageMeta.peek(true).contextTypes
	}
	
	override Uri ctxToUri(Obj?[] context) {
		PageMeta.peek(true).ctxToUri(context)
	}
}

