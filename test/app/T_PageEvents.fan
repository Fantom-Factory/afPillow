using afIoc
using afEfanXtra
using afBedSheet

@NoDoc
@Page { url=`/pageEvents` }
const mixin T_PageEvents : EfanComponent {
	@Inject	abstract PageMeta	pageMeta
	
	@PageEvent { httpMethod="GET" }
	Void defaultReturnValue() {
		// should render this page --> "Default Page"
	}
	
	@PageEvent { httpMethod="GET" }
	virtual Text onPlainEvent() {
		return Text.fromPlain("Plain Event Fired!")
	}

	@PageEvent  { httpMethod="GET"; name="dingdong" }
	Text namedEvent() {
		return Text.fromPlain("Ding Dong Event Fired!")
	}

	@PageEvent { httpMethod="GET" }
	Text ctxEvent(Str name, Int iq) {
		return Text.fromPlain("Event Ctx: name=$name, iq=$iq")
	}

	@PageEvent  { httpMethod="GET"; name="opt" }
	Text optionalEvent(Str name := "not supplied") {
		return Text.fromPlain("Optional Event Ctx: name=$name")
	}

	@PageEvent { name=""; httpMethod="POST" }
	Text emptyEvent(Str name := "not supplied") {
		return Text.fromPlain("Empty Event Ctx: name=$name")
	}
}

@NoDoc
@Page { url=`/pageEvents2` }
const mixin T_PageEvents2 : T_PageEvents {
	override Text onPlainEvent() {
		return Text.fromPlain("Plain SUBCLASS Event Fired!")
	}
}

@NoDoc
@Page { url=`/pageCtxEvents` }
const mixin T_PageCtxEvents : EfanComponent {
	@Inject			abstract PageMeta	pageMeta
	@PageContext	abstract Str?		name
	@PageContext	abstract Int? 		iq

					abstract Str?		ctxName
					abstract Int? 		ctxIq
	
	@PageEvent { httpMethod="GET" }
	Text plainEvent() {
		return Text.fromPlain("Plain Event Fired!\nPage Ctx: name=$name, iq=$iq")
	}

	@PageEvent { httpMethod="GET" }
	Text ctxEvent(Str name2, Int iq2) {
		return Text.fromPlain("Page Ctx: name=$name, iq=$iq\nEvent Ctx: name=$name2, iq=$iq2")
	}
	
	@PageEvent { httpMethod="GET" }
	Void setVars(Str name2, Int iq2) {
		this.ctxName = name2
		this.ctxIq = iq2
	}
}