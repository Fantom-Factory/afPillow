using afIoc
using afEfanXtra
using afBedSheet

@Page { uri=`/responseObj`; template=`fan://afEfanXtra/res/viaRenderMethod.efan` }
@NoDoc
const mixin T_ResponseObj : EfanComponent {
	@Inject	abstract Pages pages
	
	@InitRender
	Void init() {
		throw ReProcessErr(pages.pageMeta(WelcomepagePage#, null))
	}
	
	Str render() { "" }
}
