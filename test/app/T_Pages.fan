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
@Page { uri=`/welcome2`; template=`fan://afEfanXtra/res/viaRenderMethod.efan` }
const mixin Welcome2Page : EfanComponent {
	@Inject			abstract PageMeta	pageMeta
	@PageContext	abstract Str		context	
	Str render() { "pageUri:${pageMeta.pageUri} ctx:${context}" }
}

@NoDoc
@Page { uri=`/welcome3`; template=`fan://afEfanXtra/res/viaRenderMethod.efan` }
const mixin Welcome3Page : EfanComponent {
	@Inject			abstract PageMeta	pageMeta
	@PageEvent
	Obj xxx(Str ctx) { Text.fromPlain("xxx pageUri:${pageMeta.pageUri} ctx:${ctx}") }
	Str render() { "wotever" }
}

