using afEfanXtra

@NoDoc
@Page { url=`/optionalInitParams`}
const mixin T_OptionalInitParams : EfanComponent {
	
	abstract Str? p1; abstract Str? p2; abstract Str? p3
	
	@InitRender
	Void initRender(Str? p1, Str p2 := "dodaa", Str? p3 := null) {
		this.p1 = p1
		this.p2 = p2
		this.p3 = p3
	}

	override Str renderTemplate() { "$p1 $p2 $p3" }
}

@NoDoc
@Page { url=`/optionalPageCtxs`}
const mixin T_OptionalPageCtxs : EfanComponent {
	
	@PageContext
	abstract Str? p1
	@PageContext { optional=true }
	abstract Str? p2
	@PageContext { optional=true }
	abstract Str? p3
	
	override Str renderTemplate() { "$p1 $p2 $p3" }
}

// ---- Nullable ----

@NoDoc
@Page { url=`/initParamNullable`}
const mixin T_InitParamNullable : EfanComponent {
	abstract Str? p1
	@InitRender
	Void initRender(Str? p1) { this.p1 = p1	}
	override Str renderTemplate() { "$p1" }
}

@NoDoc
@Page { url=`/pageCtxNullable`}
const mixin T_PageCtxNullable : EfanComponent {
	@PageContext
	abstract Str? p1
	override Str renderTemplate() { "$p1" }
}

// ---- Optional ----

@NoDoc
@Page { url=`/initParamOptional`}
const mixin T_InitParamOptional : EfanComponent {
	abstract Str? p1
	@InitRender
	Void initRender(Str? p1 := null) { this.p1 = p1	}
	override Str renderTemplate() { "$p1" }
}

@NoDoc
@Page { url=`/pageCtxOptional`}
const mixin T_PageCtxOptional : EfanComponent {
	@PageContext { optional=true }
	abstract Str? p1
	override Str renderTemplate() { "$p1" }
}
