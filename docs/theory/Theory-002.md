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
