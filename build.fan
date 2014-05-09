using build

class Build : BuildPod {

	new make() {
		podName = "afPillow"
		summary = "Something for your web app to get its teeth into!"
		version = Version("1.0.7")

		meta = [	
			"proj.name"		: "Pillow",
			"afIoc.module"	: "afPillow::PillowModule",			
			"tags"			: "templating, web",
			"repo.private"	: "true"
		]

		index = [	
			"afIoc.module"	: "afPillow::PillowModule"
		]

		depends = [	
			"sys 1.0",
			"concurrent 1.0",
			"web 1.0",
			
			"afIoc 1.6.0+",
			"afIocConfig 1.0.4+",
			"afIocEnv 1.0.4+",

			"afBedSheet 1.3.6+",
			"afEfanXtra 1.1.0+",
			"afPlastic 1.0.10+",

			"afBounce 1.0.0+",
			"afButter 0.0.6+"
		]

		srcDirs = [`test/app-tests/`, `test/app/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/utils/`]
		resDirs = [`test/app/`]

		docApi = true
		docSrc = true
	}
}

