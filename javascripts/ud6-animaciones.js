// Animaciones de la UD6 (apuntes). Cada una se monta en un <div class="ud6-anim" data-anim="...">.

function crear(etiqueta, clase, html) {
  const el = document.createElement(etiqueta);
  if (clase) el.className = clase;
  if (html !== undefined) el.innerHTML = html;
  return el;
}

function boton(texto, alPulsar) {
  const b = crear("button", "md-button ud6-boton", texto);
  b.type = "button";
  b.addEventListener("click", alPulsar);
  return b;
}

const esperar = (ms) => new Promise((ok) => setTimeout(ok, ms));


// 1 · El event loop (apartado 2.4)

const CODIGO_LOOP = [
  'console.log("1 · síncrono");',
  'setTimeout(() => console.log("2 · tarea"), 0);',
  'Promise.resolve().then(() => console.log("3 · microtarea"));',
  'console.log("4 · síncrono");',
];

const PASOS_LOOP = [
  { linea: -1, pila: [], web: [], micro: [], tareas: [], consola: [],
    texto: "Pulsa ▶ Paso para ejecutar el código línea a línea." },
  { linea: 0, pila: ["console.log(1)"], web: [], micro: [], tareas: [], consola: ["1 · síncrono"],
    texto: "Línea 1: código síncrono. Entra en la pila, se ejecuta y sale." },
  { linea: 1, pila: ["setTimeout"], web: ["⏱ 0 ms"], micro: [], tareas: [], consola: ["1 · síncrono"],
    texto: "Línea 2: setTimeout no espera. Le pide al navegador el temporizador y sigue." },
  { linea: 1, pila: [], web: [], micro: [], tareas: ["log 2"], consola: ["1 · síncrono"],
    texto: "Los 0 ms se cumplen enseguida, pero el callback va a la cola de TAREAS: no entra mientras la pila tenga trabajo." },
  { linea: 2, pila: ["then"], web: [], micro: ["log 3"], tareas: ["log 2"], consola: ["1 · síncrono"],
    texto: "Línea 3: la promesa ya está cumplida, así que su then va a la cola de MICROTAREAS." },
  { linea: 3, pila: ["console.log(4)"], web: [], micro: ["log 3"], tareas: ["log 2"], consola: ["1 · síncrono", "4 · síncrono"],
    texto: "Línea 4: síncrono otra vez. Se ejecuta antes que nada de lo que espera en las colas." },
  { linea: -1, pila: [], web: [], micro: ["log 3"], tareas: ["log 2"], consola: ["1 · síncrono", "4 · síncrono"],
    texto: "Se acabó el código: la pila está vacía. El event loop mira las colas: primero TODAS las microtareas." },
  { linea: -1, pila: ["log 3"], web: [], micro: [], tareas: ["log 2"], consola: ["1 · síncrono", "4 · síncrono", "3 · microtarea"],
    texto: "La microtarea pasa a la pila y se ejecuta." },
  { linea: -1, pila: ["log 2"], web: [], micro: [], tareas: [], consola: ["1 · síncrono", "4 · síncrono", "3 · microtarea", "2 · tarea"],
    texto: "Sin microtareas pendientes, entra UNA tarea: la del setTimeout. Orden final: 1, 4, 3, 2." },
];

function eventLoop(caja) {
  const codigo = crear("pre", "ud6-codigo");
  const lineas = CODIGO_LOOP.map((texto) => codigo.appendChild(crear("div", "", texto.replace(/</g, "&lt;"))));

  const columnas = {
    pila: "📚 Pila de llamadas",
    web: "🌐 Web APIs (navegador)",
    micro: "⚡ Microtareas",
    tareas: "📬 Tareas",
    consola: "🖥️ Consola",
  };
  const zona = crear("div", "ud6-columnas");
  const listas = {};
  for (const [clave, titulo] of Object.entries(columnas)) {
    const col = zona.appendChild(crear("div", `ud6-col ud6-col-${clave}`));
    col.appendChild(crear("div", "ud6-col-titulo", titulo));
    listas[clave] = col.appendChild(crear("div", "ud6-fichas"));
  }

  const texto = crear("p", "ud6-explica");
  let paso = 0;

  function pintar() {
    const ahora = PASOS_LOOP[paso];
    const antes = PASOS_LOOP[paso - 1];
    lineas.forEach((l, i) => l.classList.toggle("ud6-activa", i === ahora.linea));
    for (const clave of Object.keys(columnas)) {
      listas[clave].replaceChildren(...ahora[clave].map((t) => {
        const nueva = !antes || !antes[clave].includes(t);
        return crear("span", nueva ? "ud6-ficha ud6-entra" : "ud6-ficha", t);
      }));
    }
    texto.textContent = `${paso}/${PASOS_LOOP.length - 1} · ${ahora.texto}`;
    siguiente.disabled = paso === PASOS_LOOP.length - 1;
  }

  const siguiente = boton("▶ Paso", () => { paso++; pintar(); });
  const reiniciar = boton("⟲ Reiniciar", () => { paso = 0; pintar(); });
  const mandos = crear("div", "ud6-mandos");
  mandos.append(siguiente, reiniciar);

  caja.append(codigo, mandos, zona, texto);
  pintar();
}


