using concurrent::Actor
using afIoc
using afIocConfig
using afEfanXtra

internal class PageMetaStateFactory  {

	@Config { id="afPillow.welcomePageName" }
	@Inject private const Str 					welcomePageName
	@Config { id="afPillow.welcomePageStrategy" }
	@Inject private const WelcomePageStrategy	welcomePageStrategy
	
	@Inject	private const ContentTypeResolver	contentTypeResolver
	@Inject	private const PageUrlResolver		pageUrlResolver
	@Inject	private const ComponentMeta			componentMeta
	@Inject	private const EfanXtra				efanXtra
	@Inject	private const Registry				registry

	Type? pageType
	InitRenderMethod? initRender
	
	new make(|This|in) { in(this) }

	PageMetaState toPageMetaState(Type pageType) {
		this.pageType	= pageType
		this.initRender	= InitRenderMethod(componentMeta, pageType)		
		
		if (initRender.hasOptionalParams && !eventMethods.isEmpty)
			throw PillowErr(ErrMsgs.optionalParamsNotAllowedWithEvents)
		
		return PageMetaState {
			it.pageType			= this.pageType
			it.pageBaseUri		= this.pageBaseUri
			it.contentType		= this.contentType
			it.isWelcomePage	= this.isWelcomePage
			it.httpMethod		= this.httpMethod
			it.disableRoutes	= this.disableRoutes
			it.pageGlob			= this.pageGlob
			it.eventMethods		= this.eventMethods
			it.initRender		= this.initRender
		}
	}
	
	Uri pageBaseUri() {
		clientUri := pageUrlResolver.pageUrl(pageType)

		// convert welcome pages
		if (welcomePageStrategy.isOn && isWelcomeUri(clientUri))
			clientUri = clientUri.parent

		return clientUri
	}
	
	MimeType contentType() {
		contentTypeResolver.contentType(pageType)
	}
	
	Bool isWelcomePage() {
		clientUri := pageUrlResolver.pageUrl(pageType)
		return isWelcomeUri(clientUri)
	}
	
	Str httpMethod() {
		page := (Page) Type#.method("facet").callOn(pageType, [Page#])	// Stoopid F4
		return page.httpMethod
	}
	
	Bool disableRoutes() {
		page := (Page) Type#.method("facet").callOn(pageType, [Page#])	// Stoopid F4
		return page.disableRoutes
	}

	Uri pageGlob() {
		clientUri 	:= pageUrlResolver.pageUrl(pageType)
		if (welcomePageStrategy.isOn && isWelcomeUri(clientUri))
			clientUri = clientUri.parent		
		clientUri = initRender.paramGlob(clientUri)
		return clientUri
	}

	Method[] eventMethods() {
		pageType.methods.findAll { it.hasFacet(PageEvent#) }
	}
	
	private Bool isWelcomeUri(Uri clientUri) {
		return clientUri.name.equalsIgnoreCase(welcomePageName)
	}	
}
