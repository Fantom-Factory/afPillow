using build

class Build : BuildPod {

	new make() {
		podName = "afPillow"
		summary = "Something for your web app to get its teeth into!"
		version = Version("1.1.0")

		meta = [	
			"proj.name"		: "Pillow",
			"afIoc.module"	: "afPillow::PillowModule",
			"repo.tags"		: "web",
			"repo.public"	: "false"
		]

		index = [	
			"afIoc.module"	: "afPillow::PillowModule"
		]

		depends = [	
			"sys 1.0",
			"concurrent 1.0",
			"web 1.0",
		
			// ---- Core ------------------------
			"afBeanUtils  1.0.6  - 1.0",
			"afConcurrent 1.0.12 - 1.0",
			"afPlastic    1.0.20 - 1.0",
			"afIoc        3.0.0  - 3.0",
			"afIocConfig  1.1.0  - 1.1",
			"afIocEnv     1.1.0  - 1.1",

			// ---- Web ------------------------
			"afBedSheet   1.5.0  - 1.5",
			"afEfanXtra   1.2.0  - 1.2",
//			"afEfan       1.4.3  - 1.4",

			// ---- Test -----------------------
			"afBounce     1.1.0  - 1.1",
			"afButter     1.1.10 - 1.1"
		]

		srcDirs = [`test/app-tests/`, `test/app/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/utils/`]
		resDirs = [`doc/`,`test/app/`]
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

