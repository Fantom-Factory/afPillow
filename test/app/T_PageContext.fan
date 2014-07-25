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
		// just test withContext() works - sometimes we forget to set fields in the it-block
		pages.pageMeta(T_PageContext#).withContext(null)
		
		if (context == "err") {
			try {
				return pages.pageMeta(T_PageContext#, ["Muhaha", `/blah`]).pageUrl.toStr
			} catch (Err e) {
				return e.msg
			}
		}
		return
		"context=${context}\nclientUri=" + pageMeta.pageUrl + "\nclientUri=" + pages.pageMeta(T_PageContext#, ["Dude"]).pageUrl
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
				return pages.pageMeta(T_PageContextMulti#, ["Muhaha"]).pageUrl.toStr
			} catch (Err e) {
				return e.msg
			}
		}
		return 
		"context=${name}/${age}
		 clientUri=${pageMeta.pageUrl}
		 singleUri=" + pages.pageMeta(T_PageContext#, ["Dude"]).pageUrl + "\n" +
		 "clientUri=" + pages.pageMeta(T_PageContextMulti#, ["Dude", 666]).pageUrl
	}
}
