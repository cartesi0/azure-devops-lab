# Consegna UD02 — Domande sui concetti

1. Una macchina virtuale lascia più responsabilità al cliente perché, oltre all'applicazione e ai dati, il cliente deve gestire anche il sistema operativo, gli aggiornamenti, la configurazione e il software installato. Con App Service, invece, Microsoft gestisce anche sistema operativo e runtime.

2. Il tenant Microsoft Entra contiene identità e oggetti della directory. La sottoscrizione è il confine amministrativo, di fatturazione e delle risorse Azure. Il resource group è un contenitore logico dentro una sottoscrizione che raggruppa risorse con uno stesso scopo o ciclo di vita.

3. La località del resource group indica dove Azure conserva i metadati del resource group. Non obbliga le risorse contenute a essere nella stessa region, perché ogni risorsa può avere una propria località.

4. Una region è un'area geografica Azure che contiene uno o più datacenter. Una availability zone è invece un gruppo fisicamente separato di datacenter all'interno della stessa region, con alimentazione, rete e raffreddamento indipendenti.

5. `az account show` deve essere eseguito prima di creare una risorsa per verificare quale sottoscrizione è attualmente attiva. In questo modo si evita di creare risorse nella sottoscrizione sbagliata.

6. I tag servono per organizzare, classificare e identificare le risorse, ma non controllano chi può accedere alle risorse. Per questo non devono essere usati come sistema di sicurezza o autorizzazione.

7. Azure CLI permette di eseguire comandi ripetibili, salvarli in script e selezionare precisamente le informazioni necessarie. Il portale è più comodo per esplorare le risorse graficamente, ma le operazioni manuali sono meno facilmente riproducibili.

8. Il comando di eliminazione avvia il processo di rimozione, ma Azure può impiegare del tempo per completarlo. Il cleanup è concluso solo quando si verifica che il resource group o la risorsa non esistano più.
