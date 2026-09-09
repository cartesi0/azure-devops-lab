# Consegna UD02 — Laboratorio autonomo

## Requisito e piano

- requisito interpretato: creare un ambiente Azure temporaneo di sviluppo, separato dal laboratorio guidato, composto da una rete virtuale con subnet e da uno storage account vuoto. Tutte le risorse saranno raccolte in un resource group dedicato per poterle eliminare insieme al termine della prova.

- risorse previste: un resource group dedicato, una VNet `vnet-cea-auto`, una subnet `snet-workload` con prefisso `10.30.10.0/24` e uno storage account StorageV2 Standard_LRS.

- nomi e tag scelti: il resource group userà il prefisso `rg-cea-ud02-auto-` con un suffisso generato automaticamente. Lo storage userà `stceaauto` seguito dallo stesso tipo di suffisso. I tag saranno `course=cloud-engineer-academy`, `unit=UD02`, `environment=dev`, `scenario=autonomous` e `deleteAfter` entro due giorni.

- verifiche preliminari: controllerò la sottoscrizione attiva e il suo stato con `az account show`, recupererò la località già verificata dal file `01_VARIABILI_LAB.sh` e controllerò i nomi generati prima di creare le risorse.

## Svolgimento

Riporta i passaggi essenziali, i controlli da portale e CLI e gli output anonimizzati che dimostrano il risultato.

## Diagnosi

- errore o anomalia analizzata:
- ipotesi:
- controllo:
- correzione:
- verifica successiva:

## Cleanup e consegna

- risorse eliminate:
- controllo finale:
- hash abbreviato e messaggio del commit:

