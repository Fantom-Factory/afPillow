using build::BuildPod

class Build : BuildPod {

	new make() {
		podName = "afBedSheetEfanExtra"
		summary = "A library for integrating efanXtra components with the afBedSheet web framework"
		version = Version([0,0,2])

		meta	= [	"org.name"		: "Alien-Factory",
					"org.uri"		: "http://www.alienfactory.co.uk/",
					"vcs.uri"		: "https://bitbucket.org/Alien-Factory/afbedsheetefanextra",
					"proj.name"		: "BedSheetEfanExtra",
					"license.name"	: "BSD 2-Clause License",	
					"repo.private"	: "false"

					,"afIoc.module"	: "afBedSheetEfanExtra::BedSheetEfanExtraModule"
				]

		index	= [	"afIoc.module"	: "afBedSheetEfanExtra::BedSheetEfanExtraModule"
				]


		depends = ["sys 1.0", "afIoc 1.4+", "afIocConfig 0+", "afBedSheet 1.0+", "afEfanExtra 0+", "afSlim 0+", "afPlastic 1.0.4+"]
		srcDirs = [`test/unit-tests/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/utils/`]
		resDirs = [`doc/`]

		docApi = true
		docSrc = true

		// exclude test code when building the pod
		srcDirs = srcDirs.exclude { it.toStr.startsWith("test/") }
//		resDirs = resDirs.exclude { it.toStr.startsWith("test/") }
	}
}
