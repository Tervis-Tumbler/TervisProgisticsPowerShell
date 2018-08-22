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
        [Parameter(ValueFromPipelineByPropertyName)]$Contact,
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
        [Parameter(ValueFromPipelineByPropertyName)]$Contact,
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
    $WCSShipDates = Get-WCSShipDate -EnvironmentName Production
    $ShipDate = $WCSShipDates |
    Where-Object {$Service -match $_.carrierId} |
    Select-Object -ExpandProperty shipDate

    New-ProgisticsPackageShipment @PSBoundParameters -Shipper "TERVIS" -Terms "SHIPPER" -CountryCode "US" -WeightUnit "LB" -Weight $WeightInLB -ShipDate $ShipDate
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
        [Parameter(Mandatory)]$Carrier,
        [Parameter(Mandatory)][int]$MSN,
        [Parameter(Mandatory)]$TrackingNumber,
        $Output
    )

    $Service = Find-ProgisticsPackage -carrier $Carrier -TrackingNumber $TrackingNumber |
    Select-Object -ExpandProperty ResultData |
    Select-Object -ExpandProperty ResultData |
    Select-Object -ExpandProperty Service

    $ServiceToStandardDocumentMap = @{
        "TANDATA_FEDEXFSMS.FEDEX.SP_PS" = "TANDATA_FEDEXFSMS_SP_LABEL.STANDARD"
        "CONNECTSHIP_ENDICIA.USPS.FIRST" = "CONNECTSHIP_ENDICIA_LABEL.STANDARD"
        "TANDATA_FEDEXFSMS.FEDEX.FHD" = "TANDATA_FEDEXFSMS_GROUNDLABEL.STANDARD"
    }

    Invoke-ProgisticsPackagePrint @PSBoundParameters -Document $ServiceToStandardDocumentMap.$Service -Shipper "TERVIS" -StockSymbol "THERMAL_LABEL_8" #"STANDARD_4_8_STOCK"
}