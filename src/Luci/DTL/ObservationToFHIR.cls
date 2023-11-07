/// 
Class Luci.DTL.ObservationToFHIR Extends Ens.DataTransform
{

/// Main method of transformation class
ClassMethod Transform(source As Luci.Messages.StoreObservationRequest, ByRef target As HS.FHIRServer.Interop.Request) As %Status
{

  set input = {}.%FromJSON(source.Input)
  set FhirOBs = ..Iput2FHIR(input)
	set stream = ..CreateQuickStream(FhirOBs)


	set target = ##class(HS.FHIRServer.Interop.Request).%New()

	return ..PupulateInteropRequest(target, stream)
}

ClassMethod Iput2FHIR(input As %Library.DynamicObject) As %Library.DynamicObject
{
	set FhirOutput = ..CreateHeader()
	do ..CreateEntries(input,.FhirOutput)
	//set FhirOutput.total = FhirOutput.entry.%Size()
  	return FhirOutput
}

/// Create FHIR bundle Header
ClassMethod CreateHeader() As %DynamicObject
{
	set FhirOutput = {}
	set FhirOutput.resourceType = "Bundle"
	set FhirOutput.id = $ZCONVERT($System.Util.CreateGUID(), "L")
	set FhirOutput.meta = {"profile": ["http://hl7.org/fhir/StructureDefinition/Bundle"]}
	set FhirOutput.type = "transaction"
	
	return FhirOutput
}

/// Create FHIR bundle Header
ClassMethod CreateEntries(input As %Library.DynamicObject, Output FhirOutput As %DynamicObject) As %DynamicObject
{

	set FhirOutput.entry=[]

	do ..CreatePatientResource(input.patient,.FhirOutput)
	
	do ..CreateObservationResource(input.observation,.FhirOutput)


	return FhirOutput
}

ClassMethod CreatePatientResource(input As %Library.DynamicObject, Output FhirOutput As %DynamicObject) As %Status
{
	set entry= {}
	set entry.fullURL ="urn:uuid:61ebe359-bfdc-4613-8bf2-c5e300945f0a"
	set resource = {}
	set resource.resourceType="Patient"
	set resource.id = input.uuid //$ZCONVERT($System.Util.CreateGUID(), "L")

	set resource.meta = {"profile":  ["http://fhir.nl/fhir/StructureDefinition/nl-core-patient"]}
  do resource.%Set("active",1,"boolean")

  set resource.name = ..GetName(input)
  set resource.telecom = ..GetTelecom(input)
  set resource.address = ..GetAddress(input)
	
	set entry.resource = resource
	set entry.request = {"method": "PUT","url": "Patient"}
  set entry.request.url = "Patient/"_resource.id
	do FhirOutput.entry.%Push(entry)

	return $$$OK
}

/// Create FHIR bundle Header
ClassMethod CreateObservationResource(input As %Library.DynamicObject, FhirOutput As %DynamicObject) As %Status
{
	set entry= {}
	set entry.fullURL ="urn:uuid:61ebe359-bfdc-4613-8bf2-c5e300945f0b"
	set resource = {}
	set resource.resourceType = "Observation"
	set resource.id = input.observationId
	set resource.meta = {"profile": ["http://nictiz.nl/fhir/StructureDefinition/zib-BloodPressure"]}
	set resource.status="registered"	

	set subject={}
	set subject.reference = "Patient/"_FhirOutput.entry.%Get(0).resource.id
	set subject.display = FhirOutput.entry.%Get(0).resource.name.%Get(0).family
	set resource.subject = subject
	set resource.category = [{"coding":  [{"system": "http://hl7.org/fhir/observation-category","code": "vital-signs","display": "Vital Signs" }]}]
	set resource.code = {"coding": [{"system": "http://loinc.org","code": "85354-9","display": "Blood pressure panel with all children optional"}], "text": "Blood pressure panel with all children optional"}

	//set resource.effectiveDateTime = ""
	set resource.method = {"coding": [{"system": "http://snomed.info/sct","code": "10179008","display": "Invasive"}],"text": "Invasief"}

	//set resource.components=[]

  set resource.component = ..GetComponents(input)
	set resource.effectiveDateTime = input.%Get("observedAt")
  set entry.resource = resource
	set entry.request = {"method": "PUT"}
  set entry.request.url = "Observation/"_resource.id

	do FhirOutput.entry.%Push(entry)
}

/// Create quickstream from DynamicObject
ClassMethod CreateQuickStream(patient As %Library.DynamicObject) As HS.SDA3.QuickStream
{
	set stream = ##class(HS.SDA3.QuickStream).%New()

	do patient.%ToJSON(stream)

	return stream
}

/// Populate Interop request
ClassMethod PupulateInteropRequest(target As HS.FHIRServer.Interop.Request, quickstream As HS.SDA3.QuickStream) As %Status
{
	#; set target.Request.TimestampUTC // is autofilled
	#; set target.Request = ##class(HS.FHIRServer.API.Data.Request).%New()
	set target.Request.SessionApplication = "/fhir/r4"
	set target.Request.RequestMethod = "POST"
	set target.Request.RequestPath = ""
	set target.Request.IsRecursive = 0
	set target.Request.BaseURL = "https://localhost:52773/fhir/r4/"
	set target.Request.RequestFormatCode = "JSON"
	set target.Request.ResponseFormatCode = "JSON"
	set target.QuickStreamId = quickstream.%Id()

	Return $$$OK
}

/// Build Json patient from HL7 PID segment
/// PID|1||3003078^^^HIX^PI~111122333^^^NLMINBIZA^NNNLD||de Mannaam&de&Mannaam^G^A^^^^L||19630826|M|||StraatnaamPatient 666  bis&StraatnaamPatient&666^bis^WoonplaatsPatient^^1111AA^NL^H||020-4715283&PRN&PH~0612345678&ORN&CP~&NET&Internet&G.de.Mannaam@hotmail.com
ClassMethod GetFHIRPatientFromPID(pid As EnsLib.HL7.Segment, Output conditionalquery As %String) As %Library.DynamicObject
{
	set observation = { "resourceType": "Observation" }


	return observation
}

ClassMethod GetName(input As %Library.DynamicObject) As %Library.DynamicObject
{
  set name =[]
  set n1 = {}

  set n1.use="official"
  set n1.family = input.%Get("full_name")
  if input.%Get("first_name") '="" {

    set n1.given=[]
    do n1.given.%Push(input.%Get("first_name"))
    set n1."_given"=[]
    set ext = []
    set ex1 = {"url":"http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"}
    set ex1.valueCode = "CL"
    do ext.%Push(ex1)
    set givenext = {}
    set givenext.extension = []
    do givenext.extension.%Push(ex1)

    do n1."_given".%Push(givenext)
  }
  do name.%Push(n1)

  return name
}

