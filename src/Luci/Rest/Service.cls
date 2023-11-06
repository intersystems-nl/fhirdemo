Include Mbox

Class Mbox.Rest.Service Extends Deployment.Service
{

Parameter SETTINGS = "GeslotenAutorisatieTarget:Basic:selector?context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId},OpenAutorisatieTarget:Basic:selector?context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId},AbonnerenTarget:Basic:selector?context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId},OpzeggenTarget:Basic:selector?context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";

/// Name of the production item to send the request to
Property GeslotenAutorisatieTarget As Ens.DataType.ConfigName;

/// Name of the production item to send the Open
/// Autorisatievraag to
Property OpenAutorisatieTarget As Ens.DataType.ConfigName;

/// Name of the production item to send the request to
Property AbonnerenTarget As Ens.DataType.ConfigName;

/// Name of the production item to send the request to
Property OpzeggenTarget As Ens.DataType.ConfigName;

/// Handles an incoming REST authorization request
Method GeslotenAutorisatie(Input As Mbox.Data.GeslotenAutorisatievraag, Output Result As Mbox.Data.GeslotenAutorisatievraagResponse) As %Status
{
	Set Result = ""
	
	Set CallReq = ##class(Mbox.Msg.GeslotenAutorisatievraagReq).%New()
	Set CallReq.Input = Input
	
	#dim CallRsp As Mbox.Msg.GeslotenAutorisatievraagRsp
	Set sc = ..SendRequestSyncCleanUp(..GeslotenAutorisatieTarget, CallReq, .CallRsp)
	If 'sc Quit $$$BuildStatus("Error calling target '{}'", sc, ..GeslotenAutorisatieTarget)
	
	Set Result = CallRsp.Response
	
	Quit $$$OK
}

/// Handles an incoming REST open authorization request
Method OpenAutorisatie(Input As Mbox.Data.OpenAutorisatievraag, Output Result As Mbox.Data.OpenAutorisatievraagResponse) As %Status
{
	Set Result = ""
	
	Set CallReq = ##class(Mbox.Msg.OpenAutorisatievraagReq).%New()
	Set CallReq.Input = Input
	
	#dim CallRsp As Mbox.Msg.OpenAutorisatievraagRsp
	Set sc = ..SendRequestSyncCleanUp(..OpenAutorisatieTarget, CallReq, .CallRsp)
	If 'sc Quit $$$BuildStatus("Error calling target '{}'", sc, ..OpenAutorisatieTarget)
	
	Set Result = CallRsp.Response
	
	Quit $$$OK
}

/// Handles an incoming REST subscribe request
Method Subscribe(Input As Mbox.Data.AbonnerenVerzoek, Output Result As Mbox.Data.AbonnerenResponse) As %Status
{
	Set Result = ""
	
	Set CallReq = ##class(Mbox.Msg.AbonnerenReq).%New()
	Set CallReq.Verzoek = Input
	
	#dim CallRsp As Mbox.Msg.AbonnerenRsp
	Set sc = ..SendRequestSyncCleanUp(..AbonnerenTarget, CallReq, .CallRsp)
	If 'sc Quit $$$BuildStatus("Error calling target '{}'", sc, ..AbonnerenTarget)
	
	Set Result = CallRsp.Response
	
	Quit $$$OK
}

/// Handles an incoming REST unsubscribe request
Method Unsubscribe(Input As Mbox.Data.OpzeggenVerzoek, Output Result As Mbox.Data.AbonnerenResponse) As %Status
{
	Set Result = ""
	
	Set CallReq = ##class(Mbox.Msg.OpzeggenReq).%New()
	Set CallReq.Verzoek = Input
	
	#dim CallRsp As Mbox.Msg.OpzeggenRsp
	Set sc = ..SendRequestSyncCleanUp(..OpzeggenTarget, CallReq, .CallRsp)
	If 'sc Quit $$$BuildStatus("Error calling target '{}'", sc, ..AbonnerenTarget)
	
	Set Result = CallRsp.Response
	
	Quit $$$OK
}

}
