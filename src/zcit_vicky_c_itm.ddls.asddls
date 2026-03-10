@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Item Consumption View'
@Search.searchable: true
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZCIT_VICKY_C_ITM
  as projection on ZCIT_VICKY_I_ITM
{
  key SalesDocument,
  key SalesItemnumber,
  @Search.defaultSearchElement: true
  Material,
  Plant,
  @Semantics.quantity.unitOfMeasure: 'Quantityunits'
  Quantity,
 @Consumption.valueHelpDefinition: [{ entity: { name: 'I_UnitOfMeasure', element: 'UnitOfMeasure' } }]
Quantityunits,
  LocalCreatedBy,
  LocalCreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
  
  /* Associations */
  _salesHeader : redirected to parent ZCIT_VICKY_C_HDR
}
