@{
  AllNodes = @(
    @{
      # Nombre del Server donde se instala WEB y se configura IIS
      NodeName = "TEST-SQL2016"
      # Bandera para avisar al programa si deseamos Instalar ICF24 (WEB y AplicationPool IIS). "S" o "N"
      InstalarWebCipol = "S"

      # Nombre de la base CIPOL, uruario y pass para acceso
      DBCipol = "WEBCIPOL"
      UserCipol = "usrcipol"
      PassCipol = "usrcipol"

      # Instancia de la Base de Datos SQL
      ServerSQL = "TEST-SQL2016"
      Instancia = "TEST-SQL2016\SQL2016ENT"
      # Bandera para avisar al programa si deseamos crear y/o actualizar la base de datos. "S" o "N"
      CrearBase = "S"

      # Nombre de App pool y web aplication
      WebAppPoolName = "CIPOL"
      WebApplicationName = "CIPOL"

      # Carpeta contenedora del Publish de la Web, dentro del proyecto de actualizacion. (dejar .\CIPOL por defecto)
      SourcePath = ".\CIPOL"

      # Carpeta destino donde se instala la WEB
      DestinationPath = "C:\inetpub\wwwroot\CIPOL"
    }
  )
}
