# Consegna UD05 — Domande sui concetti

Per ciascuna domanda 1–8 riporta una risposta motivata.

1. **Perché due VNet da collegare non devono avere CIDR sovrapposti?**  
   Due VNet da collegare tramite peering o VPN devono avere spazi di indirizzamento distinti. Se usassero gli stessi indirizzi, Azure non riuscirebbe a determinare in modo univoco verso quale rete instradare il traffico destinato a un determinato IP.

2. **Quale rete è più grande, `/24` o `/26`, e perché?**  
   Una rete `/24` è più grande di una `/26`. Con IPv4, una `/24` lascia 8 bit disponibili per gli indirizzi e contiene 256 indirizzi complessivi, mentre una `/26` ne lascia 6 e contiene 64 indirizzi. Quindi, aumentando il numero dopo lo slash, la rete diventa più piccola.

3. **Perché un public IP non garantisce raggiungibilità?**  
   La presenza di un public IP non significa automaticamente che una risorsa sia raggiungibile. Devono essere presenti anche un servizio in ascolto sulla porta corretta, regole NSG che consentano il traffico, route valide e una configurazione corretta del sistema operativo o dell'applicazione.

4. **Come viene scelta una regola NSG tra più corrispondenti?**  
   Le regole NSG vengono valutate in ordine di priorità, partendo dal numero più basso. Quando Azure trova la prima regola che corrisponde al traffico, applica l'azione `Allow` o `Deny` e interrompe la valutazione delle regole successive.

5. **Che cosa significa che un NSG è stateful?**  
   Significa che, quando una connessione viene consentita in una direzione, il traffico di risposta appartenente alla stessa connessione viene consentito automaticamente. Non è quindi necessaria una regola speculare per il traffico di risposta. Questo però non autorizza una nuova connessione indipendente nella direzione opposta.

6. **Perché un `Allow` sulla NIC non supera un `Deny` applicabile sulla subnet?**  
   Se sono presenti NSG sia sulla subnet sia sulla NIC, il traffico deve essere consentito da entrambi. Un `Allow` presente sull'NSG della NIC non può annullare un `Deny` applicato dall'NSG della subnet, perché ogni livello di filtraggio deve permettere il traffico.

7. **Qual è la differenza tra DNS, routing e NSG?**  
   Il DNS traduce un nome in un indirizzo IP. Il routing decide quale percorso deve seguire il traffico per raggiungere una destinazione. L'NSG invece controlla se quel traffico è consentito o negato in base a parametri come origine, destinazione, protocollo e porta. Sono quindi funzioni differenti e una non sostituisce le altre.

8. **Perché IP Flow Verify verrà completato dopo la creazione della VM?**  
   IP Flow Verify ha bisogno di una VM e della relativa interfaccia di rete per verificare concretamente se uno specifico flusso viene consentito o negato. In UD05 possiamo controllare configurazione, NSG, priorità e route effettive delle NIC, ma senza una VM non possiamo eseguire un test completo del traffico reale. La verifica pratica verrà quindi completata in UD06.
