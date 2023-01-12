
# Lab - Configure Conditional Access policies for WVD (AD DS)
# Student lab manual

## Lab dependencies

- An Azure subscription
- A Microsoft account or an Azure AD account with the Global Administrator role in the Azure AD tenant associated with the Azure subscription and with the Owner or Contributor role in the Azure subscription
- The completed lab **Prepare for deployment of Azure Virtual Desktop (AD DS)**
- The completed lab **Deploy host pools and session hosts by using the Azure portal (AD DS)**

## Estimated Time

60 minutes

## Lab scenario

You need to control access to a deployment of Azure Virtual Desktop in an Active Directory Domain Services (AD DS) environment by using Azure Active Directory (Azure AD) conditional access.

## Objectives
  
After completing this lab, you will be able to:

- Prepare for Azure Active Directory (Azure AD)-based Conditional Access for Azure Virtual Desktop
- Implement Azure AD-based Conditional Access for Azure Virtual Desktop

## Lab files

- None 

## Instructions

### Exercise 0: Prerequisite - Setup Azure AD Connect
1. From your lab computer, start a web browser, navigate to the [Azure portal]( ), and sign in by providing credentials of a user account with the Owner role in the subscription you will be using in this lab.
2. In the Azure portal, search for and select **Virtual machines** and, from the **Virtual machines** blade, select **az140-dc-vm11**.
3. On the **az140-dc-vm11** blade, select **Connect**, in the drop-down menu, select **Bastion**, on the **Bastion** tab of the **az140-dc-vm11 \| Connect** blade, select **Use Bastion**.
4. When prompted, provide the following credentials and select **Connect**:

   |Setting|Value|
   |---|---|
   |User Name|**Student**|
   |Password|**Pa55w.rd1234**|

  > **Note**: On clicking **Connect**, if you encounter an error **A popup blocker is preventing new window from opening. Please allow popups and retry**, then select the popup blocker icon at the top, select **Always allow pop-ups and redirects from https://portal.azure.com** and click on **Done**, and try connecting to the VM again.
  
  > **Note**: If you are prompted **See text and images copied to the clipboard**, select **Allow**. 

5. Once logged in, a logon task will start executing. When prompted **Do you want PowerShell to install and import the Nuget provider now?** enter **Y** and hit enter.
   > **Note**: Wait for the logon task to complete and present you with **Microsoft Azure Active Directory Connect** wizard. This should take about 10 minutes. If the **Microsoft Azure Active Directory Connect** wizard is not presented to you after the logon task completes, then launch it manually by double clicking the **Azure AD Connect** icon on the desktop.


6. On the **Welcome to Azure AD Connect** page of the **Microsoft Azure Active Directory Connect** wizard, select the checkbox **I agree to the license terms and privacy notice** and select **Continue**.
7. On the **Express Settings** page of the **Microsoft Azure Active Directory Connect** wizard, select the **Customize** option.
8. On the **Install required components** page, leave all optional configuration options deselected and select **Install**.
9. On the **User sign-in** page, ensure that only the **Password Hash Synchronization** is enabled and select **Next**.
10. On the **Connect to Azure AD** page, authenticate by using the credentials of the **aadsyncuser** user account you created in the previous exercise and select **Next**. 

   > **Note**: Provide the userPrincipalName attribute of the **aadsyncuser** account available in the **LabValues** text file present on desktop and specify the password **Pa55w.rd1234**.

11. On the **Connect your directories** page, select the **Add Directory** button to the right of the **adatum.com** forest entry.
12. In the **AD forest account** window, ensure that the option to **Create new AD account** is selected, specify the following credentials, and select **OK**:

   |Setting|Value|
   |---|---|
   |User Name|**ADATUM\Student**|
   |Password|**Pa55w.rd1234**|

13. Back on the **Connect your directories** page, ensure that the **adatum.com** entry appears as a configured directory and select **Next**
14. On the **Azure AD sign-in configuration** page, note the warning stating **Users will not be able to sign-in to Azure AD with on-premises credentials if the UPN suffix does not match a verified domain name**, enable the checkbox **Continue without matching all UPN suffixes to verified domain**, and select **Next**.

   > **Note**: This is expected, since the Azure AD tenant does not have a verified custom DNS domain matching one of the UPN suffixes of the **adatum.com** AD DS.

