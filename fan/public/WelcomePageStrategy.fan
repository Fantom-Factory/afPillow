
** Defines a strategy for handling the interaction between welcome page and directory URIs. The redirect options are
** useful for diverting legacy traffic to your new pages. 
** Note that to prevent conflicting URIs, only pages with no context and no events are redirected.
** 
** To change the strategy set the application default in your 'AppModule'. Example:
** 
** pre>
** syntax: fantom
** 
** @Contribute { serviceType=ApplicationDefaults# }
** static Void contributeApplicationDefaults(Configuration config) {
**     config[PillowConfigIds.welcomePageStrategy] = WelcomePageStrategy.off
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
	**   /app/       --> 307 Temporary Redirect to '/index'
	offWithRedirects,
	
	** Welcome pages are accessed via directory URIs and welcome page URIs return 404s.
	** 
	**   /app/index  --> 404 Not found
	**   /app/       --> 200 OK
	on,
	
	** Welcome pages are accessed via directory URIs and welcome page URIs are redirected to the directory URI.
	** 
	**   /app/index  --> 307 Temporary Redirect to '/'
	**   /app/       --> 200 OK
	** 
	** This is the default setting.
	onWithRedirects;
	
	** Returns 'true' is the 'WelcomePageStrategy' is 'on'.
	Bool isOn() {
		this == on || this == onWithRedirects
	}
}
