using afIoc
using afEfanXtra
using afBedSheet

@Page { url=`/pageMethod`; httpMethod="POST" }
@NoDoc
const mixin T_PageMethod : EfanComponent {
	
	@PageEvent { httpMethod="POST" }
	Obj getsome() {
		return Text.fromPlain("POST Event Rendered")
	}
	
	override Str renderTemplate() { "POST Rendered" }
}
