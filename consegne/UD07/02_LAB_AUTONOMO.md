# UD07 — Consegna laboratorio autonomo

## 1. Script CLI idempotente

- logica: lo script verifica con `az group exists` se il Resource Group `rg-ud07-auto` esiste. Se non esiste lo crea; se esiste lo riutilizza. Successivamente aggiunge/aggiorna i tag e mostra lo stato finale della risorsa.
- prima esecuzione: il Resource Group `rg-ud07-auto` non esisteva ed è stato creato correttamente nella regione `northeurope`.
- seconda esecuzione: il Resource Group esisteva già ed è stato riutilizzato senza crearne un duplicato.
- verifica: il Resource Group `rg-ud07-auto` risulta in stato `Succeeded`.

Lo script utilizza una logica idempotente: può essere eseguito più volte mantenendo lo stesso stato desiderato senza creare risorse duplicate.

---

## 2. PowerShell equivalente

- controllo esistenza: effettuato tramite `Get-AzResourceGroup` con `-ErrorAction SilentlyContinue`.
- creazione: il Resource Group `rg-ud07-auto-ps` viene creato con `New-AzResourceGroup` solamente se non esiste.
- modifica: i tag vengono aggiunti/aggiornati tramite `Update-AzTag -Operation Merge`.
- output: vengono mostrate le proprietà `ResourceGroupName`, `Location`, `ProvisioningState` e `Tags`.

Alla seconda esecuzione PowerShell ha restituito:

`Il Resource Group esiste già: lo riutilizzo.`

Il Resource Group risultava:

- nome: `rg-ud07-auto-ps`
- location: `northeurope`
- provisioning state: `Succeeded`
- `ManagedBy=Autonomo`
- `UD=07`
- `State=Verified`

Anche la procedura PowerShell risulta quindi idempotente.

---

## 3. Activity Log

Dopo aver modificato un tag del Resource Group `rg-ud07-auto`, la modifica è stata registrata nell'Activity Log.

- operazione: `Update resource group`
- status: `Succeeded`
- timestamp: `15/09/2026 23:36:14 GMT+0200`

L'evento non è comparso immediatamente nel portale ma dopo alcuni minuti, mostrando una normale latenza di aggiornamento dell'Activity Log.

Il campo `caller` non è stato riportato.

---

## 4. KQL

È stata eseguita nel Log Analytics Workspace UD07 la seguente query:

```kusto
datatable(
  Component:string,
  Status:string,
  DurationMs:int
)
[
  "WEB","OK",120,
  "API","OK",180,
  "DB","WARN",430,
  "API","WARN",510
]
| summarize
    Requests=count(),
    AvgDuration=avg(DurationMs)
  by Status
| sort by AvgDuration desc
```

Risultato:

| Status | Requests | AvgDuration |
|---|---:|---:|
| WARN | 2 | 470 |
| OK | 2 | 150 |

1. La query produce **2 righe aggregate**, una per lo stato `WARN` e una per lo stato `OK`.

2. Lo stato con la latenza media più alta è **WARN**, con `AvgDuration = 470 ms`.

3. `summarize` cambia la granularità perché raggruppa più righe elementari in risultati aggregati. In questo caso le 4 righe iniziali vengono trasformate in 2 gruppi basati sul campo `Status`.

In pratica:

```text
4 eventi individuali
        ↓
summarize by Status
        ↓
2 risultati aggregati
```

---

## 5. Metrics

Sul Resource Group principale UD07 è stato individuato lo Storage Account:

`stud0789475706`

Sono state visualizzate le metric definitions disponibili.

Tra le metriche presenti:

- `UsedCapacity`
- `Transactions`
- `Ingress`
- `Egress`
- `SuccessServerLatency`
- `SuccessE2ELatency`
- `Availability`

È stata scelta:

- metrica: `UsedCapacity`
- unità: `Bytes`
- aggregazione: `Average`
- dato presente: no, nel campione osservato non era disponibile un valore numerico
- interpretazione: la metrica `UsedCapacity` è supportata dallo Storage Account, ma al momento della verifica Azure ha restituito solamente il timestamp senza un valore numerico `Average`.

Non è stata cambiata metrica per tentativi, come richiesto dal laboratorio.

Una metric definition disponibile non implica necessariamente che sia già presente un campione numerico utilizzabile nel periodo osservato.

---

## 6. Alert

È stata analizzata la Metric Alert Rule già configurata nel laboratorio guidato senza modificarla.

- scope: Storage Account `stud0789475706`
- condition: metrica `Transactions`, aggregazione `Total`, condizione maggiore di `0`
- severity: `3`
- evaluation frequency: `5 minuti`
- window size: `5 minuti`
- Action Group: presente, `ag-ud07`
- alert rule: abilitata

