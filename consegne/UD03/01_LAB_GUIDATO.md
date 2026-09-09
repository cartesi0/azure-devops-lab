# Consegna UD03 — Laboratorio guidato

## Contesto anonimizzato

- sottoscrizione e tenant verificati: sì, sessione Azure CLI autenticata e sottoscrizione attiva
- percorso Entra eseguito: A
- resource group temporaneo: `rg-cea-identity-bb5fae`

## Identità e assegnazione RBAC

| Principal anonimizzato | Ruolo | Scope | Diretta/ereditata | Motivo |
|---|---|---|---|---|
| Gruppo di test | Reader | Resource group del laboratorio | Diretta | Consentire la sola consultazione delle risorse |
| Account amministrativo | Owner | Subscription | Ereditata | Ruolo già presente a livello superiore |

È stato creato un utente cloud temporaneo e un gruppo Security con membership Assigned. L'utente di test è stato aggiunto al gruppo.

Al gruppo è stato assegnato il ruolo Reader direttamente sul resource group del laboratorio.

È stato inoltre osservato che l'account amministrativo dispone di Owner ereditato dalla subscription. Il ruolo Reader non riduce privilegi più ampi già presenti, poiché le autorizzazioni applicabili si combinano.

## Governance e costi

- tag e significato: sono stati applicati tag per identificare corso, unità, ambiente di laboratorio e data prevista di cleanup. Il tag `deleteAfter` è solo informativo e non elimina automaticamente le risorse.
- lock e operazione impedita: creato `lock-cea-delete` di tipo `CanNotDelete`; il tentativo di eliminazione del resource group è stato bloccato con errore `ScopeLocked`.
- stato di Cost Analysis: osservato il costo del resource group; essendo privo di risorse a consumo il costo può risultare pari a zero.
- budget creato o limitazione documentata: creato budget mensile da 10 € con alert all'80% del costo effettivo.
- motivo per cui il budget non blocca la spesa: il budget genera notifiche al superamento delle soglie ma non arresta automaticamente le risorse o i consumi.

## Cleanup

Da eseguire al termine del laboratorio autonomo e della verifica.

## Rilevanza professionale

L'autenticazione verifica l'identità dell'utente. Azure RBAC stabilisce quali operazioni quell'identità può eseguire e su quale scope. Un resource lock aggiunge invece una protezione di governance, ad esempio impedendo l'eliminazione anche quando l'utente dispone di autorizzazioni elevate.


