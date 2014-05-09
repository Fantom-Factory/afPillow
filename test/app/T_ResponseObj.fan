using afIoc
using afEfanXtra
using afBedSheet

@Page { uri=`/responseObj` }
@NoDoc
const mixin T_ResponseObj : EfanComponent {
	@Inject	abstract Pages pages
	
	@InitRender
	Void init() {
		throw ReProcessErr(pages.pageMeta(WelcomePage#, null))
	}
	
	override Str renderTemplate() { "" }
}
