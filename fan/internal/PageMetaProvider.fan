using afIoc

internal const class PageMetaProvider : DependencyProvider {

	override Bool canProvide(Scope currentScope, InjectionCtx ctx) {
		if (ctx.isFieldInjection)
			// all field service injection should be denoted by a facet
			return ctx.field.hasFacet(Inject#) && ctx.field.type.toNonNullable == PageMeta#

		if (ctx.isFuncInjection)
			return ctx.isFuncArgReserved.not && ctx.funcParam.type.toNonNullable == PageMeta#
		
		return false
	}
	
	override Obj? provide(Scope currentScope, InjectionCtx ctx) {
		PageMetaProxy()
	}
}
