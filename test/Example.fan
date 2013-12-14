using afIoc
using afEfanXtra
using afPillow



// ---- The only class you need! ----

const mixin Example : Page {
  abstract Int age

  Void initRender(Int age) {
    this.age = age
  }
}



// ---- Standard BedSheet Support Classes ----

class Main {
    Int main() {
        afBedSheet::Main().main([AppModule#.qname, "8069"])
    }
}

// SubModule only needed when launching from a script
@SubModule { modules=[EfanXtraModule#, PillowModule#] }
class AppModule {

   @Contribute { serviceType=EfanTemplateDirectories# }
   static Void contributeEfanDirs(OrderedConfig config) {

      // look for Example.efan in the same dir as this file
      config.add(`./`)
   }
}