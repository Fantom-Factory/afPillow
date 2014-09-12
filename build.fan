using build

class Build : BuildPod {

	new make() {
		podName = "afPillow"
		summary = "Something for your web app to get its teeth into!"
		version = Version("1.0.20")

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
			"afBeanUtils 1.0.2+",
			"afConcurrent 1.0.6+",
			"afIoc 2.0.0+",
			"afIocConfig 1.0.16+",
			"afIocEnv 1.0.14+",

			// ---- web ------------------------
			"afBedSheet 1.3.16+",
			"afEfanXtra 1.1.14+",
			"afPlastic 1.0.16+",

			// ---- test -----------------------
			"afBounce 1.0.14+",
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

