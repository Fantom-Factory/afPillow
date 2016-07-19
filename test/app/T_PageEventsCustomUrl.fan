using afIoc
using afEfanXtra
using afBedSheet

@Page { url=`/customUrl/*/custom/*/url` }
@NoDoc
const mixin T_PageEventsCustomUrl : EfanComponent {
	
	@PageContext	abstract Str	arg1
	@PageContext	abstract Str	arg2
	
	@Inject	abstract PageMeta	pageMeta
	
	@PageEvent
	Text onPlainEvent() {
		return Text.fromPlain("Plain Event Fired!")
	}

	@PageEvent
	Text ctxEvent(Str name, Int iq) {
		return Text.fromPlain("Event Ctx: name=$name, iq=$iq")
	}
}
