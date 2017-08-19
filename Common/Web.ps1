
Function Web-Download
{
    PARAM(
        [string]$Url,
        [string]$Target
    )
    try
    {
        Invoke-WebRequest -Uri $Url -OutFile $Target
    }
    catch
    {
        Write-Output $_.Exception.Message
        return $false
    }
    return $true
}