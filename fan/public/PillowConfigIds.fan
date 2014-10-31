
** [IocConfig]`http://repo.status302.com/doc/afIocConfig/` values as provided by 'Pillow'.
** To change their value, override them in your 'AppModule'. Example:
** 
** pre>
** using afIoc
** using afIocConfig
** using afPillow
**  
** class AppModule {
** 
**     @Contribute { serviceType=ApplicationDefaults# } 
**     static Void configureAppDefaults(Configuration config) {
**         config[PillowConfigIds.welcomePage] = "home"
**     }
** }
** <pre 
const mixin PillowConfigIds {
 
	** The component name (Str) of directory welcome pages.
	** 
	** Defaults to '"index"'.
	static const Str welcomePageName		:=	"afPillow.welcomePageName"

	** The default 'Content-Type' to serve pages up as, if it can not be determined.
	** 
	** Defaults to 'MimeType("text/plain")'
	static const Str defaultContentType		:=	"afPillow.defaultContentType"

	** Set the welcome page strategy which defines the interaction between welcome page URIs and directory URIs.
	** 
	** Defaults to 'WelcomePageStrategy.onWithRedirects'
	static const Str welcomePageStrategy	:=	"afPillow.welcomePageStrategy"

	** The 'cache-control' HTTP header value to set in rendered Pillow pages. 
	** The header is set before the page is rendered, making it easy to override / re-set in any '@InitRender' method.
	** 
	** The 'cache-control' HTTP header is only set in production mode. 
	** 
	** Defaults to '"max-age=0, no-cache"'
	static const Str cacheControl			:=	"afPillow.cacheControl"
}
