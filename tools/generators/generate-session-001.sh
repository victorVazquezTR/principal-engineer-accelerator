#!/usr/bin/env bash
# generate-session-001.sh
#
# Persiste la Sesión S001 - Monolithic Architecture Style
# (Phase 1 / Module 1 - Modern Software Engineering) en el repositorio.
#
# Contenido embebido en ESPAÑOL (política de idioma: docs/ es
# Spanish-only). site/ es bilingüe (ES + EN).
#
# IMPORTANTE - Supuestos explícitos hechos por falta de información en
# esta conversación (no se subió current-state.md, dashboard.md,
# learning-journal.md ni site/assets/styles.css al proyecto, y esta es
# la PRIMERA sesión generada, por lo que no existe una página S001
# previa de la cual copiar estructura exacta):
#
#   1. Estructura de site/: se asume site/sessions/<code>.<lang>.html
#      (subcarpeta "sessions"), porque el requisito mobile-first pide
#      literalmente href="../assets/styles.css" (un solo nivel arriba
#      de site/assets/). Si tu site/ real usa otra profundidad, ajusta
#      SITE_DIR y el href más abajo antes de ejecutar.
#   2. docs/dashboard.md y docs/current-state.md: no existe una versión
#      previa en este proyecto para inferir su formato exacto. Este
#      script crea una versión mínima si no existen, o inserta/actualiza
#      una sola línea marcada por el código de sesión si ya existen -
#      revisa el resultado y ajusta el formato a mano si no calza con tu
#      convención real.
#   3. Este script es la línea base de formato para site/ (lang-toggle,
#      table-wrapper, viewport) ya que no hay una S001.es.html/en.html
#      previa de la cual copiar estructura exacta. Sesiones futuras
#      deberían replicar esta misma estructura.
#
# Idempotencia: cada bloque de escritura de archivo sobreescribe su
# archivo objetivo con contenido determinista (mismo resultado en cada
# corrida). Los bloques de append (dashboard, current-state,
# learning-journal) verifican un marcador antes de escribir, para no
# duplicar entradas si el script se corre más de una vez.
#
# Git branch: antes de escribir cualquier archivo, el script crea (o
# cambia a, si ya existe) la branch "session/S001" para alojar ahí los
# archivos generados. El script SOLO hace checkout -b / checkout -
# nunca git add, commit ni push. Eso queda a criterio de Victor una vez
# que revise el resultado generado.
#
# Ubicación e invocación: este script está pensado para vivir en
# tools/generators/generate-session-001.sh dentro del repo (no en la
# raíz). Se puede correr desde cualquier directorio - detecta la raíz
# real del repo vía git, no vía "directorio donde estoy parado":
#
#   cd tools/generators && ./generate-session-001.sh
#   # o, desde la raíz del repo:
#   ./tools/generators/generate-session-001.sh
#   # o con ruta absoluta desde cualquier lado:
#   /ruta/completa/tools/generators/generate-session-001.sh
#
# Los tres modos generan docs/ y site/ en la raíz real del repo, nunca
# dentro de tools/generators/.

set -euo pipefail

CODE="S001"
TITLE="Monolithic Architecture Style"
PHASE_NAME="Engineering Foundations"
MODULE_NAME="Modern Software Engineering"
PHASE_NUM=1
MODULE_NUM=1
TRACK="Staff"   # sesión Shared, cursada aquí en el contexto del track Staff

# ---------------------------------------------------------------------
# Resolución de REPO_ROOT: el script vive en tools/generators/ (no en la
# raíz del repo), así que NO se puede asumir pwd == raíz del repo. Se
# resuelve así, en orden de preferencia:
#   1. git rev-parse --show-toplevel desde la ubicación del propio
#      script - funciona sin importar desde dónde se invoque el script
#      (./generate-session-001.sh, tools/generators/generate-session-001.sh,
#      una ruta absoluta, etc.) y sin importar la profundidad real de
#      tools/generators/ dentro del repo.
#   2. Si no hay git disponible, se asume la convención
#      <raíz>/tools/generators/<script> (dos niveles) y se calcula la
#      raíz subiendo dos niveles desde la ubicación del script. Si tu
#      script vive en otra profundidad, ajusta este fallback a mano.
# ---------------------------------------------------------------------
SCRIPT_SOURCE="${BASH_SOURCE[0]}"
SCRIPT_DIR="$(cd "$(dirname "${SCRIPT_SOURCE}")" && pwd)"

if command -v git >/dev/null 2>&1 && git -C "${SCRIPT_DIR}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
else
  REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
fi

DOCS_DIR="${REPO_ROOT}/docs"
SITE_DIR="${REPO_ROOT}/site"
SITE_SESSIONS_DIR="${SITE_DIR}/sessions"   # ver Supuesto 1 arriba
SESSION_BRANCH="session/${CODE}"

echo "== Generando entregables para ${CODE} - ${TITLE} =="
echo "  - Raíz de repo detectada: ${REPO_ROOT}"

# ---------------------------------------------------------------------
# 0. Branch de git para alojar los archivos de esta sesión.
#    Solo checkout -b / checkout. NUNCA git add, commit ni push aquí -
#    eso queda a criterio de Victor una vez revisado el resultado.
# ---------------------------------------------------------------------
GIT_AVAILABLE=false
if command -v git >/dev/null 2>&1 && git -C "${REPO_ROOT}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  GIT_AVAILABLE=true
fi

