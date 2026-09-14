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
