
** [IocConfig]`http://repo.status302.com/doc/afIocConfig/` values as provided by 'Pillow'.
** To change their value, override them in your 'AppModule'. Example:
** 
** pre>
** using afIoc
** using afIocConfig
** using afEfanXtra
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
	static const Str welcomePage		:=	"afPillow.welcomePage"

	** TODO: needs to be an enum
	** - off (component only)
	** - off & redirectDirectoryToWelcomePage
	** - on
	** - on & redirectWelcomePageToDirectory
	** Note this affects how clientUri's are reported by Pages 
//	static const Str redirectStrategy	:=	"afEfan.redirectStrategy"

}
