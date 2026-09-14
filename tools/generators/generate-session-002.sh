#!/usr/bin/env bash
#
# generate-session-002.sh
# Persistence script for Session S002 - Layered Architecture Style
# (Principal Engineer Accelerator Path)
#
# This script lives at: <repo>/tools/generators/generate-session-002.sh
# It must be safe to run more than once (idempotent): re-running it must
# not duplicate entries or corrupt docs/dashboard.md, docs/current-state.md
# or docs/learning-journal.md, and must not create duplicate git branches.
#
# It never runs `git add`, `git commit`, or `git push`. It only ever runs
# `git checkout` / `git checkout -b` to place the repo on the session
# branch before writing files.

set -euo pipefail

CODE="S002"
TITLE="Layered Architecture Style"
PHASE_NUM="1"
PHASE_NAME="Engineering Foundations"
MODULE_NUM="1"
MODULE_NAME="Modern Software Engineering"
BRANCH="session/${CODE}"

# ── 1. Path resolution ──────────────────────────────────────────────────
# The script must work no matter which directory it's invoked from, and
# no matter whether it's run directly or through a symlink.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

HAS_GIT=false
if git -C "$SCRIPT_DIR" rev-parse --show-toplevel >/dev/null 2>&1; then
  REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"
  HAS_GIT=true
else
  # Fallback: this script is expected to live at tools/generators/ inside
  # the repo, so the repo root is two levels above the script.
  REPO_ROOT="$(cd "$SCRIPT_DIR/../.." >/dev/null 2>&1 && pwd)"
  echo "WARNING: no git repository detected at or above '$SCRIPT_DIR'." >&2
  echo "         Falling back to REPO_ROOT='$REPO_ROOT' (two levels" >&2
  echo "         above the script, assuming tools/generators/ layout)." >&2
  echo "         Continuing WITHOUT creating/checking out a git branch." >&2
fi

echo "REPO_ROOT resolved to: $REPO_ROOT"

# ── 2. Git branch (only if a repo was actually detected) ────────────────
if [ "$HAS_GIT" = true ]; then
  if git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/${BRANCH}"; then
    echo "Branch '${BRANCH}' already exists — checking it out."
    git -C "$REPO_ROOT" checkout "${BRANCH}"
  else
    echo "Creating branch '${BRANCH}'."
    git -C "$REPO_ROOT" checkout -b "${BRANCH}"
  fi
fi

# ── 3. Target paths ──────────────────────────────────────────────────────
THEORY_DIR="$REPO_ROOT/docs/theory"
SESSIONS_DOC_DIR="$REPO_ROOT/docs/sessions"
ADR_DIR="$REPO_ROOT/docs/adrs"
SITE_SESSIONS_DIR="$REPO_ROOT/site/sessions"
DASHBOARD_FILE="$REPO_ROOT/docs/dashboard.md"
CURRENT_STATE_FILE="$REPO_ROOT/docs/current-state.md"
JOURNAL_FILE="$REPO_ROOT/docs/learning-journal.md"

mkdir -p "$THEORY_DIR" "$SESSIONS_DOC_DIR" "$ADR_DIR" "$SITE_SESSIONS_DIR" "$REPO_ROOT/docs"

# ── 4. docs/theory/Theory-002.md (Spanish — theory portion only) ────────
cat > "$THEORY_DIR/Theory-002.md" <<'THEORY_EOF'
# Theory-002 — Layered Architecture Style

*(Extracto teórico de Session-002.es.md — Main Topic + Sub topics.
Fuente de la verdad para el contenido completo: Session-002.es.md /
docs/sessions/Session-002.md)*

## Main Topic

### 1. ¿Qué es la Arquitectura por Capas (Layered / N-Tier)?
Una arquitectura por capas organiza el sistema en niveles horizontales,
donde cada capa tiene una responsabilidad específica y se comunica
típicamente solo con la capa inmediatamente inferior. El patrón no
prescribe un número fijo de capas, pero la variante más citada en la
literatura usa cuatro: **Presentación**, **Negocio/Aplicación**,
**Persistencia** y **Base de Datos**.

**Layers vs. Tiers:**
- **Layer (capa):** separación **lógica** del código.
- **Tier (nivel):** separación **física/de despliegue**.

Un monolito bien diseñado casi siempre está organizado internamente en
3-4 capas (un único tier, múltiples layers). Un N-Tier "clásico"
despliega esas mismas capas lógicas en máquinas separadas — pero el
número de capas lógicas no cambia solo porque se despliegue en más o
menos tiers.

### 2. Layering Estricto (Closed) vs. Relajado (Open)
- **Closed (estricto):** una petición debe atravesar cada capa
  secuencialmente. Maximiza aislamiento/reemplazabilidad, a costa de
  más código de forwarding.
- **Open (relajado):** ciertas capas pueden saltarse para flujos
  específicos. Reduce boilerplate, incrementa acoplamiento.

## Sub topics

### 3. El Anti-Patrón "Architecture Sinkhole"
Ocurre cuando una petición atraviesa múltiples capas como simple
pass-through, sin lógica de negocio real en ninguna capa. Regla 80/20
(Richards): hasta ~20% de los flujos en este patrón es aceptable; más
allá de eso, sobran capas o el estilo no es el adecuado.

### 4. Enforcement de Límites de Capa en CI
Categorías de herramientas (ArchUnit / dependency-cruiser /
import-linter) para reglas como "Presentación no puede importar
Persistencia directamente", incluyendo excepciones explícitas
auditables para layering relajado.

