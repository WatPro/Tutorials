using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using iTextSharp.text.pdf;

namespace ProtectPDF
{
    public class GoPDF
    {
     
        /// <summary>
        /// 
        ///  constructor to resolve embedded   resources
        public GoPDF()

        {
            // We are using well known .Net Java port itextsharp (.Net 4.0)
            // itextsharp can be  used  directly from .Net projects but for Office automation, e.g VBA,  
            // we are making this wrapper library marking project as COM visible.
            // Tou can wrap  any of itextsharp method in here.
            // after registering on user / server computer as 
            // REM  RegAsm.exe ProtectPDF.dll /tlb:ProtectPDF.tlb /codebase      ---   /unregister
            // the type lib can be added to VBA excel or word and COM cam be used.


            // little trick here - we are embedding itextsharp.dll into the ProtectPDF.dll, so only one file need to be deployed.


            // To embed a .NET dll in a compiled exe/dll:
            // 1 Do not use NUGet to get xxx.dll in to your project (this optional step to have cleaner folder)
            //   Create temp projec to get latest xxx.dll if you wish
            // 2 Add  xxx.dll to References and set property Copy Local=false. 
            // 3 Change the properties of the xxx.dll in References so that Copy Local=false
            // 4 Add "using iTextSharp.text.pdf" to class file - now you can code against it
            // 5 Add the xxx.dll file to the project as an additional file not a reference
            // 6 Set in Properties of the added xxx.dll   `1: Build Action=Embedded Resource

            // 7 During runtime we will not have xxx.dll in app folder so we need to supress .Net dependency check 
            // and resolve it to embedded resource
            // 8 Paste  code before Application.Run in the main in case of exe or in case of class library
            // into class constructor - generic code below will resolve dinamically via Reflection empedded resource(s)

 

            AppDomain.CurrentDomain.AssemblyResolve += (Object sender, ResolveEventArgs args) =>

            {

                String thisExe = System.Reflection.Assembly.GetExecutingAssembly().GetName().Name;

                System.Reflection.AssemblyName embeddedAssembly = new System.Reflection.AssemblyName(args.Name);

                String resourceName = thisExe + "." + embeddedAssembly.Name + ".dll";

 

                using (var stream = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(resourceName))

                {

                    Byte[] assemblyData = new Byte[stream.Length];

                    stream.Read(assemblyData, 0, assemblyData.Length);

                    return System.Reflection.Assembly.Load(assemblyData);

                }

            };

       

        }

        public string ProtectPdfStandard(string passwordUser,  string passwordOwner, string namepathPDFIn, string namepathPDFOUT )
        {
            string error = string.Empty;
            if (string.IsNullOrWhiteSpace(passwordUser)) return "Error: User Password not set";
            if (string.IsNullOrWhiteSpace(passwordOwner)) return "Error: Owner Password not set";
            if (string.IsNullOrWhiteSpace(namepathPDFIn)) return "Error: User Password not set";
            if (string.IsNullOrWhiteSpace(namepathPDFOUT)) return "Error: Owner Password not set";


            try
            {
                using (Stream inputStream = new FileStream(namepathPDFIn, FileMode.Open, FileAccess.Read, FileShare.Read))
                {

                    using (Stream outputStream = new FileStream(namepathPDFOUT, FileMode.Create, FileAccess.Write, FileShare.None))
                    {

                        PdfReader reader = new PdfReader(inputStream);

                        // use bitwise AND to set / combine PDF permissioning

                        PdfEncryptor.Encrypt(reader, outputStream, true, passwordUser, passwordOwner, 
                            PdfWriter.ALLOW_PRINTING |  PdfWriter.ALLOW_SCREENREADERS);
                    }

                }
            }
            catch (Exception ex)
            {
                error = ex.Message;
            }

            return error;
        }
    }
}