// 2 · Cadena de then: las dos vías (apartado 3.4)

const CASOS_CADENA = {
  bien: { nombre: "Con return", paso1: "n => n * 3" },
  llaves: { nombre: "Llaves y sin return", paso1: "n => { n * 3; }" },
  error: { nombre: "Lanza un error", paso1: 'n => { throw new Error("¡ay!"); }' },
};

function cadena(caja) {
  let caso = "bien";
  const selector = crear("div", "ud6-mandos");
  const codigo = crear("pre", "ud6-codigo");
  const vias = crear("div", "ud6-vias");
  const texto = crear("p", "ud6-explica");

  function escribirCodigo() {
    codigo.textContent =
      "Promise.resolve(2)\n" +
      `  .then(${CASOS_CADENA[caso].paso1})\n` +
      "  .then(n => n + 1)\n" +
      "  .catch(e => 0)\n" +
      "  .then(mostrar);";
  }

  const estaciones = ["Promise.resolve(2)", "then 1", "then n + 1", "catch e => 0", "then mostrar"];
  const celdas = estaciones.map((nombre, i) => {
    const columna = vias.appendChild(crear("div", "ud6-estacion"));
    columna.appendChild(crear("div", "ud6-estacion-nombre", nombre));
    return {
      verde: columna.appendChild(crear("div", "ud6-via ud6-via-verde")),
      roja: columna.appendChild(crear("div", "ud6-via ud6-via-roja")),
      columna,
    };
  });

  // Recorrido de la bolita: en qué estación, en qué vía y qué lleva.
  function recorrido() {
    if (caso === "error") return [
      { via: "verde", valor: "2", nota: "Empieza con 2." },
      { via: "roja", valor: "Error", nota: "El primer then lanza: la promesa queda rechazada y la bolita cae a la vía roja." },
      { via: "salta", valor: "", nota: "En la vía roja, los then se saltan: n + 1 no se ejecuta." },
      { via: "verde", valor: "0", nota: "El catch recoge el error y devuelve 0: la bolita vuelve a la vía verde." },
      { via: "verde", valor: "0", nota: "mostrar(0). Un catch al final recoge el error de CUALQUIER paso anterior." },
    ];
    if (caso === "llaves") return [
      { via: "verde", valor: "2", nota: "Empieza con 2." },
      { via: "verde", valor: "undefined", gris: true, nota: "Con llaves y sin return, la función no devuelve nada: sigue undefined." },
      { via: "verde", valor: "NaN", gris: true, nota: "undefined + 1 = NaN. No hay ningún error…" },
      { via: "salta", valor: "", nota: "…así que el catch se salta." },
      { via: "verde", valor: "NaN", gris: true, nota: "mostrar(NaN): el dato se ha perdido sin un solo aviso." },
    ];
    return [
      { via: "verde", valor: "2", nota: "Empieza con 2." },
      { via: "verde", valor: "6", nota: "2 × 3 = 6. Lo que devuelve un then es lo que recibe el siguiente." },
      { via: "verde", valor: "7", nota: "6 + 1 = 7." },
      { via: "salta", valor: "", nota: "No ha habido ningún error: el catch se salta." },
      { via: "verde", valor: "7", nota: "mostrar(7)." },
    ];
  }

  let turno = 0;
  async function lanzar() {
    const mio = ++turno;
    escribirCodigo();
    for (const c of celdas) {
      c.verde.textContent = "";
      c.roja.textContent = "";
      c.columna.classList.remove("ud6-saltada");
    }
    texto.textContent = "";
    for (const [i, paso] of recorrido().entries()) {
      if (mio !== turno) return;
      if (paso.via === "salta") {
        celdas[i].columna.classList.add("ud6-saltada");
      } else {
        const bolita = crear("span", paso.gris ? "ud6-bolita ud6-gris" : "ud6-bolita", paso.valor);
        if (paso.via === "roja") bolita.classList.add("ud6-roja");
        celdas[i][paso.via].replaceChildren(bolita);
      }
      texto.textContent = paso.nota;
      await esperar(1400);
    }
  }

  for (const [clave, { nombre }] of Object.entries(CASOS_CADENA)) {
    selector.appendChild(boton(nombre, () => { caso = clave; lanzar(); }));
  }

  caja.append(selector, codigo, vias, texto);
  escribirCodigo();
  texto.textContent = "Elige un caso y mira por qué vía viaja el valor.";
}


