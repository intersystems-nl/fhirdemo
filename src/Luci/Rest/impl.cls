Include (Luci, Ensemble)

/// # Een voorbeeld interface voor Luci..<br/>
/// Business logic class defined by OpenAPI in Luci.Rest.spec<br/>
Class Luci.Rest.impl Extends %REST.Impl
{

/// If ExposeServerExceptions is true, then details of internal errors will be exposed.
Parameter ExposeServerExceptions = 0;

/// Geeft de OpenAPI 2.0 documentatie van deze service terug
ClassMethod OpenAPI() As %DynamicObject
{
	#dim %request As %CSP.Request
	
	Set Data = ##class(%Dictionary.XDataDefinition).%OpenId(..%PackageName()_".spec||OpenAPI").Data
	Set Data = {}.%FromJSON(Data)
	
	; Dynamically place host and path in response
	Set Data.host = %request.GetCgiEnv("HTTP_HOST")
	Set Path = %request.GetCgiEnv("SCRIPT_NAME")
	Set Data.basePath = $Piece(Path, "/", 1, *-1)
	
	; If called without https, change the scheme
	If '%request.Secure Set Data.schemes = ["http"]
	
	Quit Data
}

/// Returns the data passed in with Content-Type JSON. Data may be
/// a string, a JSON-enabled class, or a %DynamicAbstractObject.
ClassMethod ReturnJSON(Data As %String = "", HttpStatus As %Integer = 200) As %String
{
	Do ..%SetContentType("application/json")
	Do ..%SetHeader("Access-Control-Allow-Origin", "*")
    Do ..%SetStatusCode(##class(ISCNL.Utilities.HTTPStatusHelper).GetHTTPStatusCode(HttpStatus))
	
	return ##class(ISCNL.Utilities.StringHelper).AnyObjectToString(Data)
}

/// Returns an (empty) internal server error response. Logs the
/// information passed in in an Ensemble Event Log of type Warning.
ClassMethod ReturnServerError(Status As %Status, LogMessage As %String = "") As %String
{
	if Status '= "", 'Status
    {
		Set LogMessage = LogMessage_" "_$System.Status.GetErrorText(Status)
	}

    set ^AAA = "ReturnServerError: " _ LogMessage

	$$$LOGWARNING(LogMessage)

	set message = {
        "status": "error",
        "code": "500"
    }

	if ..#ExposeServerExceptions
    {
    	set message.error = LogMessage
	}
    else
    {
    	set message.error = "Something unexepcted happened"
    }

    return ..ReturnJSON(message, 500)
}

/// Returns the username from the basic authorization header.
/// This is expected to always be present.
ClassMethod GetUser() As %String
{
	; Get Authorization header value
	Set Auth = ..%GetHeader("Authorization")
	; If we only have a login cookie, use $UserName
	If Auth = "" Quit $UserName
	; Get the base-64 encoded part
	Set Encoded = $Piece(Auth, "Basic ", 2)
	; Decode
	Set Decoded = $System.Encryption.Base64Decode(Encoded)
	; return the bit before the colon (=username)
	return $Piece(Decoded, ":", 1)
}

/// generic request handler, send the API request to the ConnectRestService
ClassMethod HandleRequest(Request As Ens.Request, wrapperProperty As %String = "", mapToProperty As %String = "results") As %DynamicObject
{
	try
    {
        #dim bs as ISCNL.BS.ConfigurableRestService.ConfigurableRestService
        set Status = ##class(Ens.Director).CreateBusinessService("RestService", .bs)

	    if 'Status
        {
            return ..ReturnServerError(Status, "Error creating business service")
        }

	    set Status = bs.SendRequestToTarget(Request, .response)

	    if 'Status
        {
            return ..ReturnServerError(Status, "Error sending request to Target")
        }

        if '$ISOBJECT(response)
        {
            return ..ReturnServerError(Status, "No response from businesshost within timeout period")
        }

        // A Business Host that processes API calls should return a repsonse inherited from BaseResponseMessage, so support
        // for error messages is present.
        // In the case there'set no repsonse other than an HTTP OK, a default Ens.Response may be returned.        
        if (response.%Extends("ISCNL.api.BaseResponseMessage"))
        {
        	return ..HandleBaseResponseMessage(response, wrapperProperty, mapToProperty)
        }

        if (response.%IsA("Ens.Response"))
        {
        	return { "status": "OK", "code": "200" }.%ToJSON()
        }

        throw ##class(%Exception.General).%New("Busines hosts returned unsupported messageclass")
	}
    catch ex
    {
		return ..ReturnServerError(ex.AsStatus(), "Exception in Handle request")
	}
}

/// Hanlde Base response message
ClassMethod HandleBaseResponseMessage(response As ISCNL.api.BaseResponseMessage, wrapperProperty As %String, mapToProperty As %String) As %Status
{
    if (response.StubContent '= "")
    {
        return ..ReturnJSON(response.StubContent, 200) /// This is supposed to have the proper structure
    }

    if (response.Error.ErrorCode '= "")
    {
        // return the response of the business host (a JSON enabeled response object) 
        // set the HttpStatuscode as defined by the BP
        return ..ReturnJSON(response.Error, response.HttpCode)
    }

    // return the response of the business host (a JSON enabeled response object) 
    // remove stubcontent, HttpCode and error from that response!
    // set the HttpStatuscode as defined by the BP
    do response.%JSONExportToStream(.json)
    #dim data as %DynamicObject = {}.%FromJSON(json)
    do data.%Remove("StubContent")
    do data.%Remove("Error")
    do data.%Remove("HttpCode")
    
    // Sometimes the response is a single json object and not an array of (model) objects
    // But in the BP response this is still wrapped in a property containing the (serial) model
    if (wrapperProperty '= "")
    {
        set results = data.%Get(wrapperProperty)

        if $ISOBJECT(results)
        {
            do data.%Set(mapToProperty, results)
            do data.%Remove(wrapperProperty)
        }
    }

    return ..ReturnJSON(data, response.HttpCode)
}

/// Returns observations that have been recorded between fromUtcDate and endUtcDate. Optional include the observationCode in the filter<br/>
/// The method arguments hold values for:<br/>
///     professionalAccountIdentifier, Who's requesting the data<br/>
///     fromUtcDate, Filter on BeginDate<br/>
///     endUtcDate, Filter on Enddate<br/>
///     observationCode, Filter on observationCode<br/>
///     validityScore, Filter on validity score. Not yet implemented!<br/>
///     mpiid, Filter on mpiid.<br/>
ClassMethod GetObservations(professionalAccountIdentifier As %String, fromUtcDate As %String, endUtcDate As %String, observationCode As %String, validityScore As %Integer, mpiid As %String) As %DynamicObject
{
    //(Place business logic here)
    //Do ..%SetStatusCode(<HTTP_status_code>)
    //Do ..%SetHeader(<name>,<value>)
    //Quit (Place response here) ; response may be a string, stream or dynamic object
}

/// Input comes in as an array of observations to store.
///             
/// If UniqueId is provided, always overwrite the existing entry.
/// Otherwise the checksum must be verified against that which is already stored within UCR to ensure we do not create duplicate entries.<br/>
/// The method arguments hold values for:<br/>
///     observations<br/>
/// WARNING: This method's signature has changed.
ClassMethod StoreObservations(observations As %DynamicObject) As %DynamicObject
{

    #dim %request As %CSP.Request
    
    try
    {
        #dim Request as Luci.Messages.StoreObservationRequest= ##class(Luci.Messages.StoreObservationRequest).%New()
        set Request.HttpMethod = %request.Method
        set Request.Input = observations.%ToJSON()
       

        return ..HandleRequest(Request)
    }
    catch ex
    {
        return ..ReturnServerError(ex.AsStatus(), "Exception in StoreObservations()")
    }
}

}
