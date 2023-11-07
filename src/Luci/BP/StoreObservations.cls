/// Business Process that stores Observations
Class Luci.BP.StoreObservations Extends (Ens.BusinessProcess, HS.HC.Util.Trace.Helper) [ ClassType = persistent ]
{

/// Setting
Parameter SETTINGS = "Target:Luci";

/// Connection where the data will be send
Property Target As Ens.DataType.ConfigName [ InitialExpression = "UCREdgeCareHome" ];

/// Main entry point for StoreObservation process
Method OnRequest(pRequest As Luci.Messages.StoreObservationRequest, Output response As Luci.Messages.ApiResponse) As %Status
{
	set response = ##class(Luci.Messages.StoreObservationResponse).%New()

	try
	{
	
		set sc = ##class(Luci.DTL.ObservationToFHIR).Transform(pRequest,.tResponse)
		if sc {
			$$$HSTRACE("Message after DTL","DTL",tResponse)
			set sc = ..SendRequestAsync(..Target,tResponse)
		}

		set response = ##class(Luci.Messages.ApiResponse).CreateResponse(200, )
		
	}
	catch ex
	{
        set response = ##class(Luci.Messages.ApiResponse).CreateErrorResponseForStatus(ex.AsStatus())
	}
	
	return $$$OK
}

/// Transform Request to an SDA3 container stream and send to UCREdge
Method TransformAndSendRequest(pRequest As Luci.Messages.StoreObservationRequest)
{
	/*; transform the input message into an SDA container
	$$$ThrowOnError(##class(HS.Local.Mediq.ConnectAPI.dtl.StoreObservationToSDAContainer).Transform(pRequest, .message))
	$$$HSTRACE("Created SDA container", "message", message)
	
	; create a streamcontainer which can be send to the TCP adapter
	$$$ThrowOnError(##class(HS.Local.Mediq.Common.dtl.XMLMessageToEnsStreamContainer).Transform(message, .streamcontainer))
	$$$HSTRACE("Created streamcontainer", "streamcontainer", streamcontainer)

	;send the streamcontainer to the edge
	$$$ThrowOnError(..SendRequestAsync(..UCREdge, .streamcontainer))
	*/
}

/// Handle a 'Response'
Method OnResponse(request As %Library.Persistent, ByRef response As %Library.Persistent, callrequest As %Library.Persistent, callresponse As %Library.Persistent, pCompletionKey As %String) As %Status
{


		set resp = ##class(ISCNL.Utilities.QuickStreamHelper).ReadQuickstream(callresponse.QuickStreamId).%ToJSON()
		set response = ##class(Luci.Messages.ApiResponse).CreateResponse(200, resp)
		return $$$OK
}

Storage Default
{
<Data name="StoreObservationDefaultData">
<Subscript>"StoreObservation"</Subscript>
<Value name="1">
<Value>TraceOperations</Value>
</Value>
<Value name="2">
<Value>ServerAPI</Value>
</Value>
<Value name="3">
<Value>UCREdge</Value>
</Value>
<Value name="4">
<Value>UpdatePatientList</Value>
</Value>
<Value name="5">
<Value>UpdateOnAllObservations</Value>
</Value>
<Value name="6">
<Value>Target</Value>
</Value>
</Data>
<DefaultData>StoreObservationDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
