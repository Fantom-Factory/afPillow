using afIoc::Inject
using afIoc::Registry
using afIocConfig::Config
using afEfanXtra::EfanXtra
using afEfanXtra::ComponentMeta
using afEfanXtra::InitRender
using afBedSheet::ValueEncoders
using afBedSheet::HttpRequest
using concurrent::Actor

** (Service) - Returns details about the Pillow page currently being rendered.
** 
** 'PageMeta' objects may also be created by the `Pages` service.
const mixin PageMeta {
	
	** Returns the page that this Meta object wraps.
	abstract Type pageType()

	** Returns the context used to initialise this page.
	abstract Obj?[] pageContext()

	** Returns a URI that can be used to render the given page. 
	** The URI takes into account:
	**  - Any welcome URI -> home page conversions
	**  - The context used to render this page
	**  - Any parent 'WebMods'
	abstract Uri pageUri()
	
	** Returns the 'Content-Type' produced by this page.
	** 
	** Returns `PillowConfigIds#defaultContextType` if it can not be determined.
	abstract MimeType contentType()
	
	** Returns 'true' if the page is a welcome page.
	abstract Bool isWelcomePage()

	** Returns a URI for a given event - use to create client side URIs to call the event.
	abstract Uri eventUri(Str eventName, Obj?[]? eventContext)

	** Returns a new 'PageMeta' with the given page context.
	abstract PageMeta withContext(Obj?[]? pageContext)
	
	abstract Str httpMethod()
	
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
	@Inject	private const PageUriResolver		pageUriResolver
	@Inject	private const HttpRequest			httpRequest
	@Inject	private const ComponentMeta			componentMeta
	@Inject	private const ValueEncoders			valueEncoders
	@Inject	private const EfanXtra				efanXtra
	@Inject	private const Registry				registry

	override const Type		pageType
	override const Obj?[]	pageContext
	
	internal new make(Type pageType, Obj?[]? pageContext, |This|in) {
		this.pageType 		= pageType
		this.pageContext	= pageContext ?: Obj?#.emptyList
		in(this)
	}

	override Uri pageUri() {
		clientUri := pageUriResolver.pageUri(pageType)

		// add extra WebMod paths - but only if we're part of a web request!
		if (Actor.locals["web.req"] != null && httpRequest.modBase != `/`)
			clientUri = httpRequest.modBase + clientUri.toStr[1..-1].toUri

		// convert welcome pages
		if (isWelcomeUri(clientUri))
			clientUri = clientUri.parent

		// append page context
		// 'checked' because some server operations don't care about the URI, they just want the glob  
		contextTypes := contextTypes
		if (contextTypes.size != pageContext.size)
			throw Err(ErrMsgs.invalidNumberOfInitArgs(pageType, contextTypes, pageContext))
		clientUri = clientUri.plusSlash + ctxToUri(pageContext)

		return clientUri
	}
	
	override MimeType contentType() {
		contentTypeResolver.contentType(pageType)
	}
	
	override Bool isWelcomePage() {
		clientUri := pageUriResolver.pageUri(pageType)
		return isWelcomeUri(clientUri)
	}
	
	override Uri eventUri(Str eventName, Obj?[]? eventContext) {
		eventMethod(eventName)		
		eventUri 	:= pageUri.plusSlash + `${eventName}`
		if (eventContext != null)
			eventUri = eventUri.plusSlash + ctxToUri(eventContext)
		return eventUri
	}
	
	override PageMeta withContext(Obj?[]? pageContext) {
		registry.autobuild(PageMeta#, [pageType, pageContext, true])
	}
	
	override Str httpMethod() {
		page := (Page) Type#.method("facet").callOn(pageType, [Page#])	// Stoopid F4
		return page.httpMethod
	}

	// ---- Internal Methods -------------------------------------------------------------------------------------------	

	override Uri serverGlob() {
		clientStr 	:= pageUriResolver.pageUri(pageType).toStr
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
		context.map { valueEncoders.toClient(it.typeof, it) ?: "" }.join("/").toUri
	}

	// ---- Private Methods --------------------------------------------------------------------------------------------	

	private Bool isWelcomeUri(Uri clientUri) {
		return clientUri.name.equalsIgnoreCase(welcomePage)
	}
	
	private Method eventMethod(Str eventName) {
		pageType.methods.find { it.hasFacet(PageEvent#) && it.name.equalsIgnoreCase(eventName) } ?: throw PillowErr(ErrMsgs.eventNotFound(pageType, eventName))		
	}
}

internal const class PageMetaProxy : PageMeta {
	
	override Type pageType() {
		PageMeta.peek(true).pageType
	}
	
	override Uri pageUri() {
		PageMeta.peek(true).pageUri
	}
	
	override Obj?[] pageContext() {
		PageMeta.peek(true).pageContext
	}

	override MimeType contentType() {
		PageMeta.peek(true).contentType
	}
	
	override Bool isWelcomePage() {
		PageMeta.peek(true).isWelcomePage
	}

	override Uri eventUri(Str eventName, Obj?[]? eventContext) {
		PageMeta.peek(true).eventUri(eventName, eventContext)
	}

	override PageMeta withContext(Obj?[]? pageContext) {
		PageMeta.peek(true).withContext(pageContext)
	}
	
	override Str httpMethod() {
		PageMeta.peek(true).httpMethod
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

