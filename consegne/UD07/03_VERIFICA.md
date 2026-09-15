# UD07 — Verifica individuale

## Parte A — Scelta singola

### 1. In Azure CLI, quale opzione estrae proprietà dall'output strutturato?

**Risposta: A. `--query`**

`--query` permette di selezionare proprietà specifiche dall'output JSON restituito dai comandi Azure CLI.

---

### 2. Quale formato è particolarmente utile per assegnare un singolo valore a una variabile Bash?

**Risposta: B. `tsv`**

`tsv` restituisce valori semplici senza virgolette o struttura JSON, quindi è molto comodo per assegnazioni come:

```bash
RG=$(az group show --name nome-rg --query name -o tsv)
```

---

### 3. PowerShell lavora principalmente con:

**Risposta: B. oggetti**

PowerShell passa oggetti strutturati tra i comandi, non soltanto testo.

---

### 4. Activity Log riguarda principalmente:

**Risposta: A. eventi del control plane della subscription**

L'Activity Log registra operazioni amministrative sulle risorse Azure, ad esempio creazioni, aggiornamenti ed eliminazioni.

---

### 5. Una diagnostic setting serve a:

**Risposta: B. instradare segnali diagnostici verso destinazioni**

Una Diagnostic Setting può inviare log e altri segnali verso destinazioni come Log Analytics Workspace, Storage Account o Event Hub.

---

### 6. Quale linguaggio si usa normalmente per interrogare Log Analytics?

**Risposta: B. KQL**

KQL, Kusto Query Language, viene utilizzato per interrogare e analizzare i dati presenti in Log Analytics.

---

### 7. Un Action Group definisce principalmente:

**Risposta: B. notifiche e azioni associate agli alert**

Un Action Group stabilisce cosa deve succedere quando un alert scatta, ad esempio inviare una email o avviare un'azione automatizzata.

---

### 8. Una metric alert rule in stato Enabled:

**Risposta: B. viene valutata, ma può non essere Fired**

`Enabled` significa che la regola è attiva. `Fired` significa invece che la condizione configurata si è effettivamente verificata.

---

## Parte B — Risposte brevi

### 9. Distingui Activity Log, Metrics e Logs.

**Activity Log** registra le operazioni amministrative effettuate sulle risorse Azure, quindi eventi del control plane come creazione, modifica o eliminazione.

**Metrics** sono valori numerici raccolti nel tempo, ad esempio numero di transazioni, disponibilità, latenza o capacità utilizzata.

**Logs** sono dati più dettagliati e strutturati che possono essere raccolti e analizzati in Log Analytics tramite KQL.

In sintesi:

```text
Activity Log = cosa è stato fatto sulla risorsa
Metrics      = come si comporta numericamente la risorsa
Logs         = dettagli interrogabili e analizzabili
```

---

### 10. Spiega l'idempotenza con un esempio amministrativo.

Uno script è idempotente quando può essere eseguito più volte senza creare duplicati o produrre risultati indesiderati.

Nel laboratorio, lo script controlla prima se `rg-ud07-auto` esiste:

```bash
az group exists --name "$RG"
```

Se non esiste lo crea; se esiste lo riutilizza.

Quindi:

```text
prima esecuzione  → crea il Resource Group
seconda esecuzione → riutilizza lo stesso Resource Group
```

Lo stato finale rimane quello desiderato.

---

### 11. Distingui `table` e `tsv`.

`table` è pensato soprattutto per la lettura da parte di una persona perché mostra i dati in colonne leggibili.

`tsv` restituisce valori semplici senza intestazioni e senza struttura JSON, quindi è più adatto agli script e alle variabili Bash.

Esempio:

```bash
az group show --name rg-ud07-auto --query name -o table
```

è utile per leggere il risultato.

```bash
RG=$(az group show --name rg-ud07-auto --query name -o tsv)
```

è utile per salvare il risultato in una variabile.

---

### 12. Spiega perché Log Analytics workspace e diagnostic setting non sono la stessa cosa.

Il **Log Analytics Workspace** è la destinazione in cui i dati possono essere raccolti, conservati e interrogati con KQL.

La **Diagnostic Setting** è invece la configurazione che decide quali segnali inviare e verso quale destinazione.

Quindi:

```text
Diagnostic Setting
        ↓
invia i dati
        ↓
Log Analytics Workspace
```

Il workspace è il contenitore/ambiente di analisi; la Diagnostic Setting è il meccanismo di instradamento.

---

### 13. Distingui Alert Rule e Action Group.

La **Alert Rule** definisce la condizione da controllare.

Esempio del laboratorio:

```text
Transactions > 0
```

L'**Action Group** definisce invece cosa fare quando la regola genera un alert, ad esempio inviare una notifica.

Quindi:

```text
Alert Rule   = quando deve scattare l'allarme
Action Group = cosa fare quando scatta
```

---

### 14. Perché correlazione temporale non implica causalità?

Due eventi che avvengono vicini nel tempo possono essere correlati, ma questo non dimostra che uno abbia causato l'altro.

Per affermare una causalità bisogna raccogliere ulteriori evidenze, ad esempio confrontare log, metriche, configurazioni, dipendenze e comportamento prima e dopo la modifica.

---

## Parte C — Scenario

> Alle 10:15 una risorsa Azure viene modificata. Alle 10:16 l'Activity Log mostra una `write` riuscita. Alle 10:20 una metrica aumenta e alle 10:25 un alert passa a Fired.

### 15. Quali fatti puoi affermare con certezza?

Posso affermare con certezza che:

- alle 10:15 è stata effettuata una modifica sulla risorsa;
- alle 10:16 l'Activity Log ha registrato una operazione `write` riuscita;
- alle 10:20 la metrica osservata è aumentata;
- alle 10:25 la condizione dell'alert è stata soddisfatta e l'alert è passato a `Fired`.

Posso quindi affermare che questi eventi sono avvenuti in questa sequenza temporale.

Non posso però affermare, basandomi soltanto su questi dati, che la modifica delle 10:15 abbia causato l'aumento della metrica o l'alert.

---

### 16. Quale ulteriore analisi è necessaria prima di affermare che la modifica delle 10:15 ha causato l'alert?

È necessario analizzare ulteriori evidenze, ad esempio:

- il dettaglio della modifica eseguita alle 10:15;
- i log della risorsa prima e dopo la modifica;
- l'andamento della metrica prima e dopo l'evento;
- la condizione esatta configurata nell'Alert Rule;
- eventuali altre modifiche o eventi avvenuti nello stesso intervallo;
- eventuali dipendenze della risorsa;
- la presenza di traffico o carico applicativo che potrebbe spiegare l'aumento della metrica.

Solo dopo aver verificato questi elementi si può valutare se esiste un legame causale tra la modifica e l'alert.

