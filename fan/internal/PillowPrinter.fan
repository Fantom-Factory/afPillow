using afIoc::Inject
using afEfanXtra::EfanXtra
using afEfanXtra::EfanXtraPrinter

internal const class PillowPrinter {
	private const static Log log := Utils.getLog(PillowPrinter#)

	@Inject private	const EfanXtra 			efanExtra
	@Inject private	const EfanXtraPrinter	exPrinter
	@Inject private	const Pages				pages

	new make(|This| in) { in(this) }
	
	Void logLibraries() {
		
		details := "\n"
		efanExtra.libraries.each |libName| {
			// log the components, filtering out pages
			details += pageDetailsToStr(libName)
			details += exPrinter.libraryDetailsToStr(libName) |Type component->Bool| { !component.hasFacet(Page#) }
		}
		
		log.info(details)
	}

	Str pageDetailsToStr(Str libName) {
		buf		 := StrBuf()
		pageTypes := efanExtra.componentTypes(libName).findAll { it.hasFacet(Page#) }
		
		if (pageTypes.isEmpty)
			return ""

		maxName	 := (Int) pageTypes.reduce(0) |size, component| { ((Int) size).max(component.name.toDisplayName.size) }
		buf.add("\nefan Library: '${libName}' has ${pageTypes.size} pages:\n\n")

		pageTypes.each |pageType| {
			pageMeta 	:= pages.pageMeta(pageType, null)
			serverGlob	:= pageMeta.serverGlob
			line := pageType.name.toDisplayName.padl(maxName) + " : " + serverGlob
			buf.add("  ${line}\n")
			
			pageType.methods.findAll { it.hasFacet(PageEvent#) }.each |eventMethod| {
				eventGlob := serverGlob.plusSlash + pageMeta.eventGlob(eventMethod)
				line = ("-(" + eventMethod.name + ")").padl(maxName) + " : " + eventGlob
				buf.add("  ${line}\n")
			}
		}
		
		return buf.toStr
	}
}
