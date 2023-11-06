Class ISCNL.api.BaseResponseMessage Extends (Ens.Response, %JSON.Adaptor)
{

Property StubContent As %String(MAXLEN = "");

/// Error object. When filled, this will become the JSON response
Property Error As ISCNL.api.Error;

/// HttpCode to send. (It's possible to send a 200, but still return an error object)
Property HttpCode As %String [ InitialExpression = "200" ];

Storage Default
{
<Data name="BaseResponseMessageDefaultData">
<Subscript>"BaseResponseMessage"</Subscript>
<Value name="1">
<Value>StubContent</Value>
</Value>
<Value name="2">
<Value>Error</Value>
</Value>
<Value name="3">
<Value>HttpCode</Value>
</Value>
<Value name="4">
<Value>KjeldCode</Value>
</Value>
</Data>
<DefaultData>BaseResponseMessageDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
