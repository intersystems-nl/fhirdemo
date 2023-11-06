Class ISCNL.Messages.RequestBase Extends (Ens.Request, %JSON.Adaptor)
{

Property User As %String;

Property HttpMethod As %String;

Storage Default
{
<Data name="RequestBaseDefaultData">
<Subscript>"RequestBase"</Subscript>
<Value name="1">
<Value>User</Value>
</Value>
<Value name="2">
<Value>HttpMethod</Value>
</Value>
</Data>
<DefaultData>RequestBaseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
