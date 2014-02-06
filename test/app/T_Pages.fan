using afIoc
using afEfanXtra

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