### 5. Cuándo NO usar (o cuándo dejar de usar) Layered Architecture
- Problema de la variedad de dominio (subdominios de complejidad muy
  distinta forzados al mismo número de capas).
- Agilidad limitada bajo layering estricto (un cambio de feature cruza
  todas las capas).
THEORY_EOF

# ── 5. docs/sessions/Session-002.md (Spanish — full session content) ────
cat > "$SESSIONS_DOC_DIR/Session-002.md" <<'SESSION_EOF'
# Phase 1 — Engineering Foundations
# Module 1 — Modern Software Engineering
# Session 002 - Layered Architecture Style

## Goal
Al finalizar esta sesión, Victor podrá diseñar, justificar y **criticar**
una arquitectura por capas (Layered / N-Tier): distinguir capas lógicas
de tiers físicos, decidir entre layering estricto (closed) y relajado
(open) según el contexto, y reconocer — y evitar — el anti-patrón
conocido como "architecture sinkhole". La sesión también conecta
explícitamente con S001: una arquitectura por capas bien delimitada
puede vivir perfectamente dentro de un monolito (la organización interna
del código es independiente de la unidad de despliegue), y refuerza el
uso de linters arquitectónicos en CI — ya introducidos en S001 — ahora
aplicados a límites *entre capas* en vez de entre bounded contexts.

## Time breakdown

| Bloque | Actividad | Duración |
|---|---|---|
| 1 | Contexto y motivación | 10 min |
| 2 | Main Topic — Layered Architecture: capas, tiers, layering estricto vs. relajado | 25 min |
| 3 | Sub topics — Architecture Sinkhole, cuándo NO usarla, enforcement en CI | 25 min |
| 4 | Real world example | 15 min |
| 5 | Exercises (3) | 40 min |
| 6 | Knowledge mastery check | 10 min |
| **Total** | | **~125 min** |

## Main Topic

### 1. ¿Qué es la Arquitectura por Capas (Layered / N-Tier)?
Una arquitectura por capas organiza el sistema en niveles horizontales,
donde cada capa tiene una responsabilidad específica y se comunica
típicamente solo con la capa inmediatamente inferior. El patrón no
prescribe un número fijo de capas, pero la variante más citada en la
literatura usa cuatro: **Presentación**, **Negocio/Aplicación**,
**Persistencia** y **Base de Datos**.

**Layers vs. Tiers — una distinción que se confunde constantemente:**
- **Layer (capa):** separación **lógica** del código. Vive en el mismo
  proceso o unidad de despliegue; es una forma de organizar el código
  fuente (paquetes, namespaces, módulos).
- **Tier (nivel):** separación **física/de despliegue**. Cada tier corre
  en una máquina o proceso distinto, con comunicación de red entre
  ellos.

Esta distinción conecta directamente con el aprendizaje central de
S001: "monolito" no es sinónimo de "sin estructura interna". Un
monolito bien diseñado casi siempre está organizado internamente en 3-4
capas (un único tier, múltiples layers). Un N-Tier "clásico" despliega
esas mismas capas lógicas en máquinas separadas (Presentación en un
servidor web, Negocio en un servidor de aplicaciones, Datos en un
servidor de base de datos) — pero **el número de capas lógicas no
cambia** solo porque se despliegue en más o menos tiers.

### 2. Layering Estricto (Closed) vs. Relajado (Open)
- **Closed (estricto):** una petición debe atravesar cada capa
  secuencialmente; ninguna capa puede saltarse. Maximiza el aislamiento
  y la reemplazabilidad de cada capa (se puede cambiar la capa de
  Persistencia sin tocar Presentación), a costa de más código de
  "paso" (forwarding).
- **Open (relajado):** ciertas capas pueden saltarse para flujos
  específicos — por ejemplo, permitir que Presentación consulte
  directamente una capa de caché o servicios de solo lectura sin pasar
  por toda la cadena. Reduce el boilerplate, pero incrementa el
  acoplamiento y reduce el aislamiento de pruebas.

Ninguna de las dos es "correcta" de forma universal: es un trade-off
explícito que debería quedar documentado (ver Ejercicio 2 — ADR-002).

## Sub topics

### 3. El Anti-Patrón "Architecture Sinkhole"
Descrito originalmente por Mark Richards: ocurre cuando una petición
atraviesa múltiples capas como **simple pass-through**, sin que ninguna
capa aplique lógica de negocio, validación o transformación real.
Richards propone la **regla 80/20** como heurística: es aceptable que
hasta ~20% de los flujos de un sistema caigan en este patrón; si una
proporción mucho mayor de las peticiones son puro pass-through, es una
señal de que sobran capas para la complejidad real que se está
aislando, o de que el estilo layered no es el más adecuado para ese
subsistema.

### 4. Enforcement de Límites de Capa en CI (conexión con S001)
El aprendizaje de S001 sobre boundaries internos como *first-class
concern* se reutiliza aquí: las mismas categorías de herramientas
(ArchUnit para JVM, dependency-cruiser para JS/TS, import-linter para
Python — citadas como categorías, no como endoso de una herramienta
específica) sirven para hacer cumplir reglas de capas, por ejemplo:
"Presentación no puede importar Persistencia directamente" o "solo el
paquete `db` puede importar el driver de base de datos". La novedad
frente a S001 es que aquí también se necesita poder **codificar
excepciones explícitas** (open layers) sin perder gobernanza — ver
Ejercicio 3.