ClassMethod GetTelecom(input As %Library.DynamicObject) As %Library.DynamicObject
{
  set telecom =[]
  set t1={}
  set t1.value = input.%Get("phoneNumber").%Get("number")
  set t1.system = "phone"
  set t1.use = "home"
  do telecom.%Push(t1)


  return telecom
}

ClassMethod GetAddress(input As %Library.DynamicObject) As %Library.DynamicObject
{
  set address =[]
  set a1 = {}
  set a1.use = "home"
  set a1.type = "both"
  
  
  set a1.extension = []

  set line = ""
  if input.%Get("address").%Get("street") '=""{
    set ex1 = {"url":"http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-streetName"}
    set ex1.valueString = input.%Get("address").%Get("street")
    do a1.extension.%Push(ex1)
    set line = ex1.valuestring
  }
  if input.%Get("address").%Get("houseNumber")'="" {
    set ex2 = {"url":"http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-houseNumber"}
    set ex2.valueString = input.%Get("address").%Get("houseNumber")
    do a1.extension.%Push(ex2)
    set line = line _" " _ex2.valuestring
  }
  if input.%Get("address").%Get("houseNumberSuffix") '=""{
    set ex3 = {"url":"http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-buildingNumberSuffix"}
    set ex3.valueString = input.%Get("address").%Get("houseNumberSuffix")
    do a1.extension.%Push(ex3)
    set line = line _" " _ex3.valuestring
  }
  if line '=""{
    set a1.line=[]
    do a1.line.%Push(line)
  }
  set a1.city = input.%Get("address").%Get("city")
  set a1.postalCode = input.%Get("address").%Get("postalCode")
  set a1.country = input.%Get("address").%Get("country")
  do address.%Push(a1)
  return address
}

