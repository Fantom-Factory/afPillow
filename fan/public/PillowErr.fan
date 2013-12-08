
** As thrown by Pillow.
const class PillowErr : Err {
	new make(Str msg := "", Err? cause := null) : super(msg, cause) {}
}
