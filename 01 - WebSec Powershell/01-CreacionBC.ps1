Configuration ScriptTest
{
    param
    (
      # Target nodes to apply the configuration
      [Parameter(Mandatory)]
      [ValidateNotNullOrEmpty()]
      [string]$Path
    )

    $xWAInstall = $Path + "\DSC\xWebAdministration"
    Copy-Item -Path $xWAInstall -Destination "C:\Program Files\WindowsPowerShell\Modules" -Recurse -Force -Passthru

    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

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
                    $DBCipol = $using:Node.DBCipol
                    $UserCipol = $using:Node.UserCipol
                    $PassCipol = $using:Node.PassCipol
                    $AppWeb = $using:Node.WebApplicationName
                    $ServerIIS = $using:Node.NodeName
                    $path = $using:Path
                    #definimos el path con el nombre de cada script
                    $sql0 =  "CREATE DATABASE [" + $DBCipol + "]"
                    $sql1 =  $path + "\DBCIPOL\01 - ESTRUCTURA.sql"
                    $sql2 =  $path + "\DBCIPOL\02 - CIPOL - ImplementacionNET.sql"
                    $sql3a =  "CREATE LOGIN [" + $UserCipol + "] WITH PASSWORD=N'" + $PassCipol + "', DEFAULT_DATABASE=[" + $DBCipol + "], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=Off"
                    $sql3b =  "CREATE USER [" + $UserCipol + "] FOR LOGIN [" + $UserCipol + "] WITH DEFAULT_SCHEMA=[dbo] EXEC sp_addrolemember N'db_owner', N'" + $UserCipol + "'"
                    $sql4 =  $path + "\DBCIPOL\03 - dbo.sprecuperardatos.sql"
                    $sql5 = "UPDATE SE_SIST_HABILITADOS SET PAGINAPORDEFECTO = 'http://" + $ServerIIS + "/" + $AppWeb + "/SISTEMASEGURIDAD/frmInicio.aspx' WHERE IDSISTEMA = '1'"

                    #llamamos al metodo sqlcmd por cada script
                    sqlcmd.exe -S $Instancia -H $Server -E -d Master    -Q $sql0
                    sqlcmd.exe -S $Instancia -H $Server -E -d $DBCipol  -i $sql1
                    sqlcmd.exe -S $Instancia -H $Server -E -d $DBCipol  -i $sql2
                    sqlcmd.exe -S $Instancia -H $Server -E -d Master    -Q $sql3a
                    sqlcmd.exe -S $Instancia -H $Server -E -d $DBCipol  -Q $sql3b
                    sqlcmd.exe -S $Instancia -H $Server -E -d $DBCipol  -i $sql4
                    sqlcmd.exe -S $Instancia -H $Server -E -d $DBCipol  -Q $sql5
                }
                catch
                {
                    throw $_.Exception
                }
            }
            TestScript = {
              $Server = $using:Node.ServerSQL
              $Instancia = $using:Node.Instancia
              $DBCipol = $using:Node.DBCipol
              $Query = "IF DB_Id('" + $DBCipol + "') IS NOT NULL BEGIN PRINT 'TRUE' END ELSE BEGIN PRINT 'FALSE' END"
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
      }
}

$direccion = $pwd.path

ScriptTest -ConfigurationData '.\Configuracion.psd1' -Path $direccion -OutputPath '.\' -Verbose

# Hacemos un PUSH desde el Server:
Start-DscConfiguration -Path ".\" -Wait -Force -verbose

PAUSE
