ROUTINE Luci [Type=INC]

#include Ensemble

/// Create a %Status from a message and another %Status.
#def1arg BuildStatus(%args) ##class(Mbox.Utility).BuildStatus(%args)

/// Build string containing placeholders
#def1arg BuildMsg(%args) ##class(Mbox.Utility).ReplacePlaceholders(%args)

/// Logs an alert
#def1arg LogAlert(%args) $$$LOGALERT($$$BuildMsg(%args))
/// Logs a status with optional extra message
#def1arg LogStatus(%args) $$$LOGSTATUS($$$BuildStatus(%args))

/// Logs an trace message
#def1arg Trace(%args) $$$TRACE($$$BuildMsg(%args))

/// Logs an alert with an error status
#def1arg LogStatusAlert(%args) $$$LOGALERT(##class(Mbox.Utility).StatusMsg(%args))

/// Gets an OID for a given code
#define OID(%code) ##class(Mbox.Utility).GetOID(%code)

#; Helpers for JSONName
#define HasJSONFieldName(%s) $$$defSubMemberDefined("Mbox.Data.GeslotenAutorisatievraag",$$$cCLASSproperty,%s,$$$cPROPparameter,"%JSONFIELDNAME")
#define JSONFieldName(%s) $$$defMemberArrayGet("Mbox.Data.GeslotenAutorisatievraag",$$$cCLASSproperty,%s,$$$cPROPparameter,"%JSONFIELDNAME")
/// Get the %JSONFIELDNAME if present, and property name if not
#define JSONName(%s) $s($$$HasJSONFieldName(%s):$$$JSONFieldName(%s),1:%s)