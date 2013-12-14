using afEfanXtra

@NoDoc
const mixin InitSigRoute : Page {
	
	abstract Int x
	abstract Str y
	
	@InitRender
	Void initRender(Int x, Str y) {
		this.x = x
		this.y = y
	}
	
}

