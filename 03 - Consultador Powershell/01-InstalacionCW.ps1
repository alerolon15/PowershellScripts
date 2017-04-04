Configuration ScriptTest
{
    param
    (
        # Target nodes to apply the configuration
      [Parameter(Mandatory)]
      [ValidateNotNullOrEmpty()]
      [string]$Path
    )

    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -Module xWebAdministration

    Node $AllNodes.NodeName {


        # Script Resource: https://msdn.microsoft.com/en-us/powershell/dsc/scriptresource
        Script SQLExecute {

          GetScript = {
                @{
                    GetScript = $GetScript
                    SetScript = $SetScript
                    TestScript = $TestScript
                    Result = $True
                }
            }

            SetScript = {
                write-verbose "running ConfigurationFile :SQLExecute";
                try {
		                $Server = $using:Node.ServerSQL
                    $Instancia = $using:Node.Instancia
                    $UserVTEF = $using:Node.UserVTEF
                    $PassVTEF = $using:Node.PassVTEF
                    $DBName = $using:Node.DBVTEF
                    $AppWeb = $using:Node.WebApplicationName
                    $DBCipol = $using:Node.DBCipol
                    $path = $using:Path
                    #definimos el path con el nombre de cada script
                    $sql0 =  "CREATE DATABASE [" + $DBName + "]"
                    $sql1 =  $path + "\DBVTEF\02 - TEFONLINE.sql"
                    $sql2a =  $path + "\DBVTEF\06 - Create_dn_Categorias.sql"
                    $sql2b =  $path + "\DBVTEF\07 - Create_DN_Motivos_Rechazos.sql"
                    $sql3 =  "CREATE LOGIN [" + $UserVTEF + "] WITH PASSWORD=N'" + $PassVTEF + "', DEFAULT_DATABASE=[" + $DBName + "], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=Off"
                    $sql4 =  "CREATE USER [" + $UserVTEF + "] FOR LOGIN [" + $UserVTEF + "] WITH DEFAULT_SCHEMA=[dbo] EXEC sp_addrolemember N'db_owner', N'" + $UserVTEF + "'"
                    $sql5a = "INSERT INTO SE_SIST_HABILITADOS (IDSISTEMA,CODSISTEMA,DESCSISTEMA,FECHAHABILITACION,NOMBREEXEC,SISTEMAHABILITADO,ICONO,OBSERVACIONES,PAGINAPORDEFECTO,DESCRIPCIONCORTA,IMPACTACAJA,SOAPACTION) VALUES(2,'VisorTEF','Visor TEF WEB',NULL,'','S','icon-screen*violet',NULL,'http://" + $Server + "/" + $AppWeb + "',NULL,'',NULL);"
		                $sql5b =  $path + "\DBVTEF\01 - Script Inicializacion Tareas VisorTef.sql"
                    $sql6 =  $path + "\DBVTEF\08 - Create_F_ImportePorCubrir.sql"
                    $sql7 =  $path + "\DBVTEF\05 - Actualizacion_Version.sql"
                    $sql8 =  $path + "\DBVTEF\04 - Actualizacion_TareasCIPOL.sql"
                    #llamamos al metodo sqlcmd por cada script
                    sqlcmd.exe -S $Instancia -H $Server -E -d Master   -Q $sql0
                    sqlcmd.exe -S $Instancia -H $Server -E -d $DBName  -i $sql1
                    sqlcmd.exe -S $Instancia -H $Server -E -d $DBName  -i $sql2a
                    sqlcmd.exe -S $Instancia -H $Server -E -d $DBName  -i $sql2b
                    sqlcmd.exe -S $Instancia -H $Server -E -d Master   -Q $sql3
                    sqlcmd.exe -S $Instancia -H $Server -E -d $DBName  -Q $sql4
                    sqlcmd.exe -S $Instancia -H $Server -E -d $DBCipol -Q $sql5a
                    sqlcmd.exe -S $Instancia -H $Server -E -d $DBCipol -i $sql5b
                    sqlcmd.exe -S $Instancia -H $Server -E -d $DBName  -i $sql6
                    sqlcmd.exe -S $Instancia -H $Server -E -d $DBName  -i $sql7
                    sqlcmd.exe -S $Instancia -H $Server -E -d $DBCipol  -i $sql8
                }
                catch
                {
                    throw $_.Exception
                }
            }
            TestScript = {
              $Server = $using:Node.ServerSQL
              $Instancia = $using:Node.Instancia
              $DBName = $using:Node.DBVTEF
              $Query = "IF DB_Id('" + $DBName + "') IS NOT NULL BEGIN PRINT 'TRUE' END ELSE BEGIN PRINT 'FALSE' END"
              $Exist = sqlcmd.exe -S $Instancia -H $Server -E -d Master -Q $Query
              Write-Verbose "Existencia de Base de datos: "
              Write-Verbose $Exist

              If ($Node.CrearBase -Eq "S")
              {
                If ($Exist -Eq "TRUE")
                {
                  Write-Verbose "Existe DB, No se usan los scripts de creación"
                  return $true
                }ELSE{
  		            Write-Verbose "No Existe DB, Se crea la Base de Datos"
                  return $false
                }
              }ELSE {
                Write-Verbose "No Crear Base de datos (Configuracion.psd1 CrearBase = N)"
                return $true;
              }
            }
        }

    Script InstalarVTEF {

        GetScript = {
              @{
                  GetScript = $GetScript
                  SetScript = $SetScript
                  TestScript = $TestScript
                  Result = $True
              }
          }
        SetScript = {
          $SoN = $Using:Node.InstalarVTEF
          If ($SoN -Eq "S")
          {
            Write-Verbose "InstalarVTEF = 'S'"
            Write-Verbose "Proceso para Crear WEB, IIS y cambiar conecctionStrings de servicio y WEB"
          }ELSE {
            Write-Verbose "InstalarVTEF = 'N'"
            Write-Verbose "No se Crea WEB ni AplicationPool, se especifico en Configuracion.psd1 que no se realice la instalacion"
          }
        }
        TestScript = {
          return $false
        }
    }


    # Solo Se ejecuta el resto del Script si en la configuracion seteamos InstalarICF24 con "S"
    If ($Node.InstalarVTEF -Eq "S")
    {
		# ------------------------------- ADD WINDOWS FEATURES -----------------------------------------------
        # Install the IIS role
        WindowsFeature IIS
        {
            Ensure          = "Present"
            Name            = "Web-Server"
        }

        # Install the ASP .NET 4.5 role
        WindowsFeature AspNet45
        {
            Ensure          = "Present"
            Name            = "Web-Asp-Net45"
        }

        # Autenticación básica
        WindowsFeature AutBasica
        {
            Ensure    = "Present"
            Name      = "Web-Basic-Auth"
			DependsOn = "[WindowsFeature]IIS"
        }

        # Autenticación Client-Auth
        WindowsFeature AutClient
        {
            Ensure    = "Present"
            Name      = "Web-Client-Auth"
			DependsOn = "[WindowsFeature]IIS"
        }

        # Autenticación cer-Auth
        WindowsFeature AutCert
        {
            Ensure    = "Present"
            Name      = "Web-Cert-Auth"
			DependsOn = "[WindowsFeature]IIS"
        }

        # Autenticación Win-Auth
        WindowsFeature AutWin
        {
            Ensure    = "Present"
            Name      = "Web-Windows-Auth"
			DependsOn = "[WindowsFeature]IIS"
        }

        # Autenticación Digest-Auth
        WindowsFeature AutDigest
        {
            Ensure    = "Present"
            Name      = "Web-Digest-Auth"
			DependsOn = "[WindowsFeature]IIS"
        }

        # Autenticación Digest-Url
        WindowsFeature AutUrl
        {
            Ensure    = "Present"
            Name      = "Web-Url-Auth"
			DependsOn = "[WindowsFeature]IIS"
        }

		# ------------------------------- FIN ADD WINDOWS FEATURES -----------------------------------------------

        # Copy the website content
        File WebContent
        {
            Ensure          = "Present"
            SourcePath      = $Path + $Node.SourcePath
            DestinationPath = $Node.DestinationPath
            Recurse         = $true
            Type            = "Directory"
            DependsOn       = "[WindowsFeature]AspNet45"
        }      

        # Create a Web Application Pool
		# Ejemplos: https://msconfiggallery.cloudapp.net/packages/xWebAdministration/1.15.0.0/Content/Examples%5CSample_xWebAppPool.ps1
        xWebAppPool NewWebAppPool
        {
            Name   = $Node.WebAppPoolName
            Ensure = "Present"
            State  = "Started"
        		managedRuntimeVersion = "v4.0"
        		managedPipelineMode  = "Integrated"
        		pingingEnabled = $true
        		pingInterval = (New-TimeSpan -Seconds 20).ToString()
        		restartSchedule  = @("04:00:00")
        		idleTimeout = (New-TimeSpan -Minutes 1440).ToString()
        		pingResponseTime = (New-TimeSpan -Seconds 120).ToString()
        }

        # Uso el Sitio Default
        xWebsite DefaultWebSite
        {
            Ensure          = "Present"
            Name            = "Default Web Site"
            State           = "Started"
            PhysicalPath    = "C:\inetpub\wwwroot"
            DependsOn       = "[WindowsFeature]IIS"
        }

        #Create a new Web Application
        xWebApplication NewWebApplication
        {

            Name = $Node.WebApplicationName
            Website = "Default Web Site"
            WebAppPool =  $Node.WebAppPoolName
            PhysicalPath = $Node.DestinationPath 
            Ensure = "Present"
            DependsOn = @("[xWebSite]DefaultWebSite","[File]WebContent")
        }
        Script ChangeConnectionStringWEBICF
          {

               GetScript = {
                    @{
                        GetScript = $GetScript
                        SetScript = $SetScript
                        TestScript = $TestScript
                        Result = $True
                    }
                }

                SetScript =
                {
                    #$path = $using:Node.FileWebConfig # "C:\temp\Web.Config"
                    $NameWeb = $using:Node.DBVTEF
                    $path = $using:Node.configWEBICF24
                    $SQL  = $using:Node.Instancia
                    $User = $using:Node.UserVTEF
                    $Pass = $using:Node.PassVTEF

                    Write-Verbose $SQL
                    Write-Verbose $path

                    $xdoc = [xml] (Get-Content $path)
                    $node = $xdoc.SelectSingleNode("//connectionStrings/add[@name='TEF_OnlineEntities']")
                    $node.Attributes["connectionString"].Value = "metadata=res://*/ModelTefOnline.csdl|res://*/ModelTefOnline.ssdl|res://*/ModelTefOnline.msl;provider=System.Data.SqlClient;provider connection string='Data Source=" + $SQL + ";Initial Catalog=" + $NameWeb +";User Id=" + $User + ";Password=" + $Pass + ";MultipleActiveResultSets=True;Application Name=EntityFramework'"
                    $xdoc.Save($path)
                }
                TestScript =
                {
                    return $false
                }
            }
            Script ChangeConnectionStringServicio
            {
             GetScript = {
                  @{
                      GetScript = $GetScript
                      SetScript = $SetScript
                      TestScript = $TestScript
                      Result = $True
                  }
              }

              SetScript =
              {
                  #$path = $using:Node.FileWebConfig # "C:\temp\Web.Config"
                  $NameWeb = $using:Node.DBVTEF
                  $path = $using:Node.configServicio
                  $SQL  = $using:Node.Instancia
                  $User = $using:Node.UserVTEF
                  $Pass = $using:Node.PassVTEF

                  Write-Verbose $SQL
                  Write-Verbose $path

                  $xdoc = [xml] (Get-Content $path)
                  $node = $xdoc.SelectSingleNode("//connectionStrings/add[@name='TEF_OnlineEntities']")
                  $node.Attributes["connectionString"].Value = "metadata=res://*/ModelTefOnline.csdl|res://*/ModelTefOnline.ssdl|res://*/ModelTefOnline.msl;provider=System.Data.SqlClient;provider connection string='Data Source=" + $SQL + ";Initial Catalog=" + $NameWeb +";User Id=" + $User + ";Password=" + $Pass + ";MultipleActiveResultSets=True;Application Name=EntityFramework'"
                  $xdoc.Save($path)
              }
              TestScript =
              {
                  return $false
              }
          }
          File VTEFCarpeta
          {
              Ensure          = "Present"
              DestinationPath = "C:\VTEF"
              Type            = "Directory"
          }

           Script SCCrearconn {
             GetScript = {
                 #Do Nothing
             }

            SetScript = {
               Write-Verbose -Message "Ejecuto crear conexión"
               $CrearConn = "'" + $Using:Path +  "\CrearConexion\CrearConexion.exe'"
               $Arguments = "SQLServerOLEDB xxx " + $using:Node.DBVTEF + " " + $using:Node.UserVTEF + " " + $using:Node.PassVTEF + " '" + $using:Node.NodeName + "' '" + $using:Node.NodeName + "' Ingles Conexion 'C:\VTEF\Conexion.xml'"
               $CrearConexion = "& " + $CrearConn + $Arguments
               Invoke-Expression $CrearConexion

            }
            TestScript = {
                # Valido si existe sino no creo nuevamente el archivo de conexión.
                $existe = test-path 'C:\VTEF\Conexion.xml'
                return $existe
            }
         }
        }ELSE { Write-Verbose "InstalarVTEF = N; no se crea WEB ni AplicationPool" }
    }
}

$direccion = $pwd.path

ScriptTest -ConfigurationData '.\Configuracion.psd1' -Path $direccion -OutputPath '.\' -Verbose

if ([System.Diagnostics.EventLog]::SourceExists("VISORTEF") -eq $false) {
  [System.Diagnostics.EventLog]::CreateEventSource("VISORTEF", "VISORTEF")
}


# Hacemos un PUSH desde el Server:
Start-DscConfiguration -Path ".\" -Wait -Force -verbose

PAUSE
