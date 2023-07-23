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

    param(
        [Parameter(Mandatory=$true)]
        [string]$vaultName,

        [Parameter(Mandatory=$true)]
        [string]$secretName,

        [Parameter(Mandatory=$false)]
        [switch]$asString
    )

    # Check if the Key Vault exists
    $keyVault = Get-AzKeyVault -VaultName $vaultName -ErrorAction SilentlyContinue

    if ($null -eq $keyVault) {
        Write-Error "Key Vault $vaultName does not exist."
        return
    }

    
    # Check if the secret exists
    $secret = Get-AzKeyVaultSecret -VaultName $vaultName -Name $secretName -ErrorAction SilentlyContinue

    if ($null -eq $secret) {
        Write-Error "Secret $secretName does not exist in Key Vault $vaultName."
        return $null
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
