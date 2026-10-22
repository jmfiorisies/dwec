#!/usr/bin/env bash
# ============================================================================
#  DWEC · Examen Parcial 1 · Modelo B
#  Crea la carpeta ~/examen1 con el proyecto del examen (Vite) y levanta sus
#  contenedores Docker. No hay que instalar nada: Node y Vite van dentro de Docker.
#  (No borra ni modifica nada más del ordenador.)
#
#  Uso:   bash crear-examen-B.sh
# ============================================================================
set -uo pipefail
DESTINO="$HOME/examen1"
IMAGEN="dwec-examen1:vite-8.3.3"

command -v docker >/dev/null || { echo "✖ No está Docker en este ordenador. Llama al profesor."; exit 1; }
docker compose version >/dev/null 2>&1 || { echo "✖ Falta 'docker compose'. Llama al profesor."; exit 1; }
docker info >/dev/null 2>&1 || { echo "✖ Docker no responde (¿está arrancado? ¿tu usuario está en el grupo docker?). Llama al profesor."; exit 1; }
[ -e "$DESTINO" ] && { echo "✖ Ya existe $DESTINO. Llama al profesor."; exit 1; }

# Nada más de Docker en marcha: se paran (no se borran) todos los contenedores que haya levantados
# (la práctica, ejercicios…), así el examen va solo y el puerto 6001 queda libre.
# Solo para el profesor, para probarlo en su equipo sin parar sus contenedores:
#   DEBUG=1 bash crear-examen-B.sh
PUERTO=6001
if [ "${DEBUG:-0}" = "1" ]; then
  echo "[DEBUG] No se para ningún contenedor."
else
  EN_MARCHA=$(docker ps -q)
  if [ -n "$EN_MARCHA" ]; then
    echo "Parando los contenedores Docker que hay en marcha:"
    docker ps --format '  - {{.Names}}'
    docker stop $EN_MARCHA >/dev/null || { echo "✖ No se han podido parar los contenedores. Llama al profesor."; exit 1; }
  fi
  [ -z "$(docker ps -q)" ] || { echo "✖ Sigue habiendo contenedores en marcha. Llama al profesor."; exit 1; }
fi
puerto_libre() { ! (exec 3<>"/dev/tcp/127.0.0.1/$1") 2>/dev/null; }
puerto_libre "$PUERTO" || { echo "✖ El puerto $PUERTO está ocupado por otro programa. Llama al profesor."; exit 1; }

mkdir -p "$DESTINO"
mkdir -p "$DESTINO/.vscode"
cat > "$DESTINO/LEEME.md" <<'FIN_LEEME_MD'
# Examen Parcial 1 · DWEC · Modelo B · Parte B

**65 minutos · 10 puntos · 7 funciones en `examen.js`** · Sin internet, sin IA y sin apuntes.

## 1 · Abrir el examen

**1.** En la web del módulo, **jmfiorisies.github.io/dwec** → UD 3 → «Examen Parcial 1 · Parte B», descarga **`crear-examen-B.sh`**.

**2.** Abre una terminal (**Ctrl+Alt+T**) y escribe:

```bash
cd ~/Descargas
bash crear-examen-B.sh
```

**3.** Se abren solas dos ventanas: **VS Code** con la carpeta `examen1` y la **página del examen** (`http://localhost:6001`). Si falta alguna o sale un ✖, llama al profesor.

**4.** **Desactiva internet** (wifi y cable) delante del profesor.

## 2 · Hacer el examen

- Escribe tu nombre en la línea `Alumno/a:` de `examen.js` y completa las 7 funciones. Cada enunciado está encima de su función (y en esta hoja). Son independientes: si te atascas, pasa a la siguiente.
- Guarda con **Ctrl+S**. Una función a medias también puntúa.
- Para probar, escribe en `pruebas.js` y mira la consola del navegador (**F12**). Ese fichero no se corrige.

## 3 · Cerrar y entregar

**1.** Guarda y escribe en la terminal:

```bash
bash ~/examen1/examen.sh entregar
```

**2.** Escribe tu nombre y primer apellido. Sale un **código de entrega**: **apúntalo en tu hoja**, junto a tu nombre.

**3.** Avisa al profesor. Cuando active internet, envía por correo a **jcorfio941@g.educaand.es** el fichero `examen1-B-….tar.gz` que está en el **Escritorio** (adjunto, asunto «Examen DWEC P1 · tu nombre»). No vuelvas a empaquetar.

## 🆘 Si algo falla

| Problema | Qué hacer |
|---|---|
| Has cerrado VS Code | `bash ~/examen1/examen.sh code` |
| Has cerrado la página | `bash ~/examen1/examen.sh web` |
| La página no carga | `bash ~/examen1/examen.sh arrancar` |
| La página dice «No se puede cargar tu código» | Error de sintaxis en `examen.js`: busca el subrayado rojo |
| Cualquier otro ✖ | Llama al profesor |

## ⛔ Normas

