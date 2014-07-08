using afIoc
using afEfanXtra
using afBedSheet

@NoDoc
@Page
const mixin Basic 		: EfanComponent { }

@NoDoc
@Page
const mixin BasicNested : EfanComponent { }

@NoDoc
@Page { url=`/facetRemapped` }
const mixin FacetPage 	: EfanComponent { }

@NoDoc
@Page { url=`/welcome` }
const mixin WelcomePage : EfanComponent {
	@Inject	abstract PageMeta	pageMeta
}

@NoDoc
@Page { url=`/welcome2` }
const mixin Welcome2Page : EfanComponent {
	@Inject			abstract PageMeta	pageMeta
	@PageContext	abstract Str		context	
	override Str renderTemplate() { "pageUrl:${pageMeta.pageUrl} ctx:${context}" }
}

@NoDoc
@Page { url=`/welcome3` }
const mixin Welcome3Page : EfanComponent {
	@Inject			abstract PageMeta	pageMeta
	@PageEvent
	Obj xxx(Str ctx) { Text.fromPlain("xxx pageUrl:${pageMeta.pageUrl} ctx:${ctx}") }
	override Str renderTemplate() { "wotever" }
}