// 3 · En serie o en paralelo (apartado 4.3)

function serieParalelo(caja) {
  const LENTO = 2;  // 1 s del ejemplo = 2 s en pantalla
  const filas = [
    { titulo: "En serie (dos await)", barras: [
      { nombre: "usuario", desde: 0, hasta: 1 },
      { nombre: "tareas", desde: 1, hasta: 1.5 },
    ] },
    { titulo: "Promise.all", barras: [
      { nombre: "usuario", desde: 0, hasta: 1 },
      { nombre: "tareas", desde: 0, hasta: 0.5 },
    ] },
  ];
  const total = 1.5;

  const reloj = crear("div", "ud6-reloj", "0,00 s");
  const pista = crear("div", "ud6-pistas");
  const barras = [];
  for (const fila of filas) {
    const bloque = pista.appendChild(crear("div", "ud6-pista"));
    bloque.appendChild(crear("div", "ud6-pista-titulo", fila.titulo));
    for (const b of fila.barras) {
      const carril = bloque.appendChild(crear("div", "ud6-carril"));
      const barra = carril.appendChild(crear("div", "ud6-barra", `🛵 ${b.nombre}`));
      barra.style.left = `${(b.desde / total) * 100}%`;
      barras.push({ ...b, barra });
    }
    const meta = bloque.appendChild(crear("div", "ud6-meta", "🏁"));
    meta.style.left = `calc((100% - 1.5em) * ${Math.max(...fila.barras.map((b) => b.hasta)) / total})`;
    fila.meta = meta;
  }

  let animacion = 0;
  function lanzar() {
    cancelAnimationFrame(animacion);
    filas.forEach((f) => f.meta.classList.remove("ud6-visible"));
    const inicio = performance.now();
    function cuadro(t) {
      const s = Math.min((t - inicio) / 1000 / LENTO, total);
      reloj.textContent = `${s.toFixed(2).replace(".", ",")} s`;
      for (const b of barras) {
        const hecho = Math.max(0, Math.min(s, b.hasta) - b.desde);
        b.barra.style.width = `${(hecho / total) * 100}%`;
        b.barra.classList.toggle("ud6-llegada", s >= b.hasta);
      }
      for (const f of filas) {
        const fin = Math.max(...f.barras.map((b) => b.hasta));
        f.meta.classList.toggle("ud6-visible", s >= fin);
      }
      if (s < total) animacion = requestAnimationFrame(cuadro);
    }
    animacion = requestAnimationFrame(cuadro);
  }

  const mandos = crear("div", "ud6-mandos");
  mandos.append(boton("▶ Lanzar los repartidores", lanzar), reloj);
  const nota = crear("p", "ud6-explica",
    "🏁 marca cuándo sigue tu código. En serie, el segundo repartidor no sale hasta que vuelve el primero (1,5 s). " +
    "Con <code>Promise.all</code> salen a la vez y se espera al más lento (1 s). Va a cámara lenta: ×2.");
  caja.append(mandos, pista, nota);
}


// 4 · El sobre de fetch (apartado 6.2)

