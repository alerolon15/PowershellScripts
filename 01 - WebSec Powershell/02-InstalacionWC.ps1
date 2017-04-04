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
    Import-DscResource -Module xWebAdministration -ModuleVersion '1.17.0.1'

    Node $AllNodes.NodeName {

      Script InstalarWebCipol {

        GetScript = {
              @{
                  GetScript = $GetScript
                  SetScript = $SetScript
                  TestScript = $TestScript
                  Result = $True
              }
          }
        SetScript = {
          $SoN = $Using:Node.InstalarWebCipol
          If ($SoN -Eq "S")
          {
            Write-Verbose "InstalarWebCipol = 'S'"
            Write-Verbose "Proceso para Crear WEB, IIS"
          }ELSE {
            Write-Verbose "InstalarWebCipol = 'N'"
            Write-Verbose "No se Crea WEB ni AplicationPool, se especifico en Configuracion.psd1 que no se realice la instalacion"
          }
        }
        TestScript = {
          return $false
        }
    }


    # Solo Se ejecuta el resto del Script si en la configuracion seteamos InstalarICF24 con "S"
    If ($Node.InstalarWebCipol -Eq "S")
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

        xWebApplication NewWebApplication
        {

            Name = $Node.WebApplicationName
            Website = "Default Web Site"
            WebAppPool =  $Node.WebAppPoolName
            PhysicalPath = $Node.DestinationPath 
            Ensure = "Present"
            DependsOn = @("[xWebSite]DefaultWebSite","[File]WebContent")
        }

        xWebApplication WebApplicationSISTSEGURIDAD
        {
            Name = "SISTEMASEGURIDAD"
            Website = "Default Web Site\" + $Node.WebApplicationName + "\"
            WebAppPool =  $Node.WebAppPoolName
            PhysicalPath = "C:\inetpub\wwwroot\" + $Node.WebApplicationName + "\SISTEMASEGURIDAD"
            Ensure = "Present"
            DependsOn = @("[xWebSite]DefaultWebSite","[File]WebContent")
            #DependsOn = @("[xWebApplication]NewWebApplication")
        }
	xWebApplication WebApplicationWEBCIPOL
        {
            Name = "WEBCIPOL"
            Website = "Default Web Site\" + $Node.WebApplicationName + "\"
            WebAppPool =  $Node.WebAppPoolName
            PhysicalPath = "C:\inetpub\wwwroot\" + $Node.WebApplicationName + "\WEBCIPOL"
            Ensure = "Present"
            DependsOn = @("[xWebSite]DefaultWebSite","[File]WebContent")
            #DependsOn = @("[xWebApplication]NewWebApplication")
        }
	xWebApplication WebApplicationWSCIPOL
        {
            Name = "wsCipol"
            Website = "Default Web Site\" + $Node.WebApplicationName + "\"
            WebAppPool =  $Node.WebAppPoolName
            PhysicalPath = "C:\inetpub\wwwroot\" + $Node.WebApplicationName + "\wsCipol"
            Ensure = "Present"
            DependsOn = @("[xWebSite]DefaultWebSite","[File]WebContent")
            #DependsOn = @("[xWebApplication]NewWebApplication")

        }

    }
  }
}

$direccion = $pwd.path

ScriptTest -ConfigurationData '.\Configuracion.psd1' -Path $direccion -OutputPath '.\' -Verbose 

# Hacemos un PUSH desde el Server:
Start-DscConfiguration -Path ".\" -Wait -Force -verbose 

PAUSE