15. On the **Domain and OU filtering** page, select the option **Sync selected domains and OUs**, expand the adatum.com node, clear all checkboxes, select only the checkbox next to the **ToSync** OU, and select **Next**.
16. On the **Uniquely identifying your users** page, accept the default settings, and select **Next**.
17. On the **Filter users and devices** page, accept the default settings, and select **Next**.
18. On the **Optional features** page, accept the default settings, and select **Next**.
19. On the **Ready to configure** page, ensure that the **Start the synchronization process when configuration completes** checkbox is selected and select **Install**.

   > **Note**: Installation should take about 2 minutes.

20. Review the information on the **Configuration complete** page and select **Exit** to close the **Microsoft Azure Active Directory Connect** window.

21. Within the Remote Desktop session to **az140-dc-vm11**, open Microsoft Edge browser shortcut for Azure or navigate to the [Azure portal](https://portal.azure.com). If prompted, sign in by using the Azure AD credentials of the user account with the Owner role in the subscription you are using in this lab.
22. In the Azure portal, use the **Search resources, services, and docs** text box at the top of the Azure portal page, search for and navigate to the **Azure Active Directory** blade and, on your Azure AD tenant blade, in the **Manage** section of the hub menu, select **Users**.
23. On the **All users (Preview)** blade, note that the list of user objects includes the listing of AD DS user accounts you created earlier in this lab, with the **Yes** entry appearing in the **Directory synced** column.

   > **Note**: You might have to wait a few minutes and refresh the browser page for the AD DS user accounts to appear. Proceed to next step only if you are able to see the listing of AD DS user accounts you created. 

24. Within the Remote Desktop session to **az140-dc-vm11**, start **Windows PowerShell ISE** as administrator, and run the following to create an organizational unit that will host the computer objects of the Azure Virtual Desktop hosts:

   ```powershell
   New-ADOrganizationalUnit 'WVDInfra' –path 'DC=adatum,DC=com' -ProtectedFromAccidentalDeletion $false
   ```
25. Once the users are reflecting in the Azure AD, right click on the **lab-prerequisite** PowerShell file present on the desktop and select **Run with PowerShell** in the popup options. This will configure the storage account with the naming convention `storage<DeploymentID>` and file share with the name `az140-22-profiles`.
   
   > **Note**: The script execution will take about 5 minutes. Once completed, the PowerShell window will display the text `Lab Pre-requisite Task Completed Successfully` in green color and the Powershell window will automatically close after a few seconds.
  
  
26. Now click on the **Session-host** PowerShell file present on the desktop and select **Run with PowerShell** in the popup options. This will create the Session host.


27. Within the Remote Desktop session to az140-dc-vm11, in the browser window displaying the Azure portal, search for and select Virtual machines and, on the Virtual machines blade, in the list of virtual machines, select az140-24-p3-0. 

28. Open Run command and run with pscript and copy the content of p3script.ps1 available on desktop.

29. On the **az140-24-p3-0** blade, select **Connect**, in the drop-down menu, select **RDP**, on the **RDP** tab of the **az140-24-p3-0 \| Connect** blade, in the **IP address** drop-down list, select the **Private IP address (10.0.3.4)** entry, and then select **Download RDP File**.
30. When prompted, sign in with the following credentials:

   |Setting|Value|
   |---|---|
   |User Name|**Student**|
   |Password|**Pa55w.rd1234**|

  > **Note**: If you get **Welcome to Microsoft Teams: Get started** page, then close the application.

31. Within the Remote Desktop session to **az140-24-p3-0**, start **Windows PowerShell ISE** as administrator.

33. Within the Remote Desktop session to **az140-24-p3-0**, click on the **connect** PowerShell file present on the desktop and select **Run with PowerShell** in the popup options. This will connect session host to host pool.

34. If you get the popup NutGet provider is requied to continue select yes.
35. Give the credential to login the Azure account from enviroment page.


### Exercise 1: Prepare for Azure AD-based Conditional Access for Azure Virtual Desktop

The main tasks for this exercise are as follows:

1. Configure Azure AD Premium P2 licensing
1. Configure Azure AD Multi-Factor Authentication (MFA)
1. Register a user for Azure AD MFA
1. Configure hybrid Azure AD join
1. Trigger Azure AD Connect delta synchronization

#### Task 1: Configure Azure AD Premium P2 licensing

>**Note**: Premium P1 or P2 licensing of Azure AD is required in order to implement Azure AD Conditional Access. You will use a 30-day trial for this lab.

1. From your lab computer, start a web browser, navigate to the [Azure portal](https://portal.azure.com), and sign in by providing credentials of a user account with the Owner role in the subscription you will be using in this lab and the Global Administrator role in the Azure AD tenant associated with that subscription.
1. In the Azure portal, search for and select **Azure Active Directory** to navigate to the Azure AD tenant associated with the Azure subscription you are using for this lab.
1. On the Azure Active Directory blade, in the vertical menu bar on the left side, in the **Manage** section, click **Users**. 
1. On the **Users | All users (Preview)** blade, select **aduser5**.
1. On the **aduser5 | Profile** blade, in the toolbar, click **Edit**, in the **Settings** section, in the **Usage location** dropdown list, select country where the lab environment is located and, in the toolbar, click **Save**.
1. On the **aduser5 | Profile** blade, in the **Identity** section, identify the user principal name of the **aduser5** account.

    >**Note**: Record this value. You will need it later in this lab.

1. On the **Users | All users (Preview)** blade, select the user account you used to sign at the beginning of this task and repeat the previous step in case your account does not have the **Usage location** assigned. 

    >**Note**: The **Usage location** property must be set in order to assign an Azure AD Premium P2 licenses to user accounts.

1. On the **Users | All users (Preview)** blade, select the **aadsyncuser** user account and identify its user principal name.

    >**Note**: Record this value. You will need it later in this lab.

1. In the Azure portal, navigate back to the **Overview** blade of the Azure AD tenant and, in the vertical menu bar on the left side, in the **Manage** section, click **Licenses**.
1. On the **Licenses \| Overview** blade, in the vertical menu bar on the left side, in the **Manage** section, click **All products**.
1. On the **Licenses \| All products** blade, in the toolbar, click **+ Try/Buy**.
1. On the **Activate** blade, click **Free trial** in the **ENTERPRISE MOBILITY + SECURITY E5** section and then click **Activate**. 
1. While on the **Licenses \| Overview** blade, refresh the browser window to verify that the activation was successful. 
1. On the **Licenses - All products** blade, select the **Enterprise Mobility + Security E5** entry. 
1. On the **Enterprise Mobility + Security E5** blade, in the toolbar, click **+ Assign**.
1. On the **Assign license** blade, click **Add users and groups**, on the **Add users and groups** blade, select **aduser5** and your user account, and click **Select**.
1. Back on the **Assign license** blade, click **Assignment options**, on the **Assignment options** blade, verify that all options are enabled, click **Review + assign**, click **Assign**.

#### Task 2: Configure Azure AD Multi-Factor Authentication (MFA)

1. On your lab computer, in the web browser displaying the Azure portal, navigate back to the **Overview** blade of the Azure AD tenant and, in the vertical menu on the left side, in the **Manage** section, click **Security**.
1. On the **Security | Getting started** blade, in the vertical menu on the left side, in the **Protect** section, click **Identity Protection**.
1. On the **Identity Protection | Overview** blade, in the vertical menu on the left side, in the **Protect** section, click **MFA registration policy** (if necessary, refresh the web browser page).
1. On the **Identity Protection | MFA registration policy** blade, in the **Assignments** section of the **Multi-factor authentication registration policy**, click **All users**, on the **Include** tab, click the **Select individuals and groups** option, on the **Select users**, click **aduser5**, click **Select**, at the bottom of the blade, set the **Enforce policy** switch to **On**, and click **Save**.

#### Task 3: Register a user for Azure AD MFA

1. On your lab computer, open an **InPrivate** web browser session, navigate to the [Azure portal](https://portal.azure.com), and sign in by providing the **aduser5** user principal name you identified earlier in this exercise and the password you set when creating this user account.
1. When presented with the message **More information required**, click **Next**. This will automatically redirect your browser to the **Microsoft Authenticator** page.
1. On the **Additional security verification** page, in the **Step 1: How should we contact you?** section, select your preferred authentication method and follow instructions to complete the registration process. 
1. On the Azure portal page, in the upper right corner, click the icon representing the user avatar, click **Sign out**, and close the **In private** browser window. 

#### Task 4: Configure hybrid Azure AD join

> **Note**: This functionality can be leveraged to implement additional security when setting up Conditional Access for devices based on their Azure AD join status.

1. On the lab computer, in the web browser displaying the Azure portal, search for and select **Virtual machines** and, from the **Virtual machines** blade, select **az140-dc-vm11**.
1. On the **az140-dc-vm11** blade, select **Connect**, in the drop-down menu, select **Bastion**, on the **Bastion** tab of the **az140-dc-vm11 \| Connect** blade, select **Use Bastion**.
1. When prompted, provde the following credentials and select **Connect**:

   |Setting|Value|
   |---|---|
   |User Name|**Student**|
   |Password|**Pa55w.rd1234**|

1. Within the Remote Desktop session to **az140-dc-vm11**, in the **Start** menu, expand the **Azure AD Connect** folder and select **Azure AD Connect**.
> **Note** If you receive a failure error window that the Sync Service is not running, go to PowerShell command window and enter **Start-Service "ADSync"**, and then try the step 4 again.
3. On the **Welcome to Azure AD Connect** page of the **Microsoft Azure Active Directory Connect** window, select **Configure**.
4. On the **Additional tasks** page in the **Microsoft Azure Active Directory Connect** window, select **Configure device options** and select **Next**.
5. On the **Overview** page in the **Microsoft Azure Active Directory Connect** window, review the information regarding **Hybrid Azure AD join** and **Device writeback** and select **Next**.
6. On the **Connect to Azure AD** page in the **Microsoft Azure Active Directory Connect** window, authenticate by using the credentials of the **aadsyncuser** user account you created in the previous exercise and select **Next**.  

   > **Note**: Provide the userPrincipalName attribute of the **aadsyncuser** account you recorded earlier in this lab and specify the password you set when creating this user account. 

1. On the **Device options** page in the **Microsoft Azure Active Directory Connect** window, ensure that the **Configure Hybrid Azure AD join** option is selected and select **Next**. 
1. On the **Device operating systems** page in the **Microsoft Azure Active Directory Connect** window, select the **Windows 10 or later domain-joined devices** checkbox and select **Next**. 
1. On the **SCP configuration** page in the **Microsoft Azure Active Directory Connect** window, select the checkbox next to the **adatum.com** entry, in the **Authentication Service** drop-down list, select **Azure Active Directory** entry, and select **Add**. 
1. When prompted, in the **Enterprise Admin Credentials** dialog box, specify the following credentials, and select **OK**:

   |Setting|Value|
   |---|---|
   |User Name|**ADATUM\Student**|
   |Password|**Pa55w.rd1234**|

1. Back on the **SCP configuration** page in the **Microsoft Azure Active Directory Connect** window, select **Next**.
1. On the **Ready to configure** page in the **Microsoft Azure Active Directory Connect** window, select **Configure** and, once the configuration completes, select **Exit**.
1. Within the Remote Desktop session to **az140-dc-vm11**, start **Windows PowerShell ISE** as administrator.
1. Within the Remote Desktop session to **az140-dc-vm11**, from the **Administrator: Windows PowerShell ISE** console, run the following to move the **az140-cl-vm11** computer account to the **WVDClients** organizational unit (OU):

   ```powershell
   Move-ADObject -Identity "CN=az140-cl-vm11,CN=Computers,DC=adatum,DC=com" -TargetPath "OU=WVDClients,DC=adatum,DC=com"
   ```

1. Within the Remote Desktop session to **az140-dc-vm11**, in the **Start** menu, expand the **Azure AD Connect** folder and select **Azure AD Connect**.
1. On the **Welcome to Azure AD Connect** page of the **Microsoft Azure Active Directory Connect** window, select **Configure**.
1. On the **Additional tasks** page in the **Microsoft Azure Active Directory Connect** window, select **Customize synchronization options** and select **Next**.
1. On the **Connect to Azure AD** page in the **Microsoft Azure Active Directory Connect** window, authenticate by using the credentials of the **aadsyncuser** user account you created in the previous exercise and select **Next**. 

   > **Note**: Provide the userPrincipalName attribute of the **aadsyncuser** account you recorded earlier in this lab and specify the password you set when creating this user account. 

1. On the **Connect your directories** page in the **Microsoft Azure Active Directory Connect** window, select **Next**.
1. On the **Domain and OU filtering** page in the **Microsoft Azure Active Directory Connect** window, ensure that the option **Sync selected domains and OUs** is selected, expand the **adatum.com** node, ensure that the checkbox next to the **ToSync** OU is selected, select the checkbox next to the **WVDClients** OU, and select **Next**.
1. On the **Optional features** page in the **Microsoft Azure Active Directory Connect** window, accept the default settings, and select **Next**.
1. On the **Ready to configure** page in the **Microsoft Azure Active Directory Connect** window, ensure that the checkbox **Start the synchronization process when configuration completes** is selected and select **Configure**.
1. Review the information on the **Configuration complete** page and select **Exit** to close the **Microsoft Azure Active Directory Connect** window.

#### Task 5: Trigger Azure AD Connect delta synchronization

1. Within the Remote Desktop session to **az140-dc-vm11**, switch to the **Administrator: Windows PowerShell ISE** window.
1. Within the Remote Desktop session to **az140-dc-vm11**, from the **Administrator: Windows PowerShell ISE** console pane, run the following to trigger Azure AD Connect delta synchronization:

   ```powershell
   Import-Module -Name "C:\Program Files\Microsoft Azure AD Sync\Bin\ADSync"
   Start-ADSyncSyncCycle -PolicyType Initial
   ```

1. Within the Remote Desktop session to **az140-dc-vm11**, start Microsoft Edge and navigate to the [Azure portal](https://portal.azure.com). When prompted, sign in by using the Azure AD credentials of the user account with the Global Administrator role in the Azure AD tenant associated with the Azure subscription you are using in this lab.
1. Within the Remote Desktop session to **az140-dc-vm11**, in the Microsoft Edge window displaying the Azure portal, search for and select **Azure Active Directory** to navigate to the Azure AD tenant associated with the Azure subscription you are using for this lab.
1. On the Azure Active Directory blade, in the vertical menu bar on the left side, in the **Manage** section, click **Devices**. 
1. On the **Devices | All devices** blade, review the list of devices and verify that the **az140-cl-vm11** device is listed with the **Hybrid Azure AD joined** entry in the **Join Type** column.

   > **Note**: You might have to wait a few minutes for the synchronization to take efect before the device appears in the Azure portal.

### Exercise 2: Implement Azure AD-based Conditional Access for Azure Virtual Desktop

The main tasks for this exercise are as follows:

1. Create an Azure AD-based Conditional Access policy for all Azure Virtual Desktop connections
1. Test the Azure AD-based Conditional Access policy for all Azure Virtual Desktop connections
1. Modify the Azure AD-based Conditional Access policy to exclude hybrid Azure AD joined computers from the MFA requirement
1. Test the modified Azure AD-based Conditional Access policy

#### Task 1: Create an Azure AD-based Conditional Access policy for all Azure Virtual Desktop connections

>**Note**: In this task, you will configure an Azure AD-based Conditional Access policy that requires MFA to sign in to a Azure Virtual Desktop session. The policy will also enforce reauthentication after the first 4 hours following a successful authentication.

1. On your lab computer, in the web browser displaying the Azure portal, navigate back to the **Overview** blade of the Azure AD tenant and, in the vertical menu on the left side, in the **Manage** section, click **Security**.
1. On the **Security \| Getting started** blade, in the vertical menu on the left side, in the **Protect** section, click **Conditional Access**.
1. On the **Conditional Access \| Policies** blade, in the toolbar, click **+ New policy**, and in the context menu, select **Create New Policy**.
1. On the **New** blade, configure the following settings:

   - In the **Name** text box, type **az140-31-wvdpolicy1**
   - In the **Assignments** section, select the **Users or workload identities** option, in the **What does this policy apply to?** drop-down list, ensure that **Users and groups** is selected, in the **Select Users and groups** section, select the **Users and groups** checkbox, on the **Select** blade, click **aduser5**, and then click **Select**.
   - In the **Assignments** section, click **Cloud apps or actions**, ensure that in the **Select what this policy applies to** switch, the **Cloud apps** option is selected, click the **Select apps** option, on the **Select** blade, select the checkbox next to the **Azure Virtual Desktop** entry, and click **Select**. 
   - In the **Assignments** section, click **Conditions**, click **Client apps**, on the **Client apps** blade, set the **Configure** switch to **Yes**, ensure that both the **Browser** and **Mobile apps and desktop clients** checkboxes are selected, and click **Done**.
   - In the **Access controls** section, click **Grant**, on the **Grant** blade, ensure that the **Grant access** option is selected, select the **Require multi-factor authentication** checkbox and click **Select**.
   - In the **Access controls** section, click **Session**, on the **Session** blade, select the **Sign-in frequency** checkbox, in the first textbox, type **4**, in the **Select units** dropdown list, select **Hours**, leave the **Persistent browser session** checkbox cleared, and click **Select**.
   - Set the **Enable policy** switch to **On**.

1. On the **New** blade, click **Create**. 

#### Task 2: Test the Azure AD-based Conditional Access policy for all Azure Virtual Desktop connections

1. On your lab computer, open an **InPrivate** web browser session, navigate to the [Azure portal](https://portal.azure.com), and sign in by providing the **aduser5** user principal name you identified earlier in this exercise and the password you set when creating this user account.

   > **Note**: Verify that you are not prompted to authenticate via MFA.

1. In the **InPrivate** web browser session, navigate to the Azure Virtual Desktop HTML5 web client page at [https://rdweb.wvd.microsoft.com/arm/webclient](https://rdweb.wvd.microsoft.com/arm/webclient).

   > **Note**: Verify that this will automatically trigger authentication via MFA.

1. In the **Enter code** pane, type the code from the text message or authenticator app that you registered and select **Verify**.
1. On the **All Resources** page, click **Command Prompt**, on the **Access local resources** pane, clear the **Printer** checkbox, and click **Allow**.
1. When prompted, in the **Enter your credentials**, in the **User name** textbox type the user principal name of **aduser5** and, in the **Password** textbox, type the password you set when creating this user account and click **Submit**.
1. Verify that the **Command Prompt** Remote App was launched successfully.
1. In the **Command Prompt** Remote App window, at the command prompt, type **logoff** and press the **Enter** key.
1. Back on the **All Resources** page, in the upper right corner, click **aduser5**, in the dropdown menu, click **Sign Out**, and close the **InPrivate** web browser window.

#### Task 3: Modify the Azure AD-based Conditional Access policy to exclude hybrid Azure AD joined computers from the MFA requirement

>**Note**: In this task, you will modify the Azure AD-based Conditional Access policy that requires MFA to sign in to a Azure Virtual Desktop session such that connections originating from Azure AD joined computers will not require MFA.

1. On your lab computer, in the browser window displaying the Azure portal, on the **Conditional Access | Policies** blade, click the entry representing the **az140-31-wvdpolicy1** policy.
1. On the **az140-31-wvdpolicy1** blade, in the **Access controls** section, click **Grant**, on the **Grant** blade, select the **Require multi-factor authentication** and **Require Hybrid Azure AD joined device** checkboxes, ensure that the **Require one of the selected controls** option is enabled, and click **Select**.
1. On the **az140-31-wvdpolicy1** blade, click **Save**.

>**Note**: It might take a few minutes for the policy to take effect.

#### Task 4: Test the modified Azure AD-based Conditional Access policy

1. On your lab computer, in the browser window displaying the Azure portal, search for and select **Virtual machines** and, on the **Virtual machines** blade, select the **az140-cl-vm11** entry.
1. On the **az140-cl-vm11** blade, select **Connect**, in the drop-down menu, select **Bastion**, on the **Bastion** tab of the **az140-cl-vm11 \| Connect** blade, select **Use Bastion**.
1. When prompted, provde the following credentials and select **Connect**:

   |Setting|Value|
   |---|---|
   |User Name|**Student@adatum.com**|
   |Password|**Pa55w.rd1234**|

1. Within the Remote Desktop session to **az140-cl-vm11**, start Microsoft Edge and navigate to navigate to the Azure Virtual Desktop HTML5 web client page at [https://rdweb.wvd.microsoft.com/arm/webclient](https://rdweb.wvd.microsoft.com/arm/webclient).

   > **Note**: Verify that this time you will not be prompted to authenticate via MFA. This is because **az140-cl-vm11** is Hybrid Azure AD-joined.

1. On the **All Resources** page, double-click **Command Prompt**, on the **Access local resources** pane, clear the **Printer** checkbox, and click **Allow**.
1. When prompted, in the **Enter your credentials**, in the **User name** textbox type the user principal name of **aduser5** and, in the **Password** textbox, type the password you set when creating this user account and click **Submit**.
1. Verify that the **Command Prompt** Remote App was launched successfully.
1. In the **Command Prompt** Remote App window, at the command prompt, type **logoff** and press the **Enter** key.
1. Back on the **All Resources** page, in the upper right corner, click **aduser5**, in the dropdown menu, click **Sign Out**.
1. Within the Remote Desktop session to **az140-cl-vm11**, click **Start**, in the vertical bar directly above the **Start** button, click the icon representing the signed in user account, and, in the pop-up menu, click **Sign out**.


