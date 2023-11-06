Include Ensemble

/// Helper for getting fragments from a Jwt Access token
Class ISCNL.Utilities.JwtHelper Extends %RegisteredObject
{

/// HealthshareLoginId
Property HealthshareLoginId As %String [ Calculated, Transient ];

/// Get Healthshare login id
Method HealthshareLoginIdGet() As %String
{
    return ..Payload."healthshare_login_id"
}

/// Healthshare Roles
Property HealthshareRoles As %String [ Calculated, Transient ];

/// Get Healthshare Roles
Method HealthshareRolesGet() As %String
{
    return ..Payload."healthshare_roles"
}

/// HealthshareUsername
Property HealthshareUsername As %String [ Calculated, Transient ];

/// Get HealthshareUsername
Method HealthshareUsernameGet() As %String
{
    return ..Payload."healthshare_username"
}

/// ExpirationDateTime
Property ExpirationDateTime As %String [ Calculated, Transient ];

/// Get ExpirationDateTime
Method ExpirationDateTimeGet() As %String
{
    return $ZDATETIMEH(..Payload.exp, -2)
}

/// Get professional id and Expiration for logging
Method GetProfessionalIDAndExpiration(Output iserror As %Boolean) As %String
{
    try
    {
        s Now = ##class(%OAuth2.Utils).TimeInSeconds($ztimestamp,0)
        // set iserror = (..ExpirationDateTime < $ZDATETIME($HOROLOG, -2))
        set iserror = (..Payload.exp < Now)
        $$$TRACE("Current in secs: " _ Now)
        $$$TRACE("Expiration in secs: " _ ..Payload.exp)
        return "Provider: " _ ..Payload.name _ " ID: " _ ..HealthshareLoginId _ "; token expire" _ $CASE(iserror, 1:"d", :"s") _ " at " _ $ZDATETIME(..ExpirationDateTime, 2, 3)
    }
    catch ex
    {
        set iserror = 1
        return "; is not a valid access token"
    }
}

/// Payload from JWT
Property Payload As %DynamicObject;

/// Get payload from jwt
/// JWT Example
/// {
///   "jti": "https://MDQCHGLD01.dev.mediq.com/ucr/oauth2.S43jCkaPMbBzjOwPE0Ui7v8iDYo",
///   "iss": "https://MDQCHGLD01.dev.mediq.com/ucr/oauth2",
///   "sub": "Wietze",
///   "exp": 1677644750,
///   "aud": "https://mdqchgld01.dev.mediq.com/ucr/csp/healthshare/hsods/fhir/r4",
///   "healthshare_login_domain": "%HS_Default",
///   "healthshare_login_id": "Wietze",
///   "healthshare_roles": "%HSCM_CareTeam_Admin,%HSCM_CareTeam_Clinician,%HSCM_Clinician,%HSCM_Config_Admin,%HSCM_Form_Clinician,%HSCM_Task_Admin,%HSCM_Template_Admin,%HS_Administrator,%HS_Clinician,%HS_UserManager,HSGroup_Service,HS_Nurse_DK_Diabetes",
///   "healthshare_username": "Wietze",
///   "iat": 1677572750,
///   "name": "Wietze Drost",
///   "phone_number_verified": false,
///   "preferred_username": "Wietze"
/// }
ClassMethod CreateFromAccessToken(jwt As %String) As ISCNL.Utilities.JwtHelper
{
    set instance = ..%New()

    try
    {
        set jsonPayload = $SYSTEM.Encryption.Base64Decode($Translate($Piece(jwt,".",2),"-_","+/"))
        set instance.Payload = {}.%FromJSON(jsonPayload)
    }
    catch ex
    {
        $$$LOGWARNING("CreateFromAccessToken: " _ $System.Status.GetErrorText(ex.AsStatus()))
        set instance.Payload = {
            "exp": 1,
            "aud": "NoAud",
            "healthshare_login_domain": "%HS_Default",
            "healthshare_login_id": (jwt),
            "healthshare_roles": "none",
            "healthshare_username": (jwt),
            "iat": 0,
            "name": (jwt),
            "phone_number_verified": false,
            "preferred_username": (jwt)
        }
    }

    return instance
}

}
