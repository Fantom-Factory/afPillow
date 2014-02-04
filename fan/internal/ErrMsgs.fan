
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

	static Str invalidNumberOfInitArgs(Type pageType, Type[] initTypes, Obj[] context) {
		"Page ${pageType.qname} requires ${initTypes.size} init parameter(s) but ${context.size} were given: " + context.map { it.toStr }
	}
}
