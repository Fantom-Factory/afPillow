using afIoc
using afEfanXtra

@NoDoc
@Page { url=`/pageContextStr` }
const mixin T_PageContext : EfanComponent {
	@Inject	abstract Pages 		pages
	@Inject	abstract PageMeta 	pageMeta

	@PageContext	
			abstract Str 		context
	
	override Str renderTemplate() {
		if (context == "err") {
			try {
				return pages.pageMeta(T_PageContext#, ["Muhaha", `/blah`]).pageUri.toStr
			} catch (Err e) {
				return e.msg
			}
		}
		return
		"context=${context}\nclientUri=" + pageMeta.pageUri + "\nclientUri=" + pages.pageMeta(T_PageContext#, ["Dude"]).pageUri
	}
}


@NoDoc
@Page { url=`/pageContextStrMulti` }
const mixin T_PageContextMulti : EfanComponent {
	@Inject	abstract Pages		pages	
	@Inject	abstract PageMeta 	pageMeta
	
	@PageContext	abstract Str?	name
	@PageContext	abstract Int?	age

	override Str renderTemplate() {
		if (name == "err") {
			try {
				return pages.pageMeta(T_PageContextMulti#, ["Muhaha"]).pageUri.toStr
			} catch (Err e) {
				return e.msg
			}
		}
		return 
		"context=${name}/${age}
		 clientUri=${pageMeta.pageUri}
		 singleUri=" + pages.pageMeta(T_PageContext#, ["Dude"]).pageUri + "\n" +
		 "clientUri=" + pages.pageMeta(T_PageContextMulti#, ["Dude", 666]).pageUri
	}
}
