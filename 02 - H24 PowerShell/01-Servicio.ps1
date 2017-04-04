

configuration EjemploMSI
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

  # Import the module that defines custom resources
  Import-DscResource -ModuleName PSDesiredStateConfiguration

  # Dynamically find the applicable nodes from configuration data
  # Node $AllNodes.where{$_.Role -eq "Web"}.NodeName
	Node $AllNodes.NodeName
    {

  Script UnistallService
  {
      GetScript = {
                    @{
                        GetScript = $GetScript
                        SetScript = $SetScript
                        TestScript = $TestScript
                        Result = $True
                    }
      }

      SetScript = {
                try {
                        $Programa = Get-WmiObject -Class Win32_Product -Filter "Name = 'ICF24Sercice.Setup'"
                        $Programa.Uninstall()
                    }
                catch
                    {
                        throw $_.Exception
                    }
       }

       TestScript = {
                try {
                        $Programa = Get-WmiObject -Class Win32_Product -Filter "Name = 'ICF24Sercice.Setup'"
                    }
                catch
                    {
                        throw $_.Exception
                    }

                if (!$Program) {
                    return $true
                }else {
                    return $false
                }
       }
    }
    File CarpetaInstaladora {
            Ensure          = "Present"
            Type            = 'Directory'
            DestinationPath = $Path + $Node.CarpetaInstall
        }

    Package PackageInstall
        {

            Ensure      = "Present"
            Path        = $Path + $Node.CarpetaInstall + $Node.ExeICF
            Name        = "ICF24Sercice.Setup"
            ProductId   = "{852BCBA9-74ED-468B-8F32-C75DDCEACF2D}"
            DependsOn   = "[File]CarpetaInstaladora"
        }
    }
}


$direccion = $pwd.path

EjemploMSI -ConfigurationData '.\Configuracion.psd1' -Path $direccion -OutputPath '.\' -Verbose

# APLICAR CONFIGURACION

# Pruebo hacer PUSH desde mi Workstation:
Start-DscConfiguration -Path ".\" -Wait -verbose -Force
PAUSE
