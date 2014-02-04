using afIoc
using afEfanXtra

@PageUri { uri=`/pageContextStr` }
@EfanTemplate { uri=`fan://afEfanXtra/res/viaRenderMethod.efan`}
const mixin T_PageContext : Page {
	@Inject			abstract Pages pages
	@PageContext	abstract Str context
	
	Str render() {
		if (context == "err") {
			try {
				return pages.pageMeta(T_PageContext#).clientUri(["Muhaha", `/blah`]).toStr
			} catch (Err e) {
				return e.msg
			}
		}
		return
		"context=${context}\nclientUri=" + pages.pageMeta(T_PageContext#).clientUri + "\nclientUri=" + pages.pageMeta(T_PageContext#).clientUri(["Dude"])
	}
}


@PageUri { uri=`/pageContextStrMulti` }
@EfanTemplate { uri=`fan://afEfanXtra/res/viaRenderMethod.efan`}
const mixin T_PageContextMulti : Page {
	@Inject			abstract Pages	pages	
	@PageContext	abstract Str?	name
	@PageContext	abstract Int? 	age

	Str render() {
		if (name == "err") {
			try {
				return pages.pageMeta(T_PageContextMulti#).clientUri(["Muhaha"]).toStr
			} catch (Err e) {
				return e.msg
			}
		}
		return 
		"context=${name}/${age}
		 clientUri=${pages.pageMeta(T_PageContextMulti#).clientUri}
		 singleUri=" + pages.pageMeta(T_PageContext#).clientUri(["Dude"]) + "\n" +
		 "clientUri=" + pages.pageMeta(T_PageContextMulti#).clientUri(["Dude", 666])
	}
}