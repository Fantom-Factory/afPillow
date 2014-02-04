using afIoc
using afEfanXtra
using afBedSheet

@PageUri { uri=`/pageEvents` }
@Page
@NoDoc
const mixin T_PageEvents : EfanComponent {
	@Inject	abstract PageMeta	pageMeta
	
	@PageEvent
	Text plainEvent() {
		return Text.fromPlain("Plain Event Fired!")
	}

	@PageEvent
	Text ctxEvent(Str name, Int iq) {
		return Text.fromPlain("Event Ctx: name=$name, iq=$iq")
	}
}


@PageUri { uri=`/pageCtxEvents` }
@Page
@NoDoc
const mixin T_PageCtxEvents : EfanComponent {
	@Inject			abstract PageMeta	pageMeta
	@PageContext	abstract Str?		name
	@PageContext	abstract Int? 		iq
	
	@PageEvent
	Text plainEvent() {
		return Text.fromPlain("Plain Event Fired!\nPage Ctx: name=$name, iq=$iq")
	}

	@PageEvent
	Text ctxEvent(Str name2, Int iq2) {
		return Text.fromPlain("Page Ctx: name=$name, iq=$iq\nEvent Ctx: name=$name2, iq=$iq2")
	}
}