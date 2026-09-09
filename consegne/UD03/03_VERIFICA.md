# Consegna UD03 — Verifica

## Parte A — Scelta singola

1. **B. L'autenticazione è riuscita, ma manca un'autorizzazione applicabile.**

   Se l'utente è riuscito ad accedere al portale significa che è stato autenticato. Il problema riguarda quindi i permessi che possiede sul resource group.

2. **D. Password.**

   Una role assignment Azure è composta da principal, role definition e scope. La password non fa parte dell'assegnazione del ruolo.

3. **C. Reader sul resource group.**

   Se il team deve soltanto consultare le risorse, Reader è sufficiente e permette di rispettare il principio del minimo privilegio.

4. **B. Ereditato.**

   Un ruolo assegnato sulla subscription viene normalmente ereditato dai resource group e dalle risorse che si trovano al suo interno.

5. **B. Contributor.**

   Contributor permette di creare e modificare le risorse, ma normalmente non permette di assegnare ruoli ad altri utenti.

6. **C. Impedisce l'eliminazione finché applicabile.**

   Il lock CanNotDelete serve a proteggere la risorsa dalla cancellazione. Non sostituisce RBAC e non impedisce le normali operazioni di lettura.

7. **B. Genera una condizione di notifica, ma non costituisce un tetto automatico.**

   Un budget permette di controllare i costi e ricevere avvisi, ma non ferma automaticamente le risorse quando viene raggiunto.

8. **B. Microsoft Entra ID con ruolo appropriato.**

   Gli utenti cloud vengono gestiti tramite Microsoft Entra ID. Azure RBAC viene invece utilizzato per assegnare l'accesso alle risorse Azure.

## Parte B — Risposte brevi

9. Assegnare i ruoli a un gruppo è più semplice da gestire rispetto alle assegnazioni fatte singolarmente agli utenti. Se entra una nuova persona nel team è sufficiente aggiungerla al gruppo, mentre se una persona lascia il team basta rimuoverla. In questo modo non è necessario modificare ogni volta le singole assegnazioni RBAC.

10. Un ruolo Microsoft Entra riguarda la gestione della directory e delle identità. Ad esempio, User Administrator può gestire gli utenti di Microsoft Entra.

    Un ruolo Azure riguarda invece l'accesso alle risorse Azure. Ad esempio, Reader permette di consultare le risorse presenti nello scope sul quale viene assegnato.

11. L'utente avrà di fatto i permessi di Contributor sul resource group. Il ruolo Contributor arriva dalla subscription e viene ereditato dal resource group. Il Reader assegnato direttamente sul resource group non elimina né limita i permessi più elevati già ricevuti.

12. Per diagnosticare un errore `AuthorizationFailed` controllerei:

    1. che Azure CLI sia autenticata e che l'account utilizzato sia quello corretto;
    2. che sia selezionata la subscription corretta;
    3. lo scope sul quale sto tentando di eseguire l'operazione;
    4. i ruoli assegnati direttamente e quelli ereditati;
    5. che il ruolo posseduto contenga effettivamente il permesso richiesto dall'operazione.

13. Il tag `deleteAfter` è solamente un'informazione associata alla risorsa e può essere utilizzato, ad esempio, per indicare quando effettuare il cleanup.

    Il lock `CanNotDelete` è invece una protezione che impedisce l'eliminazione della risorsa finché il lock rimane applicato.

    Il budget serve a monitorare i costi e a generare degli avvisi quando vengono raggiunte determinate soglie, ma non blocca automaticamente la spesa.

## Parte C — Caso situazionale

14. La prima scelta sbagliata è assegnare Contributor sull'intera subscription a una persona che deve solamente consultare una VNet. Sono stati concessi molti più privilegi e su uno scope molto più grande del necessario.

    Un'altra interpretazione errata è pensare che Contributor permetta automaticamente di assegnare ruoli RBAC ad altri utenti.

    Anche l'errore `ScopeLocked` è un problema separato dai permessi Contributor: indica la presenza di un resource lock.

15. Se il tecnico deve solamente consultare quella specifica VNet, la soluzione con il minimo privilegio sarebbe assegnargli `Reader` direttamente sulla VNet.

    Se invece dovesse consultare tutte le risorse presenti in `rg-network-prod`, allora sarebbe più appropriato assegnare Reader sul resource group.

16. Il tecnico non riesce ad assegnare Reader al collega perché Contributor permette di gestire le risorse ma non include normalmente il permesso necessario per creare le role assignment.

    Per assegnare ruoli sarebbe necessario un ruolo che contenga i permessi RBAC necessari, assegnato sullo scope corretto.

    L'errore `ScopeLocked`, invece, non dipende da Contributor. Significa che sullo scope che sta tentando di eliminare è presente un lock applicabile, ad esempio `CanNotDelete`.

    Per effettuare il cleanup bisogna prima rimuovere il lock, se si possiedono i permessi per farlo e se la cancellazione è realmente prevista.
