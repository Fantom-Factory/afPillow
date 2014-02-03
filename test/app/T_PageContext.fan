using afIoc
using afEfanXtra

@PageUri { uri=`/pageContextStr` }
@EfanTemplate { uri=`fan://afEfanXtra/res/viaRenderMethod.efan`}
const mixin T_PageContext : Page {
	
	@Inject
	abstract Pages pages
	
	@PageContext
	abstract Str? context
	
	Str render() {
		return "context=${context}\nclientUri=" + pages.clientUri(T_PageContext#)
//		"context=${context}\nclientUri=" + pages.clientUri(T_PageContext#) + "\nclientUri=" + pages.clientUri(T_PageContext#, "Dude")
	}
}
