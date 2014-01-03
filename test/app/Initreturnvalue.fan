using afEfanXtra
using afBedSheet

@NoDoc
const mixin Initreturnvalue : Page {
	
	@InitRender
	Void initRender() {
		throw ReProcessErr(Text.fromPlain("Train trouble."))
	}
}

