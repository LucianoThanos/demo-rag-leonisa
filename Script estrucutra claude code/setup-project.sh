#!/usr/bin/env bash
# ============================================================================
# setup-project.sh — Genera un esqueleto limpio del proyecto Claude Leonisa
# Uso:  bash setup-project.sh [nombre-del-proyecto]
#       Si no se pasa argumento, pregunta interactivamente.
# ============================================================================

set -euo pipefail

# ── Obtener nombre del proyecto ────────────────────────────────────────────────
if [[ $# -ge 1 ]]; then
  PROJECT_NAME="$1"
else
  echo ""
  read -rp "Nombre del proyecto: " PROJECT_NAME
  if [[ -z "$PROJECT_NAME" ]]; then
    echo ""
    echo "ERROR: Debe ingresar un nombre de proyecto."
    echo ""
    exit 1
  fi
fi

DEST="$PROJECT_NAME"

# ── Validar que no exista ya ────────────────────────────────────────────────
if [[ -d "$DEST" ]]; then
  echo ""
  echo "ERROR: La carpeta '$DEST' ya existe y no se puede crear."
  echo "Elija un nombre diferente para el proyecto."
  echo ""
  exit 1
fi

# ============================================================================
echo ""
echo "=== Setup Proyecto Claude Leonisa ==="
echo "Proyecto: $PROJECT_NAME"
echo ""

# ── Crear estructura base ────────────────────────────────────────────────────
mkdir -p "$DEST"/{.claude/{agents,rules,skills,hooks},src/{frontend,backend},docs,requerimientos/"casos de uso",tests,scripts}

# ── .claude/agents/ ──────────────────────────────────────────────────────────
cat > "$DEST/.claude/agents/requirements-agent.md" << 'EOF'
# Requirements Agent

Eres el agente de requerimientos. Tu responsabilidad es:

1. Leer documentos del cliente en `requerimientos/`
2. Extraer funcionalidades, entidades y reglas de negocio
3. Generar Casos de Uso en formato Gherkin en `docs/`
4. Producir Especificaciones Técnicas detalladas

## Flujo

1. Analizar documentos de entrada
2. Identificar actores, entidades y relaciones
3. Escribir escenarios Gherkin (Given/When/Then)
4. Documentar especificaciones técnicas

## Salida

- `docs/casos-de-uso.md` — Casos de uso en Gherkin
- `docs/especificaciones-tecnicas.md` — Especificaciones técnicas
EOF

cat > "$DEST/.claude/agents/architect-agent.md" << 'EOF'
# Architect Agent

Eres el arquitecto de software. Tu responsabilidad es:

1. Diseñar la arquitectura de componentes del frontend
2. Definir la API REST (openapi.yaml)
3. Establecer patrones de comunicación entre capas
4. Documentar decisiones arquitectónicas

## Flujo

1. Revisar especificaciones técnicas en `docs/`
2. Diseñar la arquitectura de componentes
3. Definir endpoints API en `docs/api/openapi.yaml`
4. Documentar decisiones en `docs/decisiones/`

## Salida

- `docs/arquitectura/componentes.md` — Arquitectura de componentes
- `docs/api/openapi.yaml` — Definición de API
- `docs/decisiones/` — ADRs (Architecture Decision Records)
EOF

cat > "$DEST/.claude/agents/database-architect.md" << 'EOF'
# Database Architect Agent

Eres el especialista en diseño de base de datos. Tu responsabilidad es:

1. Diseñar el esquema de base de datos (SQLite)
2. Generar migraciones SQL en `db/migrations/`
3. Definir relaciones, índices y restricciones
4. Documentar el modelo de datos

## Flujo

1. Revisar entidades de las especificaciones técnicas
2. Diseñar tablas y relaciones
3. Crear migraciones SQL versionadas
4. Documentar el DER (Diagrama Entidad-Relación)

## Salida

- `db/migrations/` — Archivos SQL de migración
- `docs/arquitectura/modelo-datos.md` — Documentación del modelo
EOF

cat > "$DEST/.claude/agents/backend-dev.md" << 'EOF'
# Backend Developer Agent

Eres el desarrollador backend. Tu responsabilidad es:

1. Implementar endpoints de la API en Express
2. Crear modelos de datos y conexión con SQLite
3. Implementar la lógica de negocio
4. Escribir tests de integración

## Convenciones

- TypeScript estricto, ES Modules
- Handlers en `src/backend/api/handlers/`
- Modelos en `src/backend/models/`
- Rutas en `src/backend/routes/`
- Tipos en `src/backend/types/`

## Flujo

1. Leer openapi.yaml y especificaciones
2. Crear modelos y tipos
3. Implementar handlers y rutas
4. Escribir tests
EOF

cat > "$DEST/.claude/agents/frontend-dev.md" << 'EOF'
# Frontend Developer Agent

Eres el desarrollador frontend. Tu responsabilidad es:

1. Implementar componentes React con TypeScript
2. Consumir APIs del backend
3. Implementar páginas y flujos de navegación
4. Escribir tests de componentes

## Convenciones

- React + TypeScript + Tailwind CSS
- Componentes en `src/frontend/components/`
- Páginas en `src/frontend/pages/`
- Hooks en `src/frontend/hooks/`
- Servicios API en `src/frontend/services/`

## Flujo

1. Usar prototipado visual (Stitch MCP) para diseño
2. Implementar componentes atómicos primero
3. Componer páginas y flujos
4. Integrar con APIs del backend
5. Escribir tests
EOF

# ── .claude/rules/ ───────────────────────────────────────────────────────────
cat > "$DEST/.claude/rules/frontend-patterns.md" << 'EOF'
# Frontend Patterns

## Stack

- React 18+ con TypeScript
- Tailwind CSS para estilos
- Vite como bundler

## Convenciones

- Componentes funcionales con hooks
- Tipos estrictos, sin `any`
- ES Modules (`import`/`export`)
- Indentación de 2 espacios
- Nombres de componentes en PascalCase
- Nombres de hooks en camelCase (prefijo `use`)

## Estructura

- `components/` — Componentes reutilizables
- `pages/` — Vistas/páginas principales
- `hooks/` — Custom hooks
- `services/` — Llamadas a API
- `types/` — Interfaces y tipos TypeScript

## Patrones

- Estado local con `useState`, estado global solo si es necesario
- Props tipadas con interfaces
- Manejo de errores con boundaries o try/catch en servicios
- Composición sobre herencia
EOF

cat > "$DEST/.claude/rules/backend-patterns.md" << 'EOF'
# Backend Patterns

## Stack

- Node.js + Express con TypeScript
- SQLite como base de datos
- better-sqlite3 como driver

## Convenciones

- TypeScript estricto, ES Modules
- Indentación de 2 espacios
- Nombres de archivos en camelCase
- Handlers async con try/catch
- Respuestas JSON estandarizadas

## Estructura

- `api/handlers/` — Controladores de endpoints
- `models/` — Modelos de datos y acceso DB
- `routes/` — Definición de rutas Express
- `services/` — Lógica de negocio
- `types/` — Interfaces y tipos TypeScript

## Patrones

- Separación estricta: handler → service → model
- Validación de input en handlers
- Transacciones para operaciones multi-tabla
- Migraciones SQL versionadas en `db/migrations/`
EOF

cat > "$DEST/.claude/rules/database-patterns.md" << 'EOF'
# Database Patterns

## Motor

- SQLite con better-sqlite3

## Convenciones

- Migraciones en `db/migrations/` con prefijo numérico
- Nombres de tablas en snake_case
- Campos de auditoría: `created_at`, `updated_at`
- Claves primarias: `id` INTEGER AUTOINCREMENT
- Soft delete con campo `deleted_at` cuando aplique

## Patrones

- Cada migración es idempotente (IF NOT EXISTS)
- Índices para campos de búsqueda frecuente
- Foreign keys con ON DELETE CASCADE o SET NULL según caso
- Transacciones para operaciones atómicas
EOF

# ── .claude/settings.json ────────────────────────────────────────────────────
cat > "$DEST/.claude/settings.json" << 'EOF'
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
EOF

# ── CLAUDE.md ────────────────────────────────────────────────────────
cat > "$DEST/CLAUDE.md" << 'EOF'
# Instrucciones del Proyecto

Ver @README.md para una visión general del proyecto y @package.json para los comandos principales.

---

## Reglas de Contexto (Rules)

Para mantener un historial limpio y no procesar todo el repositorio de una, Claude tiene perfiles de reglas especializados según la capa de aplicación. **Claude debe revisar automáticamente estas reglas** cuando vaya a modificar o crear archivos en los dominios respectivos:

- **Frontend**: Consulta `.claude/rules/frontend-patterns.md` antes de programar componentes en React y Tailwind.
- **Backend**: Consulta `.claude/rules/backend-patterns.md` antes de alterar endpoints de Express, modelos o la DB con SQLite.

---

## Estilo de Código General

- **ES Modules**: Utiliza sintaxis nativa de módulos (`import`/`export`). Prohíbido CommonJS (`require`).
- **TypeScript**: Tipado estricto por defecto. No uses `any`.
- **Imports**: Destructura los imports cuando sea posible.
- **Formato**: Usa indentación de 2 espacios.

## Arquitectura de Carpetas

- **Convención Principal**: Todo el código de Frontend y Backend debe ubicarse obligatoriamente dentro de la carpeta `src/`, separados en subcarpetas lógicas.
- **Frontend**: `src/frontend/` (Contiene la aplicación React completa, componentes, páginas, assets)
- **Backend**: `src/backend/` (Contiene todos los servicios de Node/Express)
  - Handlers y Controladores: `src/backend/api/handlers/`
  - Modelos de datos y conexión DB: `src/backend/models/`
  - Rutas: `src/backend/routes/`
  - Tipos: `src/backend/types/`
- Migraciones de Base de Datos: `db/migrations/`

## Orquestación de Agentes (Flujo de Creación)

Para crear nuevas funcionalidades o proyectos desde cero, se debe seguir estrictamente este flujo de trabajo multi-agente, invocando a los roles definidos en `.claude/agents/`:

1. **Requerimientos (`@requirements-agent.md`)**: Primero, solicita al agente de requerimientos que procese los documentos del cliente en `/requerimientos` y genere los Casos de Uso (Gherkin) y las Especificaciones Técnicas en `/docs`.
2. **Arquitectura y Base de Datos (`@architect-agent.md` / `@database-architect.md`)**: Luego, invoca al arquitecto (y al experto en base de datos si aplica) para que diseñe la base de datos, genere la arquitectura de componentes y defina la API (`openapi.yaml`) basándose en las especificaciones documentadas en el paso anterior.
3. **Desarrollo Backend (`@backend-dev.md`)**: Delega al desarrollador backend la inicialización o modificación del proyecto en `/src/backend`, implementando los modelos, endpoints de la API y lógica de negocio.
4. **Desarrollo Frontend (`@frontend-dev.md`)**: Delega al desarrollador frontend la implementación visual en `/src/frontend`, utilizando prototipado visual inicial (ej. Stitch MCP) antes de escribir el código de los componentes iterando sobre las APIs ya definidas.

## Flujo de Trabajo

- Siempre ejecuta `npm test` al completar una funcionalidad y hacer cambios relevantes.
- Por cuestiones de rendimiento, al desarrollar, prefiere correr tests individuales focalizados antes que toda la suite completa.
- Tras un bloque de trabajo, haz una validación de tipos (`typecheck`).

## Convenciones de Git

- **Ramas**: Prefijos semánticos, formato `feature/nombre-corto` o `fix/descripcion-bug`.
- **Commits**: Seguir estrictamente The Conventional Commits (`feat: ...`, `fix: ...`, `docs: ...`).
- Referencias adicionales: `docs/git-instructions.md` (si el proyecto tiene) y `~/.claude/my-project-instructions.md` (preferencias de usuario).
EOF

# ── Requerimientos ───────────────────────────────────────────────────────────
cat > "$DEST/requerimientos/plantilla-descripcion-general.md" << 'EOF'
# Proyecto: [Nombre del Proyecto]

## Contexto General
Este documento define los requisitos funcionales y técnicos del sistema.
Debe ser utilizado por los agentes para generar:
- Casos de uso
- Arquitectura
- Base de datos
- Implementación

---

## Objetivo del Sistema
[Explicar claramente qué problema resuelve el sistema]

Formato recomendado:
- Problema:
- Solución:
- Valor para el usuario:

---

## Alcance del MVP

### Incluye
- [Funcionalidad principal 1]
- [Funcionalidad principal 2]
- [CRUD principal del sistema]
- [Persistencia de datos]

### No incluye
- [Funcionalidades futuras]
- [Integraciones complejas]
- [Optimización avanzada]

---

## Usuarios del Sistema
Definir quién usa la app y cómo:

- Tipo de usuario: [Ej: Usuario final]
- Nivel técnico: [Bajo / Medio / Alto]
- Objetivo principal: [Qué quiere lograr]

---

## Funcionalidades Principales

### [Modulo 1 - Ej: Gestion de Tareas]
- Crear tarea
- Editar tarea
- Eliminar tarea
- Marcar como completada

### [Modulo 2]
- [Accion]
- [Accion]

---

## Reglas de Negocio (MUY IMPORTANTE)

- [Ej: Una tarea no puede estar completada sin fecha]
- [Ej: El titulo es obligatorio]
- [Ej: No se permiten duplicados]

---

## Requisitos de Datos

Entidades principales:

### Tarea
- id
- titulo
- descripcion
- estado (pendiente/completado)
- fecha_creacion

---

## Stack Tecnologico

- **Frontend:** React + Tailwind
- **Backend:** Node.js + Express
- **Base de Datos:** SQLite

---

## Integraciones (Opcional)

- [API externa]
- [Auth provider]

(Si no hay, aclarar: "No aplica en MVP")

---

## Requisitos No Funcionales

### Seguridad
- Autenticacion con JWT
- Passwords hasheados con bcrypt

### Rendimiento
- Respuesta < 500ms
- Manejo eficiente de estado

### Escalabilidad
- Arquitectura modular
- Separacion frontend/backend

---

## Estructura Esperada del Proyecto

```bash
src/
 ├── backend/
 └── frontend/
docs/
requerimientos/
```
EOF

cat > "$DEST/requerimientos/casos de uso/plantilla-descripcion-casos-de-uso.md" << 'EOF'
# Caso de Uso [Numero/ID]: [Nombre descriptivo de la accion]

**Actor:** [Quien realiza la accion. Ej: Usuario autenticado, Administrador, Sistema, Invitado]

**Precondicion:** [Que tiene que haber pasado antes para que este flujo pueda ejecutarse. Ej: El usuario ha iniciado sesion y se encuentra en la pantalla del panel de control.]

**Flujo Principal:**
1. [Accion del Usuario] - El usuario [hace clic en / navega a / selecciona]...
2. [Accion del Usuario] - El usuario [escribe / completa el formulario con]...
3. [Accion de Envio] - El usuario presiona [Enter / el boton de enviar].
4. [Validacion del Sistema] - El sistema valida que [condicion a cumplir, ej: los campos no esten vacios].
5. [Accion Interna/Backend] - El sistema [guarda / actualiza / elimina] los datos en la base de datos con el estado [estado correspondiente].
6. [Respuesta Visual/Frontend] - El sistema actualiza la interfaz mostrando [que cambia en la pantalla para confirmar el exito].

**Flujos Alternativos (Excepciones y Errores):**
* **[Nombre del Error 1, ej: Campo vacio]:** Si [condicion del error], el sistema [reaccion del sistema, ej: deshabilita el boton o muestra el mensaje "El campo es obligatorio"]. El flujo se detiene aqui hasta que el usuario corrija la accion.
* **[Nombre del Error 2, ej: Fallo de servidor]:** Si la base de datos no responde, el sistema muestra un *toast* rojo con el mensaje "Error al procesar la solicitud" y permite reintentar.

---
**Postcondicion (Opcional):**
[Estado del sistema despues de que el flujo principal termina con exito. Ej: La tarea queda registrada y es visible en la lista general.]
EOF

# ── configuracion.md ─────────────────────────────────────────────────────────
cat > "$DEST/configuracion.md" << 'EOF'
# Configuracion del Proyecto — Claude Leonisa

## Resumen General

Este documento describe todo lo que genera el script `setup-project.sh` al crear un nuevo proyecto.

---

## Estructura de Carpetas

```
<proyecto>/
├── .claude/
│   ├── agents/              # Definiciones de agentes especializados
│   ├── rules/                # Reglas de contexto por dominio
│   ├── skills/               # Skills personalizados (vacio, punto de extension)
│   ├── hooks/                # Hooks de automatizacion (vacio, punto de extension)
│   └── settings.json         # Configuracion de Claude Code
├── src/
│   ├── frontend/             # Aplicacion React + TypeScript + Tailwind
│   └── backend/              # API Node.js + Express + SQLite
├── docs/                     # Documentacion de arquitectura y API
├── requerimientos/
│   ├── plantilla-descripcion-general.md
│   └── casos de uso/
│       └── plantilla-descripcion-casos-de-uso.md
├── tests/                    # Tests (frontend y backend)
├── scripts/                  # Scripts auxiliares
├── CLAUDE.md                 # Instrucciones maestras para Claude
└── configuracion.md         # Este archivo
```

---

## Agentes (.claude/agents/)

Cada agente tiene un rol especifico dentro del flujo de desarrollo:

| Agente | Archivo | Responsabilidad |
|--------|---------|----------------|
| Requerimientos | `requirements-agent.md` | Analiza documentos del cliente, extrae funcionalidades/reglas de negocio, genera casos de uso Gherkin y especificaciones tecnicas |
| Arquitecto | `architect-agent.md` | Disea la arquitectura de componentes, define la API REST (openapi.yaml), documenta decisiones |
| Base de Datos | `database-architect.md` | Disea el esquema SQLite, genera migraciones SQL, define relaciones e indices |
| Backend Dev | `backend-dev.md` | Implementa endpoints Express, modelos, rutas, logica de negocio y tests |
| Frontend Dev | `frontend-dev.md` | Implementa componentes React, consume APIs, paginas, flujos y tests |

---

## Reglas de Contexto (.claude/rules/)

Las reglas se activan automaticamente cuando Claude trabaja en cada dominio:

| Regla | Archivo | Dominio |
|-------|---------|---------|
| Frontend Patterns | `frontend-patterns.md` | React, TypeScript, Tailwind, convenciones de componentes |
| Backend Patterns | `backend-patterns.md` | Express, SQLite, handlers, servicios, validaciones |
| Database Patterns | `database-patterns.md` | Migraciones, convenciones SQL, auditoria, soft delete |

---

## Configuracion de Claude Code (.claude/settings.json)

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Habilita el modo de **agentes en paralelo**, permitiendo que multiples agentes trabajen simultaneamente en tareas independientes.

---

## Plantillas de Requerimientos

### Descripcion General (`requerimientos/plantilla-descripcion-general.md`)

Template para documentar:
- Objetivo del sistema (problema, solucion, valor)
- Alcance del MVP (que incluye y que no)
- Usuarios del sistema
- Funcionalidades principales por modulo
- Reglas de negocio
- Requisitos de datos (entidades)
- Stack tecnologico
- Requisitos no funcionales

### Casos de Uso (`requerimientos/casos de uso/plantilla-descripcion-casos-de-uso.md`)

Template para cada caso de uso:
- Actor y precondicion
- Flujo principal paso a paso
- Flujos alternativos (errores y excepciones)
- Postcondicion

---

## Flujo de Trabajo Multi-Agente

El proceso de creacion sigue este orden estricto:

1. **Requerimientos** — Procesar documentos del cliente en `requerimientos/` y generar casos de uso + especificaciones en `docs/`
2. **Arquitectura + Base de Datos** — Diseñar DB, componentes y API basandose en las especificaciones
3. **Backend Dev** — Implementar modelos, endpoints y logica de negocio en `src/backend/`
4. **Frontend Dev** — Implementar UI consumiendo las APIs en `src/frontend/`

---

## Convenciones Generales

- **ES Modules** (`import`/`export`), prohibido CommonJS (`require`)
- **TypeScript** estricto, sin `any`
- **Indentacion** de 2 espacios
- **Git**: Ramas con prefijo semantico (`feature/`, `fix/`), commits convencionales
- **Tests**: Ejecutar `npm test` tras cada funcionalidad, `typecheck` tras bloques de trabajo

---

## Lo que NO genera el script

Los siguientes archivos quedan a cargo del programador:

- `package.json` — Dependencias y scripts del proyecto
- `tsconfig.json` — Configuracion de TypeScript
- `.env` / `.env.example` — Variables de entorno
- `README.md` — Documentacion del proyecto
- Carpeta `db/` — Se crea cuando el agente de base de datos genera las migraciones
EOF

# ============================================================================
# Output tipo arbol + pasos recomendados
# ============================================================================
echo ""
echo "  $PROJECT_NAME/"
echo "  ├── .claude/"
echo "  │   ├── agents/"
echo "  │   │   ├── requirements-agent.md"
echo "  │   │   ├── architect-agent.md"
echo "  │   │   ├── database-architect.md"
echo "  │   │   ├── backend-dev.md"
echo "  │   │   └── frontend-dev.md"
echo "  │   ├── rules/"
echo "  │   │   ├── frontend-patterns.md"
echo "  │   │   ├── backend-patterns.md"
echo "  │   │   └── database-patterns.md"
echo "  │   ├── skills/"
echo "  │   ├── hooks/"
echo "  │   └── settings.json"
echo "  ├── src/"
echo "  │   ├── frontend/"
echo "  │   └── backend/"
echo "  ├── docs/"
echo "  ├── requerimientos/"
echo "  │   ├── plantilla-descripcion-general.md"
echo "  │   └── casos de uso/"
echo "  │       └── plantilla-descripcion-casos-de-uso.md"
echo "  ├── tests/"
echo "  ├── scripts/"
echo "  ├── CLAUDE.md"
echo "  └── configuracion.md"
echo ""
echo "=== Setup completado ==="
echo ""
echo "Agentes en paralelo: HABILITADO (CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1)"
echo ""
echo "Siguientes pasos recomendados:"
echo ""
echo "  1. Entrar al proyecto:"
echo "     cd $PROJECT_NAME"
echo ""
echo "  2. Inicializar repositorio:"
echo "     git init && git add . && git commit -m 'chore: initial scaffold'"
echo ""
echo "  3. Abrir en tu editor:"
echo "     code .  (VS Code / Cursor / Antigravity)"
echo ""
echo "  4. Definir stack:"
echo "     - Frontend (React, Angular, etc.)"
echo "     - Backend (Node, Spring, etc.)"
echo ""
echo "  5. Empezar por:"
echo "     - README.md (objetivo del proyecto)"
echo "     - CLAUDE.md (contexto para IA)"
echo ""