using build

class Build : BuildPod {

	new make() {
		podName = "afPillow"
		summary = "Something for your web app to get its teeth into!"
		version = Version("1.0.14")

		meta = [	
			"proj.name"		: "Pillow",
			"afIoc.module"	: "afPillow::PillowModule",			
			"tags"			: "templating, web",
			"repo.private"	: "false"
		]

		index = [	
			"afIoc.module"	: "afPillow::PillowModule"
		]

		depends = [	
			"sys 1.0",
			"concurrent 1.0",
			"web 1.0",
		
			// ---- core ------------------------
			"afBeanUtils 1.0.0+",
			"afConcurrent 1.0.6+",
			"afIoc 1.6.4+",
			"afIocConfig 1.0.8+",
			"afIocEnv 1.0.6+",

			// ---- web ------------------------
			"afBedSheet 1.3.10+",
			"afEfanXtra 1.1.6+",
			"afPlastic 1.0.14+",

			// ---- test -----------------------
			"afBounce 1.0.8+",
			"afButter 1.0.0+"
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

