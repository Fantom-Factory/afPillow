
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
**   @Contribute { serviceType=ApplicationDefaults# } 
**   static Void configureAppDefaults(MappedConfig config) {
**     config[PillowConfigIds.welcomePage] = "start"
**   }
** }
** <pre 
const mixin PillowConfigIds {
 
	** The component name of directory welcome pages.
	** Defaults to "index".
	static const Str welcomePage			:=	"afPillow.welcomePage"

	** The default 'Content-Type' to serve pages up as, if it can not be determined.
	** Defaults to 'MimeType("text/plain")'
	static const Str defaultContentType		:=	"afPillow.defaultContentType"

	** Set to 'false' to disable the automatic routing of request URLs to Pillow page rendering.
	** Defaults to 'true'.
	static const Str enableRouting			:=	"afPillow.enableRouting"

	** TODO: needs to be an enum
	** - off (component only)
	** - off & redirectDirectoryToWelcomePage
	** - on
	** - on & redirectWelcomePageToDirectory
	** Note this affects how clientUri's are reported by Pages 
//	static const Str redirectStrategy	:=	"afEfan.redirectStrategy"

}
