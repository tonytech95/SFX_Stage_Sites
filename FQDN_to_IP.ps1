param (
    $hostnameFilePath = ".\hostnames.txt",
    $ipAddressFilePath = ".\ipaddresses.txt"
)

# Check to see if the ipaddresses.txt file exists; if not, create one with a carriage return.
if (!(Test-Path $ipAddressFilePath)) {
    New-Item -ItemType File -Path $ipAddressFilePath
    "`r" | Out-File -FilePath $ipAddressFilePath -Encoding ASCII -Append
}

# Read hostnames from the input file
$hostnames = @('exn-api3-stage.sfxresorts.net','exn-api3.sfxresorts.net','exn3-stage.sfxresorts.com','www-stage.vacationclix.com','www-stage.sfxresorts.com','members-stage.vacationclix.com','members3-stage.sfxresorts.com','exn3.sfxresorts.com','exn3-dev.sfxresorts.com')

# Initialize an array to store IP addresses
$ipAddresses = @()

Write-Host $hostnames

# Loop through each hostname, resolve its IP address, and add it to the array
foreach ($hostname in $hostnames) {
    $resolvedIPs = (Resolve-DnsName -Name $hostname -Type A).IPAddress
    foreach ($ip in $resolvedIPs) {
        if (![string]::IsNullOrWhiteSpace($ip)) {
            $ipAddresses += $ip
        }
    }
}

# Sort and deduplicate the IP addresses
$ipAddresses = $ipAddresses | Sort-Object | Get-Unique

Write-Host $ipAddresses

# Convert the IP addresses to a single string separated by newline
$ipAddressesString = $ipAddresses -join "`r`n"

# Save the sorted IP addresses to the temporary output text file
$ipAddressesString | Out-File -FilePath .\ipaddresses-tmp.txt -Encoding Ascii -Force

# Compare the current and previous IP addresses
$areDifferences = @(Compare-Object (Get-Content -Path $ipAddressFilePath) (Get-Content -Path .\ipaddresses-tmp.txt))

if ($areDifferences) {
    # Differences found. Update the main output text file.
    Move-Item -Path .\ipaddresses-tmp.txt -Destination $ipAddressFilePath -Force
    Write-Host "Differences found. IP addresses updated."
	
}
else {
    # No differences found. Clean up the temporary file.
    Remove-Item -Path .\ipaddresses-tmp.txt -Force
    Write-Host "No differences found. IP addresses unchanged."
}
