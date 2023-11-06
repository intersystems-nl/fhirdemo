/// Various helper methods for dealing with Quickstream
Class ISCNL.Utilities.QuickStreamHelper
{

/// Creates quickstream for resource
ClassMethod CreateQuickStream(resource As %Library.DynamicObject) As %String
{
	set stream = ##class(HS.SDA3.QuickStream).%New()

	do resource.%ToJSON(stream)

	return stream.%Id()
}

/// Read json FHIR Resource from quickstream
ClassMethod ReadQuickstream(quickStreamId As %String) As %DynamicObject
{
	if (quickStreamId '= "")
	{
		set stream = ##class(HS.SDA3.QuickStream).%OpenId(quickStreamId)

		try
		{
			return ##class(%DynamicObject).%FromJSON(stream)
		}
		catch ex
		{
			// Ignore exception; deal with the non-json response  
			do stream.Rewind()
			set error = stream.Read(, .sc)

			return { "error": (error) }
		}
	}

	return {}
}

}