const CASOS_FETCH = {
  "200 JSON": { llega: true, estado: 200, tipo: "application/json", cuerpo: '[{"titulo":"Up"}]' },
  "404": { llega: true, estado: 404, tipo: "text/html", cuerpo: "<h1>Not Found</h1>" },
  "500": { llega: true, estado: 500, tipo: "text/html", cuerpo: "<h1>Error</h1>" },
  "200 pero HTML (Vite)": { llega: true, estado: 200, tipo: "text/html", cuerpo: "<!doctype html>…" },
  "Sin red": { llega: false },
};

function sobreFetch(caja) {
  const selector = crear("div", "ud6-mandos");
  const cable = crear("div", "ud6-cable");
  cable.append(crear("span", "ud6-extremo", "🖥️ página"), crear("span", "ud6-extremo ud6-derecha", "🗄️ servidor"));
  const sobre = cable.appendChild(crear("div", "ud6-sobre"));
  const tijeras = cable.appendChild(crear("div", "ud6-tijeras", "✂️"));

  const puertas = [
    { pregunta: "¿Hay respuesta?", codigo: "await fetch(url)" },
    { pregunta: "¿r.ok? (200–299)", codigo: "if (!r.ok) throw …" },
    { pregunta: "¿Es JSON?", codigo: 'tipo.includes("json")' },
    { pregunta: "Leer el cuerpo", codigo: "return r.json()" },
  ];
  const fila = crear("div", "ud6-puertas");
  const luces = puertas.map((p) => {
    const el = fila.appendChild(crear("div", "ud6-puerta", `<b>🚪 ${p.pregunta}</b><code>${p.codigo}</code>`));
    return el;
  });
  const resultado = crear("p", "ud6-explica");

  let turno = 0;
  async function enviar(nombre) {
    const mio = ++turno;
    const c = CASOS_FETCH[nombre];
    luces.forEach((l) => l.classList.remove("ud6-pasa", "ud6-para"));
    tijeras.classList.remove("ud6-visible");
    resultado.textContent = "";
    sobre.className = "ud6-sobre ud6-ida";
    sobre.textContent = "✉️ GET";
    await esperar(1100);
    if (mio !== turno) return;

    if (!c.llega) {
      tijeras.classList.add("ud6-visible");
      sobre.className = "ud6-sobre ud6-roto";
      sobre.textContent = "✉️ ✗";
      await esperar(600);
      luces[0].classList.add("ud6-para");
      resultado.innerHTML = "No hay respuesta: <code>fetch</code> <b>rechaza</b> con <code>TypeError: Failed to fetch</code>. Es el único caso en el que <code>fetch</code> falla solo.";
      return;
    }

    sobre.className = `ud6-sobre ud6-vuelta ud6-s${String(c.estado)[0]}`;
    sobre.textContent = `✉️ ${c.estado}`;
    await esperar(1100);
    if (mio !== turno) return;

    const pasos = [
      [true, `Llega un sobre sellado con <b>${c.estado}</b>: <code>fetch</code> se cumple. Aunque sea un error HTTP, es una respuesta.`],
      [c.estado < 300, c.estado < 300 ? "<code>r.ok</code> es <code>true</code>." : `<code>r.ok</code> es <code>false</code>: <code>getJSON</code> lanza <code>Error("HTTP ${c.estado} en …")</code>. Sin esta línea, el error pasaría sin que nadie lo viera.`],
      [c.tipo.includes("json"), c.tipo.includes("json") ? "<code>Content-Type: application/json</code>." : `<code>Content-Type: ${c.tipo}</code>: lanza <code>Error("… no es JSON")</code>. Sin esta puerta, <code>r.json()</code> daría <code>SyntaxError: Unexpected token '&lt;'</code>.`],
      [true, `Se lee el cuerpo: <code>${c.cuerpo.replace(/</g, "&lt;")}</code> → datos para pintar.`],
    ];
    for (const [i, [pasa, explica]] of pasos.entries()) {
      luces[i].classList.add(pasa ? "ud6-pasa" : "ud6-para");
      resultado.innerHTML = explica;
      if (!pasa) return;
      await esperar(900);
      if (mio !== turno) return;
    }
  }

  for (const nombre of Object.keys(CASOS_FETCH)) {
    selector.appendChild(boton(nombre, () => enviar(nombre)));
  }
  caja.append(selector, cable, fila, resultado);
  resultado.textContent = "Elige qué contesta el servidor y sigue el sobre por las cuatro puertas de getJSON.";
}


