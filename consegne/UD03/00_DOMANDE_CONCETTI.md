# Consegna UD03 — Domande sui concetti

Per ciascuna domanda 1–8 riporta una risposta motivata.

1. **Perché autenticazione riuscita e autorizzazione sufficiente non sono equivalenti?**

   L'autenticazione verifica chi sono, cioè se le mie credenziali sono valide. L'autorizzazione stabilisce invece cosa posso fare dopo essere entrato. Posso quindi accedere correttamente ad Azure ma non avere il permesso di leggere, modificare o eliminare una determinata risorsa.

2. **Quale differenza operativa esiste tra ruolo Microsoft Entra e ruolo Azure?**

   I ruoli Microsoft Entra servono principalmente a gestire gli oggetti della directory, come utenti e gruppi. I ruoli Azure RBAC servono invece a gestire l'accesso alle risorse Azure. Ad esempio, User Administrator può gestire utenti in Entra ID, mentre Reader può leggere le risorse Azure nello scope assegnato.

3. **Quali tre elementi formano una role assignment?**

   Una role assignment è formata da:
   - principal: l'identità a cui viene dato il permesso;
   - role definition: il ruolo e quindi le operazioni consentite;
   - scope: il livello sul quale il ruolo viene applicato.

   In sintesi: principal + ruolo + scope.

4. **Perché Reader su un resource group è preferibile a Contributor sulla sottoscrizione quando serve soltanto consultare quel progetto?**

   Perché applica il principio del minimo privilegio. Reader permette di consultare le risorse senza modificarle e, assegnandolo solo al resource group necessario, limita anche lo scope. Contributor sulla sottoscrizione concederebbe invece molti più permessi e su un numero molto maggiore di risorse rispetto a quanto realmente necessario.

5. **Perché un ruolo ereditato non si rimuove dalla risorsa figlia?**

   Perché l'assegnazione è stata creata a uno scope superiore, ad esempio sulla subscription. La risorsa figlia riceve il ruolo per ereditarietà, ma non possiede direttamente quell'assegnazione. Per rimuoverla bisogna quindi intervenire sullo scope in cui è stata originariamente assegnata.

6. **Un tag `deleteAfter` impedisce l'eliminazione? Motiva.**

   No. `deleteAfter` è soltanto un tag, cioè un'informazione associata alla risorsa. Può indicare quando sarebbe opportuno effettuare il cleanup, ma da solo non esegue nessuna azione e non impedisce l'eliminazione.

7. **Che cosa cambia tra lock `CanNotDelete` e ruolo Reader?**

   Reader è un ruolo RBAC che stabilisce cosa un'identità è autorizzata a fare: permette la lettura ma non la modifica delle risorse. `CanNotDelete` è invece un resource lock di governance che impedisce l'eliminazione dello scope protetto anche a utenti che potrebbero avere permessi elevati. RBAC riguarda quindi le autorizzazioni dell'identità, mentre il lock protegge la risorsa da una specifica operazione.

8. **Perché un budget non è sufficiente a garantire che la spesa non superi una cifra?**

   Perché il budget serve principalmente a monitorare i costi e generare notifiche quando vengono raggiunte determinate soglie. Non spegne automaticamente le risorse e non blocca automaticamente i consumi. Per impedire realmente ulteriori spese servirebbero altre azioni o automazioni.
