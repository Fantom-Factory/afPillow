using afIoc
using afEfanXtra
using afBedSheet

@Page { url=`/pageEvents` }
@NoDoc
const mixin T_PageEvents : EfanComponent {
	@Inject	abstract PageMeta	pageMeta
	
	@PageEvent
	Void defaultReturnValue() {
		// should render this page --> "Default Page"
	}
	
	@PageEvent
	Text plainEvent() {
		return Text.fromPlain("Plain Event Fired!")
	}

	@PageEvent { name="dingdong" }
	Text namedEvent() {
		return Text.fromPlain("Ding Dong Event Fired!")
	}

	@PageEvent
	Text ctxEvent(Str name, Int iq) {
		return Text.fromPlain("Event Ctx: name=$name, iq=$iq")
	}
}


@Page { url=`/pageCtxEvents` }
@NoDoc
const mixin T_PageCtxEvents : EfanComponent {
	@Inject			abstract PageMeta	pageMeta
	@PageContext	abstract Str?		name
	@PageContext	abstract Int? 		iq

					abstract Str?		ctxName
					abstract Int? 		ctxIq
	
	@PageEvent
	Text plainEvent() {
		return Text.fromPlain("Plain Event Fired!\nPage Ctx: name=$name, iq=$iq")
	}

	@PageEvent
	Text ctxEvent(Str name2, Int iq2) {
		return Text.fromPlain("Page Ctx: name=$name, iq=$iq\nEvent Ctx: name=$name2, iq=$iq2")
	}
	
	@PageEvent
	Void setVars(Str name2, Int iq2) {
		this.ctxName = name2
		this.ctxIq = iq2
	}
}