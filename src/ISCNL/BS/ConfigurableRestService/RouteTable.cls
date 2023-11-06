Class ISCNL.BS.ConfigurableRestService.RouteTable Extends (%Persistent, %JSON.Adaptor)
{

/// Class of incoming message 
Property RequestClassname As %String(MAXLEN = "");

/// Business Host to formward the request to
Property TargetConfigName As %String(MAXLEN = "");

/// Sync (default) or async request?
Property Sync As %Boolean [ InitialExpression = 1 ];

/// Return Stub instead of actual formarding the message?
Property UseStub As %Boolean [ InitialExpression = 1 ];

/// Stub contents
Property StubContent As %String(MAXLEN = "");

/// Business Service (for generating lines between production items)
Property Bs As %String(MAXLEN = "");

Storage Default
{
<Data name="RouteTableDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>RequestClassname</Value>
</Value>
<Value name="3">
<Value>TargetConfigBame</Value>
</Value>
<Value name="4">
<Value>Sync</Value>
</Value>
<Value name="5">
<Value>UseStub</Value>
</Value>
<Value name="6">
<Value>StubContents</Value>
</Value>
<Value name="7">
<Value>TargetConfigName</Value>
</Value>
<Value name="8">
<Value>StubContent</Value>
</Value>
<Value name="9">
<Value>Bs</Value>
</Value>
</Data>
<DataLocation>^HS.Local.Impl.IB8AD.RouteTableD</DataLocation>
<DefaultData>RouteTableDefaultData</DefaultData>
<ExtentSize>0</ExtentSize>
<IdLocation>^HS.Local.Impl.IB8AD.RouteTableD</IdLocation>
<IndexLocation>^HS.Local.Impl.IB8AD.RouteTableI</IndexLocation>
<StreamLocation>^HS.Local.Impl.IB8AD.RouteTableS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
