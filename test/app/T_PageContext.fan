using afIoc
using afEfanXtra

@NoDoc
@Page { uri=`/pageContextStr`; template=`fan://afEfanXtra/res/viaRenderMethod.efan`}
const mixin T_PageContext : EfanComponent {
	@Inject			abstract Pages 	pages
	@PageContext	abstract Str 	context
	
	Str render() {
		if (context == "err") {
			try {
				return pages.pageMeta(T_PageContext#, ["Muhaha", `/blah`]).pageUri.toStr
			} catch (Err e) {
				return e.msg
			}
		}
		return
		"context=${context}\nclientUri=" + pages.pageMeta(T_PageContext#, null).pageUri + "\nclientUri=" + pages.pageMeta(T_PageContext#, ["Dude"]).pageUri
	}
}


@NoDoc
@Page { uri=`/pageContextStrMulti`; template=`fan://afEfanXtra/res/viaRenderMethod.efan`}
const mixin T_PageContextMulti : EfanComponent {
	@Inject			abstract Pages	pages	
	@PageContext	abstract Str?	name
	@PageContext	abstract Int?	age

	Str render() {
		if (name == "err") {
			try {
				return pages.pageMeta(T_PageContextMulti#, ["Muhaha"]).pageUri.toStr
			} catch (Err e) {
				return e.msg
			}
		}
		return 
		"context=${name}/${age}
		 clientUri=${pages.pageMeta(T_PageContextMulti#, null).pageUri}
		 singleUri=" + pages.pageMeta(T_PageContext#, ["Dude"]).pageUri + "\n" +
		 "clientUri=" + pages.pageMeta(T_PageContextMulti#, ["Dude", 666]).pageUri
	}
}