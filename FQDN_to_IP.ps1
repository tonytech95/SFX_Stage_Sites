param (
    $hostnameFilePath = ".\hostnames.txt",
    $ipAddressFilePath = ".\ipaddresses.txt"
)

# Read hostnames from the input file
$hostnames = @('exn-api3-stage.sfxresorts.net','exn-api3.sfxresorts.net','exn3-stage.sfxresorts.com','www-stage.vacationclix.com','www-stage.sfxresorts.com','members-stage.vacationclix.com','members3-stage.sfxresorts.com','exn3.sfxresorts.com','exn3-dev.sfxresorts.com')

# Initialize an array to store IP addresses
$ipAddresses = @()

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


# Convert the IP addresses to a single string separated by newline
$ipAddressesString = $ipAddresses -join "`r`n"


# Get current Time
$checktime = Get-Date

# Update Github Gist
$headers = @{
    "Accept" = "application/vnd.github+json"
    "Authorization" = "Bearer `$`{`{ GitHub.token `}`}"
    "X-GitHub-Api-Version" = "2022-11-28"
}
Invoke-RestMethod -Uri "https://api.github.com/gists/b8915f9d80a866f6c53c6323e978ab7e" `
    -Method Patch `
    -Headers $headers `
    -ContentType "application/x-www-form-urlencoded" `
    -Body "{`"description`":`"Last Check time: $checktime`",`"files`":{`"README.md`":{`"content`":`"$ipAddressesString`"}}}"