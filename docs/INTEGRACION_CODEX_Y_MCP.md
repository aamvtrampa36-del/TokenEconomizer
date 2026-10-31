# Instalar TokenEconomizer: Codex y otros clientes

Este repositorio conserva los adaptadores Python originales de Microsoft TokenEconomizer. Su instalación local y el MCP remoto son **modos independientes**.

## Opción A: hooks reales en Codex (CLI / entorno que permita plugins y scripts)

Requisitos: Codex instalado y conectado, Git, Python 3.10+, acceso a una terminal y permiso para ejecutar hooks.

En Windows (PowerShell), desde la carpeta donde quieras guardar TokenEconomizer:

```powershell
git clone https://github.com/aamvtrampa36-del/TokenEconomizer.git
codex plugin marketplace add "$((Resolve-Path .\TokenEconomizer).Path)"
codex plugin add tokeneconomizer@tokeneconomizer
codex
```

Al abrir Codex, acepta la confianza del directorio y revisa/autoriza los hooks si te los presenta. Cierra y abre **otra sesión**: los hooks de inicio no se ejecutan retroactivamente.

En la conversación de Codex escribe exactamente:

```text
$tokeneconomizer:status
```

También existen `$tokeneconomizer:microskills`, `$tokeneconomizer:toolprune` y `$tokeneconomizer:config`. La configuración incorpora los eventos `SessionStart`, `UserPromptSubmit`, `PostToolUse`, `Stop` y `SessionEnd` en `plugin/hooks/codex-hooks.json`. Codex exige confiar en los hooks: usa `/hooks` para revisarlos.

**No necesitas una nueva API key para instalar estos hooks locales.** Se usa la sesión que Codex ya tiene.

Para actualizar: `git pull` en el clon y `codex plugin add tokeneconomizer@tokeneconomizer` de nuevo.

### Codex en la nube

La instalación debe realizarse en un **entorno de Codex Cloud que ejecute scripts**, con el repositorio disponible y Python instalado. Ve a Settings > Codex Cloud > Environments y configura/publica un entorno que incluya los archivos del plugin. Instalar un plugin en la web **no descarga automáticamente los scripts al entorno**. Revisa los hooks que requieran aprobación; inicia una tarea nueva después de publicar el entorno. No hay garantía de que el mismo procedimiento de PowerShell se ejecute dentro del contenedor cloud.

La versión y el soporte real dependen del entorno. No afirmes que los hooks funcionan en Codex Cloud sin ver su estado y eventos en una ejecución real.

## Opción B: MCP remoto Cloudflare (independiente de Codex)

Servidor MCP actualmente desplegado (se conserva su nombre operativo):

```text
https://tokeneconomizer-lab.cdf-cloud-mvp-20261019.workers.dev/mcp
```

El servidor protege operaciones con OAuth o credencial de servicio. No compartas los secretos internos `TE_OAUTH_SIGNING_KEY` ni `TE_SERVICE_TOKEN`, ni los pongas en GitHub. La conexión OAuth actual fue creada para ChatGPT; **no se ha verificado el inicio de sesión OAuth con todos los clientes MCP**, por lo que no prometas compatibilidad de autenticación universal sin pruebas.

Para Codex CLI o un cliente MCP compatible con Bearer, necesitarías una **credencial de servicio de uso específico** y configurarla como secreto local del cliente; no uses una contraseña de administrador ni la clave de firma. El repositorio público **no contiene credenciales**.

El Worker de Cloudflare conserva su propio backend Python + Durable Object. Puede funcionar aun sin Codex, y se integra por su cuenta con CDF CLOUD. Los eventos que CDF CLOUD envía son telemetría mínima, **no hooks de sesión de un agente**. Las microhabilidades y el pruning no se aplican automáticamente a ChatGPT solo por agregar el MCP.

## Otros clientes sin Codex

Desde un clon del mismo repositorio:

```bash
claude plugin marketplace add /ruta/absoluta/TokenEconomizer
claude plugin install tokeneconomizer@tokeneconomizer
```

Para GitHub Copilot CLI:

```bash
copilot plugin marketplace add /ruta/absoluta/TokenEconomizer
copilot plugin install tokeneconomizer@tokeneconomizer
```

Para Pi: `pi install git:github.com/aamvtrampa36-del/TokenEconomizer`. Para opencode, consulta `plugin/README.md` (soporte experimental).

Los hooks de cada agente requieren el proceso del agente y se ejecutan **localmente**. El MCP remoto es un servicio independiente y no depende de esos hooks.

## Seguridad y atribución

El proyecto original está bajo licencia Apache-2.0, conserva el `LICENSE` y los autores originales. Nunca publiques claves reales o historiales de conversaciones en este repositorio. Antes de activar poda automática, verifica que restaure herramientas necesarias. No atribuyas ahorro de tokens a la instalación por sí sola: mídelo.
