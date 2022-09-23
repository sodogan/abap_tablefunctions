@EndUserText.label: 'Custom entity calling Table Func'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_GEOMETRIES_CUSTOM_HANDLER'

@Search.searchable: true
@Metadata.allowExtensions: true

@VDM.viewType: #CONSUMPTION

@UI.headerInfo: {
  typeName: 'Geometries',
  typeNamePlural: 'Geometries',
  title: {  label: 'Geometries'}
}
define root custom entity ZCUSTOM_ACTUAL_GEOMETRIES_V
  //with parameters p_status: /dmo/overall_status
{
      @UI.facet: [ { id:              'ActualGeoms',
                   purpose:         #STANDARD,
                   type:            #IDENTIFICATION_REFERENCE,
                   label:           'Actual Geom',
                   position:        10 }
                 ]
      @UI              : {
      lineItem         : [ { position: 10 } ],
      identification   : [ { position: 10, importance: #HIGH, type: #STANDARD } ],
      selectionField   : [ { position: 10 } ]
      }
      @EndUserText.quickInfo         : 'Actual Geom ID'
      @EndUserText.label             : 'Actual Geom ID'
      @Search.defaultSearchElement   : true
      @Search.fuzzinessThreshold     : 0.8
  key ACTUALGEOMETRYID : abap.int8;
      @UI              : {
      lineItem         : [ { position: 20 } ],
      identification   : [ { position: 20, importance: #HIGH, type: #STANDARD } ],
      selectionField   : [ { position: 20 } ]
      }
      @EndUserText.quickInfo         : 'Actual Block ID'
      @EndUserText.label             : 'Actual Block ID'
      @Search.defaultSearchElement   : true
      @Search.fuzzinessThreshold     : 0.8
      ACTUALBLOCKID    : abap.int8;
      @UI              : {
      lineItem         : [ { position: 30 } ],
      identification   : [ { position: 30, importance: #HIGH, type: #STANDARD } ],
      selectionField   : [ { position: 30 } ]
      }
      @EndUserText.quickInfo         : 'GPS Quality'
      @EndUserText.label             : 'GPS Quality'
      GPSQUALITY       : abap.string;
}
