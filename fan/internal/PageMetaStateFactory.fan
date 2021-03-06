using concurrent::Actor
using afIoc::Inject
using afIocConfig::Config
using afEfanXtra::ComponentMeta
using afEfanXtra::EfanXtra

internal class PageMetaStateFactory  {

	@Config { id="afPillow.welcomePageName" }
	@Inject private const Str 					welcomePageName
	@Config { id="afPillow.welcomePageStrategy" }
	@Inject private const WelcomePageStrategy	welcomePageStrategy
	
	@Inject	private const ContentTypeResolver	contentTypeResolver
	@Inject	private const PageUrlResolver		pageUrlResolver
	@Inject	private const ComponentMeta			componentMeta
	@Inject	private const EfanXtra				efanXtra

	Type? pageType
	InitRenderMethod? initRender
	
	new make(|This|in) { in(this) }

	PageMetaState toPageMetaState(Type pageType) {
		this.pageType	= pageType
		this.initRender	= InitRenderMethod(componentMeta, pageType)		
		
		// can't have optional page params AND event methods
		if (initRender.hasOptionalParams && !eventMethods.isEmpty)
			// unless the event is called with NO page ctx AND has a different httpMethod
			if (initRender.minNumArgs > 0)	// TODO check http methods -> introduce an Event objs
				throw PillowErr(ErrMsgs.optionalParamsNotAllowedWithEvents)
		
		return PageMetaState {
			it.pageType			= this.pageType
			it.pageBaseUri		= this.pageBaseUri
			it.contentType		= this.contentType
			it.isWelcomePage	= this.isWelcomePage
			it.httpMethod		= this.httpMethod
			it.routesDisabled	= this.disableRouting
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
		page := (Page) pageType.facet(Page#)
		return page.httpMethod
	}
	
	Bool disableRouting() {
		page := (Page) pageType.facet(Page#)
		return page.disableRouting 
	}

	Uri pageGlob() {
		clientUrl 	:= pageUrlResolver.pageUrl(pageType)

		// leave the URL alone if it's been set by the user
		if (clientUrl.toStr.contains("*"))
			return clientUrl
		
		if (welcomePageStrategy.isOn && isWelcomeUri(clientUrl)) {
			clientUrl = clientUrl.parent
			
			// remove the trailing /slash/ as per the new BedSheet routing standard
			// (if we don't, we'll incur a redirect penalty)
			if (clientUrl.path.size > 0)
				clientUrl = clientUrl.parent.plusName(clientUrl.name)
		}

		// add wildcards for each param
		clientUrl = initRender.paramGlob(clientUrl)
		return clientUrl
	}

	Method[] eventMethods() {
		// find all page event methods, taking care to both search the hierarchy AND take unique overridden methods 
		methods := Str:Method[:]
		inheritance := pageType.inheritance.rw.reverse
		for (i := 0; i < inheritance.size; ++i) {
			meths := inheritance[i].methods
			for (x := 0; x < meths.size; ++x) {
				method := meths[x]
				if (method.hasFacet(PageEvent#))
					methods[method.name] = method
			}
		}
		return methods.vals
	}
	
	private Bool isWelcomeUri(Uri clientUri) {
		return clientUri.name.equalsIgnoreCase(welcomePageName)
	}	
}
