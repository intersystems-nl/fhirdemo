Class Luci.Rest.spec Extends %REST.Spec
{

/// Respond to CORS header requests; allows API to be accessed
/// on the internal port from an external Swagger-UI.
Parameter HandleCorsRequest = 1;

/// If Strict=0 (false), then only the swagger properties which are needed for code generation are checked during compile.
/// If Strict=1 (true), then all swagger properties are checked during compile.
Parameter Strict = 1;

/// Projection to fix generated classes
Projection Fixer As Luci.Rest.Fixer;

// =====

XData OpenAPI [ MimeType = application/json ]
{
{
  "swagger": "2.0",
  "info": {
    "title": "Luci",
    "version": "v1",
    "description": "# Een voorbeeld interface voor Luci.."
  },
  "schemes": [
    "https"
  ],
  "host": "localhost",
  "basePath": "/lucu/v1",
  "consumes": [
    "application/json"
  ],
  "produces": [
    "application/json"
  ],
  "paths": {


    "/doc": {
      "get": {
        "operationId": "OpenAPI",
        "summary": "Geeft de OpenAPI 2.0 documentatie van deze service terug",
        "responses": {
          "200": {
            "description": "Succes"
          },
          "406": {
            "description": "Not acceptable"
          },
          "500": {
            "description": "Internal server error"
          },
          "503": {
            "description": "Service unavailable"
          }
        }
      }
    },
    "/Observations": {
      "get": {
        "tags": [
          "Observations"
        ],
        "x-ISC_CORS": true,
        "operationId": "GetObservations",
        "summary": "Returns observations that have been recorded between fromUtcDate and endUtcDate. Optional include the observationCode in the filter",
        "produces": [
          "application/json"
        ],
        "parameters": [
          {
            "in": "query",
            "name": "professionalAccountIdentifier",
            "description": "Who's requesting the data",
            "type": "string",
            "format": "base64"
          },
          {
            "in": "query",
            "name": "fromUtcDate",
            "description": "Filter on BeginDate",
            "type": "string",
            "format": "date-time"
          },
          {
            "in": "query",
            "name": "endUtcDate",
            "description": "Filter on Enddate",
            "type": "string",
            "format": "date-time"
          },
          {
            "in": "query",
            "name": "observationCode",
            "description": "Filter on observationCode",
            "type": "string"
          },
          {
            "in": "query",
            "name": "validityScore",
            "description": "Filter on validity score. Not yet implemented!",
            "format": "int32",
            "type": "integer"
          },
          {
            "in": "query",
            "name": "mpiid",
            "description": "Filter on mpiid.",
            "type": "string"
          }
        ],
        "responses": {
          "200": {
            "description": "Success"
          },
          "400": {
            "description": "Invalid professionalAccountIdentifier"
          },
          "404": {
            "description": "Patient not found"
          }
        }
      },
      "post": {
        "tags": [
          "Observations"
        ],
        "x-ISC_CORS": true,
        "operationId": "StoreObservations",
        "summary": "Change observations inside UCR according to mappings.",
        "description": "Input comes in as an array of observations to store.\r\n            \r\nIf UniqueId is provided, always overwrite the existing entry.\r\nOtherwise the checksum must be verified against that which is already stored within UCR to ensure we do not create duplicate entries.",
        "consumes": [
          "application/json"
        ],
        "produces": [
          "application/json"
        ],
        "parameters": [
          {
            "in": "body",
            "name": "observations",
            "description": "",
            "schema":{"type":"object"}
          }
        ],
        "responses": {
          "200": {
            "description": "Accepted"
          },
          "401": {
            "description": "Not authorized because of inactive treatment agreement or when not given medical data consent"
          }
        }
      }
    }
  },
  "definitions": {

  }

}
}

}
