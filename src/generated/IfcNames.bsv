
typedef enum {
   NoInterface,
   PlatformIfcNames_MemServerRequestS2H,
   PlatformIfcNames_MMURequestS2H,
   PlatformIfcNames_MemServerIndicationH2S,
   PlatformIfcNames_MMUIndicationH2S,

   IfcNames_DmaRequestS2H0,
   IfcNames_DmaRequestS2H1,
   IfcNames_DmaRequestS2H2,
   IfcNames_DmaRequestS2H3,
   IfcNames_DmaRequestS2H4,
   IfcNames_DmaRequestS2H5,
   IfcNames_DmaRequestS2H6,
   IfcNames_DmaRequestS2H7,

   IfcNames_DmaIndicationH2S0,
   IfcNames_DmaIndicationH2S1,
   IfcNames_DmaIndicationH2S2,
   IfcNames_DmaIndicationH2S3,
   IfcNames_DmaIndicationH2S4,
   IfcNames_DmaIndicationH2S5,
   IfcNames_DmaIndicationH2S6,
   IfcNames_DmaIndicationH2S7

} IfcNames deriving (Eq,Bits);
