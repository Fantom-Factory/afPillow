using afBeanUtils::NotFoundErr

** As thrown by Pillow.
const class PillowErr : Err {
	new make(Str msg := "", Err? cause := null) : super(msg, cause) {}
}

@NoDoc
const class PageNotFoundErr : PillowErr, NotFoundErr {	
	override const Str?[] availableValues
	
	new make(Str msg, Obj?[] availableValues, Err? cause := null) : super(msg, cause) {
		this.availableValues = availableValues.map { it?.toStr }.sort
	}
	
	override Str toStr() {
		NotFoundErr.super.toStr
	}
}
