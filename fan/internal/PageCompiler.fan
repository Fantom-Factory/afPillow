using afIoc
using afPlastic
using afEfanXtra

internal const class PageCompiler {
	
	@Inject	private const Pages pages
	
	new make(|This|in) { in(this) }
	
	|Type, PlasticClassModel| callback() {
		|Type comType, PlasticClassModel model| {
			if (pages.pageTypes.contains(comType))
				pages[comType].initRender.compileMethod(model)
		}
	}

}
