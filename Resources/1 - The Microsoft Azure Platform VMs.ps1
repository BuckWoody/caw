# Azure Overview Training Class.ps1
# Author: Buck Woody
# Last Edited: 09/17/2015
# Purpose: Shows the basics of working with the command-line in Azure

# Connect to Azure Account
Add-AzureAccount
Get-AzureSubscription | Sort SubscriptionName | Select SubscriptionName 

# Change to using the ARM model
Switch-AzureMode AzureResourceManager

# Create a Resource Group
# Resources and reference: https://azure.microsoft.com/en-us/documentation/articles/virtual-networks-arm-asm-s2s/ 

# Find Locations
$loc=Get-AzureLocation | where { $_.Name –eq "Microsoft.Compute/virtualMachines" }
$loc.Locations

# Now make the RG
$rgName="<resource group name>"
$locName="<location name, such as West US>"
New-AzureResourceGroup -Name $rgName -Location $locName

# Create a Storage Account
$rgName="<resource group name>"
$locName="<location name, such as West US>"
$saName="<storage account name>"
$saType="<storage account type, specify one: Standard_LRS, Standard_GRS, Standard_RAGRS, or Premium_LRS>"
New-AzureStorageAccount -Name $saName -ResourceGroupName $rgName –Type $saType -Location $locName
Get-AzureStorageAccount | Sort Name | Select Name 


# Create an Availability Set
$avName="<availability set name>"
$rgName="<resource group name>"
$locName="<location name, such as West US>"
New-AzureAvailabilitySet –Name $avName –ResourceGroupName $rgName -Location $locName

# Create a Network
# Resources and References: 
# Network Resource Provider Info - https://azure.microsoft.com/en-us/documentation/articles/resource-groups-networking/ 
# This example makes two subnets
$rgName="<resource group name>"
$locName="<location name, such as West US>"
$frontendSubnet=New-AzureVirtualNetworkSubnetConfig -Name frontendSubnet -AddressPrefix 10.0.1.0/24
$backendSubnet=New-AzureVirtualNetworkSubnetConfig -Name backendSubnet -AddressPrefix 10.0.2.0/24
New-AzurevirtualNetwork -Name TestNet -ResourceGroupName $rgName -Location $locName -AddressPrefix 10.0.0.0/16 -Subnet $frontendSubnet,$backendSubnet

# List Networks
$rgName="<resource group name>"
Get-AzureVirtualNetwork -ResourceGroupName $rgName | Sort Name | Select Name
# Get-AzureVirtualNetwork -ResourceGroupName 20150916-Training-Buck | Sort Name | Select Name


# Create a VM
# Resources and references: 

# Set values for existing resource group and storage account names
$rgName="<resource group name>"
$locName="<location name, such as West US>"
$saName="<storage account name>"

# Set the existing virtual network and subnet index
$vnetName="<virtual network name>"
$subnetIndex=0
$vnet=Get-AzurevirtualNetwork -Name $vnetName -ResourceGroupName $rgName

# Create the NIC
$nicName="<network interface card name>"
$domName="<domain name>"
$pip=New-AzurePublicIpAddress -Name $nicName -ResourceGroupName $rgName -DomainNameLabel $domName -Location $locName -AllocationMethod Dynamic
$nic=New-AzureNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $locName -SubnetId $vnet.Subnets[$subnetIndex].Id -PublicIpAddressId $pip.Id

# Specify the name, size, and existing availability set
$vmName="<virtual machine name>"
$vmSize="Standard_A3"
$avName="<availability group name>"
$avSet=Get-AzureAvailabilitySet –Name $avName –ResourceGroupName $rgName
$vm=New-AzureVMConfig -VMName $vmName -VMSize $vmSize -AvailabilitySetId $avset.Id

# Add a 200 GB additional data disk
$diskSize=200
$diskLabel="<disk label name>"
$diskName="<disk name>"
$storageAcc=Get-AzureStorageAccount -ResourceGroupName $rgName -Name $saName
$vhdURI=$storageAcc.PrimaryEndpoints.Blob.ToString() + "vhds/" + $vmName + $diskName  + ".vhd"
Add-AzureVMDataDisk -VM $vm -Name $diskLabel -DiskSizeInGB $diskSize -VhdUri $vhdURI -CreateOption empty

# Specify the image and local administrator account, and then add the NIC
$pubName="MicrosoftWindowsServer"
$offerName="WindowsServer"
$skuName="2012-R2-Datacenter"
$cred=Get-Credential -Message "Type the name and password of the local administrator account."
$vm=Set-AzureVMOperatingSystem -VM $vm -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm=Set-AzureVMSourceImage -VM $vm -PublisherName $pubName -Offer $offerName -Skus $skuName -Version "latest"
$vm=Add-AzureVMNetworkInterface -VM $vm -Id $nic.Id

# Specify the OS disk name and create the VM
$diskName="OSDisk"
$storageAcc=Get-AzureStorageAccount -ResourceGroupName $rgName -Name $saName
$osDiskUri=$storageAcc.PrimaryEndpoints.Blob.ToString() + "vhds/" + $vmName + $diskName  + ".vhd"
$vm=Set-AzureVMOSDisk -VM $vm -Name $diskName -VhdUri $osDiskUri -CreateOption fromImage
New-AzureVM -ResourceGroupName $rgName -Location $locName -VM $vm


# General References:
# Quickstart JSON templates for the ARM: https://github.com/Azure/azure-quickstart-templates 
# Authoring Azure Resource Manager Templates: https://azure.microsoft.com/en-us/documentation/articles/resource-group-authoring-templates/ 
# Explanation of the entire VM Creation Process: https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-ps-create-preconfigure-windows-resource-manager-vms/ 