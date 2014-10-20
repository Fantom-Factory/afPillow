
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

	static Str invalidNumberOfPageArgs(Type pageType, Int minNoOfArgs, Int maxNoOfArgs, Obj?[] context) {
		extra := (minNoOfArgs != maxNoOfArgs) ? " to ${maxNoOfArgs}" : Str.defVal
		return "Page ${pageType.qname} requires ${minNoOfArgs}${extra} init parameter(s) but ${context.size} were given: " + context.map { it.toStr }
	}

	static Str invalidNumberOfEventArgs(Method eventMethod, Int minNoOfArgs, Int maxNoOfArgs, Obj?[]? context) {
		extra := (minNoOfArgs != maxNoOfArgs) ? " to ${maxNoOfArgs}" : Str.defVal
		return "Event ${eventMethod.qname} requires ${minNoOfArgs}${extra} parameter(s) but ${context?.size ?: 0} were given: " + context?.map { it.toStr }
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
	
	static Str eventTypeNotKnown(Obj event) {
		"Event should be either a Str or a page Method - ${event}"
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

	static Str pageCtxMustBeNullable(Field field) {
		"Page context ${field.qname} must be nullable because it is marked as optional."
	}

	static Str pageCtxMustBeOptional(Field field) {
		"Page context ${field.qname} must be optional because the page context before it was."
	}
	
	static Str stripSys(Str str) {
		str.replace("sys::", "")
	}
}
