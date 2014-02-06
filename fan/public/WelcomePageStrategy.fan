
** Defines a strategy for handling the interaction between welcome page and directory URIs. The redirect options are
** useful for diverting legacy traffic to your new pages.
** 
** To change the strategy set the application default in your 'AppModule'. Example:
** 
** pre> 
** @Contribute { serviceType=ApplicationDefaults# }
** static Void contributeApplicationDefaults(MappedConfig config) {
**     config[PillowConfigIds.welcomePageStrategy]	= WelcomePageStrategy.off
** }
** <pre
enum class WelcomePageStrategy {

	** Welcome pages are accessed via their normal URIs and directory URIs return 404s.
	** 
	**   /app/index  --> 200 OK
	**   /app/       --> 404 Not Found
	off,
	
	** Welcome pages are accessed via their normal URIs and directory URIs are redirected to the welcome page.
	** 
	**   /app/index  --> 200 OK
	**   /app/       --> 302 Redirect
	offWithRedirects,
	
	** Welcome pages are accessed via directory URIs and welcome page URIs return 404s.
	** 
	**   /app/index  --> 404 Not found
	**   /app/       --> 200 OK
	on,
	
	** Welcome pages are accessed via directory URIs and welcome page URIs are redirected to the directory URI.
	** 
	**   /app/index  --> 302 Redirect to '/'
	**   /app/       --> 200 OK
	onWithRedirects;
	
	** Returns 'true' is the 'WelcomePageStrategy' is 'on'.
	Bool isOn() {
		this == on || this == onWithRedirects
	}
}
