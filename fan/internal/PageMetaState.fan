
internal const class PageMetaState {
	const Type 		pageType
	const Uri 		pageBaseUri
	const MimeType 	contentType
	const Bool 		isWelcomePage
	const Str		httpMethod
	const Bool		routesDisabled
	const Uri 		pageGlob
	const Method[]	eventMethods

	const InitRenderMethod	initRender

	new make(|This|in) { in(this) }
}
