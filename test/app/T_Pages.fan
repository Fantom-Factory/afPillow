using afIoc
using afEfanXtra

@NoDoc
@Page
const mixin Basic 		: EfanComponent { }

@NoDoc
@Page
const mixin BasicNested : EfanComponent { }

@NoDoc
@PageUri { uri=`/facetRemapped` }
@Page
const mixin FacetPage 	: EfanComponent { }

@NoDoc
@Page
const mixin WelcomepagePage : EfanComponent {
	@Inject	abstract PageMeta	pageMeta
}