- Usa solo el VS Code del examen y solo la carpeta `~/examen1`. Nada de IA, apuntes ni código ajeno: **usar IA supone suspender**.
- Queda registrado en tu entrega: si cierras el VS Code del examen o abres otro, si pegas mucho código de golpe, si se activa internet, y una copia de `examen.js` cada minuto.
- No toques `datos.js`, `main.js`, `index.html`, `estilos.css`, `Dockerfile`, `docker-compose.yml`, `.vscode/` ni el registro (`registro.sh`, `.registro/`).
FIN_LEEME_MD
cat > "$DESTINO/datos.js" <<'FIN_DATOS_JS'
// Librería «Marcapáginas» · Datos del examen (NO modificar este fichero)
//
// Cada libro: { id, titulo, genero, precio, stock, edadMinima? }
//   - genero: "novela" | "comic" | "ensayo"
//   - precio: euros, tarifa "general"
//   - edadMinima: edad recomendada. Puede valer 0 (para todos los públicos)
//     o NO EXISTIR (el libro está sin clasificar).

export const libros = [
  { id: 1, titulo: "Dune", genero: "novela", precio: 22, stock: 4, edadMinima: 14 },
  { id: 2, titulo: "Astérix en Hispania", genero: "comic", precio: 12.5, stock: 1, edadMinima: 0 },
  { id: 3, titulo: "Sapiens", genero: "ensayo", precio: 24, stock: 2 },
  { id: 4, titulo: "El Principito", genero: "novela", precio: 9, stock: 10, edadMinima: 0 },
  { id: 5, titulo: "Maus", genero: "comic", precio: 30, stock: 0, edadMinima: 14 },
  { id: 6, titulo: "Cosmos", genero: "ensayo", precio: 18.5, stock: 3, edadMinima: 12 },
  { id: 7, titulo: "Mortadelo y Filemón", genero: "comic", precio: 7.5, stock: 6 },
  { id: 8, titulo: "La sombra del viento", genero: "novela", precio: 11, stock: 2, edadMinima: 16 },
];
FIN_DATOS_JS
cat > "$DESTINO/examen.js" <<'FIN_EXAMEN_JS'
// ============================================================================
//  DWEC · Examen Parcial 1 · Modelo B · Parte B (práctica)
//  Alumno/a: ____________________________________________
// ============================================================================
//
//  Normas:
//    - Completa SOLO las funciones de este fichero. No cambies sus nombres ni
//      sus parámetros, y no quites los `export`.
//    - Nada de `var` ni de `==` / `!=`.
//    - No modifiques nunca el array ni los objetos que recibes (inmutabilidad).
//    - Para probar tus funciones, usa pruebas.js (resultado en la consola del
//      navegador, F12). La nota sale de LEER tu código: una función a medias
//      también puntúa.
//    - Puedes crear funciones auxiliares si las necesitas.
//
//  Redondeo: cuando se pida redondear a 2 decimales, usa la función
//  `redondear` que ya tienes hecha.
// ============================================================================

export const redondear = (n) => Math.round(n * 100) / 100;

// ----------------------------------------------------------------------------
// Ejercicio 1 (1 punto) · filter + map
// Devuelve un array con los TÍTULOS de los libros que están en "últimas
// unidades": stock 1 o 2 (los que tienen stock 0 NO cuentan).
//   ultimasUnidades(libros) → ["Astérix en Hispania", "Sapiens", "La sombra del viento"]
// ----------------------------------------------------------------------------
export const ultimasUnidades = (lista) => {
  // TU CÓDIGO AQUÍ
};

// ----------------------------------------------------------------------------
// Ejercicio 2 (1 punto) · switch o ternario + parámetro por defecto
// Devuelve el precio según la tarifa, redondeado a 2 decimales:
//   "socio" → −15 %   ·   "general" → igual   ·   "regalo" → +2 € (envoltorio)
//   Si no se indica tarifa, se entiende "general".
//   Cualquier otra tarifa → null.
//   precioTarifa(20, "socio") → 17     precioTarifa(20) → 20
// Escríbela como FUNCIÓN DECLARADA (con la palabra `function`).
// ----------------------------------------------------------------------------
export function precioTarifa(precio, tarifa) {
  // TU CÓDIGO AQUÍ (añade el valor por defecto que corresponda)
}

// ----------------------------------------------------------------------------
// Ejercicio 3 (1,5 puntos) · find + ?. + ??
// Busca el libro por id y devuelve un texto:
//   "Dune · edad mínima: 14 años"
//   "El Principito · edad mínima: 0 años"    ← 0 es un dato válido
//   "Sapiens · edad mínima: sin clasificar"  ← la propiedad no existe
//   "No existe el libro 99"                  ← id que no está en la lista
// ----------------------------------------------------------------------------
export const fichaEdad = (lista, id) => {
  // TU CÓDIGO AQUÍ
};