ClassMethod GetComponents(input As %Library.DynamicObject) As %Library.DynamicObject
{
  
  set component =[]
  #dim iterator As %Iterator.Object = input.components.%GetIterator()
  while iterator.%GetNext(.key, .value, .type)
  {
  
    set c1 ={"code":{"coding":[]}}
    set coding = value


    #dim iterator2 As %Iterator.Object = value.code.%GetIterator()
    while iterator2.%GetNext(.key2, .value2, .type2)
    { 
      if value2.system = "http://loinc.org"
      {
        set coding = value2
        quit
      }

    }

    set q1 = {}
    set q1.value = value.value+0
    set fhirunit = ##class(Ens.Util.FunctionSet).Lookup("ObservationToFHIRUnits", coding.code ,"unknown^unknown^unknown",1)
    set q1.unit = $Piece(fhirunit,"^",2)
    set q1.system = "http://unitsofmeasure.org"
    set q1.code = $Piece(fhirunit,"^",3)
    set c1.valueQuantity = q1

    do c1.code.coding.%Push(coding)
    do component.%Push(c1)
    

  }

 
  return component
}

XData SampleInput [ MimeType = application/json ]
{
{
  "observationId": "1",
  "code": [
    {
      "system": "http:\/\/snomed.info\/sct",
      "code": "363787002",
      "display": "Observable entity"
    },
    {
      "code": "8480-6",
      "system": "http://loinc.org",
      "display": "Systolic blood pressure"
    },
    {
      "code": "8462-4",
      "system": "http://loinc.org",
      "display": "Diastolic blood pressure"
    },
    {
      "code": "8867-4",
      "system": "http://loinc.org",
      "display": "Heart rate"
    }
  ],
  "dataAbsentReason": null,
  "components": [
    {
      "value": "78",
      "code": [
        {
          "system": "urn:oid:2.16.840.1.113883.2.4.3.135",
          "code": "item_id|5cde77a0-edef-4c23-90e3-17ec98d95905",
          "display": "Unit Test Item"
        },
        {
          "system": "urn:oid:2.16.840.1.113883.2.4.3.135",
          "code": "item_version|f6c22232-7d69-431e-965a-0d52620b31cf",
          "display": "Unit Test Item"
        },
        {
          "code": "8867-4",
          "system": "http://loinc.org",
          "display": "Heart rate"
        }
      ]
    },
    {
      "value": "80.0",
      "code": [
        {
          "system": "urn:oid:2.16.840.1.113883.2.4.3.135",
          "code": "item_id|d345b7bb-8d52-4e3a-bf64-460f72515508",
          "display": "Unit Test Item"
        },
        {
          "system": "urn:oid:2.16.840.1.113883.2.4.3.135",
          "code": "item_version|938a29ec-3f0c-45ba-a7be-e5a72413baf3",
          "display": "Unit Test Item"
        },
        {
          "code": "8462-4",
          "system": "http://loinc.org",
          "display": "Diastolic blood pressure"
        }
      ]
    },
    {
      "value": "120.0",
      "code": [
        {
          "system": "urn:oid:2.16.840.1.113883.2.4.3.135",
          "code": "item_id|ab27be58-4b04-40be-b270-984a93815eeb",
          "display": "Unit Test Item"
        },
        {
          "system": "urn:oid:2.16.840.1.113883.2.4.3.135",
          "code": "item_version|0c870310-6707-447a-9e12-2895a796cdd1",
          "display": "Unit Test Item"
        },
        {
          "code": "8480-6",
          "system": "http://loinc.org",
          "display": "Systolic blood pressure"
        }
      ]
    }
  ],
  "note": null,
  "observedAt": "2021-05-07T11:40:01+02:00"
}
}

