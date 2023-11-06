Class ISCNL.api.Error Extends (%SerialObject, %XML.Adaptor, %JSON.Adaptor)
{

/// Error Code
Property ErrorCode As %String(%JSONFIELDNAME = "errorCode");

Property Subject As %String(%JSONFIELDNAME = "subject", MAXLEN = "");

Property Description As %String(%JSONFIELDNAME = "description", MAXLEN = "");

Property SessionId As %String(%JSONFIELDNAME = "sessionId");

/// 	ErrorCode - Documented errorcode, 
/// 	Subject - Description of subsystem where error occurred
/// 	Description - Errordescription
///     Sessionid - Intersystems SessionID for tracability
ClassMethod CreateError(pErrorCode As %String, pSubject As %String(MAXLEN=""), pDescription As %String(MAXLEN=""), pSessionId As %String) As ISCNL.api.Error
{
	
	#dim tErr As ISCNL.api.Error
    s tErr = ##class(ISCNL.api.Error).%New()
    s tErr.ErrorCode = pErrorCode
    s tErr.Subject = pSubject
    s tErr.Description = pDescription
    s tErr.SessionId = pSessionId
	
	return tErr
}

Storage Default
{
<Data name="ErrorState">
<Value name="1">
<Value>ErrorCode</Value>
</Value>
<Value name="2">
<Value>ErrorMessage</Value>
</Value>
<Value name="3">
<Value>Subject</Value>
</Value>
<Value name="4">
<Value>Description</Value>
</Value>
<Value name="5">
<Value>SessionId</Value>
</Value>
</Data>
<State>ErrorState</State>
<StreamLocation>^HS.Local.Impl.Itzos.api.ErrorS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
