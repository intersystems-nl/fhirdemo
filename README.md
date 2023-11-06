# FHIR demo
This repository provides sample code that shows how you can customize the InterSystems IRIS for Health FHIR Repository. This code is from Theo Stolkers Customizing Intersystems
FHIR serser. Additional an input REST service was added to input observations, which are translated into a FHIR bundle and send to the FHIR repo.

## Set Up
This repo can be run using docker compose:

    `docker-compose up`

After starting, you can access the following URLs:
- Management Portal at http://localhost:32783/csp/sys/UtilHome.csp?$NAMESPACE=FHIR. Login using _SYSTEM/SYS
 
## Using $$$FSLog()
This repo enables $$$FSLog after creating the FHIR Repository through the command 

    `set ^FSLogChannel("all") = 1`

## Run the Sample

## Documentation
The following InterSystems IRIS for Health Documentation is helpful as background information:

**The InterSystems IRIS for Health FHIR Repository**

[FHIR Server: An Introduction](https://docs.intersystems.com/irisforhealth20231/csp/docbook/Doc.View.cls?KEY=HXFHIR_server_intro)

[Customizing a FHIR Server](https://docs.intersystems.com/irisforhealth20231/csp/docbook/DocBook.UI.Page.cls?KEY=HXFHIR_server_customize_arch)

**The FHIR specification**

[RESTful API](https://hl7.org/fhir/R4/http.html)

[Search](https://hl7.org/fhir/R4/search.html)

[References](https://hl7.org/fhir/R4/references.html)

**Background for Programmers**

[Using ObjectScript](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GCOS_intro)

[Using Embedded Python](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=AFL_epython)

## Bugslist
There are no known bugs at this point in time

## Finally
Use or operation of this code is subject to acceptance of the license available in the code repository for this code.

