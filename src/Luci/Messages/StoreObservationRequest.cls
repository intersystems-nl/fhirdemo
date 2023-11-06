Class Luci.Messages.StoreObservationRequest Extends ISCNL.Messages.RequestBase
{

Property Input As %String(MAXLEN = "");

Storage Default
{
<Data name="StoreObservationRequestDefaultData">
<Subscript>"StoreObservationRequest"</Subscript>
<Value name="1">
<Value>Input</Value>
</Value>
</Data>
<DefaultData>StoreObservationRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