### 5. Cuándo NO usar (o cuándo dejar de usar) Layered Architecture
- **El "problema de la variedad de dominio":** un sistema con
  subdominios de complejidad muy distinta (un panel de administración
  CRUD simple junto a un motor de pricing complejo) tiende a forzar el
  mismo número de capas sobre ambos, añadiendo overhead innecesario al
  subdominio simple.
- **Agilidad limitada:** en un layering estricto, un cambio de features
  típicamente cruza todas las capas, lo que puede alargar el ciclo de
  entrega frente a estilos organizados verticalmente (por feature o
  dominio).
- Nota de precisión: algunas fuentes secundarias que resumen
  *Fundamentals of Software Architecture* incluyen tablas numéricas de
  "rating" por característica arquitectónica (deployability,
  testability, etc.). No se citan esas cifras exactas aquí porque no
  provienen directamente del texto primario del libro, solo de resúmenes
  de terceros — la caracterización cualitativa (bajo costo/simplicidad,
  baja agilidad/evolutividad) sí está ampliamente corroborada en
  múltiples fuentes independientes.

## Real world example
*(Escenario construido con fines pedagógicos, no un caso real
documentado. Continúa el universo narrativo de la plataforma de
e-commerce usada en S001, ahora mirando un subsistema distinto.)*

El módulo de **Catálogo y Búsqueda** de la misma plataforma de
e-commerce de S001 se diseñó originalmente con 4 capas cerradas:
API (Presentación) → Application Service → Domain → Repository
(Persistencia). Con el tiempo, dos equipos distintos añadieron una capa
de "Facade" y una capa de "DTO Mapping" — cada una "por prolijidad" —
llevando el total a 6 capas. Una revisión de performance encontró que
~65% de las peticiones de lectura (`GET /products/{id}`,
`GET /categories/{id}/products`) atravesaban Facade y Application
Service sin aplicar ninguna lógica: puro forwarding. Con la regla 80/20
de Richards como referencia, 65% está muy por encima del umbral
saludable (~20%), señal clara de architecture sinkhole en el camino de
lectura. El equipo decidió colapsar Facade + Application Service en una
única capa "Application" para los paths de **lectura** (relajando el
layering ahí), mientras mantiene el layering **estricto** en los paths
de **escritura** (crear/actualizar producto), donde sí hay validaciones
y reglas de negocio genuinas en cada capa.

## Exercises

### Ejercicio 1 — Modelado

**Contexto del Ejercicio**
Eres el Principal Engineer responsable del módulo de Catálogo y
Búsqueda descrito arriba. La dirección de ingeniería te pide una
propuesta de rediseño de capas antes del próximo trimestre.

**Tarea:**
1. Propón un diseño de capas que distinga explícitamente el camino de
   **lectura** (consultas de catálogo) del camino de **escritura**
   (alta/edición de productos), indicando la responsabilidad concreta
   de cada capa en cada camino.
2. Decide, para cada camino, si aplicarás layering estricto (closed) o
   relajado (open), y justifica la decisión en términos de los
   trade-offs vistos en el Main Topic (aislamiento/reemplazabilidad vs.
   boilerplate/acoplamiento).
3. Estima — con la evidencia disponible en el escenario (65% de
   lecturas como pass-through) — si el diseño resultante seguiría
   cayendo en architecture sinkhole, y en qué % aproximado, aplicando
   la regla 80/20 como criterio de aceptación.

### Ejercicio 2 — ADR-002

**Contexto del Ejercicio**
El Architecture Review Board de la compañía requiere un ADR formal
antes de aprobar cualquier cambio de capas en un servicio que
atraviesa >10K requests/minuto en hora pico.

**Tarea:**
Redacta el borrador del **ADR-002**, decidiendo entre:
- (a) mantener las 6 capas originales con layering estricto en todos
  los caminos, o
- (b) colapsar a un diseño de capas diferenciado por camino
  (lectura relajada / escritura estricta), como el propuesto en el
  Ejercicio 1.

El ADR debe incluir explícitamente el trade-off de gobernanza: (b)
reduce el sinkhole pero introduce una excepción a la regla "toda
petición atraviesa todas las capas", que debe quedar documentada y
enforced (ver Ejercicio 3) para no degenerar en acoplamiento
descontrolado.

### Ejercicio 3 — Enforcement en CI

**Contexto del Ejercicio**
La decisión del Ejercicio 2 (opción b) solo es sostenible si la
excepción de layering relajado queda codificada como regla explícita,
no como una convención verbal.

**Tarea:**
Diseña — en pseudocódigo/forma conceptual, no como configuración
completa de producción — una regla de CI para **una** de las tres
categorías de herramientas ya usadas en S001 (ArchUnit / dependency-
cruiser / import-linter) que:
1. Prohíba que el paquete de Presentación importe directamente el
   paquete de Persistencia para cualquier operación de escritura.
2. Permita explícitamente la excepción de lectura únicamente a través
   de un módulo con nombre reservado (p. ej. `read_facade` o
   `ReadFacade`), de forma que la excepción sea visible y auditable en
   el propio nombre de la regla, no oculta en la lógica del código.

