using afIoc::Inject
using afIocConfig::Config
using afEfanXtra::EfanTemplateFinders

@NoDoc
const mixin ContentTypeResolver {
	abstract MimeType contentType(Type pageType)
}

internal const class ContentTypeResolverImpl : ContentTypeResolver {

	@Inject private const EfanTemplateFinders templatefinder
	
	@Config { id="afPillow.defaultContentType" }
	@Inject private const MimeType defaultMimeType
	
	new make(|This| in) { in(this) } 
	
	override MimeType contentType(Type pageType) {

		// look for an explicit content type from the @PageContentType facet
		pageCt := (PageContentType?) Type#.method("facet").callOn(pageType, [PageContentType#, false])
		if (pageCt != null)
			return pageCt.contentType
		
		// look for content type from the extension
		file	:= templatefinder.findTemplate(pageType)
		efan 	:= file.ext ?: ""
		name 	:= file.name[0..<-(efan.size+1)]
		ext		:= name.toUri.ext?.lower
		eType 	:= ext != null ? MimeType.forExt(ext) : null

		if (eType != null)
			return eType

		// hmmm... what if...!?
		if (ext == "xhtml")
			return  MimeType("application/xhtml+xml; charset=utf-8")

		// no idea - return the default
		return defaultMimeType
	}
	
}
