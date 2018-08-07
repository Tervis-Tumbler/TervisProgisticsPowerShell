Set-TervisProgisticsEnvironment -Name Production
Get-ProgisticsCarrier 
Get-ProgisticsShipper -carrier TANDATA_FEDEXFSMS.FEDEX
$Files = Get-ProgisticsShipFile -carrier TANDATA_FEDEXFSMS.FEDEX -shipper TERVIS
$Files[0].attributes.item

Find-ProgisticsPackage -carrier TANDATA_FEDEXFSMS.FEDEX -TrackingNumber 420296269261299994587628021155
Find-ProgisticsPackage -carrier TANDATA_FEDEXFSMS.FEDEX -TrackingNumber 9261299994587628021155


Set-TervisProgisticsEnvironment -Name Delta
Invoke-TervisProgisticsPrint -Carrier TANDATA_FEDEXFSMS.FEDEX -MSN 101320160 -Output png
Invoke-TervisProgisticsPrint -Carrier TANDATA_FEDEXFSMS.FEDEX -MSN 101320160 -Output Zebra.Zebra110XiIIIPlus
Invoke-TervisProgisticsPrint -Carrier TANDATA_FEDEXFSMS.FEDEX -MSN 101320160

$var.output.imageList.imageOutput | Set-Content out.png -Encoding Byte

$Data = [System.Text.Encoding]::ASCII.GetString($var.output.binaryOutput)


Set-TervisProgisticsEnvironment -Name Delta
$Response = Invoke-TervisProgisticsPrint -Carrier TANDATA_FEDEXFSMS.FEDEX -MSN 101320160 -Output Zebra.Zebra110XiIIIPlus
$Data = [System.Text.Encoding]::ASCII.GetString($Response.output.binaryOutput)
Send-PrinterData -Data $Data -ComputerName Cheers