/// Generic methods that help deal with HTTP Status handling
Class ISCNL.Utilities.HTTPStatusHelper Extends %CSP.REST
{

/// Get Full HTTP code for numeric HTTP status
ClassMethod GetHTTPStatusCode(httpStatus As %String) As %String
{
	#dim HTTPStatusCodes as %DynamicObject = {
		"200": (..#HTTP200OK),
		"201": (..#HTTP201CREATED),
		"202": (..#HTTP202ACCEPTED),
		"204": (..#HTTP204NOCONTENT),
		"304": (..#HTTP304NOTMODIFIED),
		"400": (..#HTTP400BADREQUEST),
		"401": (..#HTTP401UNAUTHORIZED),
		"403": (..#HTTP403FORBIDDEN),
		"404": (..#HTTP404NOTFOUND),
		"405": (..#HTTP405METHODNOTALLOWED),
		"406": (..#HTTP406NOTACCEPTABLE),
		"409": (..#HTTP409CONFLICT),
		"415": (..#HTTP415UNSUPPORTEDMEDIATYPE),
		"422": (..#HTTP422UNPROCESSABLEENTITY),
		"423": (..#HTTP423LOCKED),
		"500": (..#HTTP500INTERNALSERVERERROR)
	}

	return HTTPStatusCodes.%Get(httpStatus, httpStatus)
}

/// Is this HTTPStatus code is an erro ror not
ClassMethod HTTPStatusIsOK(httpStatus As %String) As %String
{
	return (httpStatus >= 200) && (httpStatus < 300)
}

}
