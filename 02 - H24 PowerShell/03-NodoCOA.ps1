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
				# Autenticación HTTP
        WindowsFeature HTTPActivation
        {
            Ensure    = "Present"
            Name      = "AS-HTTP-Activation"
						DependsOn = "[WindowsFeature]IIS"
        }



		# ------------------------------- FIN ADD WINDOWS FEATURES -----------------------------------------------

        # Copy the website content
        File WebContent
        {
            Ensure          = "Present"
            SourcePath      = $Path + $Node.SourcePathNC
            DestinationPath = $Node.DestinationPathNC
            Recurse         = $true
            Type            = "Directory"
            DependsOn       = "[WindowsFeature]AspNet45"
        }      

        # Create a Web Application Pool
		# Ejemplos: https://msconfiggallery.cloudapp.net/packages/xWebAdministration/1.15.0.0/Content/Examples%5CSample_xWebAppPool.ps1
        xWebAppPool NewWebAppPool
        {
            Name   = $Node.WebAppPoolNameNC
            Ensure = "Present"
            State  = "Started"
	      		managedRuntimeVersion = "v4.0"
	      		identityType  = "LocalSystem"
	      		managedPipelineMode  = "Integrated"
	      		pingingEnabled = $true
	      		pingInterval = (New-TimeSpan -Seconds 20).ToString()
	      		restartSchedule  = @("04:00:00")
	      		idleTimeout = (New-TimeSpan -Minutes 1440).ToString()
	      		pingResponseTime = (New-TimeSpan -Seconds 120).ToString()
        }

				xWebsite NewWebsite
        {
            Ensure          = "Present"
            Name            = $Node.WebApplicationNameNC
            State           = "Started"
            PhysicalPath    = $Node.DestinationPathNC
            BindingInfo     = @(
                MSFT_xWebBindingInformation
                {
                    Protocol = "HTTP"
                    Port     = $Node.PuertoNC
                }
            )
            DependsOn       = "[File]WebContent"
        }

        #Create a new Web Application
        xWebApplication NewWebApplication
        {
            Name = $Node.WebApplicationNameNC
            Website = $Node.WebApplicationNameNC
            WebAppPool =  $Node.WebAppPoolNameNC
            PhysicalPath = $Node.DestinationPathNC 
            Ensure = "Present"
            DependsOn = @("[File]WebContent")
        }


        Script ChangeConnectionString
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
                  $NameWeb = $using:Node.DBICF
                  $path = "C:\COA.WcfValidationLibrary\Web.Config"
                  $SQL  = $using:Node.Instancia
                  $User = $using:Node.UserICF
                  $Pass = $using:Node.PassICF

                  Write-Verbose $SQL
                  Write-Verbose $path

                  $xdoc = [xml] (Get-Content $path)
                  $node = $xdoc.SelectSingleNode("//connectionStrings/add[@name='MulticanalEntities']")
                  $node.Attributes["connectionString"].Value = "metadata=res://*/ModelMulticanal.csdl|res://*/ModelMulticanal.ssdl|res://*/ModelMulticanal.msl;provider=System.Data.SqlClient;provider connection string=Data Source=" + $SQL + ";Initial Catalog=" + $NameWeb +";User Id=" + $User + ";Password=" + $Pass + ";MultipleActiveResultSets=True;Application Name=EntityFramework"
                  $xdoc.Save($path)
              }
              TestScript =
              {
                  return $false
              }
        }
    }
}

$direccion = $pwd.path

ScriptTest -ConfigurationData '.\Configuracion.psd1' -Path $direccion -OutputPath '.\' -Verbose

# Hacemos un PUSH desde el Server:
Start-DscConfiguration -Path ".\" -Wait -Force -verbose

PAUSE
