using build

class Build : BuildPod {

	new make() {
		podName = "afPillow"
		summary = "Something for your web app to get its teeth into!"
		version = Version("1.0.23")

		meta = [	
			"proj.name"		: "Pillow",
			"afIoc.module"	: "afPillow::PillowModule",
			"tags"			: "web",
			"repo.private"	: "true"
		]

		index = [	
			"afIoc.module"	: "afPillow::PillowModule"
		]

		depends = [	
			"sys 1.0",
			"concurrent 1.0",
			"web 1.0",
		
			// ---- Core ------------------------
			"afBeanUtils  1.0.4  - 1.0",
			"afConcurrent 1.0.6  - 1.0",
			"afPlastic    1.0.16 - 1.0",
			"afIoc        2.0.0  - 2.0",
			"afIocConfig  1.0.16 - 1.0",
			"afIocEnv     1.0.14 - 1.0",

			// ---- Web ------------------------
			"afBedSheet   1.4.0  - 1.4",
			"afEfanXtra   1.1.18 - 1.1",

			// ---- Test -----------------------
			"afBounce     1.0.18 - 1.0",
			"afButter     1.0.4  - 1.0"
		]

		srcDirs = [`test/app-tests/`, `test/app/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/utils/`]
		resDirs = [`test/app/`]
	}
	
	@Target
	override Void compile() {
		// remove test pods from final build
		testPods := "afBounce afButter".split
		depends = depends.exclude { testPods.contains(it.split.first) }
		srcDirs = srcDirs.exclude { it.toStr.startsWith("test/") }
		resDirs = resDirs.exclude { it.toStr.startsWith("test/") }
		super.compile
	}
}

