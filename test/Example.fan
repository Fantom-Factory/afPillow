using afIoc
using afBedSheet
using afEfanXtra
using afPillow

// ---- The only class you need! ----

@Page
const mixin Example : EfanComponent {

    @PageContext
    abstract Int age
}

// ---- Standard Main Class ----

class Main {
    Int main() {
        afBedSheet::Main().main([AppModule#.qname, "8069"])
    }
}

// ---- Support class, needed when running from a script ----

@SubModule { modules=[EfanXtraModule#, PillowModule#] }
class AppModule {
    @Contribute { serviceType=EfanTemplateDirectories# }
    static Void contributeEfanDirs(OrderedConfig config) {
        // Look for Example.efan in the same dir as this file
        config.add(`./`)
    }
}