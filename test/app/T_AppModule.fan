using afIoc
using afIocConfig
using afBedSheet
using afEfanXtra
using afPlastic
using afConcurrent

@SubModule { modules=[PillowModule#, EfanXtraModule#, PlasticModule#, ConcurrentModule#] }
internal const class T_AppModule { }