### Evidence
Contenido a persistir vía `generate-session-002.sh` en
`docs/adrs/ADR-002.md`:
```markdown
# ADR-002: Layering Diferenciado por Camino (Lectura Relajada / Escritura Estricta) para el Módulo de Catálogo

## Estatus
Propuesto

## Contexto
El módulo de Catálogo y Búsqueda opera con 6 capas cerradas. Una
revisión de performance encontró que ~65% de las peticiones de lectura
son pass-through puro (architecture sinkhole), muy por encima del
umbral de 20% considerado saludable (regla 80/20, Richards).

## Decisión
Colapsar Facade + Application Service en una única capa "Application"
para el camino de lectura (layering relajado/open), manteniendo
layering estricto/closed para el camino de escritura, donde persisten
validaciones y reglas de negocio genuinas en cada capa.

## Consecuencias
- Positivas: reduce el sinkhole ratio en lectura; menos código de
  forwarding sin valor.
- Negativas: introduce una excepción explícita a la regla "toda
  petición atraviesa todas las capas", que debe quedar enforced en CI
  (ver regla de boundary del Ejercicio 3) para no degenerar en
  acoplamiento no gobernado entre Presentación y Persistencia.
```

## Resources
- Libro: *Fundamentals of Software Architecture: An Engineering
  Approach* — Mark Richards, Neal Ford (O'Reilly, 1.ª ed., 2020) —
  https://www.oreilly.com/library/view/fundamentals-of-software/9781492043447/
- Reporte gratuito: *Software Architecture Patterns* — Mark Richards
  (O'Reilly) — capítulo sobre Layered Architecture y el anti-patrón
  "architecture sinkhole" — https://www.oreilly.com/content/software-architecture-patterns/
- Artículo: "Presentation Domain Data Layering" — Martin Fowler —
  https://martinfowler.com/bliki/PresentationDomainDataLayering.html
- Documentación oficial: "N-tier architecture style" — Azure
  Architecture Center, Microsoft Learn —
  https://learn.microsoft.com/en-us/azure/architecture/guide/architecture-styles/n-tier
- Artículo: "Difference Between Layers and Tiers" — Baeldung on
  Computer Science — https://www.baeldung.com/cs/layers-vs-tiers

## Knowledge mastery check
- [ ] Puedo definir arquitectura por capas y diferenciar layers de tiers.
- [ ] Puedo explicar la diferencia entre layering estricto (closed) y
      relajado (open), y sus trade-offs.
- [ ] Puedo identificar el anti-patrón "architecture sinkhole" y aplicar
      la regla 80/20 para decidir si es un problema real en un caso
      dado.
- [ ] Puedo justificar cuándo NO conviene layered architecture, o cuándo
      colapsar capas existentes.
- [ ] Puedo diseñar una regla de enforcement en CI que permita
      excepciones explícitas (open layers) sin perder gobernanza.
- [ ] Puedo conectar la decisión de layering interno con la decisión de
      "monolito vs. microservicio" de S001 como variables
      independientes entre sí.

## Principal Engineer Lens

**Technical Perspective**
- El costo de un "pass-through" en llamadas dentro del mismo proceso es
  mayoritariamente de mantenimiento (código, tests, cognitive load), no
  de latencia — la latencia real por hop solo se vuelve significativa
  cuando esas capas se despliegan en tiers físicos separados con
  llamadas de red.
- "Problema de la variedad de dominio": tratar un subdominio CRUD
  simple con el mismo número de capas que un subdominio de negocio
  complejo es una causa común de sinkhole — no toda parte del sistema
  necesita la misma profundidad de capas.

**Business Perspective**
- Costo de adopción: layered architecture es, según Richards & Ford,
  uno de los estilos de menor costo inicial y curva de aprendizaje más
  baja — es el estilo que la mayoría de los desarrolladores ya conoce.
- Costo de agilidad: en layering estricto, un cambio de feature típico
  cruza todas las capas, lo que puede alargar el lead time de entrega
  frente a una organización vertical por dominio (tema que se retoma
  más adelante en el roadmap, p. ej. al hablar de DORA metrics).

**AI Perspective**
- Un componente de IA (p. ej. re-ranking semántico de resultados de
  búsqueda del catálogo) debería vivir detrás de la capa de Dominio, no
  ser llamado directamente desde Presentación — su latencia
  no-determinista se aísla mejor detrás de un límite arquitectónico
  explícito con timeouts/circuit breakers (patrón que se profundiza más
  adelante en el roadmap, S064).

**Leadership Perspective**
- Gobernanza de la abstracción: no toda capa nueva propuesta por un
  equipo es una separación de responsabilidades genuina; algunas son
  "resume-driven design" o abstracción prematura. Exigir que cada capa
  nueva se justifique en un ADR (con su sinkhole ratio estimado) es un
  mecanismo de gobernanza barato y efectivo.
- La excepción documentada (open layer) es preferible a la excepción
  tácita: un ADR + una regla de CI auditable es gobernanza real; una
  convención verbal no lo es.

## End-of-Session Success Criteria
- [ ] El archivo `generate-session-002.sh` existe en
      `tools/generators/`, tiene permisos de ejecución y se ejecuta de
      forma idempotente.
- [ ] `docs/theory/Theory-002.md`, `docs/sessions/Session-002.md` y
      `docs/adrs/ADR-002.md` están generados.
- [ ] `docs/dashboard.md`, `docs/current-state.md` y
      `docs/learning-journal.md` reflejan el avance de la sesión.
- [ ] El sitio estático en `/site` compila `S002.es.html` y
      `S002.en.html`, con viewport, `table-wrapper` y `lang-toggle`.
- [ ] Los 3 ejercicios están resueltos con justificación explícita de
      trade-offs.

## Reflection
Layering estricto no es "más arquitectura": cada capa añadida sin una
responsabilidad propia, verificable y distinta de sus vecinas es deuda
técnica disfrazada de buena práctica. El objetivo no es maximizar el
número de capas, sino maximizar el número de capas que realmente
justifican su propio costo — y estar dispuesto a colapsarlas, con la
misma disciplina de ADR con la que se decidió crearlas, cuando la
evidencia (como un sinkhole ratio por encima del 20%) indica que dejaron
de hacerlo.
SESSION_EOF

# ── 6. docs/adrs/ADR-002.md ──────────────────────────────────────────────
cat > "$ADR_DIR/ADR-002.md" <<'ADR_EOF'
# ADR-002: Layering Diferenciado por Camino (Lectura Relajada / Escritura Estricta) para el Módulo de Catálogo

## Estatus
Propuesto

## Contexto
El módulo de Catálogo y Búsqueda opera con 6 capas cerradas. Una
revisión de performance encontró que ~65% de las peticiones de lectura
son pass-through puro (architecture sinkhole), muy por encima del
umbral de 20% considerado saludable (regla 80/20, Richards).

## Decisión
Colapsar Facade + Application Service en una única capa "Application"
para el camino de lectura (layering relajado/open), manteniendo
layering estricto/closed para el camino de escritura, donde persisten
validaciones y reglas de negocio genuinas en cada capa.

## Consecuencias
- Positivas: reduce el sinkhole ratio en lectura; menos código de
  forwarding sin valor.
- Negativas: introduce una excepción explícita a la regla "toda
  petición atraviesa todas las capas", que debe quedar enforced en CI
  (ver regla de boundary del Ejercicio 3 de Session-002) para no
  degenerar en acoplamiento no gobernado entre Presentación y
  Persistencia.
ADR_EOF

echo "Wrote docs/theory/Theory-002.md, docs/sessions/Session-002.md, docs/adrs/ADR-002.md"

# ── 7. site/sessions/S002.es.html and S002.en.html ───────────────────────
cat > "$SITE_SESSIONS_DIR/S002.es.html" <<'HTML_ES_EOF'
<!DOCTYPE html>
<html lang="es">
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta charset="UTF-8">
<title>S002 - Layered Architecture Style</title>
<link rel="stylesheet" href="../assets/styles.css">
</head>
<body>
<div class="lang-toggle">
  <a href="S002.es.html" class="lang-active">ES</a>
  <a href="S002.en.html">EN</a>
</div>
<header>
  <p>Phase 1 — Engineering Foundations / Module 1 — Modern Software Engineering</p>
  <h1>Session 002 - Layered Architecture Style</h1>
</header>
<main>
  <section>
    <h2>Goal</h2>
    <p>Al finalizar esta sesión, Victor podrá diseñar, justificar y
    criticar una arquitectura por capas (Layered / N-Tier): distinguir
    capas lógicas de tiers físicos, decidir entre layering estricto
    (closed) y relajado (open) según el contexto, y reconocer — y
    evitar — el anti-patrón conocido como "architecture sinkhole".
    Conecta explícitamente con S001: layering interno y unidad de
    despliegue (monolito vs. microservicios) son variables
    independientes.</p>
  </section>
  <section>
    <h2>Time breakdown</h2>
    <div class="table-wrapper">
      <table>
        <thead>
          <tr><th>Bloque</th><th>Actividad</th><th>Duración</th></tr>
        </thead>
        <tbody>
          <tr><td>1</td><td>Contexto y motivación</td><td>10 min</td></tr>
          <tr><td>2</td><td>Main Topic — capas, tiers, layering estricto vs. relajado</td><td>25 min</td></tr>
          <tr><td>3</td><td>Sub topics — Architecture Sinkhole, enforcement en CI</td><td>25 min</td></tr>
          <tr><td>4</td><td>Real world example</td><td>15 min</td></tr>
          <tr><td>5</td><td>Exercises (3)</td><td>40 min</td></tr>
          <tr><td>6</td><td>Knowledge mastery check</td><td>10 min</td></tr>
          <tr><td><strong>Total</strong></td><td></td><td><strong>~125 min</strong></td></tr>
        </tbody>
      </table>
    </div>
  </section>
  <section>
    <h2>Main Topic</h2>
    <h3>1. ¿Qué es la Arquitectura por Capas (Layered / N-Tier)?</h3>
    <p>Organiza el sistema en niveles horizontales; cada capa tiene una
    responsabilidad específica y se comunica típicamente solo con la
    capa inmediatamente inferior. Variante más citada: Presentación,
    Negocio/Aplicación, Persistencia, Base de Datos.</p>
    <p><strong>Layers vs. Tiers:</strong> layer = separación lógica del
    código; tier = separación física/de despliegue. Un monolito bien
    diseñado casi siempre está organizado en 3-4 capas dentro de un
    único tier.</p>
    <h3>2. Layering Estricto (Closed) vs. Relajado (Open)</h3>
    <p>Closed: toda petición atraviesa cada capa secuencialmente — más
    aislamiento, más forwarding. Open: ciertas capas pueden saltarse —
    menos boilerplate, más acoplamiento.</p>
  </section>
  <section>
    <h2>Sub topics</h2>
    <h3>3. El Anti-Patrón "Architecture Sinkhole"</h3>
    <p>Peticiones que atraviesan capas como simple pass-through, sin
    lógica de negocio real. Regla 80/20 (Richards): hasta ~20% de los
    flujos en este patrón es aceptable.</p>
    <h3>4. Enforcement de Límites de Capa en CI</h3>
    <p>ArchUnit / dependency-cruiser / import-linter (categorías) para
    reglas de capas, incluyendo excepciones explícitas auditables.</p>
    <h3>5. Cuándo NO usar Layered Architecture</h3>
    <p>Problema de la variedad de dominio; agilidad limitada bajo
    layering estricto.</p>
  </section>
  <section>
    <h2>Real world example</h2>
    <p><em>(Escenario pedagógico, no un caso real documentado.)</em>
    Módulo de Catálogo y Búsqueda: de 4 a 6 capas; ~65% de lecturas
    como pass-through puro (architecture sinkhole). Decisión: layering
    relajado en lectura, estricto en escritura.</p>
  </section>
  <section>
    <h2>Exercises</h2>
    <h3>Ejercicio 1 — Modelado</h3>
    <p>Diseño de capas diferenciado por camino (lectura/escritura),
    justificación de closed/open, estimación del sinkhole ratio.</p>
    <h3>Ejercicio 2 — ADR-002</h3>
    <p>Borrador de ADR-002 comparando 6 capas estrictas vs. diseño
    diferenciado por camino.</p>
    <h3>Ejercicio 3 — Enforcement en CI</h3>
    <p>Regla conceptual de CI que prohíbe Presentación → Persistencia
    en escritura y permite la excepción de lectura solo vía un módulo
    con nombre reservado (p. ej. <code>read_facade</code>).</p>
  </section>
  <section>
    <h2>Resources</h2>
    <ul>
      <li>Mark Richards &amp; Neal Ford — <em>Fundamentals of Software Architecture</em> (O'Reilly, 2020) — <a href="https://www.oreilly.com/library/view/fundamentals-of-software/9781492043447/">enlace</a></li>
      <li>Mark Richards — <em>Software Architecture Patterns</em> (O'Reilly, reporte gratuito) — <a href="https://www.oreilly.com/content/software-architecture-patterns/">enlace</a></li>
      <li>Martin Fowler — "Presentation Domain Data Layering" — <a href="https://martinfowler.com/bliki/PresentationDomainDataLayering.html">enlace</a></li>
      <li>Azure Architecture Center — "N-tier architecture style" — <a href="https://learn.microsoft.com/en-us/azure/architecture/guide/architecture-styles/n-tier">enlace</a></li>
      <li>Baeldung — "Difference Between Layers and Tiers" — <a href="https://www.baeldung.com/cs/layers-vs-tiers">enlace</a></li>
    </ul>
  </section>
  <section>
    <h2>Knowledge mastery check</h2>
    <ul>
      <li>Definir arquitectura por capas y diferenciar layers de tiers.</li>
      <li>Explicar layering estricto vs. relajado y sus trade-offs.</li>
      <li>Identificar el architecture sinkhole y aplicar la regla 80/20.</li>
      <li>Justificar cuándo NO usar layered architecture.</li>
      <li>Diseñar enforcement de CI con excepciones explícitas.</li>
      <li>Conectar layering interno con la decisión monolito/microservicios de S001.</li>
    </ul>
  </section>
  <section>
    <h2>Principal Engineer Lens</h2>
    <p><strong>Technical:</strong> el costo de un pass-through in-process
    es de mantenimiento, no de latencia, salvo que las capas se
    desplieguen en tiers físicos separados.</p>
    <p><strong>Business:</strong> bajo costo de adopción y curva de
    aprendizaje; costo de agilidad si el layering es estricto.</p>
    <p><strong>AI:</strong> componentes de IA detrás de la capa de
    Dominio, aislados con timeouts/circuit breakers.</p>
    <p><strong>Leadership:</strong> gobernanza de la abstracción vía
    ADRs; excepción documentada mejor que excepción tácita.</p>
  </section>
  <section>
    <h2>End-of-Session Success Criteria</h2>
    <ul>
      <li>generate-session-002.sh existe en tools/generators/, es
      ejecutable e idempotente.</li>
      <li>Theory-002.md, Session-002.md y ADR-002.md generados.</li>
      <li>dashboard.md, current-state.md y learning-journal.md
      actualizados.</li>
      <li>Sitio estático compila S002.es.html y S002.en.html.</li>
      <li>Los 3 ejercicios resueltos con trade-offs explícitos.</li>
    </ul>
  </section>
  <section>
    <h2>Reflection</h2>
    <p>El objetivo no es maximizar el número de capas, sino maximizar
    el número de capas que realmente justifican su propio costo — y
    estar dispuesto a colapsarlas cuando la evidencia lo indique.</p>
  </section>
</main>
</body>
</html>
HTML_ES_EOF

cat > "$SITE_SESSIONS_DIR/S002.en.html" <<'HTML_EN_EOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta charset="UTF-8">
<title>S002 - Layered Architecture Style</title>
<link rel="stylesheet" href="../assets/styles.css">
</head>
<body>
<div class="lang-toggle">
  <a href="S002.es.html">ES</a>
  <a href="S002.en.html" class="lang-active">EN</a>
</div>
<header>
  <p>Phase 1 — Engineering Foundations / Module 1 — Modern Software Engineering</p>
  <h1>Session 002 - Layered Architecture Style</h1>
</header>
<main>
  <section>
    <h2>Goal</h2>
    <p>By the end of this session, Victor will be able to design,
    justify, and critique a Layered / N-Tier architecture: distinguish
    logical layers from physical tiers, decide between strict (closed)
    and relaxed (open) layering depending on context, and recognize —
    and avoid — the "architecture sinkhole" anti-pattern. It connects
    explicitly to S001: internal layering and the deployment unit
    (monolith vs. microservices) are independent variables.</p>
  </section>
  <section>
    <h2>Time breakdown</h2>
    <div class="table-wrapper">
      <table>
        <thead>
          <tr><th>Block</th><th>Activity</th><th>Duration</th></tr>
        </thead>
        <tbody>
          <tr><td>1</td><td>Context and motivation</td><td>10 min</td></tr>
          <tr><td>2</td><td>Main Topic — layers, tiers, strict vs. relaxed layering</td><td>25 min</td></tr>
          <tr><td>3</td><td>Sub topics — Architecture Sinkhole, CI enforcement</td><td>25 min</td></tr>
          <tr><td>4</td><td>Real world example</td><td>15 min</td></tr>
          <tr><td>5</td><td>Exercises (3)</td><td>40 min</td></tr>
          <tr><td>6</td><td>Knowledge mastery check</td><td>10 min</td></tr>
          <tr><td><strong>Total</strong></td><td></td><td><strong>~125 min</strong></td></tr>
        </tbody>
      </table>
    </div>
  </section>
  <section>
    <h2>Main Topic</h2>
    <h3>1. What Is Layered Architecture (Layered / N-Tier)?</h3>
    <p>Organizes the system into horizontal levels; each layer has a
    specific responsibility and typically communicates only with the
    layer immediately below it. Most-cited variant: Presentation,
    Business/Application, Persistence, Database.</p>
    <p><strong>Layers vs. Tiers:</strong> layer = logical separation of
    code; tier = physical/deployment separation. A well-designed
    monolith is almost always organized into 3-4 layers inside a single
    tier.</p>
    <h3>2. Strict (Closed) vs. Relaxed (Open) Layering</h3>
    <p>Closed: every request crosses each layer sequentially — more
    isolation, more forwarding. Open: certain layers can be skipped —
    less boilerplate, more coupling.</p>
  </section>
  <section>
    <h2>Sub topics</h2>
    <h3>3. The "Architecture Sinkhole" Anti-Pattern</h3>
    <p>Requests that cross layers as simple pass-through, with no real
    business logic. 80/20 rule (Richards): up to ~20% of a system's
    flows falling into this pattern is acceptable.</p>
    <h3>4. Enforcing Layer Boundaries in CI</h3>
    <p>ArchUnit / dependency-cruiser / import-linter (categories) for
    layer rules, including explicit, auditable exceptions.</p>
    <h3>5. When NOT to Use Layered Architecture</h3>
    <p>The domain variety problem; limited agility under strict
    layering.</p>
  </section>
  <section>
    <h2>Real world example</h2>
    <p><em>(Pedagogical scenario, not a documented real case.)</em>
    Catalog and Search module: grew from 4 to 6 layers; ~65% of reads
    as pure pass-through (architecture sinkhole). Decision: relaxed
    layering on reads, strict on writes.</p>
  </section>
  <section>
    <h2>Exercises</h2>
    <h3>Exercise 1 — Modeling</h3>
    <p>Path-differentiated layer design (read/write), closed/open
    justification, sinkhole ratio estimate.</p>
    <h3>Exercise 2 — ADR-002</h3>
    <p>Draft ADR-002 comparing 6 strict layers vs. a path-differentiated
    design.</p>
    <h3>Exercise 3 — CI Enforcement</h3>
    <p>Conceptual CI rule forbidding Presentation → Persistence on
    writes, allowing the read exception only via a reserved-name module
    (e.g. <code>read_facade</code>).</p>
  </section>
  <section>
    <h2>Resources</h2>
    <ul>
      <li>Mark Richards &amp; Neal Ford — <em>Fundamentals of Software Architecture</em> (O'Reilly, 2020) — <a href="https://www.oreilly.com/library/view/fundamentals-of-software/9781492043447/">link</a></li>
      <li>Mark Richards — <em>Software Architecture Patterns</em> (O'Reilly, free report) — <a href="https://www.oreilly.com/content/software-architecture-patterns/">link</a></li>
      <li>Martin Fowler — "Presentation Domain Data Layering" — <a href="https://martinfowler.com/bliki/PresentationDomainDataLayering.html">link</a></li>
      <li>Azure Architecture Center — "N-tier architecture style" — <a href="https://learn.microsoft.com/en-us/azure/architecture/guide/architecture-styles/n-tier">link</a></li>
      <li>Baeldung — "Difference Between Layers and Tiers" — <a href="https://www.baeldung.com/cs/layers-vs-tiers">link</a></li>
    </ul>
  </section>
  <section>
    <h2>Knowledge mastery check</h2>
    <ul>
      <li>Define layered architecture and distinguish layers from tiers.</li>
      <li>Explain strict vs. relaxed layering and their trade-offs.</li>
      <li>Identify the architecture sinkhole and apply the 80/20 rule.</li>
      <li>Justify when NOT to use layered architecture.</li>
      <li>Design CI enforcement with explicit exceptions.</li>
      <li>Connect internal layering to S001's monolith/microservices decision.</li>
    </ul>
  </section>
  <section>
    <h2>Principal Engineer Lens</h2>
    <p><strong>Technical:</strong> the cost of an in-process pass-through
    is mostly maintenance, not latency, unless layers are deployed
    across separate physical tiers.</p>
    <p><strong>Business:</strong> low adoption cost and learning curve;
    agility cost under strict layering.</p>
    <p><strong>AI:</strong> AI components live behind the Domain layer,
    isolated with timeouts/circuit breakers.</p>
    <p><strong>Leadership:</strong> governance of abstraction via ADRs;
    a documented exception beats a tacit one.</p>
  </section>
  <section>
    <h2>End-of-Session Success Criteria</h2>
    <ul>
      <li>generate-session-002.sh exists under tools/generators/, is
      executable and idempotent.</li>
      <li>Theory-002.md, Session-002.md and ADR-002.md generated.</li>
      <li>dashboard.md, current-state.md and learning-journal.md
      updated.</li>
      <li>Static site compiles S002.es.html and S002.en.html.</li>
      <li>All 3 exercises solved with explicit trade-offs.</li>
    </ul>
  </section>
  <section>
    <h2>Reflection</h2>
    <p>The goal is not to maximize the number of layers, but to
    maximize the number of layers that genuinely justify their own
    cost — and to be willing to collapse them when the evidence says
    so.</p>
  </section>
</main>
</body>
</html>
HTML_EN_EOF

echo "Wrote site/sessions/S002.es.html and site/sessions/S002.en.html"

# ── 8. Idempotent helper: upsert a marker-delimited block in a file ──────
# Replaces the block between "<!-- marker:START -->" and
# "<!-- marker:END -->" if the marker already exists in the file;
# otherwise appends a new block (creating the file with a minimal
# header first if it doesn't exist yet).
upsert_block() {
  local file="$1" marker="$2" content="$3" header="$4"
  local start="<!-- ${marker}:START -->"
  local end="<!-- ${marker}:END -->"

  if [ ! -f "$file" ]; then
    printf '%s\n\n' "$header" > "$file"
  fi

  if grep -qF "$start" "$file" 2>/dev/null; then
    # Replace existing block in place using awk (portable, no GNU-only sed -i quirks).
    awk -v start="$start" -v end="$end" -v content="$content" '
      $0 == start { print; print content; skip=1; next }
      $0 == end   { print; skip=0; next }
      skip != 1   { print }
    ' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
  else
    {
      printf '\n%s\n' "$start"
      printf '%s\n' "$content"
      printf '%s\n' "$end"
    } >> "$file"
  fi
}

TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

# ── 9. docs/dashboard.md — upsert one row/section per session code ──────
DASHBOARD_CONTENT="- **${CODE}** — ${TITLE} (Phase ${PHASE_NUM}, Module ${MODULE_NUM} — ${MODULE_NAME}) — status: completed — last updated: ${TIMESTAMP}"
upsert_block "$DASHBOARD_FILE" "DASHBOARD:${CODE}" "$DASHBOARD_CONTENT" \
  "# Dashboard — Principal Engineer Accelerator Path"$'\n\n'"NOTE: this file is managed defensively by tools/generators/generate-session-*.sh scripts using marker-delimited blocks per session code, since the exact pre-existing dashboard format used before this generation flow was not available to the script author. If you already track progress here in a different format, reconcile manually — this script will not touch anything outside its own \`DASHBOARD:<CODE>\` markers."

# ── 10. docs/current-state.md — single block, overwritten each run ──────
NEXT_CODE="S003"
NEXT_TITLE="Hexagonal Architecture (Ports & Adapters)"
CURRENT_STATE_CONTENT="- Track: Staff / Architect / Product AI (Shared)
- Last completed session: ${CODE} — ${TITLE}
- Phase ${PHASE_NUM} — ${PHASE_NAME} / Module ${MODULE_NUM} — ${MODULE_NAME}
- Next session: ${NEXT_CODE} — ${NEXT_TITLE}
- Last updated: ${TIMESTAMP}"
upsert_block "$CURRENT_STATE_FILE" "CURRENT_STATE" "$CURRENT_STATE_CONTENT" \
  "# Current State — Principal Engineer Accelerator Path"$'\n\n'"NOTE: managed defensively via a single \`CURRENT_STATE\` marker block, format not verified against any pre-existing file."

# ── 11. docs/learning-journal.md — append-only, guarded by session code ─
JOURNAL_MARKER="JOURNAL:${CODE}"
if ! grep -qF "<!-- ${JOURNAL_MARKER}:START -->" "$JOURNAL_FILE" 2>/dev/null; then
  JOURNAL_ENTRY="### ${CODE} — ${TITLE} (${TIMESTAMP})
- Phase ${PHASE_NUM} — ${PHASE_NAME} / Module ${MODULE_NUM} — ${MODULE_NAME}
- Key learning: layering interno (open/closed) y unidad de despliegue
  (monolito vs. microservicios) son variables independientes; el
  anti-patrón architecture sinkhole y la regla 80/20 (Richards) dan un
  criterio objetivo para decidir cuándo colapsar capas."
  upsert_block "$JOURNAL_FILE" "$JOURNAL_MARKER" "$JOURNAL_ENTRY" \
    "# Learning Journal — Principal Engineer Accelerator Path"
else
  echo "Journal entry for ${CODE} already present — skipping (idempotent)."
fi

echo "Updated docs/dashboard.md, docs/current-state.md, docs/learning-journal.md"
echo ""
echo "Done. Session ${CODE} - ${TITLE} persisted."
if [ "$HAS_GIT" = true ]; then
  echo "Repo is on branch '${BRANCH}'. No commits were made — review and commit manually."
fi
