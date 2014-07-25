using build

class Build : BuildPod {

	new make() {
		podName = "afPillow"
		summary = "Something for your web app to get its teeth into!"
		version = Version("1.0.17")

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
			"afBeanUtils 1.0.2+",
			"afConcurrent 1.0.6+",
			"afIoc 1.7.2+",
			"afIocConfig 1.0.12.1+",
			"afIocEnv 1.0.10.1+",

			// ---- web ------------------------
			"afBedSheet 1.3.12+",
			"afEfanXtra 1.1.10.1+",
			"afPlastic 1.0.16+",

			// ---- test -----------------------
			"afBounce 1.0.10+",
			"afButter 1.0.2+"
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

