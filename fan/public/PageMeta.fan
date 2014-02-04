using afIoc::Inject
using afIocConfig::Config
using afEfanXtra::EfanXtra
using afEfanXtra::ComponentMeta
using afEfanXtra::InitRender
using afBedSheet::ValueEncoders
using afBedSheet::HttpRequest
using concurrent::Actor

const mixin PageMeta {
	
	** Returns the page that this Meta object wraps.
	abstract Type pageType()
	
	** Returns a URI that can be used to render the given page and context.
	abstract Uri clientUri(Obj?[]? pageContext := null)
	
	** Returns the 'Content-Type' produced by this page.
	abstract MimeType contentType()
	
	** Returns 'true' if the given page type is a welcome page.
	abstract Bool isWelcomePage()

	** Renders the given page, using the 'pageContext' as arguments to '@InitRender'. 
	** 
	** Note that 'pageContext' items converted their appropriate type () via BedSheet's 'ValueEncoder' service.
	abstract Str render(Obj?[]? pageContext := null) 
	
	** Returns Meta for a given event - use to create client side URIs to call the event.
	abstract EventMeta eventMeta(Str eventName, Obj?[]? pageContext := null)
	
	@NoDoc
	abstract internal Uri serverGlob()
	
	@NoDoc
	abstract internal Type[] contextTypes()
	
	@NoDoc
	abstract Uri ctxToUri(Obj?[] context)
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
	
	internal new make(Type pageType, |This|in) {
		in(this)
		this.pageType = pageType
	}
	
	override Uri clientUri(Obj?[]? context := null) {
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
		renderingType := RenderingPageMetaImpl.peek?.type
		if (context == null && renderingType == pageType) {
			page 	:= RenderingPageMetaImpl.peek.page
			fields	:= pageType.fields.findAll { it.hasFacet(PageContext#) || it.name == PageContext#.name.decapitalize }
			args	:= fields.map { it.get(page) }
			clientUri = clientUri.plusSlash + ctxToUri(args)
		}

		return clientUri
	}
	
	override MimeType contentType() {
		contentTypeResolver.contentType(pageType)
	}
	
	override Bool isWelcomePage() {
		clientUri := clientUriResolver.clientUri(pageType)
		return isWelcomeUri(clientUri)
	}
	
	override Str render(Obj?[]? pageContext := null) {
		page := (Page) efanXtra.component(pageType)
		return RenderingPageMetaImpl.pushRenderingPage(page, pageType) |->Str| {
			return efanXtra.render(pageType, pageContext)
		}
	}
	
	override EventMeta eventMeta(Str eventName, Obj?[]? pageContext := null) {
		EventMeta(this, pageContext, eventName)
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
	
	** Returns 'clientUri'.
	override Str toStr() {
		clientUri.toStr
	}

	private Bool isWelcomeUri(Uri clientUri) {
		return clientUri.name.equalsIgnoreCase(welcomePage)
	}	
}


const class EventMeta {
	private const 	PageMeta	pageMeta
	private const 	Uri			pageUri
	private const 	Str			eventName
	private const 	Method		eventMethod
	
	internal new make(PageMeta pageMeta, Obj?[]? pageContext, Str eventName) {
		this.eventMethod	= pageMeta.pageType.methods.find { it.hasFacet(PageEvent#) && it.name.equalsIgnoreCase(eventName) } ?: throw PillowErr(ErrMsgs.eventNotFound(pageMeta.pageType, eventName))		
		this.pageMeta		= pageMeta
		// pageContext may not be const, so serialise it to a Str
		this.pageUri		= pageMeta.clientUri(pageContext)
		this.eventName 		= eventName
	}
	
	** Returns a URI that can be used to call the given event
	Uri clientUri(Obj?[]? eventContext := null) {
		eventUri := pageMeta.clientUri.plusSlash + `${eventName}`
		if (eventContext != null)
			eventUri = eventUri.plusSlash + pageMeta.ctxToUri(eventContext)
		return eventUri
	}
	
	internal Uri eventGlob() {
		eventStr	:= eventName
		noOfParams 	:= eventMethod.params.size
		noOfParams.times { eventStr += "/*" }
		return eventStr.toUri
	}
	
	** Returns 'clientUri'.
	override Str toStr() {
		clientUri.toStr
	}
}
