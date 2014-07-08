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
	
	new make(|This|in) { in(this) }

	PageMetaState toPageMetaState(Type pageType) {
		this.pageType = pageType
		return PageMetaState {
			it.pageType			= this.pageType
			it.pageBaseUri		= this.pageBaseUri
			it.contentType		= this.contentType
			it.isWelcomePage	= this.isWelcomePage
			it.httpMethod		= this.httpMethod
			it.serverGlob		= this.serverGlob
			it.contextTypes		= this.contextTypes
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

	Uri serverGlob() {
		clientUri 	:= pageUrlResolver.pageUrl(pageType)
		if (welcomePageStrategy.isOn && isWelcomeUri(clientUri))
			clientUri = clientUri.parent
		noOfParams 	:= contextTypes.size
		noOfParams.times { clientUri = clientUri.plusSlash + `*` }
		return clientUri
	}

	Uri eventGlob(Method eventMethod) {
		eventStr	:= eventMethod.name
		noOfParams 	:= 	eventMethod.params.size
		noOfParams.times { eventStr += "/*" }
		return eventStr.toUri
	}

	Type[] contextTypes() {
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

	private Bool isWelcomeUri(Uri clientUri) {
		return clientUri.name.equalsIgnoreCase(welcomePageName)
	}	
}
