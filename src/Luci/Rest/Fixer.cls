Include Luci

/// Projection that applies some fixes to the spec-generated
/// classes (.disp and .impl):
/// - Fix calls directly to %REST.Impl in dispatch methods
/// - Remove timestamp from implementation description
Class Luci.Rest.Fixer Extends %Projection.AbstractProjection
{

ClassMethod CreateProjection(ClassName As %String, ByRef Parameters As %String, Modified As %String, qstruct) As %Status
{
	Set DispName = $$$ClassPackageName(ClassName)_".disp"
	Set ImplName = $$$ClassPackageName(ClassName)_".impl"
	
	; Loop through all methods in the dispatcher class, and change calls
	; directly to %REST.Impl to calls to our subclass, so these methods
	; can be overridden if needed. This is particularly useful for method
	; %ReportRESTError, which is intended to be overridden but can't be
	; because of the hardcoded classname.
	
	Set ClassDef = ##class(%Dictionary.ClassDefinition).%OpenId(DispName, , .sc)
	If 'sc Quit $$$BuildStatus("Error opening dispatcher class {}:", sc, DispName)
	
	Set key = ""
	For  {
		#dim MethodDef As %Dictionary.MethodDefinition
		Set MethodDef = ClassDef.Methods.GetNext(.key)
		If key = "" Quit
		
		Set Name = MethodDef.Name
		
		Set Code = MethodDef.Implementation.Read()
		Set Code = $Replace(Code, "##class(%REST.Impl).", "##class("_ImplName_").")
		Set sc = MethodDef.Implementation.Clear()
		If 'sc Return $$$BuildStatus("Error clearing current implementation of {}:", sc, Name)
		Set sc = MethodDef.Implementation.Write(Code)
		If 'sc Return $$$BuildStatus("Error updating current implementation of {}:", sc, Name)
	}
	
	Set sc = ClassDef.%Save()
	If 'sc Quit $$$BuildStatus("Error saving updated dispatch class {}:", sc, Name)
	
	Do ..QueueClass(DispName)
	
	; While we're at it, remove the "Updated ..." line from the
	; implementation class, it needlessly messes with source control.
	
	Set ClassDef = ##class(%Dictionary.ClassDefinition).%OpenId(ImplName, , .sc)
	If 'sc Quit $$$BuildStatus("Error opening implementation class {}:", sc, ImplName)
	
	Set Desc = ClassDef.Description
	If $Piece(Desc, $$$EOL, *) ? 1"Updated "1.E {
		Set Desc = $Piece(Desc, $$$EOL, 1, *-1)
		Set ClassDef.Description = Desc
		
		Set sc = ClassDef.%Save()
		If 'sc Quit $$$BuildStatus("Error saving updated implementation class {}:", sc, Name)
		
		Do ..QueueClass(DispName)
	}
	
	Quit $$$OK
}

}
