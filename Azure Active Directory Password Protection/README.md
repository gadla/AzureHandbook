# Azure Active Directory Password Protection: A Comprehensive Guide

In today's digital world, ensuring the security of user accounts and credentials is of utmost importance for any organization. Traditional password policies have long been the backbone of account security. However, these policies often fall short when faced with the ingenuity of human creativity in choosing easily guessable or weak passwords. To address this, Microsoft introduced Azure Active Directory Password Protection, a feature that provides an additional layer of defense by preventing the use of weak and commonly used passwords.

Azure AD Password Protection helps you eliminate easily guessed passwords from your environment, which can dramatically lower the risk of being compromised by attackers. It uses a globally banned password list that Microsoft updates and a per-tenant custom list that you manage. The banned password lists are enforced by Azure AD when changing or resetting passwords and can also be used in your on-premises Windows Server Active Directory.

In this blog post, we will walk through the steps of installing, registering, and configuring Azure AD Password Protection. This guide is intended for IT administrators who have a good understanding of Azure Active Directory and on-premises Active Directory Domain Services.

Whether you're looking to enhance your organization's password security or just want to learn more about Azure AD Password Protection, this guide is for you. Let's dive in!

<br>
<br>


# How Azure Active Directory Password Protection Works

Azure Active Directory Password Protection enhances the standard Active Directory complexity rules by including a list of globally banned passwords. This list contains the most commonly used weak passwords and their variants, which are often targeted by attackers. These are the passwords that users are prohibited from selecting when they change or reset their password in Azure AD or Windows Server Active Directory (when Azure AD Password Protection is enabled).

Azure AD Password Protection uses two types of banned password lists:

1. **Global Banned Password List**: This list is maintained by Microsoft and is updated based on the most commonly seen weak passwords. It uses fuzzy matching techniques to catch character substitutions and small changes to commonly used weak passwords. This means passwords like "P@ssw0rd" and "Pa$$word1" would both be considered weak, as they are derived from the commonly used weak password "Password".

2. **Custom Banned Password List**: In addition to the global list, each organization can maintain its own custom list of banned words. This list can include words specific to the organization, such as the company name, products, or other related terms that would make a password guessable. 

The password protection works by normalizing the new password that a user attempts to set and comparing it against the banned password lists. The normalization process includes converting all characters to lowercase and removing common character substitutions (e.g., '0' for 'o', '$' for 's', etc.). If the normalized password matches a word on the banned password lists, the password change is rejected.

Azure AD Password Protection for Windows Server Active Directory works by deploying two types of agents in your on-premises environment:

1. **Azure AD Password Protection Proxy**: This agent is responsible for forwarding password validation requests from your on-premises Active Directory to Azure AD.

2. **Azure AD Password Protection DC Agent**: This agent runs on each domain controller and intercepts password set and reset attempts, forwarding them to Azure AD for validation via the Azure AD Password Protection Proxy.

Through this combination of globally banned passwords, customizable lists, and on-premises agents, Azure AD Password Protection provides a robust solution to prevent the use of weak and guessable passwords in your environment.

<br>
<br>

# Pre-requisites for Azure AD Password Protection

Before you begin the process of setting up Azure Active Directory Password Protection, there are a few requirements that you need to ensure are met in your environment. 

1. **.NET Framework 4.7.2 or later**: The Azure AD Password Protection agents require .NET Framework 4.7.2 or later to be installed on all domain controllers. The latest version of .NET Framework can be downloaded and installed from Microsoft's official website.

2. **DFSR for SYSVOL replication**: The Azure AD Password Protection DC Agent requires the Distributed File System Replication (DFSR) to be in use for SYSVOL replication in your domain. The older File Replication Service (FRS) for SYSVOL replication is not supported.

3. **User Account with Enterprise Admin Rights**: To install and configure the Azure AD Password Protection agents, you will need a user account with Enterprise Admin rights in your on-premises Active Directory environment.

4. **User Account with Global Admin Rights**: In order to register the Azure AD Password Protection agents with Azure AD, you will need a user account with Global Admin rights in your Azure AD tenant.

5. **Azure Active Directory P1 or P2 license**: Azure AD Password Protection is a premium feature and requires Azure Active Directory P1 or P2 license.

Please note that these are the basic requirements for setting up Azure AD Password Protection. Depending on your specific network setup and security configurations, additional considerations might need to be made. For instance, if your Azure AD Password Protection Proxy is behind an HTTP proxy, additional configuration steps will be necessary.

<br>
<br>


# Downloading the Azure AD Password Protection Agents

There are two types of agents that you need to download for Azure AD Password Protection: the Proxy Agent and the DC Agent. Here are the steps to download these agents:

