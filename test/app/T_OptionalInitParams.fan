using afEfanXtra

@NoDoc
@Page { url=`/optionalInit1`}
const mixin T_OptionalInitParams1 : EfanComponent {
	
	abstract Str? p1; abstract Str? p2; abstract Str? p3
	
	@InitRender
	Void initRender(Str p1, Str p2 := "dodaa", Str? p3 := null) {
		this.p1 = p1
		this.p2 = p2
		this.p3 = p3
	}

	override Str renderTemplate() { "$p1 $p2 $p3" }
}

@NoDoc
@Page { url=`/optionalInit2`}
const mixin T_OptionalInitParams2 : EfanComponent {
	
	override Str renderTemplate() { "wotever" }
}
