# Azure Image Builder
## Prerequisite
```sh
az feature register --namespace Microsoft.VirtualMachineImages --name VirtualMachineTemplatePreview
```
## Parsing output command
```sh
cmd=$(az deployment group create ... | jq -r '.properties.outputs.cmd.value')
eval $cmd
```