if [ "${GIT_AVAILABLE}" = true ]; then
  CURRENT_BRANCH="$(git -C "${REPO_ROOT}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')"
  if git -C "${REPO_ROOT}" show-ref --verify --quiet "refs/heads/${SESSION_BRANCH}"; then
    if [ "${CURRENT_BRANCH}" != "${SESSION_BRANCH}" ]; then
      echo "  - Branch '${SESSION_BRANCH}' ya existe. Cambiando a ella (checkout, sin add/commit/push)..."
      git -C "${REPO_ROOT}" checkout "${SESSION_BRANCH}"
    else
      echo "  - Ya estás en la branch '${SESSION_BRANCH}'."
    fi
  else
    echo "  - Creando branch '${SESSION_BRANCH}' (checkout -b, sin add/commit/push)..."
    git -C "${REPO_ROOT}" checkout -b "${SESSION_BRANCH}"
  fi
else
  echo "  - ADVERTENCIA: no se detectó un repositorio git en ${REPO_ROOT}."
  echo "    Se omite la creación de branch; los archivos se generarán en"
  echo "    el working directory actual de todas formas."
fi

mkdir -p "${DOCS_DIR}/theory" "${DOCS_DIR}/sessions" "${DOCS_DIR}/adrs" "${SITE_SESSIONS_DIR}"

# ---------------------------------------------------------------------
# 1. docs/theory/Theory-001.md  (solo la teoría: Main Topic + Sub topics)
# ---------------------------------------------------------------------
cat > "${DOCS_DIR}/theory/Theory-001.md" << 'EOF'
# Phase 1 — Engineering Foundations
# Module 1 — Modern Software Engineering
# Theory 001 - Monolithic Architecture Style

## Main Topic

### 1. Definición y unidad de despliegue

Un **monolito** es, ante todo, una decisión sobre la **unidad de
despliegue**: toda la funcionalidad de la aplicación se empaqueta,
versiona y despliega como un único artefacto (un `.jar`, un contenedor,
un binario). No es una afirmación sobre el tamaño del código, la calidad
del diseño interno, ni sobre si el equipo que lo mantiene es pequeño o
grande.

Esta distinción es importante porque en la conversación de la industria
"monolito" se usa frecuentemente como sinónimo de "código mal diseñado",
lo cual es un error categorial: se puede tener un monolito con módulos
internos bien delimitados (ver `Modular Monolith`, sesión S022) o un
conjunto de microservicios con acoplamiento igual de problemático que
cualquier monolito descuidado. El estilo de despliegue y la calidad del
diseño interno son variables independientes.

### 2. Comunicación interna y modelo de datos

Dentro de un monolito, los distintos módulos se comunican típicamente
mediante **llamadas de función in-process** (invocación directa en el
mismo espacio de memoria y el mismo proceso), no mediante llamadas de
red. Esto tiene consecuencias verificables y no triviales:

- No hay serialización/deserialización de payloads entre módulos (a
  diferencia de una llamada HTTP/gRPC entre servicios).
- No hay latencia de red ni necesidad de manejar fallos parciales de red
  (timeouts, reintentos, circuit breakers) *entre módulos internos* —
  aunque sí pueden existir hacia dependencias externas (bases de datos,
  APIs de terceros).
- Las transacciones que involucran múltiples módulos pueden apoyarse en
  una **transacción ACID local** si comparten la misma base de datos,
  evitando la complejidad de patrones de consistencia distribuida como
  Saga o TCC (cubiertos en el Módulo 4, sesiones S051 y S052).

### 3. Monolito vs. "Big Ball of Mud": la distinción crítica

El verdadero anti-patrón no es "monolito" — es la **ausencia de límites
internos explícitos** (bounded contexts, en términos de DDD; ver S019).
Un monolito sin disciplina modular tiende, con el tiempo, a convertirse en
un "big ball of mud". La causa raíz de ese deterioro no es haber elegido
el estilo monolítico; es la falta de mecanismos de *enforcement* (en
tiempo de compilación, revisión de código o CI) que impidan que los
módulos violen sus límites declarados.

## Sub topics

### 4. Modelo de escalamiento: vertical y por réplica completa

Un monolito se escala de dos formas: escalamiento vertical (más
CPU/RAM/IO en la misma instancia) y escalamiento horizontal por réplica
completa (múltiples instancias idénticas detrás de un balanceador de
carga). La limitación estructural frente a microservicios (S005) es que
no se puede escalar un módulo individual de forma independiente según
su propia carga.

### 5. Boundaries internos y modularidad

Mantener módulos bien delimitados dentro de un monolito requiere
mecanismos activos de enforcement: visibilidad a nivel de
paquete/módulo en el lenguaje, linters arquitectónicos en CI (categoría
de herramienta: ArchUnit, dependency-cruiser, import-linter — como
ejemplos de categoría, no recomendación evaluada), y revisión de código
con checklist explícito cuando no hay tooling automatizado.

### 6. Trade-offs frente a estilos distribuidos

