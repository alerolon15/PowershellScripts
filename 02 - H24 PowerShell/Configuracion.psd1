@{
  AllNodes = @(
    @{
      # Nombre del Server donde se instala WEB y se configura IIS
      NodeName = "SERVER26"
      # Bandera para avisar al programa si deseamos Instalar ICF24 (WEB y AplicationPool IIS). "S" o "N"
      InstalarICF24 = "S"

      # Instancia de la Base de Datos SQL
      ServerSQL = "SERVER26"
      Instancia = "SERVER26\SQL2014SE"
      # Bandera para avisar al programa si deseamos crear y/o actualizar la base de datos. "S" o "N"
      CrearBase = "S"

      # Nombre de la base ICF24, usuario y pass para acceso
      DBICF = "ICF24"
      UserICF = "usrmc"
      PassICF = "usrmc"

      # Nombre de la base CIPOL, uruario y pass para acceso
      DBCipol = "WEBCIPOL"
      UserCipol = "usrcipol"
      PassCipol = "usrcipol"

      # Nombre de App pool y web aplication
      WebAppPoolName = "ICF24"
      WebApplicationName = "ICF24"

      # Carpeta contenedora del Publish de la Web, dentro del proyecto de actualizacion. (dejar .\WEBICF por defecto)
      SourcePath = ".\WEBICF"

      # Carpeta destino donde se instala la WEB
      DestinationPath = "C:\inetpub\wwwroot\ICF24"

      # Path donde se encuentra el web.config del Servicio, con nombre del MSI y CarpetaInstall (dejar .\Servicio\ por defecto)
      FileWebConfig = "C:\Program Files (x86)\ICF24Service\Config\App.connectionStrings.config"
      CarpetaInstall = ".\Servicio\"
      ExeICF = "MultiCanal.Setup.msi"

      # Configuracion para instalacion del NodoCoa
      WebAppPoolNameNC = "COA.WcfValidationLibrary"
      WebApplicationNameNC = "COA.WcfValidationLibrary"
      SourcePathNC = ".\COA.WcfValidationLibrary"
      DestinationPathNC = "C:\COA.WcfValidationLibrary\"
      PuertoNC = 8733
    }
  )
}
