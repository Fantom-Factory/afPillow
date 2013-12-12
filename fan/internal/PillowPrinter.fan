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
			details += exPrinter.libraryDetailsToStr(libName) |Type component->Bool| { !component.fits(Page#) }
		}
		
		log.info(details)		
	}

	Str pageDetailsToStr(Str libName) {
		buf		 := StrBuf()
		comTypes := efanExtra.componentTypes(libName).findAll { it.fits(Page#) }

		maxName	 := (Int) comTypes.reduce(0) |size, component| { ((Int) size).max(component.name.toDisplayName.size) }
		buf.add("\nEfan Library: '${libName}' has ${comTypes.size} pages:\n\n")

		comTypes.each |comType| {
			line := comType.name.toDisplayName.padl(maxName) + " : " + pages.clientUri(comType).toStr 
			buf.add("  ${line}\n")
		}
		return buf.toStr
	}
	
	
}
