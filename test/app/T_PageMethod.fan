using afIoc
using afEfanXtra
using afBedSheet

@Page { uri=`/pageMethod`; template=`fan://afEfanXtra/res/viaRenderMethod.efan`; httpMethod="POST" }
@NoDoc
const mixin T_PageMethod : EfanComponent {
	
	@PageEvent { httpMethod="POST" }
	Obj getsome() {
		return Text.fromPlain("POST Event Rendered")
	}
	
	Str render() { "POST Rendered" }
}
