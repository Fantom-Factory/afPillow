using afEfanXtra

@NoDoc
@Page
const mixin InitSigRoute : EfanComponent  {
	
	abstract Int x
	abstract Str y
	
	@InitRender
	Void initRender(Int x, Str y) {
		this.x = x
		this.y = y
	}
	
}

