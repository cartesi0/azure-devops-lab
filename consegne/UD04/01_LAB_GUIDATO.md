# Consegna UD04 — Laboratorio guidato

## Contesto anonimizzato

- resource group: `rg-cea-storage-<suffix>`
- storage account: `stcea<suffix>`
- region: `italynorth`
- tipo e ridondanza: `StorageV2 - Standard_LRS`

## Servizi e configurazione

| Elemento | Configurazione | Motivazione |
|---|---|---|
| Blob container | `documents`, privato | Usato per salvare i file del laboratorio |
| access tier | Hot | I file devono essere subito disponibili |
| accesso pubblico | Disabilitato | Non voglio che i Blob siano accessibili in modo anonimo |
| trasferimento/TLS | HTTPS obbligatorio, TLS 1.2 | Per proteggere i dati durante il trasferimento |

## Autorizzazione e lifecycle

Per accedere ai Blob ho assegnato al mio utente il ruolo `Storage Blob Data Contributor` direttamente sullo storage account.

Con `--auth-mode login` ho usato il mio account Microsoft Entra ID, quindi Azure controlla il mio utente e i permessi RBAC prima di farmi lavorare sui dati.

Ho provato anche l'accesso tramite Shared Key. La differenza principale è che la Shared Key è una chiave molto potente e condivisa, quindi va trattata come un segreto. Per questo l'ho usata solo temporaneamente e senza salvarla nei file o nel repository.

Ho creato anche una User Delegation SAS per un solo Blob, con permesso di sola lettura e durata di 30 minuti. Ho verificato che il file si potesse scaricare correttamente tramite la SAS.

Per il lifecycle ho creato la regola `delete-temporary`, che si applica solo ai Blob con prefisso:

`documents/temporary/`

La regola elimina i file dopo 1 giorno dall'ultima modifica. In questo modo i file temporanei non rimangono nello storage inutilmente.

## Verifiche, costi e cleanup

Durante il laboratorio ho verificato:

- la creazione dello storage account;
- il container `documents`;
- il Blob caricato;
- l'upload da CLI di un file temporaneo;
- il download di un Blob usando Entra ID;
- il confronto tra file originale e file scaricato tramite `cmp`;
- il download tramite User Delegation SAS;
- la corretta configurazione della lifecycle policy.

I costi dello Storage possono cambiare in base alla quantità di dati, alla ridondanza scelta, al tier, al numero di operazioni e ai dati trasferiti o recuperati.

Il cleanup finale verrà fatto dopo il laboratorio autonomo e la verifica, perché lo storage account serve ancora per le attività successive.

## Rilevanza professionale

Userei Azure Blob Storage quando devo salvare file come documenti, immagini, log o backup e non mi serve una vera cartella di rete.

Userei invece Azure Files se avessi bisogno di una condivisione SMB/NFS accessibile da più sistemi.

Per l'accesso preferirei Microsoft Entra ID con RBAC rispetto alle Shared Key, perché permette di assegnare permessi più precisi e di sapere quale utente sta effettuando le operazioni.