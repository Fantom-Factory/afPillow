using afIoc::Inject
using afIoc::Registry
using afEfanXtra::EfanXtra
using afEfanXtra::EfanXtraPrinter
using web::WebOutStream

internal const class PillowPrinter {
	@Inject private	const Log				log
	@Inject private	const Pages				pages
	@Inject private	const EfanXtra 			efanExtra
	@Inject private	const EfanXtraPrinter	exPrinter

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
				line = ("(${eventMethod.name})^").padl(maxName) + " : " + eventGlob
				buf.add("  ${line}\n")
			}
		}
		
		return buf.toStr
	}

	Void printPillowPages(WebOutStream out) {
		title(out, "Pillow Pages")

		map := [:] { ordered=true }
		pages.pageTypes.rw.sort.each |pageType| {
			pageMeta 	:= pages.pageMeta(pageType, null)
			serverGlob	:= pageMeta.serverGlob
			
			map[pageType.name.toDisplayName] = pageMeta.httpMethod + " - " + serverGlob
			
			pageType.methods.findAll { it.hasFacet(PageEvent#) }.each |eventMethod| {
				eventMeth := (PageEvent) Type#.method("facet").callOn(eventMethod, [PageEvent#])
				eventGlob := serverGlob.plusSlash + pageMeta.eventGlob(eventMethod)
				map["(${eventMethod.name})^"] = eventMeth.httpMethod + " - " + eventGlob 			
			}
		}

		prettyPrintMap(out, map, false)
	}
	
	private Void title(WebOutStream out, Str title) {
		out.h2("id=\"${title.fromDisplayName}\"").w(title).h2End
	}
	
	private Void prettyPrintMap(WebOutStream out, Str:Obj? map, Bool sort, Str? cssClass := null) {
		if (sort) {
			newMap := Str:Obj?[:] { ordered = true } 
			map.keys.sort.each |k| { newMap[k] = map[k] }
			map = newMap
		}
		out.table(cssClass == null ? null : "class=\"${cssClass}\"")
		map.each |v, k| { w(out, k, v) } 
		out.tableEnd
	}

	private Void w(WebOutStream out, Str key, Obj? val) {
		out.tr.td.writeXml(key).tdEnd.td.writeXml(val?.toStr ?: "null").tdEnd.trEnd
	}

}
