# Consegna UD04 — Laboratorio autonomo

## Scelta del servizio e della ridondanza

Il requisito è conservare documenti applicativi privati consultati frequentemente e accessibili come oggetti. Ho scelto **Azure Blob Storage** perché è adatto alla memorizzazione di file e oggetti accessibili tramite HTTP/API. Azure Files sarebbe più indicato per condivisioni SMB/NFS, Queue per messaggi tra componenti applicativi e Table per dati NoSQL strutturati.

Per il laboratorio è sufficiente **LRS**, perché mantiene più copie locali con costo inferiore ed è adeguato a un ambiente didattico. In produzione, se il requisito include la resilienza al guasto di una Availability Zone, sceglierei **ZRS**, che replica i dati tra più zone della stessa regione.

## Operazioni e verifica

- Storage account: StorageV2, ridondanza LRS, HTTPS obbligatorio, TLS 1.2, accesso pubblico Blob disabilitato.
- Container creato: `archive`.
- Accesso del container: privato, senza accesso anonimo.
- Autenticazione usata per le operazioni sui Blob: Microsoft Entra ID con `--auth-mode login`.
- Blob caricato: `current/documento.txt`, copia di `consegne/UD04/01_DOCUMENTO_LAB.txt`.
- Verifica eseguita con elenco Blob: nome corretto, tier Hot e dimensione coerente con il file sorgente (49 byte).
- SAS: **User Delegation SAS** limitata al singolo Blob, permesso di sola lettura (`r`) e durata massima di 15 minuti.
- Esito test SAS: lettura consentita; nessun token o URL SAS riportato nel repository.
- Esito test accesso anonimo: negato.
- La variabile contenente la SAS è stata rimossa dalla shell al termine del test.

## Diagnosi

### `AuthorizationPermissionMismatch`

- **Sintomo:** l'operazione sul Blob viene rifiutata.
- **Piano interessato:** data plane.
- **Causa possibile:** l'identità Entra non possiede un ruolo dati adeguato, lo scope è errato oppure l'assegnazione RBAC non è ancora propagata.
- **Controllo:** verificare identità corrente, ruolo assegnato e scope con `az role assignment list`.
- **Correzione:** assegnare il ruolo dati minimo necessario allo scope corretto e attendere l'eventuale propagazione RBAC.

### `ResourceNotFound: The specified container does not exist`

- **Sintomo:** Azure non trova il container richiesto.
- **Piano interessato:** data plane.
- **Causa possibile:** nome del container errato, storage account errato oppure container non creato.
- **Controllo:** elencare i container dello storage account con autenticazione Entra.
- **Correzione:** usare account e nome corretti oppure creare il container previsto.

### `curl: (22) The requested URL returned error: 403`

- **Sintomo:** la richiesta HTTP viene rifiutata con `403 Forbidden`.
- **Piano interessato:** data plane.
- **Causa possibile:** SAS scaduta, permesso mancante, firma non valida oppure tentativo di accesso anonimo a un Blob privato.
- **Controllo:** verificare scadenza, permessi e risorsa coperta dalla SAS senza stampare il token.
- **Correzione:** generare una nuova SAS a minimo privilegio per la risorsa corretta oppure autenticarsi con Entra ID.

## Lifecycle, costi e cleanup

La lifecycle rule con prefisso `documents/temporary/` seleziona soltanto i Blob il cui percorso corrisponde a quel prefisso. Il Blob `archive/current/documento.txt` non corrisponde al filtro e quindi non viene interessato da quella regola.

I principali driver di costo sono: quantità di dati archiviati, tipo di ridondanza, access tier, numero e tipo di operazioni, eventuale recupero dei dati dai tier meno frequenti e trasferimento dati in uscita. Le policy di lifecycle possono ridurre i costi spostando o eliminando automaticamente i Blob quando previsto.

Il cleanup viene eseguito soltanto dopo aver completato verifiche ed evidenze: rimozione immediata delle variabili temporanee contenenti SAS o credenziali, rimozione degli eventuali ruoli temporanei e, al termine dell'intera UD04, eliminazione delle risorse di laboratorio non più necessarie. Le risorse non sono state eliminate prima della verifica per consentire i controlli finali.

## Risultato finale

- nessun segreto pubblicato: **verificato**; account key, password, token e URL SAS non sono presenti nel file;
- hash abbreviato e messaggio del commit: `e6149c6` — `Completa laboratorio autonomo UD04 Azure Storage`.
