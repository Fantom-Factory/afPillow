
internal const class ErrMsgs {
	
	static Str pageRouteShouldBePathOnly(Type pageType, Uri pageRoute) {
		"Route `$pageRoute` for Page ${pageType.qname} must only contain a path. e.g. `/foo/bar`"
	}

	static Str pageRouteShouldStartWithSlash(Type pageType, Uri pageRoute) {
		"Route `$pageRoute` for Page ${pageType.qname} must start with a slash. e.g. `/foo/bar`"
	}

	static Str pageCanNotHaveInitRenderAndPageContext(Type pageType) {
		"Page ${pageType.qname} may NOT have both an @InitRender method AND and use @PageContext. Choose one!"
	}

	static Str renderingPageMetaNotRendering() {
		"Pillow is NOT currently rendering a page."
	}

	static Str invalidNumberOfInitArgs(Type pageType, Int minNoOfArgs, Obj[] context) {
		"Page ${pageType.qname} requires ${minNoOfArgs} init parameter(s) but ${context.size} were given: " + context.map { it.toStr }
	}

	static Str eventNotFound(Type pageType, Str eventName) {
		"Page ${pageType.qname} does not have an event method called '${eventName}'"
	}

	static Str couldNotFindPageUrl(Type pageType) {
		"Could not find a page URL for ${pageType.qname}"
	}

	static Str couldNotFindPage(Type pageType) {
		"Could not find page of Type ${pageType.qname}"
	}
	
	static Str componentNotMixin(Type type) {
		"EfanXtra component ${type.qname} is NOT a mixin"
	}

	static Str componentNotConst(Type type) {
		"EfanXtra component ${type.qname} is NOT const"
	}

	static Str optionalParamsNotAllowedWithEvents() {
		"Optional page parameters are not allowed with page events"
	}
}
