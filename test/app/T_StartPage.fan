using afEfanXtra

@NoDoc
@Page { url=`/contentTypeExplicit`; contentType=MimeType("wot/ever") }
const mixin T_ContentTypeExplicit : EfanComponent { }

@NoDoc
@Page { url=`/contentTypeXhtml` }
const mixin T_ContentTypeXhtml : EfanComponent { }

@NoDoc
@Page { url=`/contentTypeHtml` }
const mixin T_ContentTypeHtml : EfanComponent { }

@NoDoc
@Page { url=`/contentTypeDefault` }
const mixin T_ContentTypeDefault : EfanComponent { }

