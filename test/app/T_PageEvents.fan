using afIoc
using afEfanXtra
using afBedSheet

@PageUri { uri=`/pageEvents` }
const mixin T_PageEvents : Page {
	@Inject			abstract Pages pages
	
	@PageEvent
	Text plainEvent() {
		return Text.fromPlain("Plain Event Fired!")
	}

	@PageEvent
	Text ctxEvent(Str name, Int iq) {
		return Text.fromPlain("Ctx Event: name=$name, iq=$iq")
	}
}


@PageUri { uri=`/pageEventsWithContext` }
const mixin T_PageEventsWithContext : Page {
	@Inject			abstract Pages	pages	
	@PageContext	abstract Str?	name
	@PageContext	abstract Int? 	age
}