using afIoc
using afPlastic
using afEfanXtra

internal const class PageCompiler {
	
	@Inject	private const Pages 			pages
	@Inject	private const ComponentMeta		componentMeta
	
	new make(|This|in) { in(this) }
	
	|Type, PlasticClassModel| callback() {
		|Type pageType, PlasticClassModel model| {			
			fields := pageType.fields.findAll { it.hasFacet(PageContext#) || it.name == PageContext#.name.decapitalize }
			if (fields.isEmpty)
				return
			fields.first.type.signature
			sig  := fields.map |f, i->Str| { "${f.type.signature} ctx${i}" }.join(", ")
			body := fields.map |f, i->Str| { "this.${f.name} = ctx${i}" }.join("\n")
			model.addMethod(Void#, InitRender#.name.decapitalize, sig, body)
		}
	}

}
