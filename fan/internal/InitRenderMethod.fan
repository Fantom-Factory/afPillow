using afPlastic
using afEfanXtra

internal const class InitRenderMethod {

	const Type[]	paramTypes
	const Int		minNoOfArgs

	const Bool[]	optionals
	const Type		pageType
	const Field[]?	initFields
	
	new make(ComponentMeta componentMeta, Type pageType) {
		this.pageType	= pageType
		this.paramTypes = Type#.emptyList
		this.optionals	= Bool#.emptyList
		
		initFields	:= pageType.fields.findAll { it.hasFacet(PageContext#) || it.name == PageContext#.name.decapitalize }
		initMethod	:= componentMeta.findMethod(pageType, InitRender#)
		
		if (!initFields.isEmpty && initMethod != null)
			throw PillowErr(ErrMsgs.pageCanNotHaveInitRenderAndPageContext(pageType))

		if (initMethod != null) {
			this.paramTypes		= initMethod.params.map     {  it.type }
			this.optionals		= initMethod.params.map     {  it.hasDefault }
			this.minNoOfArgs	= initMethod.params.findAll { !it.hasDefault }.size
			return
		}

		if (!initFields.isEmpty) {
			this.paramTypes		= initFields.map { it.type }
			this.optionals		= initFields.map { false }
			this.minNoOfArgs	= initFields.size
			this.initFields		= initFields
		}
	}
	
	Bool hasOptionalParams() {
		optionals.any { it }
	}
	
	Bool argsMatch(Str?[] segments) {
		if (segments.size < minNoOfArgs || segments.size > paramTypes.size)
			return false
		return paramTypes.all |Type paramType, i->Bool| {
			if (i >= segments.size)
				return optionals[i]
			return (segments[i] == null) ? paramType.isNullable : true
		}
	}
	
	Void compileMethod(PlasticClassModel model) {
		if (initFields == null)
			return
		
		sig  := initFields.map |f, i->Str| {
			
			pageCtx := (PageContext) Slot#.method("facet").callOn(f, [PageContext#])	// Stoopid F4
			
			return "${f.type.signature} ctx${i}"
			
		}.join(", ")

		body := initFields.map |f, i->Str| { "this.${f.name} = ctx${i}" }.join("\n")
		init := model.addMethod(Void#, InitRender#.name.decapitalize, sig, body)
		init.facets.add(PlasticFacetModel(InitRender#))		
	}
}
