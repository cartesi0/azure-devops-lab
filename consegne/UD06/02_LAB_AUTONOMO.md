# UD06 — Consegna laboratorio autonomo

## 1. Baseline

- VM: VM06
- Nginx: active (running) since Tue 2026-09-15 08:03:53 UTC; 54s ago
- HTTP: HTTP/1.1 200 OK
Server: nginx/1.24.0 (Ubuntu)
Date: Tue, 15 Sep 2026 08:25:27 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 15 Sep 2026 08:03:52 GMT
Connection: keep-alive
ETag: "6aa8fbe8-267"
Accept-Ranges: bytes
- regola NSG:   310 Allow-HTTP-MyIP

## 2–4. Guasto, diagnosi, ripristino

- regola introdotta:  250 Disable-HTTP
- sintomo: Connessione HTTP Negata
- ipotesi: Si suppone che le regole del Firewall non siano impostate correttamente
- controllo: tramite il controllo con IP flow verify ho verificato che le seguente regola DisableHTTP non permette l'accesso |250 Disable-HTTP ---- 310 Allow-HTTP-MyIP
- causa:La regola Disable-HTTP ha una priorità più bassa a confronto della regola che permette accesso 310 Allow-HTTP-MYIP
- correzione minima: Rimuovere oppure dare una priorità più alta a Disable-HTTP a confronto di Allow-HTTP-MyIP
- verifica: Dopo aver apportato le modifiche segnalate la connessione http, funziona correttamente: HTTP/1.1 200 OK

## 5. Monitoring

- metrica: CPU
- intervallo: 1 Ora
- aggregazione: La media
- deduzione: Nell'ultima ora la media di lavoro della CPU è di 0.4975%
- cosa non posso dedurre: Non possiamo conoscere le cause dei sovraccarichi

## 6. VMSS Autoscale

- min: 1
- default: 1
- max: 4
- metrica:  % CPU
- condizione: CPU > 70% PER 5 MINUTI
- azione: +1
- perché max= Per avere un limite sui costi:

## 7. App Service scaling

- A: Scale up
- B: Azure Monitor Autoscale
- C: Automatic Scaling
- D: Per una demo voglio semplicemente passare da 1 a 2 istanze manualmente.

## 8. Backup policy

- frequenza: ogni 24 ore
- orario: 23:00
- retention: 1 mese
- motivazione: Per evitare pendita di dati.

## 9. HA / Backup / DR

- A:
- B:
- C:

## 10. RPO / RTO

- RPO:
- RTO:
