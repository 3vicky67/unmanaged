# unmanaged
to know about unmanaged

<img width="1307" height="586" alt="image" src="https://github.com/user-attachments/assets/5c46be95-e3f3-48e8-a55d-e30857d332cd" />

<img width="1302" height="570" alt="image" src="https://github.com/user-attachments/assets/64c7189a-be6d-4227-b11c-2cc13b28247c" />

1. Data Modeling Layer (CDS Views)
The foundation relies on CDS entities that define the data structure and handle the file upload stream.

Root Entity (Sales Order Header): The main CDS view defines the fields you see on screen (e.g., SalesDocument, SalesOrg, NetPrice).

Stream/Attachment Handling: To support the "Choose Excel File" functionality, the CDS view uses specific annotations for Large Objects (LOB).

A field (e.g., Attachment) is typed as XSTRING (a raw byte sequence, as we discussed previously) to store the file content.

It uses annotations like @Semantics.largeObject.mimeType, @Semantics.largeObject.fileName, and @Semantics.largeObject.contentDispositionPreference to render the clickable link (SalesOrder_Template.xlsx) and handle the upload/download stream natively in Fiori.

2. Behavior Definition (BDEF - Unmanaged)
Because this is an "unmanaged" scenario, the BDEF explicitly tells the framework not to generate database updates automatically.

Implementation Type: Defined as unmanaged implementation in class zbp_... unique;. This means the developer takes full control of the CRUD operations.

Custom Actions: The BDEF defines the buttons seen in the top right:

action DownloadTemplate;

action UploadData;

Draft Handling: It is highly likely this app uses with draft;. When a user uploads the Excel file, it is temporarily stored in a generated draft table. The actual processing (reading the Excel and creating the order) might happen when they execute the "Upload Data" action or hit "Save".

3. Behavior Implementation (ABAP Class)
This is where the heavy lifting happens, bridging the modern UI with legacy SAP processing.

The Unmanaged CUD Operations: In the Local Saver Class (lsc_) or Handler Class (lhc_), the create, update, and delete methods are written manually. They take the data provided by the Fiori app and map it to legacy function modules, most likely BAPI_SALESORDER_CREATEFROMDAT2 or BAPI_SALESORDER_CHANGE.

Handling the Excel Parsing: 1. When the user clicks "Upload Data", the corresponding method in the behavior pool is triggered.
2. The ABAP code reads the XSTRING value of the uploaded file from the draft table.
3. It uses a parsing API (like XCO_CP_EXCEL in modern ABAP Cloud, or CL_FDT_XL_SPREADSHEET in older releases) to convert the binary Excel data into an ABAP internal table.
4. The logic loops through the internal table, populates the necessary item structures, and updates the "Item Details" facet or directly calls the BAPI to generate the sales order items.

Status Updates: The logic updates the custom FileStatus field (changing it to "Excel Uploaded") to give visual feedback to the user.

4. UI Metadata Extensions (MDE)
The visual layout is controlled by @UI annotations, typically separated into a Metadata Extension file to keep the CDS view clean.

Facets: Annotations define the layout of the tabs: @UI.facet: [ { id: 'SalesDetails', label: 'Sales Details', type: #FIELDGROUP_REFERENCE ... } ].

Action Placement: The custom buttons are placed in the header using @UI.identification: [ { type: #FOR_ACTION, dataAction: 'UploadData', label: 'Upload Data' } ].
