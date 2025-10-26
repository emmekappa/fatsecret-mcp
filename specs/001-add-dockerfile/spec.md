# Feature Specification: Dockerized Execution

**Feature Branch**: `[001-add-dockerfile]`  
**Created**: 2025-10-26  
**Status**: Draft  
**Input**: User description: "Rendere il server MCP eseguibile in container: fornire un Dockerfile per build ed esecuzione, supporto configurazione via variabili d'ambiente e/o volume, command/entrypoint per avvio server, documentare run e health check."

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - Build & Run Container (Priority: P1)

Come contributor, voglio costruire un'immagine container del server e avviarla con un singolo comando, così posso eseguirlo senza installare tool locali.

**Why this priority**: Sblocca l'esecuzione in ambienti standardizzati e facilita l'adozione.

**Independent Test**: Da repo pulito, eseguire i comandi documentati per build e run; il container parte e il processo server è attivo, con log iniziali visibili.

**Acceptance Scenarios**:

1. Given la repository clonata, When eseguo il comando di build documentato, Then l'immagine viene creata senza errori.
2. Given l'immagine costruita, When la avvio con il comando documentato, Then il processo server parte e rimane in esecuzione.

---

### User Story 2 - Config tramite ENV/Volume (Priority: P1)

Come operatore, voglio fornire le credenziali via variabili d'ambiente o montando un file di configurazione in volume, così posso gestire i segreti e la persistenza in modo sicuro.

**Why this priority**: Gestione sicura e flessibile delle credenziali.

**Independent Test**: Avviare il container impostando ENV per client ID/secret e verificare che il server le usi; ripetere montando un file di configurazione su path previsto e verificare che venga letto/aggiornato.

**Acceptance Scenarios**:

1. Given CLIENT_ID e CLIENT_SECRET passati via ENV, When avvio il container, Then il server li carica correttamente senza richiederli interattivamente.
2. Given un volume montato contenente un file di configurazione valido, When avvio il container, Then il server legge la configurazione e può aggiornare token/persistenza nel volume.

---

### User Story 3 - Health Check & Osservabilità (Priority: P2)

Come DevOps, voglio un healthcheck del container e log su stdout/stderr, così posso monitorare lo stato e integrare con orchestratori.

**Why this priority**: Affidabilità operativa e integrazione con piattaforme.

**Independent Test**: Healthcheck del container restituisce stato "healthy" in condizioni normali; log strutturati/chiari sono disponibili su stdout/stderr all'avvio ed in caso di errore.

**Acceptance Scenarios**:

1. Given il container avviato, When l'healthcheck viene eseguito, Then restituisce 0/healthy quando il processo server è pronto.
2. Given un errore di configurazione, When il server fallisce l'avvio, Then il container esce con codice ≠ 0 e log descrittivi sono visibili su stderr.

---

### Edge Cases

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right edge cases.
-->

- Nessuna credenziale fornita: il container deve gestire l'assenza di CLIENT_ID/CLIENT_SECRET con errore chiaro.
- Volume di configurazione in sola lettura: il server non deve crashare silenziosamente; messaggio d'errore comprensibile quando non può salvare token.
- Permessi file/utente nel container: garantire che l'utente del processo possa leggere/scrivere il file di configurazione nel volume.
- Clock/Timezone nel container: evitare effetti collaterali su generazione timestamp; documentare uso del fuso orario UTC.
- Rete/Proxy: documentare come configurare variabili standard (es. HTTP(S)_PROXY) se necessarie.

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

- **FR-001**: Il progetto DEVE fornire un Dockerfile per costruire un'immagine eseguibile del server MCP con dimensioni ragionevoli.
- **FR-002**: L'immagine DEVE esporre un entrypoint/command che avvii il server MCP; DEVE offrire una modalità alternativa per avviare l'utility OAuth console.
- **FR-003**: Il runtime DEVE supportare configurazione tramite variabili d'ambiente (CLIENT_ID, CLIENT_SECRET) senza input interattivo.
- **FR-004**: Il runtime DEVE supportare persistenza configurazione/token tramite un volume montato; il path di configurazione DEVE essere documentato.
- **FR-005**: DEVE esistere un meccanismo di override del path di configurazione tramite variabile d'ambiente (es.: FATSECRET_CONFIG_PATH) per evitare vincoli della home nel container.
- **FR-006**: L'immagine DEVE includere un healthcheck che restituisca stato "healthy" quando il processo è pronto (p.es., verifica del processo vivo e/o comando diagnostico rapido documentato).
- **FR-007**: Log di avvio/errore DEVONO essere emessi su stdout/stderr in modo leggibile.
- **FR-008**: La documentazione DEV'ESSERE aggiornata con istruzioni di build, run, esempi ENV/volume e interpretazione healthcheck.

### Key Entities *(include if feature involves data)*

- **Container Image**: immagine contenente il server e le dipendenze, con entrypoint configurato.
- **Configuration File**: file di configurazione e token dell'utente persistiti su volume, accessibile dal processo.

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: Un contributor può costruire l'immagine dal repository in meno di 3 minuti su hardware di sviluppo tipico (prima build a caldo esclusa).
- **SC-002**: Un operatore può avviare il server in container passando solo variabili d'ambiente e vedere il processo attivo con log iniziali in meno di 30 secondi.
- **SC-003**: Montando un volume per la configurazione, i token vengono scritti/aggiornati nel volume senza errori di permessi nel 100% dei tentativi di base.
- **SC-004**: L'healthcheck del container passa in condizioni normali entro 10 secondi dall'avvio; in caso di errore di configurazione l'healthcheck fallisce e il container termina con codice ≠ 0.

## Constitution Compliance *(mandatory)*

Document how this feature complies with repository-wide quality gates.

- **Testing & Coverage**: Piano per aggiungere smoke test del build Docker (esecuzione di build in CI con cache) e test del comando di healthcheck in un job dedicato; target di copertura invariati per parti di codice modificate (≥90% linee, ≥80% rami); nessun waiver previsto.
- **Type Safety & Contracts**: Nessun cambiamento di contratto pubblico; eventuale supporto a FATSECRET_CONFIG_PATH introdotto con tipi espliciti e validazione runtime dell'input ENV.
- **Linting & Formatting**: Dockerfile e script associati rispettano lint/format dove applicabile; nessuna soppressione prevista.
- **Errors & Observability**: Errori di avvio per credenziali/permessi producono messaggi chiari su stderr; healthcheck fornisce segnale affidabile allo scheduler.
- **Security Hygiene**: Credenziali passate solo via ENV/secret manager o file montato; niente segreti baked nell'immagine; dipendenze container aggiornate a patch LTS.
