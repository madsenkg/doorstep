$authSuccess = $false

$authurl = #"https://github.com/login/oauth/authorize"
"https://api.github.com/applications/F5d4c44488e5b956fd62/token"

$clientId = "F5d4c44488e5b956fd62"
$clientSecret = "29f0086f104508a031b0d7d9ff54e4d35870ccc2"

$authboundary = [System.Guid]::NewGuid().ToString()
$authLF = "`r`n"

$authbodyLines = (
    "--$authboundary",
    "Content-Disposition: form-data; name=`"client_id`"$authLF",
    $clientId,
    "--$authboundary",
    "Content-Disposition: form-data; name=`"client_secret`"$authLF",
    $clientSecret,
    "--$authboundary",
    "Content-Disposition: form-data; name=`"grant_type`"$authLF",
    "client_credentials",
    "--$authboundary--"
) -join $authLF

$authbodyLines

try {
    $tokenResponse = Invoke-WebRequest -Uri $authurl -Method Post -ContentType "multipart/form-data; boundary=$authboundary" -Body $authbodyLines
    $tokenResponseJSON = ConvertFrom-Json $tokenResponse.Content

    # Extract the token from the response
    $tokenBearer = $tokenResponseJSON.token_type
    $token = $tokenResponseJSON.access_token 
    $tokenBearer
    $authSuccess = $true

    "  Authorized. Token is: $token"
}
catch {
    
    $authSuccess = $false
    "  ERROR - Unable to get an access token."
}