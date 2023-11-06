/// Forward the request to the TargetConfigName listed in the HS.Local.Impl.Itzos.bs.ConfigurableRestService.RouteTable 
/// based on the classname of incoming request.
/// If there's no entry in this table use the DefaultTargetConfigName from the settings
/// Make a sync or async request based on the -sync- setting in the routetable.
/// Return the stub or make an actual forward based on the -UseStub- setting in the routetable
/// However, if the UseStubs setting is false, the  -UseStub- setting in the routetable will be ignored
/// and the request will always be forwarded to the TargetConfigName declared in the routetable
/// 
Class ISCNL.BS.ConfigurableRestService.ConfigurableRestService Extends (Ens.BusinessService, Ens.Util.FunctionSet)
{

Parameter ADAPTER = "Ens.InboundAdapter";

/// Target configuration names
Property DefaultTargetConfigName As %String(MAXLEN = 2000);

Property UseStubs As %Boolean [ InitialExpression = 1 ];

/// Settings
Parameter SETTINGS = "UseStubs:RestService,DefaultTargetConfigName:Basic:selector?&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";

Method SendRequestToTarget(pRequest As Ens.Request, Output pResponse As Ens.Response) As %Status
{
    s Status = $$$OK
    Try {
        Set Class = pRequest.%ClassName(1)

        Set ID=""
        &sql(select ID into :ID from ISCNL_BS_ConfigurableRestService.RouteTable where RequestClassname = :Class )
        
        if (ID="") {
            s Target = ..DefaultTargetConfigName
            s Sync = 1
            s UseStub = 0 
        } else {
            s RouteItem = ##class(ISCNL.BS.ConfigurableRestService.RouteTable).%OpenId(ID)
            s Target = RouteItem.TargetConfigName          
            s Sync = RouteItem.Sync

            if (Sync = "") {
                s Sync = 1
            }
            s UseStub = RouteItem.UseStub

            if (UseStub = "") {
                s UseStub = 0
            }

            s StubContent = RouteItem.StubContent

            if (StubContent = "") {
                s StubContent = "{}"
            }
        }

        if ((..UseStubs = 1) && (UseStub = 1)){
            // Send stub if: UseStubs setting allows it AND this is indicated in the RouteTable
            s pResponse = ##class(HS.Local.Impl.Itzos.api.BaseResponseMessage).%New()
            s pResponse.StubContent = StubContent
            $$$TRACE("No actual sending to target. Return stub")
        } else {
            $$$TRACE("SendRequestToTarget [" _ Target _ "]")
            If Sync {
                set Status = ..SendRequestSync(Target, .pRequest, .pResponse)	
            } else {	
                Set pResponse = ""
                Set Status = ..SendRequestAsync(Target, .pRequest,)
            }	
        }
    }
    Catch ex {
        Set Status = ex.AsStatus()
    }
	
	Return Status
}

/// Default message handling
Method OnProcessInput(pInput As %RegisteredObject, Output pOutput As %RegisteredObject) As %Status
{
	Quit $$$OK
}

/// Return an array of connections for drawing lines on the config diagram.
ClassMethod OnGetConnections(Output pArray As %String, pItem As Ens.Config.Item)
{
    try {
        Do ##super(.pArray,pItem)
        ; create a dynamic query on the routetable to get the targets
        set myquery = "SELECT TargetConfigName FROM ISCNL_BS_ConfigurableRestService.RouteTable where BS = ?"
        set tStatement = ##class(%SQL.Statement).%New()
        $$$ThrowOnError(tStatement.%Prepare(myquery))
        set rset = tStatement.%Execute(pItem.Name)
        while rset.%Next() {
            Set pArray(rset.%Get("TargetConfigName"))="" 
        }
    }
    Catch error{
        
    }
}

}
