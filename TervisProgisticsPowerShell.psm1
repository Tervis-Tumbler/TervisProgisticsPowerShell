function Set-TervisProgisticsEnvironment {
    param (
        $Name
    )
    Get-TervisApplicationNode -ApplicationName Progistics -EnvironmentName $Name |
    Set-ProgisticsComputerName
}

function Test-TervisProgisticsPowershell {
    ipmo -force ProgisticsPowerShell, TervisProgisticsPowerShell
    Set-TervisProgisticsEnvironment -Name Delta
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

function Invoke-TervisProgisticsShip {
    param (
        $Company,
        $Address1,
        $Address2,
        $City,
        $StateProvince,
        $PostalCode,
        $Residential,
        $Phone,
        $service,
        $consigneeReference,
        $WeightInLBs
    )
    $ConsigneeParameters = $PSBoundParameters | 
    ConvertFrom-PSBoundParameters -ExcludeProperty WeightInLBs,consigneeReference,service -AsHashTable

    $ShipRequest = New-Object Progistics.ShipRequest -Property @{
        service = "TANDATA_FEDEXFSMS.FEDEX.SP_PS"
        defaults = New-Object Progistics.DataDictionary
        packages = [Progistics.DataDictionary[]]@(
            New-Object Progistics.DataDictionary -Property @{
                consignee = New-Object Progistics.NameAddress -Property (
                    $ConsigneeParameters + @{countryCode = "US"}
                )
                consigneeReference = $consigneeReference
                shipper = "TERVIS"
                terms = "SHIPPER"
                weight = New-Object Progistics.weight -Property @{
                    unit = "LB"
                    amount = $WeightInLBs
                }
                shipdate = (Get-Date)
            }
        )
    }
    
    Invoke-ProgisticsAPI -MethodName Ship -Parameter $ShipRequest
    #$Proxy = Get-ProgisticsWebServiceProxy
}

function Get-ReturnsShipmentService {
    param (
        $WeightInLB
    )
    if ($WeightInLB -lt 1) {
        "CONNECTSHIP_ENDICIA.USPS.FIRST"
    } elseif ($WeightInLB -ge 1 -and $WeightInLB -le 10) {
        "TANDATA_FEDEXFSMS.FEDEX.SP_STD"
    } elseif ($WeightInLB -gt 10) {
        "TANDATA_FEDEXFSMS.FEDEX.FHD"
    }

}

function Invoke-TervisProgisticsReturnsShip {
    param (
        $Company,
        $Address1,
        $Address2,
        $City,
        $StateProvince,
        $PostalCode,
        $Residential,
        $Phone,
        $WeightInLBs
    )
    $WeightrangeToCarrierAndServiceMapping = @{

    }
    Invoke-TervisProgisticsShip @PSBoundParameters -consigneeReference "TBSF-RETURNS"
}