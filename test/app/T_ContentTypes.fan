using afEfanXtra

@NoDoc
@PageContentType { contentType=MimeType("wot/ever") }
@PageUri { uri=`/contentTypeExplicit` }
@Page
const mixin T_ContentTypeExplicit : EfanComponent { }

@NoDoc
@PageUri { uri=`/contentTypeXhtml` }
@Page
const mixin T_ContentTypeXhtml : EfanComponent { }

@NoDoc
@PageUri { uri=`/contentTypeHtml` }
@Page
const mixin T_ContentTypeHtml : EfanComponent { }

@NoDoc
@PageUri { uri=`/contentTypeDefault` }
@Page
const mixin T_ContentTypeDefault : EfanComponent { }

