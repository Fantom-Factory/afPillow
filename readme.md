# Pillow

`afPillow` is a [Fantom](http://fantom.org/) library for integrating [efanXtra](http://repo.status302.com/doc/afBedSheet) components with the [afBedSheet](http://repo.status302.com/doc/afBedSheet) web framework.

`afPillow` automatically routes web requests to pages and returns the rendered response.



## Quick Start

Quick Start [#quickStart]
*************************
Awesome.fan:

    using afPillow::Page

    const mixin Awesome : Page { }


Awesome.efan:

    Look ma, I'm Awesome!


Start your web app and instantly see the result:

    $ curl localhost:8080/awesome
    Look ma, I'm Awesome!



## Documentation

Full API & fandocs are available on the [status302 repository](http://repo.status302.com/doc/afPillow/#overview).



## Install

Download from [status302](http://repo.status302.com/browse/afPillow).

Or install via fanr:

    $ fanr install -r http://repo.status302.com/fanr/ afPillow

To use in a project, add a dependency in your `build.fan`:

    depends = ["sys 1.0", ..., "afPillow 0+"]
