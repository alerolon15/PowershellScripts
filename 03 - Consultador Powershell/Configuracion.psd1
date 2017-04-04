@{
  AllNodes = @(
    @{
      # Nombre del Server donde se instala WEB y se configura IIS
      NodeName = "SERVER26"
      # Bandera para avisar al programa si deseamos Instalar VTEF (WEB y AplicationPool IIS). "S" o "N"
      InstalarVTEF = "S"

      # Instancia de la Base de Datos SQL
      ServerSQL = "SERVER26"
      Instancia = "SERVER26\SQL2014SE"
      # Bandera para avisar al programa si deseamos crear y/o actualizar la base de datos. "S" o "N"
      CrearBase = "S"

      # Nombre de la base ICF24, usuario y pass para acceso
      DBVTEF = "TEF_ONLINE"
      UserVTEF = "usrvtef"
      PassVTEF = "usrvtef"

      # Nombre de la base CIPOL, uruario y pass para acceso
      DBCipol = "WEBCIPOL"
      UserCipol = "usrcipol"
      PassCipol = "usrcipol"

      # Nombre de App pool y web aplication
      WebAppPoolName = "VisorTEF"
      WebApplicationName = "VisorTEF"

      # Carpeta contenedora del Publish de la Web, dentro del proyecto de actualizacion. (dejar .\WEBICF por defecto)
      SourcePath = ".\VISORTEF"

      # Carpeta destino donde se instala la WEB
      DestinationPath = "C:\inetpub\wwwroot\VisorTEF"

      #Carpetas de Conexiones para servicio y WEBICF
      configWEBICF24 = "C:\inetpub\wwwroot\ICF24\Web.connectionStrings.Config"
      configServicio = "C:\Program Files (x86)\ICF24Service\Config\App.connectionStrings.config"
    }
  )
}