| Dimensión | Monolito | Microservicios (preview de S005) |
|---|---|---|
| Complejidad operativa inicial | Baja | Alta |
| Consistencia transaccional | Simple (ACID local) | Eventual (Saga, TCC) |
| Escalamiento granular | No | Sí |
| Autonomía de despliegue | Baja | Alta (en teoría) |
| Velocidad inicial de desarrollo | Alta para equipos pequeños | Menor al inicio |
| Riesgo de blast radius | Afecta el proceso completo | Aislable por servicio |

Ninguna fila es absoluta: resume tendencias documentadas en la
literatura citada en `Session-001.md`, no garantías.
EOF
echo "  - docs/theory/Theory-001.md escrito"

# ---------------------------------------------------------------------
# 2. docs/sessions/Session-001.md (contenido completo de la sesión)
# ---------------------------------------------------------------------
cat > "${DOCS_DIR}/sessions/Session-001.md" << 'EOF'
# Phase 1 — Engineering Foundations
# Module 1 — Modern Software Engineering
# Session 001 - Monolithic Architecture Style

## Goal
Al finalizar la sesión, Victor podrá definir con precisión qué es (y qué
NO es) un estilo de arquitectura monolítico, distinguirlo del anti-patrón
"big ball of mud", y justificar — con criterios explícitos y no por
default o por costumbre — cuándo un monolito es la decisión arquitectónica
correcta para un contexto de negocio dado, documentando esa decisión en un
ADR.

## Time breakdown

| Bloque | Actividad | Duración |
|---|---|---|
| 1 | Contexto y motivación | 10 min |
| 2 | Main Topic — Definición, unidad de despliegue y comunicación interna | 20 min |
| 3 | Sub topics — Escalamiento, boundaries internos y trade-offs | 25 min |
| 4 | Real world example | 15 min |
| 5 | Exercises (3) | 45 min |
| 6 | Knowledge mastery check | 10 min |
| **Total** | | **~125 min** |

*(Ver `docs/theory/Theory-001.md` para el desarrollo completo de Main
Topic y Sub topics; este archivo referencia el contenido íntegro
distribuido también en `Session-001.es.md` / `Session-001.en.md`.)*

## Real world example

Dato verificable: es una observación documentada en la literatura de
arquitectura de microservicios que varios servicios de internet
ampliamente conocidos (Amazon.com, eBay, Netflix) comenzaron con una
arquitectura monolítica antes de evolucionar hacia arquitecturas de
servicios (Chris Richardson, microservices.io — ver Resources). No se
detallan cronologías ni cifras específicas.

Escenario ilustrativo (pedagógico, no un caso real documentado): equipo
de 4 personas construyendo el MVP de una plataforma de reservas para
consultorios médicos, con un monolito modular de 3 paquetes
(`scheduling`, `billing`, `notifications`).

## Exercises
Ver el detalle completo (Contexto + Tarea de los 3 ejercicios) en
`Session-001.es.md`. Resumen:
1. Decisión de estilo arquitectónico para un MVP de logística.
2. Enforcement de boundaries internos tras crecimiento del equipo.
3. ADR-001 formalizando la decisión (ver `docs/adrs/ADR-001.md`).

