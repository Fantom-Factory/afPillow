using build

class Build : BuildPod {

	new make() {
		podName = "afPillow"
		summary = "Something for your web app to get its teeth into!"
		version = Version("1.0.9")

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
		
			// ---- core ------------------------
			"afBeanUtils 0.0.4+",
			"afConcurrent 1.0.4+",
			"afIoc 1.6.2+",
			"afIocConfig 1.0.6+",
			"afIocEnv 1.0.4+",

			// ---- web ------------------------
			"afBedSheet 1.3.6+",
			"afEfanXtra 1.1.4+",
			"afPlastic 1.0.12+",

			// ---- test -----------------------
			"afBounce 1.0.0+",
			"afButter 0.0.6+"
		]

		srcDirs = [`test/app-tests/`, `test/app/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/utils/`]
		resDirs = [`test/app/`]
	}
	
	override Void compile() {
		// remove test pods from final build
		testPods := "afBounce afButter".split
		depends = depends.exclude { testPods.contains(it.split.first) }
		super.compile
	}
}

