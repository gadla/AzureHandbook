function Get-AzureKeyVaultSecret {

    <#
    .SYNOPSIS
        Retrieves a secret from an Azure Key Vault.

    .DESCRIPTION
        This function retrieves a secret from an Azure Key Vault. The secret can be returned as either a SecureString or a plain text string.

    .PARAMETER vaultName
        The name of the Azure Key Vault.

    .PARAMETER secretName
        The name of the secret to retrieve.

    .PARAMETER asString
        If specified, the secret will be returned as a plain text string. Otherwise, it will be returned as a SecureString.

    .EXAMPLE
        PS C:\> Get-AzureKVSecret -vaultName "myVault" -secretName "mySecret"
        This command retrieves the secret named "mySecret" from the Azure Key Vault named "myVault". The secret is returned as a SecureString.

    .EXAMPLE
        PS C:\> Get-AzureKVSecret -vaultName "myVault" -secretName "mySecret" -asString
        This command retrieves the secret named "mySecret" from the Azure Key Vault named "myVault". The secret is returned as a plain text string.

    .LINK
        For more information about how to use this function, see the online help: https://github.com/gadla/AzureHandbook/tree/main/Azure%20Key%20Va lt
    #>


    [CmdletBinding(PositionalBinding=$false)]
    param(
        [Parameter(Mandatory=$true)]
        [string]$VaultName,

        [Parameter(Mandatory=$true)]
        [string]$SecretName,

        [Parameter(Mandatory=$false)]
        [switch]$AsString
    )

    # Verifying that the Azure PowerShell module is installed. 
    $ModuleName = "Az"
    $InstalledModule = Get-InstalledModule -Name $ModuleName -ErrorAction SilentlyContinue
    if (-not($installedModule)) {
        Write-Host "The '$ModuleName' module is not installed."
        write-host "Please install it from the PowerShell Gallery: https://www.powershellgallery.com/packages/Az/."
        Write-Host "You can install it by running the following command: Install-Module -Name Az -AllowClobber -Scope CurrentUser"
        throw "The $ModuleName module is not installed. Please install it from the PowerShell Gallery: https://www.powershellgallery.com/packages/Az/."
    }


    # Verifying the Azure connectivity status within the PowerShell environment.
    $AzContext = Get-AzContext -ErrorAction SilentlyContinue
    if ($AzContext) {
        Write-Verbose "Connected to Azure with context: $($AzContext.Subscription.Name)"
    } else {
        Write-Host "Not connected to Azure."
        throw "You are not connected to Azure. Please connect to Azure using the Connect-AzAccount cmdlet."
    }

    # Check if the Key Vault exists
    Write-Host "Checking if Key Vault $VaultName exists."
    $keyVault = Get-AzKeyVault -VaultName $VaultName -ErrorAction SilentlyContinue

    if ($null -eq $keyVault) {
        Write-Host "Key Vault $VaultName was not found. Please ensure the specified Key Vault name is correct, and that you have the necessary permissions to access it. If the Key Vault does not exist, you can create it using the Azure portal or Azure PowerShell."
        throw "Key Vault $VaultName was not found. Please ensure the specified Key Vault name is correct, and that you have the necessary permissions to access it. If the Key Vault does not exist, you can create it using the Azure portal or Azure PowerShell."
    }

    
    # Check if the secret exists
    Write-Host "Checking if secret $secretName exists in Key Vault $VaultName."
    $secret = Get-AzKeyVaultSecret -VaultName $VaultName -Name $SecretName -ErrorAction SilentlyContinue

    if ($null -eq $secret) {
        Write-Host "Secret $SecretName does not exist in Key Vault $VaultName."
        throw "Secret $SecretName does not exist in Key Vault $VaultName."
    }

    if ($asString) {
        # Convert the secret to a plain text string and return it
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue)
        $plainTextSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        Write-Output $plainTextSecret
    } else {
        # Return the secret as a SecureString
        Write-Output $secret.SecretValue
    }
}


#Use this command line inorder to get the secret in removed state
Get-AzKeyVaultSecret -VaultName 'YourVaultName' -InRemovedState
#Use this command line inorder to recover the secret
undo-azkeyvaultsecretRemoval -VaultName 'YourVaultName' -Name 'YourDeletedSecretName'

# Use this KUSTO query to get the history of SecretGet operations
# This example is from https://learn.microsoft.com/en-us/azure/key-vault/general/monitor-key-vault#sample-kusto-queries
# Remember to remove the # from the beginning of each line

# AzureDiagnostics
# | where TimeGenerated > ago(90d) 
# | where ResourceProvider =="MICROSOFT.KEYVAULT" 
# | where OperationName == "SecretGet"
# | where requestUri_s contains "Yoav"
