using afIoc::Inject
using afEfanExtra::EfanExtra
using afEfanExtra::EfanExtraPrinter

internal const class BedSheetEfanExtraPrinter {
	private const static Log log := Utils.getLog(BedSheetEfanExtraPrinter#)

	@Inject private	const EfanExtra 		efanExtra
	@Inject private	const EfanExtraPrinter	eePrinter
	@Inject private	const Pages				pages

	new make(|This| in) { in(this) }
	
	Void logLibraries() {
		
		details := "\n"
		efanExtra.libraries.each |libName| {
			// log the components, filtering out pages
			details += pageDetailsToStr(libName)
			details += eePrinter.libraryDetailsToStr(libName) |Type component->Bool| { !component.fits(Page#) }
		}
		
		log.info(details)		
	}

	Str pageDetailsToStr(Str libName) {
		buf		 := StrBuf()
		comTypes := efanExtra.componentTypes(libName).findAll { it.fits(Page#) }

		maxName	 := (Int) comTypes.reduce(0) |size, component| { ((Int) size).max(component.name.toDisplayName.size) }
		buf.add("\nEfan Library: '${libName}' has ${comTypes.size} pages:\n")

		comTypes.each |comType| {
			try {
				// chill, there should be a better to get hold of the clientUri without instantiating the page
				line := comType.name.toDisplayName.padl(maxName) + " : " + pages[comType].clientUri.toStr 
				buf.add("  ${line}\n")
			} catch (Err e) { /* for abstract pages... grr! */ }
		}
		return buf.toStr
	}
	
	
}