// ----------------------------------------------------------------------------
// Ejercicio 4 (1,5 puntos) · reduce
// Devuelve el precio MEDIO de los libros de la lista, redondeado a
// 2 decimales. Con una lista vacía devuelve 0 (¡no NaN!).
// Escríbela como EXPRESIÓN DE FUNCIÓN: const precioMedio = function (...) {...}
// ----------------------------------------------------------------------------
export const precioMedio = function (lista) {
  // TU CÓDIGO AQUÍ
};

// ----------------------------------------------------------------------------
// Ejercicio 5 (1,5 puntos) · inmutabilidad (map + spread)
// Sube `euros` (por defecto 1) el precio de TODOS los libros del `genero`
// indicado. Devuelve un ARRAY NUEVO igual que `lista`, con esos precios
// subidos y redondeados a 2 decimales. Los demás libros quedan igual.
//   subirPrecio(libros, "comic", 2.5) → Astérix 15, Maus 32.5, Mortadelo 10
//   subirPrecio(libros, "ensayo")     → Sapiens 25, Cosmos 19.5
// La lista original NO puede cambiar (ni el array ni sus objetos).
// ----------------------------------------------------------------------------
export const subirPrecio = (lista, genero, euros) => {
  // TU CÓDIGO AQUÍ (añade el valor por defecto que corresponda)
};

// ----------------------------------------------------------------------------
// Ejercicio 6 (2 puntos) · closure + parámetro rest
// crearPrestamos() devuelve un objeto con tres funciones que comparten una
// lista de préstamos PRIVADA (no accesible desde fuera):
//   - prestar(socio, ...titulos): presta a ese socio todos los títulos
//     recibidos (cualquier cantidad) y devuelve cuántos libros tiene ahora
//     ese socio en total.
//   - deSocio(socio): devuelve un ARRAY NUEVO con los títulos prestados a ese
//     socio, en orden ([] si no tiene ninguno).
//   - prestados(): número total de libros prestados (de todos los socios).
// Ejemplo:
//   const p = crearPrestamos();
//   p.prestar("Ana", "Dune", "Maus")   → 2
//   p.prestar("Leo", "Cosmos")         → 1
//   p.prestar("Ana", "Sapiens")        → 3
//   p.deSocio("Ana")                   → ["Dune", "Maus", "Sapiens"]
//   p.deSocio("Eva")                   → []
//   p.prestados()                      → 4
// ----------------------------------------------------------------------------
export const crearPrestamos = () => {
  // TU CÓDIGO AQUÍ
};

// ----------------------------------------------------------------------------
// Ejercicio 7 (1,5 puntos) · funciones de alto orden
// a) transformarCon(lista, transformacion): devuelve un array nuevo con el
//    resultado de aplicar transformacion(elemento) a cada elemento.
//    PROHIBIDO usar .map(): hazlo con un bucle (for...of) y spread.
// b) conDescuento(porcentaje): devuelve una FUNCIÓN que recibe un libro y
//    devuelve su precio rebajado ese porcentaje (redondeado a 2 decimales).
// Uso:
//   transformarCon(libros, conDescuento(10)).slice(0, 3)
//   → [19.8, 11.25, 21.6]
// ----------------------------------------------------------------------------
export const transformarCon = (lista, transformacion) => {
  // TU CÓDIGO AQUÍ
};

export const conDescuento = (porcentaje) => {
  // TU CÓDIGO AQUÍ
};
FIN_EXAMEN_JS
cat > "$DESTINO/package.json" <<'FIN_PACKAGE_JSON'
{
  "name": "examen1-dwec",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite"
  },
  "devDependencies": {
    "vite": "8.3.3"
  }
}
FIN_PACKAGE_JSON
cat > "$DESTINO/pruebas.js" <<'FIN_PRUEBAS_JS'
// Zona de pruebas (NO se corrige). Lo que escribas aquí se ejecuta en el navegador cada vez
// que guardas. Mira el resultado en la consola del navegador: F12 → Consola.
import * as ex from "./examen.js";
import { libros } from "./datos.js";

// Quita las // para probar:
// console.table(libros);
// console.log(ex.ultimasUnidades(libros));
// console.log(ex.precioTarifa(20, "socio"));
FIN_PRUEBAS_JS
cat > "$DESTINO/Dockerfile" <<'FIN_DOCKERFILE'
# DWEC · Examen 1 · Imagen del entorno: Node 22 + Vite ya instalado.
# Así el alumnado no tiene que hacer `npm install` ni descargar nada durante el examen.
FROM node:22-alpine
WORKDIR /opt/vite
RUN npm install --no-audit --no-fund --loglevel=error vite@8.3.3 \
 && npm cache clean --force
ENV PATH=/opt/vite/node_modules/.bin:$PATH
WORKDIR /examen
FIN_DOCKERFILE
cat > "$DESTINO/docker-compose.yml" <<'FIN_DOCKER_COMPOSE_YML'
# DWEC · Examen 1 · Modelo B · Entorno Docker (no hay que instalar nada)
# - web:   Vite en http://localhost:6001 → la página del examen, que se recarga al guardar.
# Puerto fijo 6001 (solo en localhost). crear-examen para antes cualquier otro contenedor en marcha.
name: examen1-dwec

