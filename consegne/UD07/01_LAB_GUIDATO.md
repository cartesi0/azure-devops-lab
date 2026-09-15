# UD07 — Consegna laboratorio guidato

## CLI

- prima esecuzione script: 
Il Resource Group non esiste: lo creo.


Stato finale:
Name              Location    State
----------------  ----------  ---------
rg-ud07-cli-test  westeurope  Succeeded

- seconda esecuzione:

Il Resource Group esiste già: lo riutilizzo.

Aggiorno i tag...

Stato finale:
Name              Location    State
----------------  ----------  ---------
rg-ud07-cli-test  westeurope  Succeeded
cartesi0@DESKTOP-831RF7P:~/workspace/azure-devops-lab/consegne/UD07$


- comportamento idempotente: L'idempimento ha controllato prima se questo gruppo non esistesse già per evitare errori.
- esempio JMESPath:
- quando usare `tsv`: Si usa tsv per visualizare il risultato breve, evitando virgole e parentesi.

## PowerShell

- `Get-AzContext` verificato:

 Tenant: 8dc6e439-5791-4bdf-999b-d86709851418

SubscriptionName     SubscriptionId                       Account   Environment
----------------     --------------                       -------   -----------
Azure subscription 1 25de7285-8aa0-4c31-998e-81b9c4e4ff8b MSI@50342 AzureCloud


- Resource Group test:

ResourceGroupName Location   ProvisioningState Tags
----------------- --------   ----------------- ----
rg-ud07-ps-test   westeurope Succeeded         {[ManagedBy, PowerShell], [State, Verified], [UD, 07]}


- prima esecuzione:
Lo script ha controllato prima che non ci fosse già un RG, e dopo la creato
- seconda esecuzione:
Eseguendo una secodna volta lo script ha trovato già l'esistena del RG e non l'ha creato
- perché il controllo `if` è utile: 
Perchè ci aiuta a verificare una condizione. In questo caso prima a verificato l'esistenza del RG per evitare di ricrearlo e incorrere ad errori.

## Log Analytics

- workspace: Name            Location     State
--------------  -----------  ---------
law-ud07-25159  northeurope  Succeeded
- regione: northeurope
- query `print`:  eseguita correttamente. Risultato: Course=AZ-104, UD=7, Status=OK
- query `datatable`: eseguita correttamente. Risultato aggregato: 2 OK e 1 WARN
- risultato sintetico: il workspace è operativo e le query KQL funzionano correttamente; `summarize Count=count() by Status` ha raggruppato i dati per stato.

## Activity Log

- evento osservato: Update resource group
- status: Succeeded
- timestamp: 2026-09-15T13:41:50.5867317Z
- dati personali omessi: sì

## Diagnostic Setting

## Diagnostic Setting

- esito: creata e verificata correttamente
- destinazione: Log Analytics Workspace `law-ud07-25159`
- AzureActivity disponibile: AzureActivity non ancora popolata nel time range osservato.
- fallback usato, se necessario: no

## Metrics
## Metrics

- Storage Account: stud0789475706
- metrica: UsedCapacity
- unità: Bytes
- aggregazione: Average
- punto dati disponibile: no
- interpretazione: la metrica è disponibile per la risorsa, ma al momento non è presente un valore numerico nel periodo osservato, probabilmente perché lo Storage Account è stato creato recentemente.

## Alert

- nome:
- scope corretto: sì/no
- condition:
- severity:
- Action Group: presente/assente
- perché non è necessario che sia Fired:

## Correlazione

- modifica osservata: aggiornamento del tag `State=Changed` sullo Storage Account `stud0789475706`
- evento Activity Log: `Create/Update Storage Account` - `Succeeded` - `2026-09-15T14:47:26.3815053Z`
- la correlazione prova causalità?: no
- motivazione: l'Activity Log dimostra che la modifica dello Storage Account è stata eseguita e registrata da Azure, ma non dimostra che eventuali variazioni delle metriche siano state causate da quella modifica.

## Cleanup
 DA SVOLGERE DOPO IL LABORATORIO AUTONOMO
- diagnostic setting rimossa:
- RG CLI test eliminato:
- RG PowerShell test eliminato:
- RG principale eliminato:
