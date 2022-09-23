@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view ZGET_ACTUALGEOMETRIES_TF'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM.viewType: #BASIC
define root view entity ZI_GET_ACTUAL_GEOMETRIES 
with parameters 
   @EndUserText.label: 'Where clause'   
    p_where : abap.char(1333)
as select from zget_actualgeometries_tf(p_where: $parameters.p_where) {
    key ACTUALGEOMETRYID as ACTUALGEOMETRYID,
    ACTUALBLOCKID as ACTUALBLOCKID,
    GPSQUALITY as GPSQUALITY
}
