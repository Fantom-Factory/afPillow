using build

class Build : BuildPod {

	new make() {
		podName = "afPillow"
		summary = "Something for your web app to get its teeth into!"
		version = Version("0.0.8")

		meta	= [	
			"org.name"		: "Alien-Factory",
			"org.uri"		: "http://www.alienfactory.co.uk/",
			"proj.name"		: "Pillow",
			"proj.uri"		: "http://www.fantomfactory.org/pods/afPillow",
			"vcs.uri"		: "https://bitbucket.org/AlienFactory/afpillow",
			"license.name"	: "BSD 2-Clause License",	
			"repo.private"	: "false",
			
			"afIoc.module"	: "afPillow::PillowModule"
		]

		index	= [	
			"afIoc.module"	: "afPillow::PillowModule"
		]

		depends = [	
			"sys 1.0",
			
			"afIoc 1.5.2+", 
			"afIocConfig 1.0.2+", 
			"afBedSheet 1.3.0+", 
			"afEfanXtra 1.0.8+", 
			"afPlastic 1.0.10+",

			"afButter 0+",
			"afBounce 0+"
		]

		srcDirs = [`test/unit-tests/`, `test/app-tests/`, `test/app/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/utils/`]
		resDirs = [`doc/`, `test/app/`]

		docApi = true
		docSrc = true
	}
	
	@Target { help = "Compile to pod file and associated natives" }
	override Void compile() {
		// exclude test code when building the pod
		srcDirs = srcDirs.exclude { it.toStr.startsWith("test/") }
		resDirs = resDirs.exclude { it.toStr.startsWith("res/test/") }
		
		super.compile
		
		// copy src to %FAN_HOME% for F4 debugging
		log.indent
		destDir := Env.cur.homeDir.plus(`src/${podName}/`)
		destDir.delete
		destDir.create		
		`fan/`.toFile.copyInto(destDir)		
		log.info("Copied `fan/` to ${destDir.normalize}")
		log.unindent
	}
}

