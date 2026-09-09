# Consegna UD03 — Laboratorio autonomo

## Scenario realizzato

Per questo laboratorio ho simulato uno scenario in cui un team FinOps deve poter controllare le risorse e i costi di un ambiente Azure, senza però avere la possibilità di modificare o eliminare le risorse.

Ho creato un gruppo Microsoft Entra chiamato `grp-finops-bb5fae` e ho aggiunto al gruppo l'utente di test creato precedentemente.

Per separare questo scenario dal laboratorio guidato ho creato anche un nuovo resource group:

`rg-finops-app-bb5fae`

Su questo resource group ho assegnato al gruppo FinOps il ruolo `Reader`.

In questo modo gli utenti appartenenti al gruppo possono consultare le risorse presenti nell'ambiente, ma non possono modificarle.

Ho scelto Reader invece di Contributor o Owner perché questi ultimi avrebbero dato più permessi di quelli realmente necessari.

## Analisi degli accessi

Durante la verifica degli accessi ho trovato due situazioni differenti.

| Chi | Ruolo | Dove è stato assegnato | Tipo | Accesso sul resource group FinOps |
|---|---|---|---|---|
| Account amministrativo | Owner | Subscription | Ereditato | Può gestire completamente il resource group |
| Gruppo FinOps | Reader | `rg-finops-app-bb5fae` | Diretto | Può consultare le risorse ma non modificarle |

Il mio account amministrativo possiede il ruolo Owner sulla subscription. Di conseguenza questo permesso viene ereditato anche dai resource group presenti al suo interno.

Il gruppo FinOps invece ha ricevuto Reader direttamente sul resource group `rg-finops-app-bb5fae`.

Questo mi ha permesso di vedere nella pratica la differenza tra un ruolo assegnato direttamente su una risorsa e un ruolo ereditato da uno scope superiore.

È importante anche notare che assegnare Reader non riduce eventuali permessi più elevati già presenti. Ad esempio, un utente che possiede già Owner sulla subscription continua ad avere i privilegi di Owner anche se riceve Reader su un resource group.

## Controllo dei costi

Sul resource group FinOps ho creato un budget mensile di 10 euro.

Ho configurato un avviso all'80%, quindi al raggiungimento di 8 euro Azure può inviare una notifica.

Il budget però non rappresenta un vero limite di spesa.

Se il costo supera i 10 euro, Azure non spegne automaticamente le risorse e non impedisce ulteriori consumi. Il budget serve principalmente per monitorare la spesa e ricevere degli avvisi.

## Protezione del resource group

Per evitare eliminazioni accidentali ho applicato al resource group un lock di tipo `Delete`, cioè `CanNotDelete`.

Ho poi verificato il comportamento provando a eliminare il resource group.

Azure ha impedito l'operazione restituendo un errore `ScopeLocked`.

Successivamente ho verificato che il resource group fosse ancora leggibile normalmente.

Questo dimostra che il lock impedisce la cancellazione, ma non impedisce la normale consultazione delle risorse.

## Diagnosi di alcuni errori

### Caso A — Azure CLI non autenticata

Messaggio:

`Please run 'az login' to setup account.`

Questo errore indica che Azure CLI non dispone di una sessione di autenticazione valida.

Per controllare lo stato dell'account posso utilizzare:

`az account show --output table`

Se la sessione non è valida, è necessario eseguire nuovamente:

`az login`

Dopo il login Azure CLI dovrebbe mostrare correttamente l'account e la subscription utilizzata.

### Caso B — AuthorizationFailed

Messaggio:

`AuthorizationFailed ... Microsoft.Authorization/roleAssignments/write ...`

In questo caso l'utente è autenticato, ma non possiede i permessi necessari per creare una nuova assegnazione RBAC.

Per verificare i ruoli presenti posso utilizzare:

`az role assignment list --scope "$FINOPS_SCOPE" --include-inherited --output table`

La soluzione non è assegnare automaticamente Owner all'utente, ma verificare quale permesso manca e concedere soltanto quello necessario sullo scope corretto.

### Caso C — ScopeLocked

Messaggio:

`ScopeLocked: The scope is locked and can't be deleted.`

Questo errore indica che sulla risorsa è presente un lock che impedisce l'eliminazione.

Il lock può essere verificato con:

`az lock list --resource-group "$FINOPS_RG" --output table`

Se l'eliminazione è realmente necessaria, bisogna prima rimuovere il lock e successivamente ripetere l'operazione.

## Differenza tra autenticazione, RBAC e lock

Durante il laboratorio ho visto tre meccanismi diversi.

L'autenticazione serve a verificare chi sta accedendo ad Azure.

RBAC serve invece a stabilire cosa può fare quell'utente e su quali risorse.

Il resource lock è un ulteriore livello di protezione che può impedire determinate operazioni, come la cancellazione di un resource group.

Il budget riguarda invece il controllo dei costi e non modifica direttamente i permessi degli utenti.

## Cleanup

Al termine del laboratorio dovrò rimuovere gli oggetti temporanei creati.

La sequenza prevista è:

- [ ] eliminare il budget del resource group FinOps;
- [ ] rimuovere l'assegnazione Reader del gruppo FinOps;
- [ ] rimuovere il lock dal resource group;
- [ ] rimuovere l'utente di test dal gruppo FinOps;
- [ ] eliminare il gruppo `grp-finops-bb5fae`;
- [ ] eliminare il resource group `rg-finops-app-bb5fae`;
- [ ] verificare che il resource group non esista più;
- [ ] completare anche il cleanup degli oggetti temporanei creati nel laboratorio guidato.

## Conclusione

Questo laboratorio mi ha permesso di capire meglio come collegare un gruppo Microsoft Entra alle risorse Azure tramite RBAC.

La parte più importante è stata distinguere il ruolo assegnato direttamente al gruppo FinOps dal ruolo Owner che il mio account eredita dalla subscription.

Ho inoltre verificato nella pratica il funzionamento di budget e resource lock, che servono rispettivamente al controllo dei costi e alla protezione delle risorse da cancellazioni accidentali.
