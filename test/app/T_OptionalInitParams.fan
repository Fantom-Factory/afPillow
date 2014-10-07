using afEfanXtra

@NoDoc
@Page { url=`/optionalInitParams`}
const mixin T_OptionalInitParams : EfanComponent {
	
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
@Page { url=`/optionalPageCtx`}
const mixin T_OptionalPageCtx : EfanComponent {
	
	@PageContext
	abstract Str p1
	@PageContext { optional=true }
	abstract Str? p2
	@PageContext { optional=true }
	abstract Str? p3
	
	override Str renderTemplate() { "$p1 $p2 $p3" }
}