1. **Azure AD Password Protection Proxy Agent**: This agent acts as the intermediary between your on-premises environment and Azure AD. It communicates with Azure AD to fetch the latest password policy and sends it to the DC Agent. You can download the Proxy Agent from the [Microsoft Download Center](https://www.microsoft.com/download/details.aspx?id=57071).

2. **Azure AD Password Protection DC Agent**: This agent resides on your domain controllers. It applies the password policy received from the Proxy Agent to password change and reset events in your on-premises Active Directory. The DC Agent can be downloaded from the [Microsoft Download Center](https://www.microsoft.com/download/details.aspx?id=57071).

Once you have downloaded the agents, the next steps are to install the Proxy Agent, register it with Azure AD, and then install and register the DC Agent. These steps will be discussed in the following sections.

<br>
<br>



# Installing and Registering the Azure AD Password Protection Proxy Agent

The Proxy Agent needs to be installed on a server in your on-premises environment that can communicate with both Azure AD and your domain controllers. Here are the steps to install and register the Proxy Agent:

1. **Installation**: Run the Proxy Agent installer that you downloaded in the previous step on your chosen server. During installation, you'll need to specify a service account that the Proxy Agent will use to communicate with Azure AD. This account needs to be a member of the local Administrators group on the server.

2. **Registration**: After installation, you'll need to register the Proxy Agent with Azure AD. Open a PowerShell prompt as an administrator and navigate to the directory where the Proxy Agent is installed (by default, this is `C:\Program Files\Microsoft Azure AD Connect Password Protection Proxy Service\`). Run the following command to register the Proxy Agent:

    ```powershell
    Register-AzureADPasswordProtectionProxy -AccountUpn <global-admin-upn> -AzureCredential
    ```
   Replace `<global-admin-upn>` with the User Principal Name (UPN) of a Global Administrator account in your Azure AD tenant. You'll be prompted to enter the password for this account.

3. **Testing**: To confirm that the Proxy Agent is working correctly, you can run the following PowerShell command:

    ```powershell
    Test-AzureADPasswordProtectionProxy -TestAll
    ```
   This command tests the connectivity between the Proxy Agent and Azure AD, and between the Proxy Agent and your domain controllers. If all tests pass, you're ready to proceed to the next step, which is registering your Active Directory forest.


    Remember to replace `<global-admin-upn>` with the actual User Principal Name of your Global Administrator account in Azure AD. The UPN is usually in the format `username@domain.com`.

    For more information about the Proxy Agent, refer to the [official documentation](https://docs.microsoft.com/en-us/azure/active-directory/authentication/howto-password-ban-bad-on-premises-deploy).


<br>
<br>


# Installing and Registering the Azure AD Password Protection Proxy Agent

The Proxy Agent needs to be installed on a server in your on-premises environment that can communicate with both Azure AD and your domain controllers. Here are the steps to install and register the Proxy Agent:

1. **Installation**: Run the Proxy Agent installer that you downloaded (AzureADPasswordProtectionProxySetup.exe) in the previous step on your chosen server. During installation, you'll need to specify a service account that the Proxy Agent will use to communicate with Azure AD. This account needs to be a member of the local Administrators group on the server.

    **Note** if you are working behind an **HTTP Proxy** you should make the following changes to the file `C:\Program Files\Azure AD Password Protection Proxy\Service\AzureADPasswordProtectionProxy.exe.config`:

    ```xml
    <configuration>
    <system.net>
        <defaultProxy enabled="true">
        <proxy bypassonlocal="true"
            proxyaddress="http://yourhttpproxy.com:8080" />
        </defaultProxy>
    </system.net>
    </configuration>
    ```

    If your HTTP proxy requires authentication, add the `useDefaultCredentials` attribute:
    ```xml
    <configuration>
    <system.net>
        <defaultProxy enabled="true" useDefaultCredentials="true">
        <proxy bypassonlocal="true"
            proxyaddress="http://yourhttpproxy.com:8080" />
        </defaultProxy>
    </system.net>
    </configuration>
    ```


    **Note** if you need to set the RPC Dynamic port range, you can do so by running the following command:

    ```powershell
    t-AzureADPasswordProtectionProxyConfiguration –StaticPort <portnumber>
    ```
<br>

2. **Registering your Azure AD Password Proxy Server**: The next step is to install the Azure AD Password Protection Proxy agent on a server that can communicate with both your on-premises Active Directory and the internet. After you install the Proxy agent, it needs to be registered with Azure AD. You can do this using one of three methods:

    a. **Interactive Authentication Mode**: This method prompts you for credentials during the registration process. It's a good option when you're manually registering the Proxy agent and have the necessary credentials at hand. Use the following PowerShell command:

    ```powershell
    Register-AzureADPasswordProtectionProxy -AccountUpn 'yourglobaladmin@yourtenant.onmicrosoft.com'
    ```

    b. **Device-code Authentication Mode**: This method generates a device code that you use to authenticate in a web browser. It's a useful option when you're running the registration command from a system where you can't perform interactive authentication. Use the following PowerShell command:

    ```powershell
    Register-AzureADPasswordProtectionProxy -AccountUpn 'yourglobaladmin@yourtenant.onmicrosoft.com' -AuthenticateUsingDeviceCode
    ```

    c. **Silent (Password-based) Authentication Mode**: This method uses a PowerShell credential object for authentication. It's a good option for scripted or automated deployments. Use the following PowerShell commands:

    ```powershell
    $globalAdminCredentials = Get-Credential
    Register-AzureADPasswordProtectionProxy -AzureCredential $globalAdminCredentials
    ```

    Remember to replace `'yourglobaladmin@yourtenant.onmicrosoft.com'` with your actual global admin user principal name.

<br>

3. **Registering the Forest and Testing**
Once the proxy agent has been successfully installed and registered, the next step is to register your forest with Azure AD Password Protection. There are three authentication modes that can be used to register your forest:

   a. **Interactive Authentication Mode** - This mode will prompt for credentials during the registration process. Use the following command to register your forest in this mode:

   ```powershell
   Register-AzureADPasswordProtectionForest -AccountUpn 'yourglobaladmin@yourtenant.onmicrosoft.com'
   ```

   b. **Device-code Authentication Mode** - In this mode, you will be provided with a code that needs to be entered on a web page for authentication. This is useful if the device where you're running the command doesn't support interactive login. Here's the command to register your forest using device-code authentication:

   ```powershell
   Register-AzureADPasswordProtectionForest -AccountUpn 'yourglobaladmin@yourtenant.onmicrosoft.com' -AuthenticateUsingDeviceCode
   ```

   c. **Silent (Password-based) Authentication Mode** - This mode allows for non-interactive registration using a PowerShell credential object. Use the following commands to register your forest in silent mode:

   ```powershell
   $globalAdminCredentials = Get-Credential
   Register-AzureADPasswordProtectionForest -AzureCredential $globalAdminCredentials
   ```

   
    Please note that the registration of the forest **must** be done with an account that has `Enterprise Admins` rights.

4. **Testing**: To confirm that the Proxy Agent is working correctly, you can run the following PowerShell command:

    ```powershell
    Test-AzureADPasswordProtectionProxyHealth -TestAll
    ```
   This command tests the connectivity between the Proxy Agent and Azure AD, and between the Proxy Agent and your domain controllers. If all tests pass, you're ready to proceed to the next step, which is registering your Active Directory forest.

    Your output should look like this:

    ```powershell
    PS C:\Users\Administrator.CONTOSO> Test-AzureADPasswordProtectionProxyHealth -TestAll

    DiagnosticName          Result AdditionalInfo
    --------------          ------ --------------
    VerifyTLSConfiguration  Passed
    VerifyProxyRegistration Passed
    VerifyAzureConnectivity Passed
    ```

<br>
<br>
  
# **Installing the DC Agent (Including Windows Server Core)**
The Domain Controller (DC) agent is a crucial component of Azure AD Password Protection. It enables Azure AD Password Protection to function and enforce Azure AD password policies at the domain controller level. The DC agent can be installed on all versions of Windows Server that are currently supported by Microsoft, including Windows Server Core editions.

1. **Download the DC Agent Installer** - The DC agent installer can be downloaded from the Azure AD Password Protection portal in Azure.

2. **Run the Installer** - Once the installer has been downloaded, run it on your domain controller. The installer will guide you through the steps necessary to install the DC agent.

3. **Configuration** - After installation, the DC agent does not require any additional configuration. It will automatically begin enforcing Azure AD password policies.

4. **Installation on Windows Server Core** - The process to install the DC agent on Windows Server Core is the same as on other versions of Windows Server. However, since Windows Server Core does not have a traditional GUI, the installer must be run from a command prompt.
    ```powershell
    msiexec.exe /i "AzureADPasswordProtectionDCAgentSetup.msi" /l*v "install.log"

    ```
    Check the install.log file for any errors.


    Please note, it is `recommended` to install the DC agent on `all domain controllers in your forest`. This ensures that Azure AD password policies are enforced consistently across your entire Active Directory environment.

5. **Verification** - You can verify the installation of the DC agent by running the command. If all tests pass, the DC agent is installed and functioning correctly.
    ```powershell
    Test-AzureADPasswordProtectionDCAgentHealth -TestAll

    DiagnosticName             Result AdditionalInfo
    --------------             ------ --------------
    VerifyPasswordFilterDll    Passed
    VerifyForestRegistration   Passed
    VerifyEncryptionDecryption Passed
    VerifyDomainIsUsingDFSR    Passed
    VerifyAzureConnectivity    Passed
    ``` 
<br>
<br>

# **Setting Up Azure AD Password Protection Policies and Parameters**

Azure AD Password Protection configuration involves customizing the password policy settings and managing banned password lists. Here are the steps to do it:
1. **Log in to the Azure Portal**: Log into the Azure portal using your Azure AD global admin account or a privileged role that has been granted access to Azure AD Password Protection.

2. **Navigate to Password Protection Settings**: In the left-side navigation pane, go to "Azure Active Directory" > "Security" > "Authentication methods" > "Password protection".

3. **Configure Settings**: Here, you can adjust the settings according to your organization's requirements. Options include:

    - **Mode**: This is where you can set the enforcement   mode to "Enforced" or "Audit". The "Enforced" mode    will prevent users from choosing banned passwords,     while "Audit" mode will allow it but will log an    event each time it happens.

    - **Custom Smart Lockout**: Configure the number of     failed sign-in attempts that will trigger a lockout     and the duration of the lockout.

    - **Custom Banned Password List**: Here, you can add    any words that you specifically want to ban in your    organization, separate each word with a comma. These   words will be considered by the Azure AD Password     Protection service in addition to Microsoft's global    banned password list.

4. **Save Changes**: Once you've made the necessary changes, click "Save" at the top of the page to apply them.

Remember, any changes made here will apply to all users in your Azure AD tenant and can take up to 1 hour to propagate to all domain controllers. 

<br>
<br>

## Customizing and Understanding the Limitations of the Banned Password List

Azure AD Password Protection enables you to customize a list of banned passwords that would be blocked in your organization. These are the passwords that you deem too easy to guess or are commonly used, thus, providing a potential vector for attacks.

Here's how you can set up a custom banned password list:

1. Navigate to the Azure AD portal, and then go to the "Password protection" section.
2. In the "Custom banned password" section, you can input the words that you want to ban. 

Please note the following considerations while configuring your custom banned password list:

- You can provide up to 1000 words for your custom list.
- In the Custom banned password list section, enter the words you want to ban. Note that the words are not case sensitive and should be separated by commas.
- Each banned password should have at least 4 characters.
- The banned password list is not case-sensitive. Therefore, it does not matter if the passwords are input in uppercase or lowercase.
- Special characters are not recognized. Therefore, if you input a password with special characters in the banned list, the special characters would be ignored.
- Azure AD Password Protection doesn't support the use of regular expressions. This means that wildcard characters or pattern matching symbols cannot be used.
- The banned password list applies to all users in your organization, including administrators.

Remember, creating a robust banned password list is part of a larger strategy for maintaining strong security in your organization. It is also essential to educate your users about good password practices, such as not using easily guessable information (like birthdays or names) and encouraging the use of password managers. 

<br>
<br>

# Monitoring and Reporting
Once Azure AD Password Protection is in place, it's crucial to monitor its operation and generate reports to assess its effectiveness. Fortunately, the solution comes with built-in tools that provide visibility into how it's performing and whether any issues need to be addressed.

Here's how you can monitor Azure AD Password Protection:

Azure AD Audit Logs: These logs include entries whenever a password change or reset event occurs. You can filter the logs to find events that were rejected due to the use of a banned password. The logs can be accessed from the Azure portal by navigating to Azure Active Directory > Monitoring > Audit logs.

Domain Controller Agent Events: The Domain Controller agent generates Windows Event Log entries for every password validation attempt. You can use these entries to understand why certain passwords are being rejected.

Azure AD Password Protection Proxy Service Logs: These logs provide information about the service's operation, including communication with Azure AD. They can be used to troubleshoot connectivity issues.

For reporting, you can use Azure Monitor and Azure AD's built-in reporting capabilities. This includes the ability to create custom dashboards, alerts, and automated responses based on specific events or conditions.

Make sure to regularly review these logs and reports to ensure Azure AD Password Protection is working as expected and to identify any potential issues that need to be addressed.

<br>
<br>

# Conclusion
Implementing Azure AD Password Protection enhances the security of both cloud and on-premises resources by enforcing robust password policies consistent with best practices. It integrates seamlessly with existing infrastructure like Windows Server and Azure AD, and is even more powerful when deployed in conjunction with solutions like Azure Arc-enabled servers and services.

Azure AD Password Protection is part of a broader security strategy that should also include comprehensive measures such as multi-factor authentication, regular audits, user education, and more. These strategies, when deployed together, can significantly reduce the risk of password-related security incidents and strengthen your overall security posture.

It's also worth noting that the integration of Azure AD Password Protection with Azure Arc-enabled servers provides additional benefits in terms of centralized management and visibility across hybrid environments. We will be delving deeper into this topic in an upcoming blog post about Azure Arc-enabled servers and services, so stay tuned for that.

Thank you for following this guide, and here's to a more secure future!