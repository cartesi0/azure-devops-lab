# Consegna UD04 — Verifica

## Parte A — Scelta singola

1. **A. Blob** — È il servizio più adatto a immagini e file applicativi gestiti come oggetti e accessibili tramite HTTP/API.
2. **B. Files** — Azure Files fornisce condivisioni file gestite accessibili tramite SMB e, in scenari supportati, NFS.
3. **B. No, serve un ruolo del piano dati** — Il ruolo Contributor sullo storage account consente di gestire la risorsa, ma non concede automaticamente l'accesso ai Blob tramite Entra ID.
4. **B. ZRS** — Replica i dati tra più Availability Zone della stessa regione e protegge dal guasto di una singola zona.
5. **B. SAS** — Una Shared Access Signature permette di delegare accesso con permessi, risorsa e durata limitati.
6. **C. segnala una soglia ma non blocca i consumi** — Un budget serve al monitoraggio dei costi e alle notifiche, non elimina dati né impedisce automaticamente la spesa.
7. **B. soltanto Blob che corrispondono al filtro** — Il prefisso limita l'applicazione della lifecycle rule ai Blob che iniziano con il percorso indicato.
8. **A. rende esplicito l'uso dell'identità Entra** — `--auth-mode login` fa usare le credenziali dell'identità autenticata invece di affidarsi a una account key.

## Parte B — Risposte brevi

9. **Ridondanza e backup:** la ridondanza mantiene copie dei dati per aumentare disponibilità e durabilità in caso di guasti infrastrutturali. Il backup conserva una copia separata o una versione recuperabile nel tempo e serve anche a ripristinare dati cancellati, modificati o corrotti. La replica non sostituisce il backup perché una modifica o cancellazione può essere replicata sulle copie.

10. **Management plane e data plane:** il management plane riguarda la creazione e configurazione della risorsa Azure, per esempio `az storage account show --name <account> --resource-group <rg>`. Il data plane riguarda le operazioni sui dati contenuti nello storage, per esempio `az storage blob list --account-name <account> --container-name <container> --auth-mode login`.

11. Una SAS a minimo privilegio deve avere almeno: **scope limitato alla risorsa necessaria**, **solo i permessi indispensabili** (per esempio `r`), **scadenza breve**, **uso di HTTPS**. Quando possibile è preferibile una User Delegation SAS basata su Entra ID invece di una SAS firmata con account key.

12. **Archive** non è adatto a dati da recuperare immediatamente perché i Blob non sono disponibili online per la lettura diretta: devono prima essere reidratati verso un tier online. L'operazione può richiedere ore, quindi Archive è adatto a dati consultati molto raramente.

13. Account key e SAS sono segreti di accesso. Se vengono salvati nel repository possono essere copiati dalla cronologia Git e usati da persone non autorizzate. Devono essere mantenuti fuori dal codice e dal repository, usando variabili temporanee o sistemi dedicati alla gestione dei segreti.

## Parte C — Caso situazionale

14. I problemi sono almeno quattro:
   - assegnare solo **Contributor** non concede automaticamente accesso ai Blob tramite Entra ID, perché è un ruolo del management plane;
   - omettere `--auth-mode login` non rende esplicito l'uso dell'identità Entra e può portare a usare modalità di autenticazione differenti da quella prevista;
   - condividere una **account key** espone una credenziale molto potente e non segue il principio del minimo privilegio;
   - creare una SAS con permessi completi e durata eccessiva aumenta inutilmente superficie e durata dell'accesso.

15. Per utenti che devono soltanto leggere documenti userei **Storage Blob Data Reader** allo scope minimo necessario, per esempio il container contenente i documenti. Per un operatore che deve anche caricare o modificare Blob userei **Storage Blob Data Contributor**. Le operazioni CLI verrebbero eseguite con Entra ID e `--auth-mode login`. Per un accesso temporaneo a un singolo Blob userei una **User Delegation SAS** di sola lettura e con scadenza breve.

16. Verificherei l'accesso con comandi del data plane usando `--auth-mode login`, senza stampare credenziali o token. Per una SAS controllerei che la lettura del Blob riesca e che un'operazione non autorizzata, come la scrittura con una SAS read-only, venga rifiutata. Verificherei inoltre che l'accesso anonimo sia negato. Al termine rimuoverei dalla shell le variabili temporanee, eliminerei gli eventuali role assignment creati solo per la prova e, dopo aver raccolto le evidenze, cancellerei le risorse di laboratorio non più necessarie. Nessun token, URL SAS, account key o password deve essere inserito nel repository.
