/// Create  FHIR Namespace
Class Luci.Install.Install
{

ClassMethod SetupProduction()
{

	&sql(Insert into ISCNL_BS_ConfigurableRestService.RouteTable (BS,RequestClassName,Sync,TargetConfigName,UseStub) Values ('RestService','Luci.Messages.StoreObservationRequest',1,'StoreObservations',0))
	

    set prodClass = "Luci.FoundationProduction"
    do ##class(%EnsembleMgr).SetAutoStart($namespace, prodClass)
    job ##class(Ens.Director).StartProduction(prodClass)
}

}
