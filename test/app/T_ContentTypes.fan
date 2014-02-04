using afEfanXtra

@NoDoc
@PageContentType { contentType=MimeType("wot/ever") }
@Page { uri=`/contentTypeExplicit` }
const mixin T_ContentTypeExplicit : EfanComponent { }

@NoDoc
@Page { uri=`/contentTypeXhtml` }
const mixin T_ContentTypeXhtml : EfanComponent { }

@NoDoc
@Page { uri=`/contentTypeHtml` }
const mixin T_ContentTypeHtml : EfanComponent { }

@NoDoc
@Page { uri=`/contentTypeDefault` }
const mixin T_ContentTypeDefault : EfanComponent { }

