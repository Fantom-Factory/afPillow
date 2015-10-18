using afIoc
using afEfanXtra
using web::WebOutStream

internal const class PillowPrinter {
	@Inject private	const Log				log
	@Inject private	const Pages				pages
	@Inject private	const EfanLibraries		efanLibs
	@Inject private	const EfanXtraPrinter	exPrinter
	@Inject private	const ComponentFinder	comFinder
	@Inject private	const PageFinder		pageFinder

	new make(|This| in) { in(this) }
	
	Void logLibraries() {
		details := "\n"
		efanLibs.names.each |libName| {
			// log the components, filtering out pages
			details += pageDetailsToStr(libName)
			details += exPrinter.libraryDetailsToStr(libName) { true }
		}
		
		log.info(details)
	}

	Str pageDetailsToStr(Str libName) {
		buf			:= StrBuf()
		libPod		:= efanLibs.pod(libName)
		pageTypes	:= pageFinder.findPageTypes(libPod)
		
		if (pageTypes.isEmpty)
			return ""

		maxName	 := (Int) pageTypes.reduce(0) |size, component| { ((Int) size).max(component.name.toDisplayName.size) }
		buf.add("\nefan Library '${libName}' has ${pageTypes.size} pages:\n\n")

		pageTypes.each |pageType| {
			pageMeta 	:= pages.pageMeta(pageType, null)
			pageGlob	:= pageMeta.pageGlob
			line := pageType.name.toDisplayName.padl(maxName) + " : " + pageGlob
			buf.add("  ${line}\n")
			
			pageType.methods.findAll { it.hasFacet(PageEvent#) }.each |eventMethod| {
				eventGlob := pageMeta.eventGlob(eventMethod)
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
			if (pageMeta.routesDisabled)
				return

			pageGlob	:= pageMeta.pageGlob
			
			map[pageType.name.toDisplayName] = pageMeta.httpMethod.upper.justl(4) + " " + pageGlob
			
			pageType.methods.findAll { it.hasFacet(PageEvent#) }.each |eventMethod| {
				// TODO: research why event in abstract class only appears once!?
				pageEvent := (PageEvent) Method#.method("facet").callOn(eventMethod, [PageEvent#])
				eventGlob := pageMeta.eventGlob(eventMethod)
				map["  \u2191${eventMethod.name}"] = pageEvent.httpMethod.justl(4) + " " + eventGlob 			
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
