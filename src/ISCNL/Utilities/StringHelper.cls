/// Strinhg helper methods
Class ISCNL.Utilities.StringHelper
{

/// StartsWith helper
ClassMethod StartsWith(sourceValue As %String, searchValue As %String) As %Boolean
{
    set pattern = "1"""_searchValue_"""0.E"

    return (sourceValue ? @pattern )
}

/// Case inseitive string compare
ClassMethod Equals(s1 As %String, s2 As %String) As %Boolean
{
    return $ZCONVERT(s1, "U") = $ZCONVERT(s2, "U")
}

/// Transform any object to string
ClassMethod AnyObjectToString(object As %String = "") As %String
{
	; object may be string
	if '$IsObject(object)
    {
        return object
    }
	
	; ..or a JSON-enabled class
	if object.%Extends("%JSON.Adaptor")
    {
		do object.%JSONExportToString(.json)
		return json
	}
	
	; ...or a %DynamicAbstractObject
	return object.%ToJSON()
}

}
