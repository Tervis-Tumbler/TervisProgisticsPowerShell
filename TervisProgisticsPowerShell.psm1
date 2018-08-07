function Set-TervisProgisticsEnvironment {
    param (
        $Name
    )
    Get-TervisApplicationNode -ApplicationName Progistics -EnvironmentName $Name |
    Set-ProgisticsComputerName
}

function New-TervisProgisticsPackageShipmentWarrantyOrder {
    param (
        [Parameter(ValueFromPipelineByPropertyName)]$Company,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory)]$Address1,
        [Parameter(ValueFromPipelineByPropertyName)]$Address2,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory)]$City,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory)]$StateProvince,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory)]$PostalCode,
        [Parameter(ValueFromPipelineByPropertyName)]$Residential,
        [Parameter(ValueFromPipelineByPropertyName)]$Phone,
        [Parameter(Mandatory)]$WeightInLB
    )
    $Service = Get-TervisProgisticsPackageWarrantyOrderService -WeightInLB $WeightInLB
    New-TervisProgisticsPackageShipment @PSBoundParameters -consigneeReference "TBSF-RETURNS" -service $Service
}

function New-TervisProgisticsPackageShipment {
    param (
        [Parameter(ValueFromPipelineByPropertyName)]$Company,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory)]$Address1,
        [Parameter(ValueFromPipelineByPropertyName)]$Address2,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory)]$City,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory)]$StateProvince,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory)]$PostalCode,
        [Parameter(ValueFromPipelineByPropertyName)]$Residential,
        [Parameter(ValueFromPipelineByPropertyName)]$Phone,
        [Parameter(Mandatory)]$WeightInLB,
        $consigneeReference,
        $Service
    )
    $PSBoundParameters.Remove("WeightInLB") | Out-Null
    New-ProgisticsPackageShipment @PSBoundParameters -Shipper "TERVIS" -Terms "SHIPPER" -CountryCode "US" -WeightUnit "LB" -Weight $WeightInLB -ShipDate (Get-Date)
}

function Get-TervisProgisticsPackageWarrantyOrderService {
    param (
        $WeightInLB
    )
    if ($WeightInLB -lt 1) {
        "CONNECTSHIP_ENDICIA.USPS.FIRST"
    } elseif ($WeightInLB -ge 1 -and $WeightInLB -le 10) {
        "TANDATA_FEDEXFSMS.FEDEX.SP_PS"
    } elseif ($WeightInLB -gt 10) {
        "TANDATA_FEDEXFSMS.FEDEX.FHD"
    }
}


function Invoke-TervisProgisticsPackagePrintWarrantyOrder {
    param (
        $Carrier,
        [int]$MSN,
        $Output
    )
    $CarrierToStandardDocumentMap = @{
        "TANDATA_FEDEXFSMS.FEDEX" = "TANDATA_FEDEXFSMS_SP_LABEL.STANDARD"
        "CONNECTSHIP_ENDICIA.USPS" = "CONNECTSHIP_ENDICIA_LABEL.STANDARD"
    }

    Invoke-ProgisticsPackagePrint @PSBoundParameters -Document $CarrierToStandardDocumentMap.$Carrier -Shipper "TERVIS" -StockSymbol "THERMAL_LABEL_8" #"STANDARD_4_8_STOCK"
}