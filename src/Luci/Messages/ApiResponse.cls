/// Generic API response used by the ConnectAPI
Class Luci.Messages.ApiResponse Extends ISCNL.api.BaseResponseMessage
{

/// Error Code
Property Status As %String(%JSONFIELDNAME = "status", VALUELIST = ",OK,error") [ InitialExpression = "OK" ];

/// HttpCode to send. (It's possible to send a 200, but still return an error object)
Property HttpCode As %String(%JSONFIELDNAME = "code") [ InitialExpression = "200" ];

Property Message As %String(%JSONFIELDNAME = "message", MAXLEN = "");

/// Create response for unexpected status
ClassMethod CreateErrorResponseForStatus(sc As %Status) As Luci.Messages.ApiResponse
{
    set error = $System.Status.GetErrorText(sc)
    $$$LOGERROR(error)
    return ..CreateResponse(500, error)
}

/// Create a proper response
ClassMethod CreateResponse(httpStatus As %Integer = 200, message As %String = "") As Luci.Messages.ApiResponse
{
    if '##class(ISCNL.Utilities.HTTPStatusHelper).HTTPStatusIsOK(httpStatus)
    {
        $$$LOGERROR(message)
    }

    set response = ..%New()
    do response.SetResponse(httpStatus, message)
    return response
}

/// Set the proper error response
Method SetResponse(httpStatus As %Integer = 200, message As %String)
{
    set ..HttpCode = httpStatus

    if '##class(ISCNL.Utilities.HTTPStatusHelper).HTTPStatusIsOK(httpStatus)
    {
        set ..Status = "error"
    }

    set ..Message = message
}

Storage Default
{
<Data name="ApiResponseDefaultData">
<Subscript>"ApiResponse"</Subscript>
<Value name="1">
<Value>Status</Value>
</Value>
<Value name="2">
<Value>Message</Value>
</Value>
</Data>
<DefaultData>ApiResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
