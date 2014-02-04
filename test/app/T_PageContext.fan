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
				return pages.clientUri(T_PageContext#, ["Muhaha", `/blah`]).toStr
			} catch (Err e) {
				return e.msg
			}
		}
		return
		"context=${context}\nclientUri=" + pages.clientUri(T_PageContext#) + "\nclientUri=" + pages.clientUri(T_PageContext#, ["Dude"])
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
				return pages.clientUri(T_PageContextMulti#, ["Muhaha"]).toStr
			} catch (Err e) {
				return e.msg
			}
		}
		return 
		"context=${name}/${age}
		 clientUri=${pages.clientUri(T_PageContextMulti#)}
		 singleUri=" + pages.clientUri(T_PageContext#, ["Dude"]) + "\n" +
		 "clientUri=" + pages.clientUri(T_PageContextMulti#, ["Dude", 666])
	}
}