# BedSheetEfanExtra

`afBedSheetEfanExtra` is a [Fantom](http://fantom.org/) library for integrating [efanXtra](http://repo.status302.com/doc/afBedSheet) components with the [afBedSheet](http://repo.status302.com/doc/afBedSheet) web framework.

`afBedSheetEfanExtra` automatically routes web requests to pages and returns the rendered response.



## Quick Start

Quick Start [#quickStart]
*************************
Awesome.fan:

    using afBedSheetEfanExtra::Page

    const mixin Awesome : Page { }


Awesome.efan:

    Look ma, I'm Awesome!


Start your web app and instantly see the result:

    $ curl localhost:8080/awesome
    Look ma, I'm Awesome!



## Documentation

Full API & fandocs are available on the [status302 repository](http://repo.status302.com/doc/afBedSheetEfanExtra/#overview).



## Install

Download from [status302](http://repo.status302.com/browse/afBedSheetEfanExtra).

Or install via fanr:

    $ fanr install -r http://repo.status302.com/fanr/ afBedSheetEfanExtra

To use in a project, add a dependency in your `build.fan`:

    depends = ["sys 1.0", ..., "afBedSheetEfanExtra 0+"]
