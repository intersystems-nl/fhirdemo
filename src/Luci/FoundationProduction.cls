Class Luci.FoundationProduction Extends Ens.Production [ Not ProcedureBlock ]
{

XData ProductionDefinition
{
<Production Name="Luci.FoundationProduction" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>1</ActorPoolSize>
  <Item Name="RestService" Category="" ClassName="ISCNL.BS.ConfigurableRestService.ConfigurableRestService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="StoreObservations" Category="" ClassName="Luci.BP.StoreObservations" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="TraceOperations">*FULL*</Setting>
    <Setting Target="Host" Name="Target">Dummy</Setting>
  </Item>
  <Item Name="HS.Util.Trace.Operations" Category="" ClassName="HS.Util.Trace.Operations" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Dummy" Category="" ClassName="HS.FHIRServer.Interop.DummyOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="TraceOperations">*FULL*</Setting>
  </Item>
</Production>
}

}
