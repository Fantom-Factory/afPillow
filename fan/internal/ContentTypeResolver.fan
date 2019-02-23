using afIoc::Inject
using afIocConfig::Config
using afEfanXtra::TemplateFinders

@NoDoc
const mixin ContentTypeResolver {
	abstract MimeType? contentType(Type pageType)
}

internal const class ContentTypeResolverImpl : ContentTypeResolver {
	
	@Config { id="afPillow.defaultContentType" }
	@Inject private const MimeType defaultMimeType
	
	private const ContentTypeResolver[] resolvers
	
	new make(ContentTypeResolver[] resolvers, |This| in) {
		in(this) 
		this.resolvers = resolvers
	} 
	
	override MimeType? contentType(Type pageType) {
		resolvers.eachWhile { it.contentType(pageType) } ?: defaultMimeType
	}
}

** Look for an explicit content type from the @Page facet
internal const class ResolveContentTypeFromPageFacet : ContentTypeResolver {
	override MimeType? contentType(Type pageType) {
		page := (Page?) Type#.method("facet").callOn(pageType, [Page#])
		return page.contentType		
	}
}

** Look for content type from the extension
internal const class ResolveContentTypeFromTemplateExtension : ContentTypeResolver {
	@Inject private const TemplateFinders templatefinder

	new make(|This| in) { in(this)	} 

	override MimeType? contentType(Type pageType) {
		tsrc	:= templatefinder.getOrFindTemplate(pageType)
		efan 	:= tsrc.location.ext ?: ""
		name 	:= tsrc.location.name[0..<-(efan.size+1)]
		ext		:= name.toUri.ext?.lower
		eType 	:= ext != null ? MimeType.forExt(ext) : null		
		return eType
	}
}