XData SampleOutput [ MimeType = application/json ]
{
{
  "resourceType": "Bundle",
  "id": "004e0db1-74aa-4d07-8e4b-f3c276668a1d",
  "meta": {
    "profile": [
      "http://hl7.org/fhir/StructureDefinition/Bundle"
    ]
  },
  "type": "transaction",
  "total": 1,
  "entry": [
    {
      "fullUrl": "https://acceptatie-medmij.zorgplatform.online/Observation/056b85ec-d19c-4bde-929a-eb5212fdd0b8",
      "resource": {
        "resourceType": "Observation",
        "id": "056b85ec-d19c-4bde-929a-eb5212fdd0b8",
        "meta": {
          "profile": [
            "http://nictiz.nl/fhir/StructureDefinition/zib-BloodPressure"
          ]
        },
        "text": {
          "status": "generated",
          "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\"><h3>Observation resource for blood pressure:</h3><ul><li><p><strong>Patient:</strong> &#x27;Test Gestructureerd Vipp&#x27;</p></li><li><p><strong>Systolic blood pressure:</strong> &#x27;120 mm[Hg]&#x27;</p></li><li><p><strong>Diastolic blood pressure:</strong> &#x27;80 mm[Hg]&#x27;</p></li><li><p><strong>Average blood pressure:</strong> &#x27;92 mm[Hg]&#x27;</p></li><li><p><strong>Effective:</strong> &#x27;12-11- 2019 09:00&#x2B;0100&#x27;</p></li><li><p><strong>Method:</strong> &#x27;Invasive&#x27;</p></li><li><p><strong>Status:</strong> &#x27;Registered&#x27;</p></li><li><p><strong>Code:</strong> &#x27;85354-9&#x27;</p></li></ul></div>"
        },
        "status": "registered",
        "category": [
          {
            "coding": [
              {
                "system": "http://hl7.org/fhir/observation-category",
                "code": "vital-signs",
                "display": "Vital Signs"
              }
            ]
          }
        ],
        "code": {
          "coding": [
            {
              "system": "http://loinc.org",
              "code": "85354-9",
              "display": "Blood pressure panel with all children optional"
            }
          ],
          "text": "Blood pressure panel with all children optional"
        },
        "subject": {
          "reference": "Patient/38E690760B1594BEFF85581F6EC27B3C74CD88B9C643CAE8A2F71A69D5E46A2B",
          "display": "Test Gestructureerd Vipp"
        },
        "effectiveDateTime": "2019-11-12T09:00:00+01:00",
        "method": {
          "coding": [
            {
              "system": "http://snomed.info/sct",
              "code": "10179008",
              "display": "Invasive"
            }
          ],
          "text": "Invasief"
        },
        "component": [
          {
            "code": {
              "coding": [
                {
                  "system": "http://loinc.org",
                  "code": "8480-6",
                  "display": "Systolic blood pressure"
                }
              ],
              "text": "Systolic blood pressure"
            },
            "valueQuantity": {
              "value": 120,
              "unit": "mm[Hg]",
              "system": "http://unitsofmeasure.org",
              "code": "mm[Hg]"
            }
          },
          {
            "code": {
              "coding": [
                {
                  "system": "http://loinc.org",
                  "code": "8462-4",
                  "display": "Diastolic blood pressure"
                }
              ],
              "text": "Diastolic blood pressure"
            },
            "valueQuantity": {
              "value": 80,
              "unit": "mm[Hg]",
              "system": "http://unitsofmeasure.org",
              "code": "mm[Hg]"
            }
          },
          {
            "code": {
              "coding": [
                {
                  "system": "http://snomed.info/sct",
                  "code": "6797001",
                  "display": "Mean blood pressure"
                }
              ],
              "text": "Mean blood pressure"
            },
            "valueQuantity": {
              "value": 92,
              "unit": "mm[Hg]",
              "system": "http://unitsofmeasure.org",
              "code": "mm[Hg]"
            }
          },
          {
            "code": {
              "coding": [
                {
                  "system": "http://loinc.org",
                  "code": "8478-0",
                  "display": "Mean blood pressure"
                }
              ],
              "text": "Mean blood pressure"
            },
            "valueQuantity": {
              "value": 92,
              "unit": "mm[Hg]",
              "system": "http://unitsofmeasure.org",
              "code": "mm[Hg]"
            }
          }
        ]
      },
      "search": {
        "mode": "match"
      }
    }
  ]
}
}

}