### Enabled vs Fired

Una Alert Rule in stato **Enabled** significa che la regola è configurata e attiva e che Azure può valutarla.

Questo non significa necessariamente che l'alert sia in stato **Fired**.

`Fired` significa invece che, durante una valutazione, la condizione configurata è stata realmente soddisfatta.

Quindi:

```text
Enabled = la regola è attiva
Fired   = la condizione si è verificata
```

---

## 7. Guasto amministrativo

È stato utilizzato intenzionalmente un nome di Resource Group inesistente:

`rg-ud07-NON-ESISTE`

### Sintomo

Azure CLI non riesce a trovare il Resource Group richiesto.

### Errore

`ResourceGroupNotFound`

### Ipotesi

Le possibili cause considerate sono:

- nome del Resource Group errato;
- Resource Group inesistente;
- subscription Azure non corretta;
- risorsa precedentemente eliminata.

### Controllo

È stato verificato il contesto Azure e confrontato il nome richiesto con il Resource Group realmente esistente:

`rg-ud07-auto`

### Correzione

Non è stato creato il Resource Group inesistente.

La correzione minima consiste nell'utilizzare il nome corretto:

`rg-ud07-auto`

### Verifica

Il Resource Group corretto risulta esistente e in stato:

`Succeeded`

---

## 8. Runbook

# RUNBOOK — Risorsa Azure non trovata o contesto errato

### Sintomo

Un comando Azure CLI restituisce un errore come:

`ResourceGroupNotFound`

oppure non riesce a trovare la risorsa richiesta.

### Contesto

Prima di modificare o creare risorse è necessario verificare che il problema non dipenda semplicemente dal nome utilizzato o dal contesto Azure corrente.

### Controlli

Verificare innanzitutto account e subscription corrente:

```bash
az account show \
  --query "{Name:name,State:state}" \
  --output table
```

Verificare quindi i Resource Group disponibili:

```bash
az group list \
  --query "[].{Name:name,Location:location}" \
  --output table
```

Se necessario, controllare tutte le risorse presenti:

```bash
az resource list \
  --query "[].{Name:name,Type:type,ResourceGroup:resourceGroup}" \
  --output table
```

### Controllo resource ID/name

Il nome e il Resource Group della risorsa devono corrispondere a quelli realmente presenti nella subscription.

Un errore nel nome può produrre `ResourceGroupNotFound` anche se l'ambiente Azure funziona correttamente.

### Activity Log

Per verificare operazioni amministrative recenti:

```bash
az monitor activity-log list \
  --resource-group NOME_RG \
  --offset 1h \
  --query "[].{Time:eventTimestamp,Operation:operationName.localizedValue,Status:status.localizedValue}" \
  --output table
```

L'Activity Log permette di verificare se sulla risorsa sono state effettuate recentemente creazioni, modifiche o eliminazioni.

### Interpretazione

`ResourceGroupNotFound` non significa necessariamente che Azure abbia un problema.

Prima di intervenire bisogna verificare:

- nome del Resource Group;
- subscription corrente;
- esistenza della risorsa;
- eventuale eliminazione precedente;
- correttezza del resource name o resource ID.

### Correzione minima

La correzione deve essere la meno invasiva possibile.

Se il problema è solamente un nome errato, bisogna correggere il nome nel comando.

Non bisogna creare automaticamente una nuova risorsa soltanto per eliminare il messaggio di errore.

Nel test del laboratorio:

```text
nome errato:
rg-ud07-NON-ESISTE

nome corretto:
rg-ud07-auto
```

### Verifica

Dopo la correzione è possibile controllare il Resource Group con:

```bash
az group show \
  --name rg-ud07-auto \
  --query "{Name:name,Location:location,State:properties.provisioningState}" \
  --output table
```

Il Resource Group corretto deve risultare disponibile e in stato:

`Succeeded`

### Cleanup

Le risorse temporanee devono essere eliminate solamente quando non sono più necessarie.

Per il laboratorio autonomo il cleanup previsto riguarda:

`rg-ud07-auto`

e:

`rg-ud07-auto-ps`

Il Resource Group principale UD07 non deve essere eliminato prima della verifica finale.

---

## 9. Cleanup

- `rg-ud07-auto`: non ancora eliminato; mantenuto temporaneamente perché necessario per le verifiche del laboratorio.
- `rg-ud07-auto-ps`: non ancora eliminato; mantenuto temporaneamente perché necessario per le verifiche del laboratorio.

Il cleanup definitivo verrà eseguito dopo la verifica finale del laboratorio.