// 5 · La libreta de localStorage (apartados 7.2 y 7.3)

function libreta(caja) {
  const libro = new Map();  // simula localStorage: solo guarda textos
  const DEFECTO = { tema: "claro" };

  function cargar() {
    try {
      return JSON.parse(libro.get("app:prefs") ?? null) ?? DEFECTO;
    } catch {
      return DEFECTO;
    }
  }

  const ver = (v) => (typeof v === "string" ? JSON.stringify(v) : JSON.stringify(v) ?? String(v));

  const tarjetas = [
    { codigo: 'localStorage.setItem("app:visitas", 3)', hacer: () => { libro.set("app:visitas", String(3)); return "El 3 se guarda como el texto \"3\"."; } },
    { codigo: 'localStorage.getItem("app:visitas") + 1', hacer: () => `→ ${ver((libro.get("app:visitas") ?? null) + 1)} · todo lo leído es texto: hay que convertir con Number(…).` },
    { codigo: 'localStorage.setItem("app:prefs", { tema: "oscuro" })', hacer: () => { libro.set("app:prefs", String({ tema: "oscuro" })); return "Sin stringify, el objeto se convierte en \"[object Object]\": los datos se han perdido."; } },
    { codigo: 'localStorage.setItem("app:prefs", JSON.stringify({ tema: "oscuro" }))', hacer: () => { libro.set("app:prefs", JSON.stringify({ tema: "oscuro" })); return "Ahora sí: se guarda el texto JSON."; } },
    { codigo: "cargar()", hacer: () => `→ ${ver(cargar())} · JSON.parse vuelve a crear el objeto (o el valor por defecto si algo falla).` },
    { codigo: "🔨 el usuario edita el valor a mano", hacer: () => { libro.set("app:prefs", "{tema: oscuro"); return "En DevTools cualquiera puede cambiar la libreta: ahora no es JSON válido. Prueba otra vez cargar()."; } },
    { codigo: 'localStorage.removeItem("app:prefs")', hacer: () => { libro.delete("app:prefs"); return "Borrado. getItem devolverá null y JSON.parse(null) es null: cargar() usa el valor por defecto."; } },
  ];

  const zona = crear("div", "ud6-libreta-zona");
  const lista = zona.appendChild(crear("div", "ud6-tarjetas"));
  const papel = zona.appendChild(crear("div", "ud6-libreta"));
  const texto = crear("p", "ud6-explica", "Pulsa cada línea en orden y mira lo que entra en la libreta y lo que sale.");

  function pintarLibreta() {
    papel.replaceChildren(crear("div", "ud6-libreta-titulo", "📒 localStorage"));
    if (libro.size === 0) papel.appendChild(crear("div", "ud6-vacio", "(vacía)"));
    for (const [clave, valor] of libro) {
      const fila = papel.appendChild(crear("div", "ud6-apunte ud6-entra"));
      fila.append(crear("code", "", clave), crear("code", "", JSON.stringify(valor)));
    }
  }

  for (const t of tarjetas) {
    const b = boton(`<code>${t.codigo}</code>`, () => {
      const antes = new Map(libro);
      let mensaje = t.hacer();
      if (t.codigo === "cargar()") {
        try { JSON.parse(libro.get("app:prefs") ?? null); } catch (e) { mensaje = `✗ JSON.parse lanza ${e.name}, pero cargar() lo captura → ${ver(DEFECTO)} · la página no se rompe.`; }
      }
      texto.textContent = mensaje;
      if (String([...antes]) !== String([...libro])) pintarLibreta();
    });
    b.classList.add("ud6-tarjeta");
    lista.appendChild(b);
  }

  caja.append(zona, texto);
  pintarLibreta();
}


const ANIMACIONES = { eventloop: eventLoop, cadena, serie: serieParalelo, fetch: sobreFetch, libreta };

function montar() {
  for (const caja of document.querySelectorAll(".ud6-anim:not([data-montada])")) {
    const montar = ANIMACIONES[caja.dataset.anim];
    if (!montar) continue;
    caja.dataset.montada = "si";
    montar(caja);
  }
}

if (window.document$) window.document$.subscribe(montar);
else document.addEventListener("DOMContentLoaded", montar);
