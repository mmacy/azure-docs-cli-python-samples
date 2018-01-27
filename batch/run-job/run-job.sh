#!/bin/bash

# Create a resource group.
az group create --name myResourceGroup --location westeurope

# Create a general-purpose storage account in your resource group.
az storage account create \
    --resource-group myResourceGroup \
    --name mystorageaccount \
    --location eastus \
    --sku Standard_LRS

# Create a Batch account.
az batch account create \
    --name mybatchaccount \
    --storage-account mystorageaccount \
    --resource-group myResourceGroup \
    --location eastus

# Authenticate against the account directly for further CLI interaction.
az batch account login \
    --name mybatchaccount \
    --resource-group myResourceGroup \
    --shared-key-auth

# Create a new Linux pool with a virtual machine configuration. 
az batch pool create \
    --id mypool \
    --vm-size Standard_A1 \
    --target-dedicated 2
    --image canonical:ubuntuserver:16.04.0-LTS \
    --node-agent-sku-id "batch.node.ubuntu 16.04"


# Create a new job to encapsulate the tasks that we want to add.
az batch job create \
    --id myjob \
    --pool-id mypool

# Add tasks to the job. Here the task is a basic shell command.
az batch task create \
    --job-id myjob \
    --task-id task1 \
    --command-line "/bin/bash -c 'printenv AZ_BATCH_TASK_WORKING_DIR'"

# To add many tasks at once, specify the tasks
# in a JSON file, and pass it to the command. See tasks.json for formatting.
az batch task create \
    --job-id myjob \
    --json-file tasks.json

# Now that all the tasks are added - we can update the job so that it will automatically
# be marked as completed once all the tasks are finished.
az batch job set \
--job-id myjob \
--on-all-tasks-complete terminateJob

# Monitor the status of the job.
az batch job show --job-id myjob

# Monitor the status of a task.
az batch task show \
    --job-id myjob \
    --task-id task1
