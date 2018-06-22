function Set-TervisProgisticsEnvironment {
    param (
        $EnvironmentName
    )
    Get-TervisApplicationNode -ApplicationName Progistics -EnvironmentName $EnvironmentName |
    Set-ProgisticsComputerName
}

function Test-TervisProgisticsPowershell {
    ipmo -force ProgisticsPowerShell, TervisProgisticsPowerShell
    Set-TervisProgisticsEnvironment -EnvironmentName Delta
}

function Test-ProgisticsAPI {
    #https://connectship.com/docs/SDK/?topic=Using_AMP/Using_AMP.htm
    $Proxy = New-WebServiceProxy -Uri http://dlt-progis01/amp/wsdl -Class Progistics -Namespace Progistics
    $Proxy | gm | where name -eq ListCountries | fL
    $Proxy.ListCountries()
    $proxy.BeginListCountries()
    $Request = New-Object Progistics.ListCountriesRequest
    $Request.preProcess = "core"
    $Request.postProcess = "core"

    $Proxy.ListCountries($Request)

    $Proxy | gm | where name -eq ListUnits | fL
    #https://connectship.com/docs/SDK/Technical_Reference/AMP_Reference/Core_Messages/Message_Elements/listUnitsRequest.htm
    $Request = New-Object Progistics.ListUnitsRequest
    $Request.preProcess = "core"
    $Request.postProcess = "core"
    $Proxy.ListUnits($Request)

    get-service -ComputerName dlt-progis01 | where displayname -Match progis
    get-service -ComputerName dlt-progis01 -Name AMPService | Restart-Service
    
    $Request = New-Object Progistics.ListDocumentsRequest
    $Request.carrier = 'CONNECTSHIP_UPS.UPS'
    $Result = $Proxy.ListDocuments($Request)
    $Result.result.resultData
    
    
    $Result = $Proxy.ListCarriers((New-Object Progistics.ListCarriersRequest))
    $Result.result.resultData
}