## Resources
- Martin Fowler, "MonolithFirst" — https://martinfowler.com/bliki/MonolithFirst.html
- Martin Fowler & James Lewis, "Microservices" — https://martinfowler.com/articles/microservices.html
- Chris Richardson, "Pattern: Monolithic Architecture" — https://microservices.io/patterns/monolithic.html
- Sam Newman, *Building Microservices*, 2nd Ed. (O'Reilly) — https://www.oreilly.com/library/view/building-microservices-2nd/9781492034018/
- Mark Richards & Neal Ford, *Fundamentals of Software Architecture*, 2nd Ed. (O'Reilly) — https://www.oreilly.com/library/view/fundamentals-of-software/9781098175504/

## Knowledge mastery check
- [ ] Puedo definir un monolito en términos de unidad de despliegue, no
      de tamaño o calidad del código.
- [ ] Puedo explicar la diferencia entre "monolito" y "big ball of mud".
- [ ] Puedo enumerar al menos 3 ventajas y 3 desventajas verificables.
- [ ] Puedo explicar por qué el escalamiento es "todo o nada".
- [ ] Puedo nombrar al menos 2 mecanismos de enforcement de boundaries.
- [ ] Puedo argumentar cuándo NO conviene empezar con un monolito.

## Principal Engineer Lens

**Technical Perspective:** la comunicación in-process elimina overhead
de red pero también elimina aislamiento de fallos; la disciplina de
boundaries determina si el monolito sigue siendo mantenible.

**Business Perspective:** menor costo/tiempo al primer release; riesgo
no gestionado = deuda técnica silenciosa por erosión de boundaries.

**AI Perspective:** una llamada síncrona a un servicio de IA dentro del
flujo de request introduce latencia no determinista y un punto de fallo
compartido; aislar en patrón asíncrono con fallback determinista.

**Leadership Perspective:** la elección de estilo debe documentarse
como ADR, no adoptarse por default; Conway's Law (S117) ya opera dentro
del monolito vía la organización de paquetes internos.

## End-of-Session Success Criteria
- [ ] `generate-session-001.sh` existe, tiene permisos de ejecución y
      corre de forma idempotente.
- [ ] `docs/theory/Theory-001.md`, `docs/sessions/Session-001.md` y
      `docs/adrs/ADR-001.md` generados.
- [ ] `docs/dashboard.md`, `docs/current-state.md` y
      `docs/learning-journal.md` reflejan el avance.
- [ ] `site/sessions/S001.es.html` y `site/sessions/S001.en.html`
      compilan correctamente.
- [ ] Los 3 ejercicios resueltos con justificación de trade-offs.

## Reflection
Un monolito no es una arquitectura inferior por definición — es una
decisión legítima sobre la unidad de despliegue. El fracaso que la
industria atribuye al "estilo monolítico" es, con más precisión, el
fracaso de no mantener límites internos explícitos y su enforcement a
lo largo del tiempo.

*(Contenido completo y detallado de las 12 secciones: ver
`Session-001.es.md` / `Session-001.en.md`.)*
EOF
echo "  - docs/sessions/Session-001.md escrito"

# ---------------------------------------------------------------------
# 3. docs/adrs/ADR-001.md
# ---------------------------------------------------------------------
cat > "${DOCS_DIR}/adrs/ADR-001.md" << 'EOF'
# ADR-001: Arquitectura Monolítica para el MVP de Logística de Última Milla

## Estatus
Propuesto

## Contexto
El equipo (3 ingenieros) debe lanzar un MVP en 8 semanas para un cliente
piloto. El dominio (rutas, asignación de repartidores, tracking,
notificaciones) aún no está completamente entendido por el equipo.

## Decisión
Construir la aplicación como un monolito modular, con paquetes internos
separados por área de dominio (`routing`, `assignment`, `notifications`),
una única base de datos relacional, y un único pipeline de CI/CD.

## Consecuencias
- Positivas: menor complejidad operativa inicial, transacciones ACID
  locales entre módulos, mayor velocidad de iteración con equipo pequeño.
- Negativas: escalamiento únicamente por réplica completa (sin
  granularidad por módulo); riesgo de erosión de boundaries internos si
  no se instrumenta enforcement automatizado a tiempo.
- Trigger de revisión: si el equipo supera 10 ingenieros, o si el módulo
  de `notifications` desarrolla un patrón de carga o ciclo de despliegue
  claramente distinto al resto, reevaluar la extracción como servicio
  independiente (ver sesión S005).
EOF
echo "  - docs/adrs/ADR-001.md escrito"

# ---------------------------------------------------------------------
# 4. site/sessions/S001.es.html  y  site/sessions/S001.en.html
#    (mobile-first: viewport primero, stylesheet compartido,
#    tablas envueltas en .table-wrapper, lang-toggle)
# ---------------------------------------------------------------------
cat > "${SITE_SESSIONS_DIR}/S001.es.html" << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta charset="UTF-8">
<title>S001 - Monolithic Architecture Style</title>
<link rel="stylesheet" href="../assets/styles.css">
</head>
<body>
<div class="lang-toggle">
  <a href="S001.es.html" class="active">ES</a> |
  <a href="S001.en.html">EN</a>
</div>

<main class="session">
<p class="breadcrumb">Phase 1 — Engineering Foundations / Module 1 — Modern Software Engineering</p>
<h1>Session 001 - Monolithic Architecture Style</h1>

<h2>Goal</h2>
<p>Al finalizar la sesión, Victor podrá definir con precisión qué es (y
qué NO es) un estilo de arquitectura monolítico, distinguirlo del
anti-patrón "big ball of mud", y justificar cuándo un monolito es la
decisión arquitectónica correcta para un contexto de negocio dado,
documentando esa decisión en un ADR.</p>

<h2>Time breakdown</h2>
<div class="table-wrapper">
<table>
<thead><tr><th>Bloque</th><th>Actividad</th><th>Duración</th></tr></thead>
<tbody>
<tr><td>1</td><td>Contexto y motivación</td><td>10 min</td></tr>
<tr><td>2</td><td>Main Topic — Definición, unidad de despliegue y comunicación interna</td><td>20 min</td></tr>
<tr><td>3</td><td>Sub topics — Escalamiento, boundaries internos y trade-offs</td><td>25 min</td></tr>
<tr><td>4</td><td>Real world example</td><td>15 min</td></tr>
<tr><td>5</td><td>Exercises (3)</td><td>45 min</td></tr>
<tr><td>6</td><td>Knowledge mastery check</td><td>10 min</td></tr>
<tr><td><strong>Total</strong></td><td></td><td><strong>~125 min</strong></td></tr>
</tbody>
</table>
</div>

<h2>Main Topic</h2>
<h3>1. Definición y unidad de despliegue</h3>
<p>Un monolito es una decisión sobre la unidad de despliegue: toda la
funcionalidad se empaqueta, versiona y despliega como un único
artefacto. No es una afirmación sobre el tamaño del código ni sobre su
calidad interna. "Monolito" no es sinónimo de "código mal diseñado" —
se puede tener un monolito modular bien delimitado (S022) o
microservicios tan acoplados como cualquier monolito descuidado.</p>

<h3>2. Comunicación interna y modelo de datos</h3>
<p>Los módulos se comunican mediante llamadas de función in-process, sin
serialización de red ni necesidad de manejar fallos parciales de red
entre módulos internos. Las transacciones multi-módulo pueden apoyarse
en una transacción ACID local si comparten base de datos, evitando la
complejidad de Saga/TCC (S051, S052).</p>

<h3>3. Monolito vs. "Big Ball of Mud"</h3>
<p>El anti-patrón real es la ausencia de límites internos explícitos
(bounded contexts, S019), no el estilo monolítico. La causa del
deterioro es la falta de mecanismos de enforcement, no la elección del
estilo de despliegue.</p>

<h2>Sub topics</h2>
<h3>4. Modelo de escalamiento</h3>
<p>Vertical (más recursos por instancia) u horizontal por réplica
completa. No permite escalar un módulo individual según su propia
carga, a diferencia de microservicios (S005).</p>

<h3>5. Boundaries internos y modularidad</h3>
<p>Requiere mecanismos activos: visibilidad de paquete/módulo en el
lenguaje, linters arquitectónicos en CI (categoría: ArchUnit,
dependency-cruiser, import-linter), o revisión de código con checklist
explícito.</p>

<h3>6. Trade-offs frente a estilos distribuidos</h3>
<div class="table-wrapper">
<table>
<thead><tr><th>Dimensión</th><th>Monolito</th><th>Microservicios</th></tr></thead>
<tbody>
<tr><td>Complejidad operativa inicial</td><td>Baja</td><td>Alta</td></tr>
<tr><td>Consistencia transaccional</td><td>Simple (ACID local)</td><td>Eventual (Saga, TCC)</td></tr>
<tr><td>Escalamiento granular</td><td>No</td><td>Sí</td></tr>
<tr><td>Autonomía de despliegue</td><td>Baja</td><td>Alta (en teoría)</td></tr>
<tr><td>Velocidad inicial de desarrollo</td><td>Alta (equipos pequeños)</td><td>Menor al inicio</td></tr>
<tr><td>Riesgo de blast radius</td><td>Afecta el proceso completo</td><td>Aislable por servicio</td></tr>
</tbody>
</table>
</div>

<h2>Real world example</h2>
<p><strong>Dato verificable:</strong> según Chris Richardson
(microservices.io), varios servicios ampliamente conocidos (Amazon.com,
eBay, Netflix) comenzaron con arquitectura monolítica antes de
evolucionar a arquitecturas de servicios. No se detallan cronologías ni
cifras específicas en esa fuente.</p>
<p><strong>Escenario ilustrativo (pedagógico, no documentado):</strong>
equipo de 4 personas construyendo el MVP de una plataforma de reservas
para consultorios médicos con un monolito modular de 3 paquetes
(<code>scheduling</code>, <code>billing</code>, <code>notifications</code>).</p>

<h2>Exercises</h2>
<h3>Ejercicio 1 — Decisión de estilo arquitectónico para un MVP</h3>
<p><em>Contexto:</em> Principal Engineer de un equipo de 3 personas, MVP
de logística de última milla, 8 semanas, dominio aún no comprendido.</p>
<ol>
<li>Enumera ≥4 argumentos específicos a favor del monolito y ≥2 en contra.</li>
<li>Toma la decisión y justifícala.</li>
<li>Define la estructura inicial de paquetes internos (≥3).</li>
</ol>

<h3>Ejercicio 2 — Enforcement de boundaries internos</h3>
<p><em>Contexto:</em> 12 meses después, equipo de 3 a 12 ingenieros,
imports cruzados no planeados entre <code>routing</code> y
<code>notifications</code>.</p>
<ol>
<li>Propone un mecanismo de enforcement (categoría de herramienta y regla(s)).</li>
<li>Define la política de violación/bloqueo/excepción.</li>
<li>Identifica ≥2 señales de alerta adicionales de "big ball of mud".</li>
</ol>

<h3>Ejercicio 3 — ADR de decisión arquitectónica</h3>
<p><em>Contexto:</em> formalizar la decisión del Ejercicio 1.</p>
<ol>
<li>Redacta ADR-001 (Estatus, Contexto, Decisión, Consecuencias).</li>
<li>Incluye un trigger explícito de revisión futura.</li>
</ol>
<p>Ver <code>docs/adrs/ADR-001.md</code> para el ADR persistido.</p>

<h2>Resources</h2>
<ul>
<li>Martin Fowler, "MonolithFirst" — <a href="https://martinfowler.com/bliki/MonolithFirst.html">martinfowler.com/bliki/MonolithFirst.html</a></li>
<li>Martin Fowler &amp; James Lewis, "Microservices" — <a href="https://martinfowler.com/articles/microservices.html">martinfowler.com/articles/microservices.html</a></li>
<li>Chris Richardson, "Pattern: Monolithic Architecture" — <a href="https://microservices.io/patterns/monolithic.html">microservices.io/patterns/monolithic.html</a></li>
<li>Sam Newman, <em>Building Microservices</em>, 2nd Ed. (O'Reilly) — <a href="https://www.oreilly.com/library/view/building-microservices-2nd/9781492034018/">oreilly.com</a></li>
<li>Mark Richards &amp; Neal Ford, <em>Fundamentals of Software Architecture</em>, 2nd Ed. (O'Reilly) — <a href="https://www.oreilly.com/library/view/fundamentals-of-software/9781098175504/">oreilly.com</a></li>
</ul>

<h2>Knowledge mastery check</h2>
<ul class="checklist">
<li>Puedo definir un monolito en términos de unidad de despliegue, no de tamaño o calidad del código.</li>
<li>Puedo explicar la diferencia entre "monolito" y "big ball of mud".</li>
<li>Puedo enumerar ≥3 ventajas y ≥3 desventajas verificables del estilo monolítico.</li>
<li>Puedo explicar por qué el escalamiento es "todo o nada".</li>
<li>Puedo nombrar ≥2 mecanismos de enforcement de boundaries internos.</li>
<li>Puedo argumentar, con ≥2 criterios, cuándo NO conviene empezar con un monolito.</li>
</ul>

<h2>Principal Engineer Lens</h2>
<h3>Technical Perspective</h3>
<p>La comunicación in-process elimina overhead de red pero también el
aislamiento de fallos que la red provee; la disciplina de boundaries
determina si el monolito sigue siendo mantenible.</p>
<h3>Business Perspective</h3>
<p>Menor costo/tiempo al primer release; el riesgo no gestionado es la
deuda técnica silenciosa por erosión de boundaries.</p>
<h3>AI Perspective</h3>
<p>Una llamada síncrona a un servicio de IA dentro del flujo de request
introduce latencia no determinista y un punto de fallo compartido;
mitigación: patrón asíncrono con fallback determinista.</p>
<h3>Leadership Perspective</h3>
<p>La elección de estilo debe documentarse como ADR, no adoptarse por
default; Conway's Law (S117) ya opera dentro del monolito vía la
organización de paquetes internos.</p>

<h2>End-of-Session Success Criteria</h2>
<ul class="checklist">
<li><code>generate-session-001.sh</code> existe, tiene permisos de ejecución y corre de forma idempotente.</li>
<li><code>docs/theory/Theory-001.md</code>, <code>docs/sessions/Session-001.md</code> y <code>docs/adrs/ADR-001.md</code> generados.</li>
<li><code>docs/dashboard.md</code>, <code>docs/current-state.md</code> y <code>docs/learning-journal.md</code> reflejan el avance.</li>
<li><code>site/sessions/S001.es.html</code> y <code>site/sessions/S001.en.html</code> compilan correctamente.</li>
<li>Los 3 ejercicios resueltos con justificación de trade-offs, incluyendo el ADR-001 con su trigger.</li>
</ul>

<h2>Reflection</h2>
<p>Un monolito no es una arquitectura inferior por definición — es una
decisión legítima sobre la unidad de despliegue. El fracaso que la
industria atribuye al "estilo monolítico" es, con más precisión, el
fracaso de no mantener límites internos explícitos y su enforcement a
lo largo del tiempo.</p>

</main>
</body>
</html>
EOF
echo "  - site/sessions/S001.es.html escrito"

cat > "${SITE_SESSIONS_DIR}/S001.en.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta charset="UTF-8">
<title>S001 - Monolithic Architecture Style</title>
<link rel="stylesheet" href="../assets/styles.css">
</head>
<body>
<div class="lang-toggle">
  <a href="S001.es.html">ES</a> |
  <a href="S001.en.html" class="active">EN</a>
</div>

<main class="session">
<p class="breadcrumb">Phase 1 — Engineering Foundations / Module 1 — Modern Software Engineering</p>
<h1>Session 001 - Monolithic Architecture Style</h1>

<h2>Goal</h2>
<p>By the end of the session, Victor will be able to precisely define
what a monolithic architecture style is (and is NOT), distinguish it
from the "big ball of mud" anti-pattern, and justify when a monolith is
the correct architectural decision for a given business context,
documenting that decision in an ADR.</p>

<h2>Time breakdown</h2>
<div class="table-wrapper">
<table>
<thead><tr><th>Block</th><th>Activity</th><th>Duration</th></tr></thead>
<tbody>
<tr><td>1</td><td>Context and motivation</td><td>10 min</td></tr>
<tr><td>2</td><td>Main Topic — Definition, deployment unit, and internal communication</td><td>20 min</td></tr>
<tr><td>3</td><td>Sub topics — Scaling, internal boundaries, and trade-offs</td><td>25 min</td></tr>
<tr><td>4</td><td>Real world example</td><td>15 min</td></tr>
<tr><td>5</td><td>Exercises (3)</td><td>45 min</td></tr>
<tr><td>6</td><td>Knowledge mastery check</td><td>10 min</td></tr>
<tr><td><strong>Total</strong></td><td></td><td><strong>~125 min</strong></td></tr>
</tbody>
</table>
</div>

<h2>Main Topic</h2>
<h3>1. Definition and deployment unit</h3>
<p>A monolith is a decision about the deployment unit: all
functionality is packaged, versioned, and deployed as a single
artifact. It is not a statement about code size or internal quality.
"Monolith" is not a synonym for "poorly designed code" — you can have a
well-delimited modular monolith (S022) or microservices as coupled as
any neglected monolith.</p>

<h3>2. Internal communication and data model</h3>
<p>Modules communicate through in-process function calls, with no
network serialization or need to handle partial network failures
between internal modules. Multi-module transactions can rely on a
local ACID transaction if they share a database, avoiding the
complexity of Saga/TCC (S051, S052).</p>

<h3>3. Monolith vs. "Big Ball of Mud"</h3>
<p>The real anti-pattern is the absence of explicit internal boundaries
(bounded contexts, S019), not the monolithic style. Decay is caused by
lack of enforcement mechanisms, not by the choice of deployment style.</p>

<h2>Sub topics</h2>
<h3>4. Scaling model</h3>
<p>Vertical (more resources per instance) or horizontal by full
replica. It does not allow scaling an individual module according to
its own load, unlike microservices (S005).</p>

<h3>5. Internal boundaries and modularity</h3>
<p>Requires active mechanisms: package/module-level visibility in the
language, architectural linters in CI (category: ArchUnit,
dependency-cruiser, import-linter), or code review with an explicit
checklist.</p>

<h3>6. Trade-offs against distributed styles</h3>
<div class="table-wrapper">
<table>
<thead><tr><th>Dimension</th><th>Monolith</th><th>Microservices</th></tr></thead>
<tbody>
<tr><td>Initial operational complexity</td><td>Low</td><td>High</td></tr>
<tr><td>Transactional consistency</td><td>Simple (local ACID)</td><td>Eventual (Saga, TCC)</td></tr>
<tr><td>Granular scaling</td><td>No</td><td>Yes</td></tr>
<tr><td>Deployment autonomy</td><td>Low</td><td>High (in theory)</td></tr>
<tr><td>Initial development speed</td><td>High (small teams)</td><td>Lower at the start</td></tr>
<tr><td>Blast radius risk</td><td>Affects the whole process</td><td>Isolable per service</td></tr>
</tbody>
</table>
</div>

<h2>Real world example</h2>
<p><strong>Verifiable fact:</strong> per Chris Richardson
(microservices.io), several widely known services (Amazon.com, eBay,
Netflix) began with a monolithic architecture before evolving toward
service-based architectures. That source does not detail specific
timelines or figures.</p>
<p><strong>Illustrative scenario (pedagogical, not documented):</strong>
a 4-person team building the MVP of a scheduling platform for medical
clinics with a modular monolith of 3 packages (<code>scheduling</code>,
<code>billing</code>, <code>notifications</code>).</p>

<h2>Exercises</h2>
<h3>Exercise 1 — Architectural style decision for an MVP</h3>
<p><em>Context:</em> Principal Engineer of a 3-person team, last-mile
logistics MVP, 8 weeks, domain not yet understood.</p>
<ol>
<li>List ≥4 context-specific arguments for the monolith and ≥2 against.</li>
<li>Make the decision and justify it.</li>
<li>Define the initial internal package structure (≥3).</li>
</ol>

<h3>Exercise 2 — Enforcing internal boundaries</h3>
<p><em>Context:</em> 12 months later, team grew from 3 to 12 engineers,
unplanned cross imports between <code>routing</code> and
<code>notifications</code>.</p>
<ol>
<li>Propose an enforcement mechanism (tool category and rule(s)).</li>
<li>Define the violation/blocking/exception policy.</li>
<li>Identify ≥2 additional "big ball of mud" warning signs.</li>
</ol>

<h3>Exercise 3 — Architecture Decision Record</h3>
<p><em>Context:</em> formalize the Exercise 1 decision.</p>
<ol>
<li>Write ADR-001 (Status, Context, Decision, Consequences).</li>
<li>Include an explicit future review trigger.</li>
</ol>
<p>See <code>docs/adrs/ADR-001.md</code> for the persisted ADR.</p>

<h2>Resources</h2>
<ul>
<li>Martin Fowler, "MonolithFirst" — <a href="https://martinfowler.com/bliki/MonolithFirst.html">martinfowler.com/bliki/MonolithFirst.html</a></li>
<li>Martin Fowler &amp; James Lewis, "Microservices" — <a href="https://martinfowler.com/articles/microservices.html">martinfowler.com/articles/microservices.html</a></li>
<li>Chris Richardson, "Pattern: Monolithic Architecture" — <a href="https://microservices.io/patterns/monolithic.html">microservices.io/patterns/monolithic.html</a></li>
<li>Sam Newman, <em>Building Microservices</em>, 2nd Ed. (O'Reilly) — <a href="https://www.oreilly.com/library/view/building-microservices-2nd/9781492034018/">oreilly.com</a></li>
<li>Mark Richards &amp; Neal Ford, <em>Fundamentals of Software Architecture</em>, 2nd Ed. (O'Reilly) — <a href="https://www.oreilly.com/library/view/fundamentals-of-software/9781098175504/">oreilly.com</a></li>
</ul>

<h2>Knowledge mastery check</h2>
<ul class="checklist">
<li>I can define a monolith in terms of deployment unit, not code size or quality.</li>
<li>I can explain the difference between "monolith" and "big ball of mud".</li>
<li>I can list ≥3 verifiable advantages and ≥3 disadvantages of the monolithic style.</li>
<li>I can explain why scaling is "all or nothing".</li>
<li>I can name ≥2 mechanisms for enforcing internal boundaries.</li>
<li>I can argue, with ≥2 criteria, when it is NOT advisable to start with a monolith.</li>
</ul>

<h2>Principal Engineer Lens</h2>
<h3>Technical Perspective</h3>
<p>In-process communication removes network overhead but also the
failure isolation the network provides; boundary discipline determines
whether the monolith stays maintainable.</p>
<h3>Business Perspective</h3>
<p>Lower cost/time to first release; the unmanaged risk is silent
technical debt from boundary erosion.</p>
<h3>AI Perspective</h3>
<p>A synchronous call to an AI service inside the request flow
introduces non-deterministic latency and a shared failure point;
mitigation: an asynchronous pattern with a deterministic fallback.</p>
<h3>Leadership Perspective</h3>
<p>The style choice should be documented as an ADR, not adopted by
default; Conway's Law (S117) already operates inside the monolith via
internal package organization.</p>

<h2>End-of-Session Success Criteria</h2>
<ul class="checklist">
<li><code>generate-session-001.sh</code> exists, has execute permissions, and runs idempotently.</li>
<li><code>docs/theory/Theory-001.md</code>, <code>docs/sessions/Session-001.md</code>, and <code>docs/adrs/ADR-001.md</code> generated.</li>
<li><code>docs/dashboard.md</code>, <code>docs/current-state.md</code>, and <code>docs/learning-journal.md</code> reflect progress.</li>
<li><code>site/sessions/S001.es.html</code> and <code>site/sessions/S001.en.html</code> compile correctly.</li>
<li>All 3 exercises resolved with trade-off justification, including ADR-001 with its review trigger.</li>
</ul>

<h2>Reflection</h2>
<p>A monolith is not an inferior architecture by definition — it is a
legitimate decision about the deployment unit. What the industry often
attributes to the "monolithic style" is, more precisely, the failure to
maintain explicit internal boundaries and their enforcement over time.</p>

</main>
</body>
</html>
EOF
echo "  - site/sessions/S001.en.html escrito"

# ---------------------------------------------------------------------
# 5. docs/dashboard.md (crear si no existe; insertar fila si falta)
# ---------------------------------------------------------------------
DASHBOARD="${DOCS_DIR}/dashboard.md"
if [ ! -f "${DASHBOARD}" ]; then
  cat > "${DASHBOARD}" << 'EOF'
# Dashboard

| Code | Title | Phase | Module | Track | Status |
|---|---|---|---|---|---|
EOF
fi
if ! grep -q "^| ${CODE} " "${DASHBOARD}" 2>/dev/null; then
  echo "| ${CODE} | ${TITLE} | ${PHASE_NUM} | ${MODULE_NUM} | ${TRACK} | Completed |" >> "${DASHBOARD}"
  echo "  - docs/dashboard.md actualizado (fila ${CODE} agregada)"
else
  echo "  - docs/dashboard.md ya contenía ${CODE}, sin cambios (idempotente)"
fi

# ---------------------------------------------------------------------
# 6. docs/current-state.md (crear si no existe; reemplazar bloque marcado)
# ---------------------------------------------------------------------
CURRENT_STATE="${DOCS_DIR}/current-state.md"
MARKER_START="<!-- CURRENT-SESSION:START -->"
MARKER_END="<!-- CURRENT-SESSION:END -->"
BLOCK_CONTENT="${MARKER_START}
- Last completed session: ${CODE} - ${TITLE} (Phase ${PHASE_NUM}, Module ${MODULE_NUM}, Track ${TRACK})
- Next session: TBD (definir con Victor)
${MARKER_END}"

if [ ! -f "${CURRENT_STATE}" ]; then
  {
    echo "# Current State"
    echo ""
    echo "${BLOCK_CONTENT}"
  } > "${CURRENT_STATE}"
  echo "  - docs/current-state.md creado"
else
  if grep -q "${MARKER_START}" "${CURRENT_STATE}"; then
    # Reemplaza el bloque existente entre los marcadores (idempotente)
    python3 - "$CURRENT_STATE" "$MARKER_START" "$MARKER_END" "$BLOCK_CONTENT" << 'PYEOF'
import sys
path, start, end, block = sys.argv[1:5]
with open(path, "r", encoding="utf-8") as f:
    content = f.read()
pre, rest = content.split(start, 1)
_, post = rest.split(end, 1)
new_content = pre + block + post
with open(path, "w", encoding="utf-8") as f:
    f.write(new_content)
PYEOF
    echo "  - docs/current-state.md actualizado (bloque reemplazado)"
  else
    printf '\n%s\n' "${BLOCK_CONTENT}" >> "${CURRENT_STATE}"
    echo "  - docs/current-state.md: bloque de marcador agregado al final"
  fi
fi

# ---------------------------------------------------------------------
# 7. docs/learning-journal.md (append solo si la entrada no existe)
# ---------------------------------------------------------------------
JOURNAL="${DOCS_DIR}/learning-journal.md"
JOURNAL_HEADING="## ${CODE} - ${TITLE}"
if [ ! -f "${JOURNAL}" ]; then
  echo "# Learning Journal" > "${JOURNAL}"
  echo "" >> "${JOURNAL}"
fi
if ! grep -qF "${JOURNAL_HEADING}" "${JOURNAL}"; then
  {
    echo "${JOURNAL_HEADING}"
    echo "- Fase 1, Módulo 1 — Modern Software Engineering. Track: ${TRACK}."
    echo "- Distinción trabajada: monolito (unidad de despliegue) vs. big ball"
    echo "  of mud (ausencia de boundaries) como variables independientes."
    echo "- ADR-001 redactado: monolito modular para MVP de logística, con"
    echo "  trigger de revisión explícito (>10 ingenieros o carga divergente"
    echo "  de un módulo)."
    echo ""
  } >> "${JOURNAL}"
  echo "  - docs/learning-journal.md: entrada de ${CODE} agregada"
else
  echo "  - docs/learning-journal.md ya contenía la entrada de ${CODE}, sin cambios (idempotente)"
fi

echo "== Listo: ${CODE} persistido en docs/ y site/sessions/ =="
