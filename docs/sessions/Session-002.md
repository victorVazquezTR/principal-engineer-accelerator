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
