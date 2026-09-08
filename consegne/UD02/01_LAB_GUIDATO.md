### Confronto tra Azure Portal e Azure CLI

Nel portale ho verificato che il resource group contiene la VNet
`vnet-cea-ud02` e lo storage account `stceaa2330604`, entrambi in
Italy North.

La JSON View della VNet ha confermato:

- tipo: `Microsoft.Network/virtualNetworks`;
- località: `italynorth`;
- stato di provisioning: `Succeeded`;
- spazio indirizzi VNet: `10.20.0.0/16`;
- subnet `snet-app`: `10.20.1.0/24`;
- presenza dei tag previsti.

La struttura anonimizzata del resource ID è:

`/subscriptions/<omitted>/resourceGroups/rg-cea-ud02-a2330604/providers/Microsoft.Network/virtualNetworks/vnet-cea-ud02`

Il portale è utile per esplorare visivamente proprietà e relazioni tra
le risorse, mentre Azure CLI consente di ripetere i controlli e
selezionare direttamente i campi necessari.