using afEfanXtra

** The original Impl is 'internal' so we create out own.
internal const class TemplateDirectoriesImpl : TemplateDirectories {
	
	override const File[] templateDirs
	
	new make(File[] templateDirs) {
		templateDirs.each {  
			if (!it.isDir) // also called when file does not exist
				throw ArgErr("Template Dir `${it.normalize}` is not a directory!")
		}
		this.templateDirs = templateDirs.toImmutable
	}
}
