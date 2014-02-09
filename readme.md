# Pillow

`Pillow` is a [Fantom](http://fantom.org/) web framework that maps HTTP request URIs to Pillow Pages, letting them react to RESTful events.

`Pillow`...
 - Is a [BedSheet](http://www.fantomfactory.org/pods/afBedSheet) framework
 - Extends [efanXtra](http://www.fantomfactory.org/pods/afEfanXtra) components
 - Plays great with [Slim](http://www.fantomfactory.org/pods/afSlim)
 - Runs on [IoC](http://www.fantomfactory.org/pods/afIoc)

`Pillow` - Something for your web app to get its teeth into!


## Install

Install `Pillow` with the [Fantom Respository Manager](http://fantom.org/doc/docFanr/Tool.html#install):

    C:\> fanr install -r http://repo.status302.com/fanr/ afPillow

To use in a [Fantom](http://fantom.org/) project, add a dependency to its `build.fan`:

    depends = ["sys 1.0", ..., "afPillow 1+"]
  
  
## Quick Start

Example.efan:

    Hello Mum! I'm <%= age %> years old!


Example.fan:

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

Run the **Example.fan** script from the command line:

    C:\> fan Example.fan

    Efan Library: 'app' has 1 page(s):
      Example : /example

    C:\> curl http://localhost:8069/example/42
    
    Hello Mum! I'm 42 years old!


## Documentation

Full API & fandocs are available on the [status302 repository](http://repo.status302.com/doc/afPillow/#overview).
