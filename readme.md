## Overview 

`Pillow` is a web framework that maps HTTP request URIs to Pillow Pages, letting them react to RESTful events.

`Pillow`...

- Is a [BedSheet](http://www.fantomfactory.org/pods/afBedSheet) framework
- Extends [efanXtra](http://www.fantomfactory.org/pods/afEfanXtra) components
- Plays great with [Slim](http://www.fantomfactory.org/pods/afSlim)
- Runs on [IoC](http://www.fantomfactory.org/pods/afIoc)

`Pillow` - Something for your web app to get its teeth into!

## Install 

Install `Pillow` with the Fantom Repository Manager ( [fanr](http://fantom.org/doc/docFanr/Tool.html#install) ):

    C:\> fanr install -r http://repo.status302.com/fanr/ afPillow

To use in a [Fantom](http://fantom.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afPillow 1.0+"]

## Documentation 

Full API & fandocs are available on the [Status302 repository](http://repo.status302.com/doc/afPillow/#overview).

## Quick Start 

Example.efan:

```
Hello Mum! I'm <%= age %> years old!
```

Example.fan:

```
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
```

Run the **Example.fan** script from the command line:

```
C:\> fan Example.fan

Efan Library: 'app' has 1 page(s):
  Example : /example
```

Then point your browser at `http://localhost:8069/example/42`

    Hello Mum! I'm 42 years old!

## Usage 

To create a web page, define an `EfanComponent` that is annotated with the [Page](http://repo.status302.com/doc/afPillow/Page.html) facet. Example:

```
using afPillow::Page
using afEfanXtra::EfanComponent

@Page
const mixin Admin : EfanComponent {
    ...
}
```

[Pages](http://repo.status302.com/doc/afPillow/Page.html) are [efanXtra](http://www.fantomfactory.org/pods/afEfanXtra) components and behave in exactly the same way.

`Pillow` will automatically route URLs with your page name, to your page. Camel casing class names results in a `/` delimiter. Examples:

    `/admin`        --> Admin.fan
    `/admin/secret` --> AdminSecret.fan

Or you can use the [@Page](http://repo.status302.com/doc/afPillow/Page.html) facet to define an explicit URL.

## Welcome Pages 

`Pillow` supports the routing of welcome pages, also known as directory pages, through the [WelcomePageStrategy](http://repo.status302.com/doc/afPillow/WelcomePageStrategy.html).

When switched on, whenever a request is made for a directory URI (one that ends with a /slash/) then `Pillow` will render the directory's [welcome page](http://repo.status302.com/doc/afPillow/PillowConfigIds#welcomePageName.html), which defaults to a page named `Index`. Examples:

    `/`        --> Index.fan
    `/admin/`  --> AdminIndex.fan

More can be read about directory URLs in the article: [Should Your URLs Point to the Directory or the Index Page?](http://www.thesitewizard.com/sitepromotion/directory-name-or-index-url.shtml)

The [welcome page strategy](http://repo.status302.com/doc/afPillow/WelcomePageStrategy.html) also supports redirects, where requests for legacy pages (like `/index.html`) are redirected to the directory URI. Redirects are preferred over serving up the same page for multiple URIs to avoid [duplicate content](http://moz.com/learn/seo/duplicate-content).

## Page Contexts 

As seen in the [Quick Start](http://repo.status302.com/doc/afPillow/#quickStart.html) example, parts of the request path are automatically mapped to `@PageContext` fields. In our exmaple, the `42` in `http://localhost:8069/example/42` is mapped to the `age` page context field.

Declaring page context fields is actually shorthard for assigning fields manually from the `@InitRender` method. The [Quick Start](http://repo.status302.com/doc/afPillow/#quickStart.html) example could be re-written long hand as:

```
@Page
const mixin Example : EfanComponent {
    abstract Int age

    @InitRender
    Void initRender(Int age) {
        this.age = age
    }
}
```

Note that a Pillow Page may choose to have *either* an `@InitRender` method or `@PageContext` fields, not both. Also note that page context objects need to be immutable ('const' classes).

## Page Meta 

The [PageMeta](http://repo.status302.com/doc/afPillow/PageMeta.html) class holds information about the Pillow Page currently being rendered. Obviously, using `PageMeta` in a page class, returns information about itself! Which is quite handy.

Arguably the most useful method is `pageUri()` which returns a URI that can be used, by a client, to render the page complete with the current page context. You can create new PageMeta instances with different page context by using the `withContext()` method. Using our example again:

```
@Page
const mixin Example : EfanComponent {
    @Inject abstract PageMeta pageMeta

    @PageContext
    abstract Int age

    Str renderLinkToSelf() {
        return "<a href='${pageMeta.pageUri}'>Link to ${age}</a>"
    }

    Str renderLinkTo69() {
        page69 := pageMeta.withContext([69]).pageUri
        return "<a href='${page69}'>Link to 69</a>"
    }
}
```

`PageMeta` instances are [BedSheet](http://www.fantomfactory.org/pods/afBedSheet) response objects and may be returned from request handlers. The handler then renders the Pillow page. Use the `pageMeta()` method in the [Pages](http://repo.status302.com/doc/afPillow/Pages.html) service to create PageMeta objects for arbituary pages.

## Page Events 

Page events allow pages to respond to RESTful actions by mapping URIs to page event methods. Page event methods are called in the context of the page they are defined. Denote page events with the `@PageEvent` facet.

Lets change our example so that the page context is a `Str` and introduce an event called `loves`:

```
@Page
const mixin Example : EfanComponent {
    @Inject abstract PageMeta pageMeta

    @PageContext
    abstract Str name

    @PageEvent
    Obj loves(Str obj) {
        echo("${name} loves ${obj}!")
        return pageMeta
    }
}
```

We can call the event using the URI `http://localhost:8069/example/Emma/loves/sausage`.

`/example/Emma` would render the page, but should a link to `/example/Emma/loves/sausage` be clicked, then the page event `loves` is called.

Page events may return any standard [BedSheet](http://www.fantomfactory.org/pods/afBedSheet) response object. Above we return the `pageMeta` to re-render the page with a page context of `Emma`.

Use the `PageMeta.eventUri(name, context)` to create full event URIs that can be used by clients.

## Content Type 

Page template files should use a double extension in their name, for example,

    IndexPage.xhtml.slim

The outer extension denotes the type of templating to use, [Slim](http://www.fantomfactory.org/pods/afSlim) in our example. The innter extension is used to find the [Content-Type](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.17) that is sent in the HTTP response header. In our example, the `Content-Type` would be set to `application/xhtml+xml`.

If a double extension is not used, or not know, then the default content type, as defined by the config value, is used.

Or you can use the [@Page](http://repo.status302.com/doc/afPillow/Page.html) facet to explicitly set the content type.

