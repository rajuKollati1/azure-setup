#!/bin/bash

# Define variables
resource_group="Devara"
nsg_name="your-nsg-name"  # Replace with your NSG name
nsg_id=$(az network nsg show --resource-group "$resource_group" --name "$nsg_name" --query "id" --output tsv)

# Get list of VMs with 'dev' tag
vm_ids=$(az vm list --resource-group "$resource_group" --tag dev --query "[].id" --output tsv)

# Loop through each VM
for vm_id in $vm_ids; do
  echo "Processing VM: $vm_id"
  
  # Get network interfaces attached to the VM
  nic_ids=$(az vm show --ids "$vm_id" --query "networkProfile.networkInterfaces[].id" --output tsv)
  
  # Attach NSG to each NIC
  for nic_id in $nic_ids; do
    echo "Updating NIC: $nic_id"
    az network nic update --ids "$nic_id" --network-security-group "$nsg_id"
  done
  
  echo "NSG attached to all NICs of VM: $vm_id"
done

echo "NSG attachment completed for all VMs in the resource group $resource_group."
