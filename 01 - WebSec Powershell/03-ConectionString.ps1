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

    Node $AllNodes.NodeName {

      Script ChangeConnectionStringWebCipol
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
                  $NameWeb = $using:Node.WebApplicationName
                  $path = "C:\inetpub\wwwroot\" + $NameWeb + "\WEBCIPOL\Web.Config"
                  $SQL  = $using:Node.Instancia
                  $User = $using:Node.UserCipol
                  $Pass = $using:Node.PassCipol
                  $Server = $using:Node.NodeName

                  Write-Verbose $SQL
                  Write-Verbose $path

                  $xdoc = [xml] (Get-Content $path)

                  $node1 = $xdoc.SelectSingleNode("//applicationSettings/wsCipolServices.Properties.Settings")
                  $node1 = $xdoc.configuration.applicationSettings.SelectSingleNode("//wsCipolServices.Properties.Settings/setting[@name='wsCipolServices_Fachada_Seguridad_IniciarSesion_wsInicioSesion']")
                  $node1.Value = "http://" + $Server + "/" + $NameWeb + "/wsCIPOL/wsInicioSesion.asmx"

                  $node2 = $xdoc.SelectSingleNode("//applicationSettings/wsCipolServices.Properties.Settings")
                  $node2 = $xdoc.configuration.applicationSettings.SelectSingleNode("//wsCipolServices.Properties.Settings/setting[@name='wsCipolServices_Fachada_Seguridad_ABM_wsCOA_ABMBase']")
                  $node2.Value = "http://" + $Server + "/" + $NameWeb + "/wsCIPOL/wsCOA_ABMBase.asmx"

                  $node3 = $xdoc.SelectSingleNode("//applicationSettings/wsCipolServices.Properties.Settings")
                  $node3 = $xdoc.configuration.applicationSettings.SelectSingleNode("//wsCipolServices.Properties.Settings/setting[@name='wsCipolServices_Fachada_Seguridad_InicioSesion_Java_wsInicioSesion_Java']")
                  $node3.Value = "http://" + $Server + "/" + $NameWeb + "/wsCIPOL//wsInicioSesion_Java.asmx"

                  $node4 = $xdoc.SelectSingleNode("//applicationSettings/wsCipolServices.Properties.Settings")
                  $node4 = $xdoc.configuration.applicationSettings.SelectSingleNode("//wsCipolServices.Properties.Settings/setting[@name='wsCipolServices_Fachada_Seguridad_wsSeguridad']")
                  $node4.Value = "http://" + $Server + "/" + $NameWeb + "/wsCIPOL/wsSeguridad.asmx"

                  $node5 = $xdoc.SelectSingleNode("//applicationSettings/wsCipolServices.Properties.Settings")
                  $node5 = $xdoc.configuration.applicationSettings.SelectSingleNode("//wsCipolServices.Properties.Settings/setting[@name='wsCipolServices_Fachada_Seguridad_Downloader_wsSIRActualizaciones']")
                  $node5.Value = "http://" + $Server + "/" + $NameWeb + "/wsCIPOL/wsSIRActualizaciones.asmx"

                  $node6 = $xdoc.SelectSingleNode("//applicationSettings/wsCipolServices.Properties.Settings")
                  $node6 = $xdoc.configuration.applicationSettings.SelectSingleNode("//wsCipolServices.Properties.Settings/setting[@name='wsCipolServices_Fachada_Seguridad_CipolSupervision_wsCipolSupervision']")
                  $node6.Value = "http://" + $Server + "/" + $NameWeb + "/wsCIPOL/wsCipolSupervision.asmx"

                  $xdoc.Save($path)
              }
              TestScript =
              {
                  return $false
              }
          }

          Script ChangeConnectionStringSISTSEGURIDAD
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
                      $NameWeb = $using:Node.WebApplicationName
                      $path = "C:\inetpub\wwwroot\" + $NameWeb + "\SISTEMASEGURIDAD\Web.Config"
                      $SQL  = $using:Node.Instancia
                      $User = $using:Node.UserCipol
                      $Pass = $using:Node.PassCipol
                      $Server = $using:Node.NodeName

                      Write-Verbose $SQL
                      Write-Verbose $path

                      $xdoc = [xml] (Get-Content $path)

                      $node1 = $xdoc.SelectSingleNode("//applicationSettings/wsCipolServices.Properties.Settings")
                      $node1 = $xdoc.configuration.applicationSettings.SelectSingleNode("//wsCipolServices.Properties.Settings/setting[@name='wsCipolServices_Fachada_Seguridad_IniciarSesion_wsInicioSesion']")
                      $node1.Value = "http://" + $Server + "/" + $NameWeb + "/wsCIPOL/wsInicioSesion.asmx"

                      $node2 = $xdoc.SelectSingleNode("//applicationSettings/wsCipolServices.Properties.Settings")
                      $node2 = $xdoc.configuration.applicationSettings.SelectSingleNode("//wsCipolServices.Properties.Settings/setting[@name='wsCipolServices_Fachada_Seguridad_ABM_wsCOA_ABMBase']")
                      $node2.Value = "http://" + $Server + "/" + $NameWeb + "/wsCIPOL/wsCOA_ABMBase.asmx"

                      $node3 = $xdoc.SelectSingleNode("//applicationSettings/wsCipolServices.Properties.Settings")
                      $node3 = $xdoc.configuration.applicationSettings.SelectSingleNode("//wsCipolServices.Properties.Settings/setting[@name='wsCipolServices_Fachada_Seguridad_InicioSesion_Java_wsInicioSesion_Java']")
                      $node3.Value = "http://" + $Server + "/" + $NameWeb + "/wsCIPOL//wsInicioSesion_Java.asmx"

                      $node4 = $xdoc.SelectSingleNode("//applicationSettings/wsCipolServices.Properties.Settings")
                      $node4 = $xdoc.configuration.applicationSettings.SelectSingleNode("//wsCipolServices.Properties.Settings/setting[@name='wsCipolServices_Fachada_Seguridad_wsSeguridad']")
                      $node4.Value = "http://" + $Server + "/" + $NameWeb + "/wsCIPOL/wsSeguridad.asmx"

                      $node5 = $xdoc.SelectSingleNode("//applicationSettings/wsCipolServices.Properties.Settings")
                      $node5 = $xdoc.configuration.applicationSettings.SelectSingleNode("//wsCipolServices.Properties.Settings/setting[@name='wsCipolServices_Fachada_Seguridad_Downloader_wsSIRActualizaciones']")
                      $node5.Value = "http://" + $Server + "/" + $NameWeb + "/wsCIPOL/wsSIRActualizaciones.asmx"

                      $xdoc.Save($path)
                  }
                  TestScript =
                  {
                      return $false
                  }
              }
              File CipolCarpeta
              {
                  Ensure          = "Present"
                  DestinationPath = "C:\Cipol"
                  Type            = "Directory"
              }

              Script SCCrearconn {
                GetScript = {
                    #Do Nothing
                }

               SetScript = {
                  Write-Verbose -Message "Ejecuto crear conexión"
                  $CrearConn = "'" + $using:Path +  "\CrearConexion\CrearConexion.exe'"
                  $Arguments = "SQLServer xxx " + $using:Node.DBCipol + " " + $using:Node.UserCipol + " " + $using:Node.PassCipol + " '" + $using:Node.NodeName + "' '" + $using:Node.NodeName + "' Ingles Conexion 'C:\Cipol\Conexion.xml'"
                  Write-Verbose -Message ( $CrearConn + '  ' + $Arguments)
                  $CrearConexion = "& 'C:\Temp\01 - WebCipol Powershell\CrearConexion\CrearConexion.exe'" + $Arguments
                  $CrearConexion = "& " + $CrearConn + $Arguments
                  Invoke-Expression $CrearConexion

               }
               TestScript = {
                   # Valido si existe sino no creo nuevamente el archivo de conexión.
                   $existe = test-path 'C:\CIPOL\Conexion.xml'
                   return $existe
               }
            }
           }

}

$direccion = $pwd.path

ScriptTest -ConfigurationData '.\Configuracion.psd1' -Path $direccion -OutputPath '.\' -Verbose

# Hacemos un PUSH desde el Server:
Start-DscConfiguration -Path ".\" -Wait -Force -verbose

# Crear las fuentes de visor de eventos
if ([System.Diagnostics.EventLog]::SourceExists("WEBCIPOL") -eq $false) {
  [System.Diagnostics.EventLog]::CreateEventSource("INICIO", "WEBCIPOL")
  [System.Diagnostics.EventLog]::CreateEventSource("SISTEMASEGURIDAD", "WEBCIPOL")
  [System.Diagnostics.EventLog]::CreateEventSource("wsCipol", "WEBCIPOL")
}

PAUSE
