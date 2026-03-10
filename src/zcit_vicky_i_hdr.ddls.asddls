@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root Interface View for the Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZCIT_VICKY_I_HDR 
  as select from zcit_vicky_hdr as salesHeader
  composition [0..*] of ZCIT_VICKY_I_ITM as _salesitem
{
  key salesdocument             as SalesDocument,
      salesdocumenttype         as SalesDocumentType,
      orderreason               as OrderReason,
      salesorganization         as SalesOrganization,
      distributionchannel       as DistributionChannel,
      division                  as Division,
      salesoffice               as SalesOffice,
      salesgroup                as SalesGroup,
      @Semantics.amount.currencyCode: 'Currency'
      netprice                  as NetPrice,
      currency                  as Currency,

      @Semantics.largeObject: {
        mimeType:   'ExcelMimeType',
        fileName:   'ExcelFileName',
        contentDispositionPreference: #ATTACHMENT
      }
      excel_attachment          as ExcelAttachment,
      @Semantics.mimeType: true
      excel_mimetype            as ExcelMimeType,
      excel_filename            as ExcelFileName,
      file_status               as FileStatus,

      @Semantics.user.createdBy: true
      local_created_by          as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at          as LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      local_last_changed_by     as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at     as LocalLastChangedAt,
  
  /* Associations */
     _salesitem
}
