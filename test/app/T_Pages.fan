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
@Page { uri=`/facetRemapped` }
const mixin FacetPage 	: EfanComponent { }

@NoDoc
@Page { uri=`/welcome` }
const mixin WelcomePage : EfanComponent {
	@Inject	abstract PageMeta	pageMeta
}

@NoDoc
@Page { uri=`/welcome2` }
const mixin Welcome2Page : EfanComponent {
	@Inject			abstract PageMeta	pageMeta
	@PageContext	abstract Str		context	
	override Str renderTemplate() { "pageUri:${pageMeta.pageUri} ctx:${context}" }
}

@NoDoc
@Page { uri=`/welcome3` }
const mixin Welcome3Page : EfanComponent {
	@Inject			abstract PageMeta	pageMeta
	@PageEvent
	Obj xxx(Str ctx) { Text.fromPlain("xxx pageUri:${pageMeta.pageUri} ctx:${ctx}") }
	override Str renderTemplate() { "wotever" }
}