x-comun: &comun
  image: dwec-examen1:vite-8.3.3
  build: .
  working_dir: /examen
  user: "${UID_EXAMEN:-1000}:${GID_EXAMEN:-1000}"
  volumes:
    - .:/examen
  environment:
    TZ: "CET-1CEST,M3.5.0,M10.5.0/3"   # hora de España (la imagen no trae tzdata)
  init: true
  restart: unless-stopped

services:
  web:
    <<: *comun
    ports:
      - "127.0.0.1:6001:5173"
    command: ["vite", "--host", "0.0.0.0", "--port", "5173", "--strictPort", "--clearScreen", "false"]
FIN_DOCKER_COMPOSE_YML
cat > "$DESTINO/entregar.sh" <<'FIN_ENTREGAR_SH'
#!/usr/bin/env bash
# DWEC · Examen 1 · Modelo B · Entrega: empaqueta ~/examen1 para enviarlo por correo al profesor.
# Se ejecuta SIN internet; después el profesor activa la red para subir el fichero.
set -uo pipefail
CARPETA="$HOME/examen1"
[ -f "$CARPETA/examen.js" ] || { echo "No encuentro $CARPETA/examen.js"; exit 1; }

read -r -p "Tu nombre y primer apellido: " nombre
nombre=$(printf '%s' "$nombre" | iconv -f utf-8 -t ascii//TRANSLIT 2>/dev/null | tr -cs 'A-Za-z0-9' '-' | sed 's/^-//;s/-$//' | tr 'A-Z' 'a-z')
[ -n "$nombre" ] || { echo "Nombre vacío."; exit 1; }

cd "$CARPETA" || exit 1
# Constancia de la entrega (la red debería estar desactivada al empaquetar)
if timeout 3 bash -c '</dev/tcp/1.1.1.1/443' 2>/dev/null; then red="SÍ (¡debería estar desactivada!)"; else red="no"; fi
{
  echo "Modelo:        B"
  echo "Alumno/a:      $nombre"
  echo "Empaquetado:   $(date '+%d/%m/%Y %H:%M:%S')"
  echo "Internet:      $red"
  echo "Equipo:        $(hostname)"
  echo
  echo "Registro (.registro/registro.txt):"
  if [ -f .registro/registro.txt ]; then
    echo "  VS Code del examen cerrado:  $(grep -c 'VS Code del examen: CERRADO' .registro/registro.txt) veces"
    echo "  Otro VS Code abierto:        $(grep -c 'otro VS Code' .registro/registro.txt) veces"
    echo "  Código de golpe (pegado):    $(grep -c 'Código de golpe' .registro/registro.txt) veces"
    echo "  Registro parado y reanudado: $(grep -c 'Registro reanudado' .registro/registro.txt) veces"
    echo "  Internet activado durante:   $(grep -c 'Internet: ACTIVADO' .registro/registro.txt) veces"
    echo "  Copias de examen.js:         $(ls .registro/copias 2>/dev/null | wc -l)"
  else
    echo "  ⚠️  NO HAY REGISTRO"
  fi
} > entrega.txt

SALIDA_DIR="$HOME/Escritorio"
[ -d "$SALIDA_DIR" ] || SALIDA_DIR="$HOME/Desktop"
[ -d "$SALIDA_DIR" ] || SALIDA_DIR="$HOME"
SALIDA="$SALIDA_DIR/examen1-B-$nombre-$(date +%H%M).tar.gz"
tar -C "$HOME" --exclude=node_modules -czf "$SALIDA" examen1 || { echo "Error al empaquetar."; exit 1; }

# Código de entrega: huella del .tar.gz. Lo apuntan en la hoja; si lo enviado por correo no da el
# mismo código, no es lo que se empaquetó en clase. El profesor lo comprueba con:
#   sha256sum examen1-*.tar.gz | cut -c1-6 | tr a-f A-F
codigo=$(sha256sum "$SALIDA" | cut -c1-6 | tr 'a-f' 'A-F')
echo "$(date '+%d/%m/%Y %H:%M:%S')  Entrega $(basename "$SALIDA") · código $codigo" >> .registro/registro.txt 2>/dev/null

echo
echo "✔ Entrega creada: $SALIDA"
echo
echo "  ╔══════════════════════════════════╗"
echo "  ║   CÓDIGO DE ENTREGA:   $codigo    ║"
echo "  ╚══════════════════════════════════╝"
echo
echo "  1. Apunta el código en tu hoja, junto a tu nombre."
echo "  2. Avisa al profesor: él activará internet."
echo "  3. Envía ESTE fichero por correo (adjunto) a jcorfio941@g.educaand.es"
echo "  4. No cambies nada más ni vuelvas a empaquetar: lo que se corrige es este .tar.gz."
echo "     (Si tienes que repetir la entrega, avisa al profesor: cambia el código.)"
FIN_ENTREGAR_SH
cat > "$DESTINO/estilos.css" <<'FIN_ESTILOS_CSS'
:root {
  --rojo: #ea4335;
  --fondo: #f6f7f9;
  --tarjeta: #ffffff;
  --texto: #202124;
  --suave: #5f6368;
  --borde: #dadce0;
  --ok: #188038;
  --mal: #c5221f;
  --codigo: #f1f3f4;
  color-scheme: light dark;
}
@media (prefers-color-scheme: dark) {
  :root {
    --fondo: #17181a;
    --tarjeta: #222326;
    --texto: #e8eaed;
    --suave: #9aa0a6;
    --borde: #3c4043;
    --ok: #81c995;
    --mal: #f28b82;
    --codigo: #2d2e31;
  }
}
* { box-sizing: border-box; }
body {
  margin: 0;
  background: var(--fondo);
  color: var(--texto);
  font: 15px/1.5 system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
}
#app { max-width: 860px; margin: 0 auto; padding: 0 16px 48px; }
header {
  display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 12px;
  padding: 20px 0 14px; border-bottom: 3px solid var(--rojo); margin-bottom: 16px;
}
h1 { margin: 0; font-size: 1.35rem; color: var(--rojo); }
.marcador { min-width: 220px; color: var(--suave); }
.marcador strong { color: var(--texto); font-size: 1.2rem; }
.barra { height: 8px; background: var(--borde); border-radius: 4px; overflow: hidden; margin-top: 4px; }
.barra span { display: block; height: 100%; background: var(--ok); transition: width 0.3s; }
.ayuda { color: var(--suave); font-size: 0.9rem; margin-bottom: 16px; }
.ayuda p { margin: 4px 0; }
code, pre, kbd { font-family: ui-monospace, Consolas, monospace; font-size: 0.88em; }
code, kbd { background: var(--codigo); padding: 1px 5px; border-radius: 4px; }
.ejercicio { background: var(--tarjeta); border: 1px solid var(--borde); border-left: 4px solid var(--mal); border-radius: 8px; margin-bottom: 10px; }
.ejercicio.completo { border-left-color: var(--ok); }
summary { display: flex; justify-content: space-between; padding: 10px 14px; cursor: pointer; font-weight: 600; }
.cuenta { color: var(--suave); font-weight: 400; }
ul { list-style: none; margin: 0; padding: 0 14px 10px; }
li { padding: 4px 0; border-top: 1px solid var(--borde); }
li.fallo, li.error { color: var(--mal); }
.detalle { color: var(--texto); font-size: 0.88rem; margin: 2px 0 4px 26px; overflow-wrap: anywhere; }
.fallo-carga { background: var(--tarjeta); border: 1px solid var(--mal); border-radius: 8px; padding: 4px 16px 12px; }
.fallo-carga h2 { color: var(--mal); font-size: 1.1rem; }
pre { background: var(--codigo); padding: 10px; border-radius: 6px; white-space: pre-wrap; }
.aviso { color: var(--mal); }
FIN_ESTILOS_CSS
cat > "$DESTINO/examen.sh" <<'FIN_EXAMEN_SH'
#!/usr/bin/env bash
# DWEC · Examen 1 · Modelo B · Órdenes del examen (todo se ejecuta en Docker)
cd "$(dirname "$0")" || exit 1
URL="http://localhost:6001"
PERFIL="$HOME/.examen1-vscode"   # VS Code del examen: perfil propio, sin extensiones ni IA
# Registro del examen en segundo plano (si ya está en marcha, no se arranca otro)
registro() { (setsid nohup bash ./registro.sh >/dev/null 2>&1 &); }

case "${1:-}" in
  code)     registro
            command -v code >/dev/null || { echo "No encuentro VS Code (orden 'code'). Llama al profesor."; exit 1; }
            mkdir -p "$PERFIL/datos/User" "$PERFIL/extensiones" .vscode
            # Restaura los ajustes del examen por si se han tocado
            [ -f "$PERFIL/ajustes-examen.json" ] && cp "$PERFIL/ajustes-examen.json" .vscode/settings.json
            cp .vscode/settings.json "$PERFIL/datos/User/settings.json"
            # Extensiones: las instaladas, fuera (carpeta vacía + --disable-extensions). Las que trae
            # VS Code de serie (incluido Copilot Chat) también, salvo las mínimas para editar JS.
            PERMITIDAS=" vscode.theme-defaults vscode.vscode-theme-seti vscode.javascript vscode.typescript vscode.json vscode.html vscode.css vscode.markdown vscode.typescript-language-features "
            BIN=$(readlink -f "$(command -v code)")
            DIR_EXT=""
            for d in "$(dirname "$BIN")/../resources/app/extensions" /usr/share/code/resources/app/extensions \
                     /snap/code/current/usr/share/code/resources/app/extensions; do
              [ -d "$d" ] && { DIR_EXT=$d; break; }
            done
            QUITAR=(--disable-extension GitHub.copilot-chat --disable-extension TypeScriptTeam.jsts-chat-features)
            if [ -n "$DIR_EXT" ]; then
              for f in "$DIR_EXT"/*/package.json; do
                pub=$(grep -o '"publisher" *: *"[^"]*"' "$f" | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
                nom=$(grep -o '"name" *: *"[^"]*"' "$f" | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
                [ -n "$pub" ] && [ -n "$nom" ] || continue
                case "$PERMITIDAS" in *" $pub.$nom "*) ;; *) QUITAR+=(--disable-extension "$pub.$nom") ;; esac
              done
            else
              echo "⚠️  No encuentro las extensiones de serie de VS Code: solo se desactivan las de IA conocidas."
            fi
            (code --user-data-dir "$PERFIL/datos" --extensions-dir "$PERFIL/extensiones" \
                  --disable-extensions "${QUITAR[@]}" --new-window "$PWD" >/dev/null 2>&1 &)
            echo "VS Code del examen abierto: sin extensiones ni IA ($(( ${#QUITAR[@]} / 2 )) de serie desactivadas)." ;;
  web)      registro
            docker compose up -d >/dev/null 2>&1
            echo "Página del examen: $URL"
            command -v xdg-open >/dev/null && (xdg-open "$URL" >/dev/null 2>&1 &) ;;
  arrancar) registro; docker compose up -d && echo "Página del examen: $URL" ;;
  parar)    docker compose down ;;
  entregar) bash ./entregar.sh ;;
  *)
    echo "Uso: bash ~/examen1/examen.sh <orden>"
    echo "  code      abre el VS Code del examen (sin extensiones ni IA)"
    echo "  web       abre la página del examen ($URL)"
    echo "  arrancar  levanta los contenedores si se han parado"
    echo "  parar     para los contenedores"
    echo "  entregar  empaqueta el examen para enviarlo por correo"
    ;;
esac
FIN_EXAMEN_SH
cat > "$DESTINO/index.html" <<'FIN_INDEX_HTML'
<!doctype html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Examen 1 · DWEC · Modelo B</title>
  </head>
  <body>
    <div id="app"></div>
    <script type="module" src="/main.js"></script>
  </body>
</html>
FIN_INDEX_HTML
cat > "$DESTINO/main.js" <<'FIN_MAIN_JS'
// Página del examen: carga tus funciones y los datos para que puedas probarlos en la consola
// del navegador (F12) y ejecuta pruebas.js. Se recarga sola cada vez que guardas un fichero.
// (No hace falta tocar este fichero.)
import "./estilos.css";

const app = document.querySelector("#app");
const escapar = (t) => String(t).replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]);

const cabecera = `
  <header>
    <h1>Examen 1 · DWEC · Modelo B</h1>
  </header>`;

try {
  const datos = await import("./datos.js");
  const ex = await import("./examen.js");
  Object.assign(window, datos, { ex });
  const funciones = Object.keys(ex).filter((k) => typeof ex[k] === "function");
  app.innerHTML = `
    ${cabecera}
    <section class="ayuda">
      <p>Tu código se ha cargado. Para probar tus funciones, escribe en <code>pruebas.js</code> y mira el
        resultado en la consola del navegador (<kbd>F12</kbd> → Consola).</p>
      <p>En la consola también tienes <code>${Object.keys(datos)[0]}</code> y tus funciones en <code>ex</code>
        (${funciones.map((f) => `<code>ex.${f}</code>`).join(", ")}).</p>
      <p>La nota sale de leer tu código: una función a medias también puntúa.</p>
    </section>
    <div id="aviso-pruebas"></div>`;
  console.log("%cExamen 1 · DWEC", "color:#ea4335;font-weight:bold", "→ datos y funciones disponibles:", Object.keys(datos), "ex =", ex);
} catch (error) {
  app.innerHTML = `
    ${cabecera}
    <section class="fallo-carga">
      <h2>💥 No se puede cargar tu código</h2>
      <p>Suele ser un <strong>error de sintaxis</strong> en <code>examen.js</code> (una llave, un paréntesis o una coma):
        VS Code lo subraya en rojo. Al arreglarlo, esta página se recarga sola.</p>
      <pre>${escapar(error.message)}</pre>
    </section>`;
  console.error(error);
}

try {
  await import("./pruebas.js");
} catch (error) {
  console.error("Error en pruebas.js:", error);
  const aviso = document.querySelector("#aviso-pruebas");
  if (aviso) aviso.innerHTML = `<p class="aviso">⚠️ <code>pruebas.js</code> tiene un error: <code>${escapar(error.message)}</code> (no afecta a la nota).</p>`;
}
FIN_MAIN_JS
cat > "$DESTINO/registro.sh" <<'FIN_REGISTRO_SH'
#!/usr/bin/env bash
# DWEC · Examen 1 · Modelo B · Registro del examen (NO lo borres ni lo pares).
# Lo arranca solo «examen.sh code» y va en segundo plano. Anota en ~/examen1/.registro/registro.txt:
#   - cuándo se abre y se cierra el VS Code del examen,
#   - si hay abierto otro VS Code (el habitual),
#   - si entra mucho código de golpe en examen.js o pruebas.js (pegado); lo que entra se guarda
#     en .registro/pegados/,
#   - una copia de examen.js cada minuto (si ha cambiado) en .registro/copias/,
#   - cuándo se activa y se desactiva internet.
# El registro va dentro de la entrega.
CARPETA="$HOME/examen1"
PERFIL="$HOME/.examen1-vscode"
REG="$CARPETA/.registro"
ESTADO="$PERFIL/registro"          # copias y latido: fuera de la carpeta, para no recargar la página
UMBRAL=300                         # caracteres nuevos en un intervalo que se consideran «pegado»
INTERVALO=2                        # segundos (VS Code guarda solo cada segundo)
FICHEROS="examen.js pruebas.js"
CADA_COPIA=60                      # segundos entre copias de examen.js
CADA_RED=30                        # segundos entre comprobaciones de internet

mkdir -p "$REG/pegados" "$REG/copias" "$ESTADO" || exit 1
exec 9>"$ESTADO/lock"
flock -n 9 || exit 0               # ya hay uno en marcha

apunta() { echo "$(date '+%d/%m/%Y %H:%M:%S')  $*" >> "$REG/registro.txt"; }

# Si el registro estuvo parado (reinicio, lo han matado…), se deja constancia del hueco
if [ -f "$ESTADO/latido" ]; then
  ultimo=$(cat "$ESTADO/latido")
  (( $(date +%s) - ultimo > 15 )) && apunta "⚠️  Registro reanudado: estuvo parado desde $(date -d "@$ultimo" '+%H:%M:%S')"
fi
apunta "Registro en marcha (equipo $(hostname), usuario $USER)"

# ¿Es un proceso del VS Code del examen? (él o algún padre lleva el perfil del examen)
del_examen() {
  local p=$1
  while [ -n "$p" ] && [ "$p" -gt 1 ]; do
    tr '\0' ' ' < "/proc/$p/cmdline" 2>/dev/null | grep -q -- "$PERFIL" && return 0
    p=$(awk '{print $4}' "/proc/$p/stat" 2>/dev/null)
  done
  return 1
}
vscode_examen=0; vscode_otro=0
for p in $(pgrep -x code); do
  if del_examen "$p"; then vscode_examen=1; else vscode_otro=1; fi
done
antes_examen=$vscode_examen; antes_otro=$vscode_otro
(( antes_examen )) && apunta "VS Code del examen: abierto"
(( antes_otro ))   && apunta "⚠️  Hay otro VS Code abierto (no es el del examen)"

for f in $FICHEROS; do [ -f "$CARPETA/$f" ] && cp "$CARPETA/$f" "$ESTADO/$f"; done

hay_red() { timeout 2 bash -c '</dev/tcp/1.1.1.1/443' 2>/dev/null || timeout 2 bash -c '</dev/tcp/8.8.8.8/53' 2>/dev/null; }
copia() {   # copia de examen.js con la hora, solo si ha cambiado desde la última
  [ -f "$CARPETA/examen.js" ] || return
  cmp -s "$CARPETA/examen.js" "$ESTADO/ultima-copia.js" 2>/dev/null && return
  cp "$CARPETA/examen.js" "$REG/copias/$(date +%H%M%S)-examen.js"
  cp "$CARPETA/examen.js" "$ESTADO/ultima-copia.js"
}
if hay_red; then red=1; apunta "Internet: activado"; else red=0; apunta "Internet: desactivado"; fi
copia; ultima_copia=$(date +%s); ultima_red=$(date +%s)

inicio=$(date +%s)
while [ -d "$CARPETA" ] && (( $(date +%s) - inicio < 5 * 3600 )); do
  date +%s > "$ESTADO/latido"

  vscode_examen=0; vscode_otro=0
  for p in $(pgrep -x code); do
    if del_examen "$p"; then vscode_examen=1; else vscode_otro=1; fi
  done
  if (( vscode_examen != antes_examen )); then
    (( vscode_examen )) && apunta "VS Code del examen: abierto" || apunta "⚠️  VS Code del examen: CERRADO"
  fi
  if (( vscode_otro != antes_otro )); then
    (( vscode_otro )) && apunta "⚠️  Se ha abierto otro VS Code (no es el del examen)" || apunta "Otro VS Code: cerrado"
  fi
  antes_examen=$vscode_examen; antes_otro=$vscode_otro

  for f in $FICHEROS; do
    [ -f "$CARPETA/$f" ] || continue
    [ -f "$ESTADO/$f" ] || { cp "$CARPETA/$f" "$ESTADO/$f"; continue; }
    cmp -s "$CARPETA/$f" "$ESTADO/$f" && continue
    nuevos=$(( $(wc -c < "$CARPETA/$f") - $(wc -c < "$ESTADO/$f") ))
    if (( nuevos >= UMBRAL )); then
      lineas=$(diff "$ESTADO/$f" "$CARPETA/$f" | grep -c '^>')
      prueba="pegados/$(date +%H%M%S)-$f.diff"
      diff -u "$ESTADO/$f" "$CARPETA/$f" > "$REG/$prueba"
      apunta "⚠️  Código de golpe en $f: +$nuevos caracteres (+$lineas líneas) en ${INTERVALO} s → .registro/$prueba"
    fi
    cp "$CARPETA/$f" "$ESTADO/$f"
  done
  ahora=$(date +%s)
  if (( ahora - ultima_copia >= CADA_COPIA )); then copia; ultima_copia=$ahora; fi
  if (( ahora - ultima_red >= CADA_RED )); then
    if hay_red; then ahora_red=1; else ahora_red=0; fi
    if (( ahora_red != red )); then
      (( ahora_red )) && apunta "⚠️  Internet: ACTIVADO" || apunta "Internet: desactivado"
    fi
    red=$ahora_red; ultima_red=$ahora
  fi
  sleep "$INTERVALO"
done
FIN_REGISTRO_SH
cat > "$DESTINO/.vscode/settings.json" <<'FIN_VSCODE_SETTINGS_JSON'
// DWEC · Examen 1 · Ajustes de VS Code para el examen (NO los cambies).
// Se aplican en el VS Code del examen (bash ~/examen1/examen.sh code), que además
// arranca sin extensiones. Se vuelven a escribir cada vez que se abre.
{
  // --- Sin IA: ni chat, ni agentes, ni sugerencias "fantasma" que rellenan código ---
  "chat.disableAIFeatures": true,
  "chat.agent.enabled": false,
  "chat.commandCenter.enabled": false,
  "workbench.settings.showAISearchToggle": false,
  "github.copilot.enable": { "*": false },
  "github.copilot.nextEditSuggestions.enabled": false,
  "geminicodeassist.enable": false,
  "editor.inlineSuggest.enabled": false,

  // --- Sin extensiones: no se puede instalar ninguna durante el examen ---
  "extensions.allowed": { "*": false },
  "extensions.autoUpdate": false,
  "extensions.autoCheckUpdates": false,
  "extensions.ignoreRecommendations": true,

  // --- Autocompletado clásico (IntelliSense, sin IA): nombres de variables y métodos ---
  // Para quitarlo también, cambia estos valores a false / "off":
  "editor.quickSuggestions": { "other": true, "comments": false, "strings": false },
  "editor.suggestOnTriggerCharacters": true,
  "editor.wordBasedSuggestions": "matchingDocuments",
  "editor.parameterHints.enabled": true,

  // --- Arranque limpio ---
  "security.workspace.trust.enabled": false,
  "workbench.startupEditor": "none",
  "workbench.tips.enabled": false,
  "update.mode": "none",
  "telemetry.telemetryLevel": "off",
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 1000,
  "files.exclude": { ".registro": true }
}
FIN_VSCODE_SETTINGS_JSON
chmod +x "$DESTINO/entregar.sh" "$DESTINO/examen.sh" "$DESTINO/registro.sh"
mkdir -p "$HOME/.examen1-vscode" && cp "$DESTINO/.vscode/settings.json" "$HOME/.examen1-vscode/ajustes-examen.json"
printf 'UID_EXAMEN=%s\nGID_EXAMEN=%s\n' "$(id -u)" "$(id -g)" > "$DESTINO/.env"

cd "$DESTINO" || exit 1
if ! docker image inspect "$IMAGEN" >/dev/null 2>&1; then
  echo "Preparando la imagen $IMAGEN (solo la primera vez; necesita internet)…"
  docker compose build -q web || { echo "✖ No se ha podido preparar la imagen. Llama al profesor."; exit 1; }
fi
docker compose up -d || { echo "✖ No se han podido levantar los contenedores. Llama al profesor."; exit 1; }

URL="http://localhost:$PUERTO"
# Espera a que Vite responda (máx. 10 s) antes de abrir el navegador
for _ in $(seq 1 20); do puerto_libre "$PUERTO" || break; sleep 0.5; done
sleep 1

echo
echo "✔ Examen (modelo B) preparado en $DESTINO y contenedores en marcha."
echo
echo "  Página del examen:   $URL   (se recarga sola al guardar)"
echo
echo "Siguientes pasos:"
echo "  1. Se abre el VS Code del examen (sin extensiones ni IA). Si lo cierras:   bash ~/examen1/examen.sh code"
echo "     Usa SOLO ese VS Code: no abras el examen con tu VS Code habitual."
echo "  2. Completa examen.js (instrucciones en LEEME.md y en tu hoja)"
echo "  3. Para entregar (sin internet):   bash ~/examen1/examen.sh entregar"
echo "     y avisa al profesor: él activa internet para que lo envíes por correo."
echo
echo "  ⚠️  AHORA: desactiva internet (wifi y cable) delante del profesor."
(setsid nohup bash "$DESTINO/registro.sh" >/dev/null 2>&1 &)   # registro del examen (VS Code, pegados)
command -v code >/dev/null && bash "$DESTINO/examen.sh" code >/dev/null
command -v xdg-open >/dev/null && (xdg-open "$URL" >/dev/null 2>&1 &)
exit 0
