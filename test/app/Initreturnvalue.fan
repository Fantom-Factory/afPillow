using afEfanXtra
using afBedSheet

@NoDoc
@Page
const mixin Initreturnvalue : EfanComponent {
	
	@InitRender
	Void initRender() {
		throw ReProcessErr(Text.fromPlain("Train trouble."))
	}
}

