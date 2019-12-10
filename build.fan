using build

class Build : BuildPod {

	new make() {
		podName = "afPillow"
		summary = "Something for your web app to get its teeth into!"
		version = Version("1.2.0")

		meta = [	
			"pod.dis"		: "Pillow",
			"afIoc.module"	: "afPillow::PillowModule",
			"repo.tags"		: "web",
			"repo.public"	: "true"
		]

		depends = [	
			"sys        1.0.68 - 1.0",
			"concurrent 1.0.68 - 1.0",
			"web        1.0.68 - 1.0",
		
			// ---- Core ------------------------
			"afBeanUtils  1.0.10 - 1.0",
			"afConcurrent 1.0.24 - 1.0",
			"afPlastic    1.1.6  - 1.1",
			"afIoc        3.0.6  - 3.0",
			"afIocConfig  1.1.0  - 1.1",
			"afIocEnv     1.1.0  - 1.1",

			// ---- Web ------------------------
			"afBedSheet   1.5.12 - 1.5",
			"afEfanXtra   2.0.0  - 2.0",
			"afEfan       2.0.0  - 2.0",

//			"afEfanXtra   1.2.0  - 1.2",
			
			// ---- Test -----------------------
			"afBounce     1.1.8  - 1.1",
			"afButter     1.2.8  - 1.2"
		]

		srcDirs = [`fan/`, `fan/internal/`, `fan/internal/utils/`, `fan/public/`, `test/app/`, `test/app-tests/`]
		resDirs = [`doc/`,`test/app/`]
		
		meta["afBuild.testPods"]	= "afBounce afButter"
	}
}

