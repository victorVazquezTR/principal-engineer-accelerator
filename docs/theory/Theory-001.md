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
