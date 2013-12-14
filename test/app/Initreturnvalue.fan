using afEfanXtra
using afBedSheet

@NoDoc
const mixin Initreturnvalue : Page {
	
	@InitRender
	Text initRender() {
		Text.fromPlain("Train trouble.")
	}
}

