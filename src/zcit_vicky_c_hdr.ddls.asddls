@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Header Consumption View'
@Search.searchable: true
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZCIT_VICKY_C_HDR
  provider contract transactional_query
  as projection on ZCIT_VICKY_I_HDR
{
  key SalesDocument,
      SalesDocumentType,
      OrderReason,
      SalesOrganization,
      DistributionChannel,
      Division,
      @Search.defaultSearchElement: true
      SalesOffice,
      SalesGroup,
      @Semantics.amount.currencyCode: 'Currency'
      NetPrice,
      @Consumption.valueHelpDefinition: [{
        entity: { name: 'I_Currency', element: 'Currency' }
      }]
      Currency,

      @Semantics.largeObject: {
        mimeType:   'ExcelMimeType',
        fileName:   'ExcelFileName',
        acceptableMimeTypes: [
          'application/vnd.ms-excel',
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        ],
        contentDispositionPreference: #ATTACHMENT
      }
      ExcelAttachment,
      @Semantics.mimeType: true
      ExcelMimeType,
      ExcelFileName,
      FileStatus,

      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
  
  
  /* Associations */
  _salesitem : redirected to composition child ZCIT_VICKY_C_ITM
}
