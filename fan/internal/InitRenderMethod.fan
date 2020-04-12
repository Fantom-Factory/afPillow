using afPlastic::PlasticClassModel
using afPlastic::PlasticFacetModel
using afEfanXtra::InitRender
using afEfanXtra::ComponentMeta

@NoDoc	// public 'cos Sitemap needs to know if a page has params 
const class InitRenderMethod {
			const Type		pageType
			const Type[]	paramTypes	
	private const Bool[]	optionals
	private const Field[]?	initFields
	
	new make(ComponentMeta componentMeta, Type pageType) {
		this.pageType	= pageType
		this.paramTypes = Type#.emptyList
		this.optionals	= Bool#.emptyList
		
		initFields	:= pageType.fields.findAll { it.hasFacet(PageContext#) || it.name == PageContext#.name.decapitalize }
		initMethod	:= componentMeta.findMethod(pageType, InitRender#)
		
		if (!initFields.isEmpty && initMethod != null)
			throw PillowErr(ErrMsgs.pageCanNotHaveInitRenderAndPageContext(pageType))

		if (initMethod != null) {
			this.paramTypes		= initMethod.params.map {  it.type }
			this.optionals		= initMethod.params.map {  it.hasDefault }
			return
		}

		if (!initFields.isEmpty) {
			this.initFields		= initFields
			this.paramTypes		= initFields.map { it.type }
			opts := false
			this.optionals		= initFields.map |Field f->Bool| {
				pageCtx := (PageContext?) f.facet(PageContext#, false)
				optional := pageCtx?.optional ?: false
				
				if (optional && !f.type.isNullable)
					throw PillowErr(ErrMsgs.pageCtxMustBeNullable(f))
				
				if (optional) opts = true
				if (!optional && opts)
					throw PillowErr(ErrMsgs.pageCtxMustBeOptional(f))

				return optional
			}
		}
	}

	Int minNumArgs() {
		optionals.findAll { !it }.size
	}

	Int maxNumArgs() {
		optionals.size
	}
	
	Bool hasOptionalParams() {
		optionals.any { it }
	}

	Uri paramGlob(Uri pageGlob) {
		for (i := 0; i < optionals.size; ++i) {
			pageGlob = pageGlob.plusSlash.plusName("*")			
		}
		return pageGlob
	}
	
//	Bool argsMatch(Str?[] segments) {
//		if (segments.size < minNoOfArgs || segments.size > paramTypes.size)
//			return false
//		return paramTypes.all |Type paramType, i->Bool| {
//			if (i >= segments.size)
//				return optionals[i]
//			return (segments[i] == null) ? paramType.isNullable : true
//		}
//	}
	
	Void compileMethod(PlasticClassModel model) {
		if (initFields == null)
			return
		
		sig  := initFields.map |f, i->Str| {
			defVal := optionals[i] ? " := null" : Str.defVal
			return "${f.type.signature} ctx${i}${defVal}"
		}.join(", ")

		body := initFields.map |f, i->Str| { "this.${f.name} = ctx${i}" }.join("\n")
		init := model.addMethod(Void#, InitRender#.name.decapitalize, sig, body)
		init.facets.add(PlasticFacetModel(InitRender#))		
	}
}
