# Pillow

`Pillow` is a [Fantom](http://fantom.org/) library for integrating [efanXtra](http://repo.status302.com/doc/afBedSheet) components with the [afBedSheet](http://repo.status302.com/doc/afBedSheet) web framework. 
It automatically routes web requests to pages and returns the rendered response.


## Install

Install `Pillow` with the [Fantom Respository Manager](http://fantom.org/doc/docFanr/Tool.html#install):

    C:\> fanr install -r http://repo.status302.com/fanr/ afPillow

Or download the pod from [Status302](http://repo.status302.com/browse/afPillow) and copy it to `%FAN_HOME%/lib/fan/`.

To use in a [Fantom](http://fantom.org/) project, add a dependency to its `build.fan`:

    depends = ["sys 1.0", ..., "afPillow 0+"]
  
  
## Quick Start

Example.efan:

    Hello Mum! I'm <%= age %> years old!


Example.fan:

    using afIoc
    using afEfanXtra
    using afPillow
    
    
    
    // ---- The only class you need! ----
    
    const mixin Example : Page {
      abstract Int age
    
      @InitRender
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
    
    // SubModule only needed when running from a script
    @SubModule { modules=[EfanXtraModule#, PillowModule#] }
    class AppModule {
    
       // Contribution needed when running from a script
       @Contribute { serviceType=EfanTemplateDirectories# }
       static Void contributeEfanDirs(OrderedConfig config) {
    
          // Look for Example.efan in the same dir as this file
          config.add(`./`)
       }
    }

Run the **Example.fan** script from the command line:

    C:\> fan Example.fan

    Efan Library: 'app' has 1 page(s):
      Example : /example

    C:\> curl http://localhost:8069/example/42
    
    Hello Mum! I'm 42 years old!


## Documentation

Full API & fandocs are available on the [status302 repository](http://repo.status302.com/doc/afPillow/#overview).
