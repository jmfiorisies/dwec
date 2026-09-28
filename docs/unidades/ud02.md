# UD 2: Sintaxis, Tipos y Funciones (RA2)

JavaScript tiene fama de ser "fácil de empezar, difícil de dominar". Esta unidad es la razón:
cosas que parecen triviales (declarar una variable, comparar dos valores, escribir una
función) esconden comportamientos que, si no se entienden bien desde el principio, generan
bugs muy difíciles de rastrear más adelante. Tómate esta unidad con calma — no es solo
sintaxis, es la base de todo lo que viene después.

## 1. Sintaxis Básica, Variables y Tipos de Datos

JavaScript es un lenguaje de **tipado dinámico y débil**:

- **Dinámico** significa que una misma variable puede contener un `Number` en un momento y un
  `String` en otro — el tipo no se fija de antemano como en Java o C#, sino que se decide en
  tiempo de ejecución según el valor que tenga en cada instante.
- **Débil** significa que el propio lenguaje convierte automáticamente entre tipos cuando lo
  considera necesario (esto se llama *coerción*, y lo veremos en detalle más abajo) — a
  diferencia de un lenguaje de tipado fuerte, que te obligaría a convertir explícitamente.

Esta flexibilidad es cómoda al principio, pero es también el origen de la mayoría de bugs de
principiante en JavaScript. Todo lo que sigue está pensado para que sepas exactamente qué
está pasando "por debajo" en cada línea que escribas.

### Declaración de Variables: `var`, `let` y `const`

Antes de 2015 (ES6), `var` era la única forma de declarar variables — y daba problemas serios
que motivaron la creación de `let` y `const`. Un ejemplo real del problema:

```js
// Con var: el scope es de FUNCIÓN, no de bloque
for (var i = 0; i < 3; i++) {
  setTimeout(() => console.log(i), 100);
}
// Imprime: 3, 3, 3  <- ¡todas imprimen el mismo valor final, no 0, 1, 2!
// Esto ocurre porque las 3 funciones comparten la MISMA variable "i" (scope de función)

// Con let: el scope es de BLOQUE — cada vuelta del bucle tiene su propia "i"
for (let j = 0; j < 3; j++) {
  setTimeout(() => console.log(j), 100);
}
// Imprime: 0, 1, 2  <- el resultado esperado
```

Este es exactamente el tipo de bug que `let`/`const` eliminan de raíz. Por eso, en código
moderno, **`var` prácticamente no se usa nunca**.

| Criterio             | `var`                              | `let`                              | `const`                              |
| -------------------- | ----------------------------------- | ----------------------------------- | ------------------------------------- |
| **Ámbito (*Scope*)** | Función                             | Bloque `{}`                         | Bloque `{}`                           |
| **Reasignable**      | Sí                                  | Sí                                  | No (Valor fijo/Referencia constante)  |
| **Redeclarable**     | Sí (en el mismo ámbito)             | No — da error                       | No — da error                         |
| **Hoisting**         | Sí (inicializado como `undefined`)  | Sí (en Zona Muerta Temporal - TDZ)  | Sí (en Zona Muerta Temporal - TDZ)    |

```js
// Uso recomendado en desarrollo moderno
const API_URL = "https://api.ejemplo.com/v1"; // Valor inmutable
let contador = 0;                             // Variable reasignable
contador += 1;

// const evita reasignación de referencia, pero permite mutar objetos/arrays
const usuario = { nombre: "Ana", rol: "Admin" };
usuario.nombre = "Ana María"; // VÁLIDO: Mutación de propiedad
// usuario = {};              // ERROR: TypeError (Reasignación de referencia)
```

**Regla práctica para decidir:** empieza siempre por `const`. Si más adelante descubres que
necesitas reasignar esa variable, cámbiala a `let`. Así el propio código documenta qué
variables van a cambiar y cuáles no — y el motor de JS puede avisarte si intentas reasignar
algo que no debería cambiar.

### Tipos de Datos Primitivos y Complejos

JavaScript clasifica sus tipos de datos en dos grandes categorías, y la diferencia entre
ambas no es solo académica — determina cómo se comportan al copiarlos (lo vemos en el
siguiente apartado).

**1. Primitivos** (inmutables, se copian por valor):

| Tipo | Qué es | Ejemplo |
|---|---|---|
| `Number` | Enteros y decimales — JS no distingue entre ambos, todo es `Number` | `42`, `3.14`, `-7` |
| `String` | Cadenas de texto | `"hola"`, `'hola'`, `` `hola` `` |
| `Boolean` | Verdadero o falso | `true`, `false` |
| `Undefined` | Una variable que existe pero a la que nunca se le ha asignado un valor | `let x; // x es undefined` |
| `Null` | Ausencia de valor asignada **a propósito** por el programador | `let seleccion = null;` |
| `Symbol` | Un identificador único que nunca coincide con otro, ni aunque tenga la misma descripción | `Symbol("id") !== Symbol("id")` |
| `BigInt` | Enteros de tamaño arbitrario, para cuando `Number` se queda corto | `9007199254740993n` |

Dos casos especiales de `Number` que sorprenden a quien empieza:

```js
console.log(1 / 0);        // Infinity (no es un error, es un valor válido)
console.log("hola" * 2);   // NaN ("Not a Number" — resultado de una operación numérica imposible)
console.log(typeof NaN);   // "number"  <- NaN ES de tipo number, aunque su nombre confunda
console.log(NaN === NaN);  // false  <- NaN nunca es igual a sí mismo; para comprobarlo usa Number.isNaN(valor)
```

**Undefined vs. Null — la diferencia que confunde a todo el mundo al principio:**

- `undefined` lo pone JavaScript automáticamente cuando algo no tiene valor todavía (una
  variable declarada sin asignar, un parámetro que no se pasó, una propiedad que no existe).
- `null` lo pones **tú**, explícitamente, para decir "aquí no hay nada, y es intencionado".

```js
let usuario;
console.log(usuario); // undefined -- JS lo puso, tú no has hecho nada todavía

let sesionActiva = null; // tú decides explícitamente que no hay sesión
```

**2. Complejos / Referencia** (mutables, se copian por referencia):

- `Object`: la categoría que engloba todo lo demás — objetos literales `{}`, arrays `[]`,
  funciones, fechas (`Date`), expresiones regulares... En JavaScript, casi todo lo que no es
  primitivo es, por debajo, un objeto.

### Valor vs. Referencia: Cómo se Guardan los Datos

La distinción entre primitivos y complejos no es solo una etiqueta de categoría: determina
**qué ocurre realmente en memoria** cuando asignas una variable a otra o la pasas como
argumento a una función.

- **Primitivos → Copia por Valor:** cada variable guarda su propio valor, independiente de las
  demás. Modificar una copia nunca afecta al original.
- **Objetos → Copia por Referencia:** la variable no contiene el objeto en sí, sino una
  dirección que apunta a él en memoria. Copiar la variable copia la dirección, no el
  contenido — ambas variables terminan apuntando al mismo objeto.

```js
// Primitivos: copia por VALOR
let edad = 25;
let copiaEdad = edad;
copiaEdad = 30;
console.log(edad, copiaEdad); // 25 30 — no se afectan entre sí

// Objetos: copia por REFERENCIA
const usuario = { nombre: "Ana" };
const otraVariable = usuario; // copia la REFERENCIA, no el objeto
otraVariable.nombre = "Laura";
console.log(usuario.nombre); // "Laura" -- el "original" tambien cambio
```

Esto explica por qué, más adelante, técnicas como el operador *spread* (`{ ...objeto }`) son
necesarias para crear una copia real e independiente de un objeto — sin *spread*, solo
estarías creando una segunda referencia al mismo dato.

**Consecuencia práctica al comparar objetos:**

```js
const a = { x: 1 };
const b = { x: 1 };
console.log(a === b); // false -- son dos objetos DISTINTOS en memoria, aunque su contenido sea igual
console.log(a === a); // true  -- es literalmente el mismo objeto
```

### Coerción de Tipos, Valores *Truthy*/*Falsy* y Comparación Estricta

JavaScript realiza conversión automática de tipos (**coerción implícita**) al evaluar ciertos
operadores. Para entender la coerción hace falta primero saber qué valores se consideran
"falsos" cuando JavaScript necesita tratarlos como un booleano.

**Los valores *falsy* (solo hay 8, apréndetelos de memoria):**

```js
false, 0, -0, 0n, "", null, undefined, NaN
```

**Todo lo demás es *truthy*** — incluido, y esto sorprende mucho a quien empieza:

```js
console.log(Boolean("0"));      // true  -- es un STRING no vacío, aunque contenga el texto "0"
console.log(Boolean([]));       // true  -- un array vacío es un objeto, y los objetos siempre son truthy
console.log(Boolean({}));       // true  -- igual que arriba
console.log(Boolean(" "));      // true  -- un espacio en blanco NO es un string vacío
```

Con esta base, la coerción tiene más sentido:

```js
// Coerción Implícita (Evitar)
console.log(5 + "5");     // "55" (Number se convierte a String)
console.log("10" - 2);    // 8   (String se convierte a Number)
console.log(false == 0);  // true (false se convierte a 0, y 0 == 0)
console.log("" == 0);     // true ("" se convierte a 0)
console.log(null == undefined); // true (caso especial: solo son == entre sí)

// Comparación Estricta (Recomendado SIEMPRE)
console.log(false === 0); // false (Compara valor Y tipo de dato, sin convertir nada)
console.log("10" === 10); // false

// Coerción Explícita (cuando SÍ quieres convertir, hazlo tú mismo y que se note en el código)
const numeroTexto = "42";
const numeroReal = Number(numeroTexto);   // 42
const comoTexto = String(100);             // "100"
const comoBooleano = Boolean("cualquier cosa"); // true
```

**Regla de oro de esta unidad:** usa siempre `===` y `!==`. El operador `==` existe por
compatibilidad histórica, pero sus reglas de conversión son tan irregulares que ni los
desarrolladores con años de experiencia las recuerdan todas de memoria — no vale la pena
arriesgarse a un bug por ahorrarte un carácter.

---

## 2. Declaración e Invocación de Funciones

En JavaScript, las funciones son **ciudadanos de primera clase** (*First-Class Citizens*): se
pueden almacenar en variables, pasar como argumentos y retornar desde otras funciones — se
tratan como cualquier otro valor (un `Number`, un `String`...).

### Formas de Declarar Funciones

```js
// 1. Declaración de Función (Sujeta a Hoisting completo)
function sumar(a, b) {
  return a + b;
}

// 2. Expresión de Función (No inicializada hasta que se ejecuta esa línea)
const restar = function(a, b) {
  return a - b;
};

// 3. Función Flecha (Arrow Function - ES6)
const multiplicar = (a, b) => a * b; // Retorno implícito para expresiones de una línea
```

¿Cuál usar? Como regla práctica: usa **arrow functions** para casi todo (callbacks, funciones
cortas, métodos de array), usa **función declarada** cuando quieras aprovechar el *hoisting*
(por ejemplo, funciones auxiliares que se llaman desde arriba de donde se definen), y usa
**expresión de función tradicional** solo cuando necesites las capacidades que las arrow
functions no tienen — que es justo lo que viene ahora.

### Las Limitaciones de las Arrow Functions (Importante — se te puede escapar)

Las arrow functions no son solo "una forma más corta de escribir funciones". Son **estructuralmente
distintas** por dentro, y eso significa que hay cosas que NO puedes hacer con ellas. Estas
limitaciones aparecen constantemente en exámenes y en bugs reales de principiante:

**1. No tienen su propio `this` (ni `super`)**

Ya lo vimos en el apartado 4, pero merece repetirse aquí: una arrow function **hereda** el
`this` del lugar donde fue escrita, nunca tiene el suyo propio. Esto es justo lo que la hace
peligrosa como método de un objeto (ver el ejemplo de la sección 4) y, a la vez, lo que la
hace perfecta como callback dentro de un método (porque hereda el `this` correcto del método
que la contiene).

```js
const contador = {
  valor: 0,
  incrementar: function() {
    // Aquí "this" es "contador", correctamente
    setInterval(() => {
      this.valor++; // la arrow function HEREDA el "this" correcto de incrementar()
      console.log(this.valor);
    }, 1000);
  }
};
```

**2. No tienen el objeto `arguments`**

Las funciones tradicionales reciben automáticamente un objeto especial llamado `arguments`
con todos los argumentos pasados, aunque no estén declarados como parámetros. Las arrow
functions no lo tienen:

```js
function sumaTodo() {
  console.log(arguments); // [1, 2, 3] -- funciona, aunque no se declararon parámetros
}
sumaTodo(1, 2, 3);

const sumaTodoFlecha = () => {
  console.log(arguments); // ReferenceError: arguments is not defined
};
```

Si necesitas algo parecido en una arrow function, usa el parámetro *rest* que ya viste:
`const sumaTodo = (...args) => { console.log(args); }`.

**3. No son aptas para `call`, `apply` y `bind`**

Estos tres métodos sirven para ejecutar una función indicando manualmente cuál será su
`this`. Como una arrow function ya tiene su `this` fijado (heredado) desde el momento en que
se escribió, intentar cambiárselo con `call`/`apply`/`bind` simplemente no tiene efecto:

```js
const objeto = { nombre: "Sala A" };

function normal() { console.log(this.nombre); }
const flecha = () => { console.log(this.nombre); };

normal.call(objeto);  // "Sala A" -- call() SÍ puede fijar el "this"
flecha.call(objeto);  // no funciona como esperas -- flecha ya tenía su "this" decidido de antes
```

**4. No se pueden usar como constructor (con `new`)**

Un constructor necesita crear su propio `this` (la nueva instancia). Como una arrow function
no puede tener su propio `this`, JavaScript directamente prohíbe usarlas con `new`:

```js
const Persona = (nombre) => { this.nombre = nombre; };
const p = new Persona("Ana"); // TypeError: Persona is not a constructor
```

**5. No pueden usar `yield` (no pueden ser funciones generadoras)**

Esto es más avanzado y lo verás si trabajas con *generadores* — por ahora basta con saber que
existe esta limitación adicional.

**En resumen:** las arrow functions son geniales para callbacks cortos y para cuando quieres
heredar el `this` de fuera — pero cuando necesites un método de un objeto que use `this`, un
constructor, o acceso a `arguments`, usa una función tradicional (declarada o expresión).

### Parámetros por Defecto y Parámetros Rest

```js
// Parámetros por defecto: se usan SOLO si el argumento llega como undefined
function saludar(nombre = "Invitado", rol = "Usuario") {
  return `Hola ${nombre}, tu rol es ${rol}.`;
}
saludar();              // "Hola Invitado, tu rol es Usuario."
saludar("Ana");          // "Hola Ana, tu rol es Usuario."
saludar("Ana", null);    // "Hola Ana, tu rol es null" -- ¡null NO activa el valor por defecto, solo undefined lo hace!

// Parámetros Rest (...args): Agrupa argumentos restantes en un Array
function calcularSumaTotal(factor, ...numeros) {
  const suma = numeros.reduce((acc, curr) => acc + curr, 0);
  return suma * factor;
}

console.log(calcularSumaTotal(2, 10, 20, 30)); // (10 + 20 + 30) * 2 = 120
```

El parámetro *rest* siempre debe ser el **último** de la lista de parámetros — agrupa "todo lo
que sobre", así que no tendría sentido que hubiera más parámetros después de él.

---

## 3. Ámbitos de Variables (*Scope*) y *Hoisting*

El **ámbito** determina la accesibilidad de las variables en distintas partes del código.

```
flowchart TD
    Global[Ámbito Global] -->|Accesible por todos| FunctionScope[Ámbito de Función / Local]
    FunctionScope -->|Accesible solo dentro| BlockScope[Ámbito de Bloque: let / const dentro de IF/FOR]
```

### Tipos de Ámbito

1. **Global Scope:** Variables declaradas fuera de cualquier función o bloque. Accesibles
   desde cualquier lugar del script. **Cuidado:** cuantas más variables globales tengas, más
   fácil es que dos partes distintas del código se pisen sin querer — úsalas con moderación.
2. **Function Scope:** Variables declaradas con `var` dentro de una función. No son accesibles
   fuera de ella.
3. **Block Scope:** Variables declaradas con `let` y `const` dentro de un bloque `{}` (como un
   `if` o un bucle `for`).

```js
function evaluarAmbito() {
  if (true) {
    var variableVar = "Soy VAR";     // Ámbito de función
    let variableLet = "Soy LET";     // Ámbito de bloque
    const variableConst = "Soy CONST"; // Ámbito de bloque
  }
  console.log(variableVar);   // Imprime: "Soy VAR"
  // console.log(variableLet);  // ReferenceError: variableLet is not defined
  // console.log(variableConst);// ReferenceError: variableConst is not defined
}
```

### *Hoisting* y Zona Muerta Temporal (*TDZ*)

El *Hoisting* es el comportamiento del motor de JS que eleva las declaraciones de funciones y
variables al principio de su ámbito durante la fase de compilación, **antes** de ejecutar
ninguna línea de código.

- **`var`:** Se eleva y se inicializa como `undefined`. Por eso puedes "usarla" antes de
  declararla sin que salte error — simplemente vale `undefined` hasta que llegue la línea real.
- **`let` / `const`:** Se elevan, pero **no se inicializan**. Permanecen en la **Zona Muerta
  Temporal (TDZ)** desde el inicio del bloque hasta que se ejecuta su declaración — acceder a
  ellas antes de esa línea lanza un error, no un `undefined` silencioso.

```js
// Comportamiento de HOISTING con var
console.log(textoVar); // Imprime: undefined (no lanza error)
var textoVar = "Hola";

// Comportamiento de TDZ con let
// console.log(textoLet); // ReferenceError: Cannot access 'textoLet' before initialization
let textoLet = "Mundo";
```

**Las funciones declaradas también sufren hoisting completo** (se elevan CON su contenido, no
solo su nombre) — por eso puedes llamarlas antes de donde aparecen escritas en el archivo:

```js
saluda(); // funciona, aunque saluda() está definida más abajo
function saluda() { console.log("Hola"); }
```

Esto **no** ocurre con las expresiones de función ni las arrow functions, porque para ellas
solo se eleva la declaración de la variable (`const miFuncion`), no su contenido — y esa
variable, al usar `const`, está en TDZ hasta su línea real.

---

## 4. Contexto de Ejecución y la Palabra Clave `this`

La palabra clave `this` hace referencia al **objeto de contexto** en el que se está ejecutando
el código actual. A diferencia de otros lenguajes, en JavaScript el valor de `this` **no se
decide al escribir la función, sino al invocarla** — depende de *cómo* se llama, no de dónde
se define (excepto en las arrow functions, que son la excepción a esta regla).

1. **Invocación directa:** `this` apunta al objeto global (`window` en navegador, `global` en
   Node.js) o `undefined` en *strict mode*.
2. **Invocación como método de un objeto:** `this` apunta al objeto que posee el método.
3. **Invocación con `new`:** `this` apunta a la nueva instancia creada.
4. **En *Arrow Functions*:** Las funciones flecha **no tienen su propio `this`**. Heredan el
   contexto `this` del ámbito léxico donde fueron creadas (ver limitaciones en la sección 2).

```js
const usuario = {
  nombre: "Carlos",
  saludarTradicional: function() {
    console.log(`Hola, soy ${this.nombre}`);
  },
  saludarFlecha: () => {
    console.log(`Hola, soy ${this.nombre}`);
  }
};

usuario.saludarTradicional(); // Imprime: "Hola, soy Carlos"
usuario.saludarFlecha();      // Imprime: "Hola, soy undefined" (hereda 'this' global, no el de usuario)
```

**Un bug clásico de principiante** relacionado con esto — perder el `this` al pasar un método
como callback:

```js
const boton = {
  etiqueta: "Enviar",
  manejarClic: function() {
    console.log(`Botón pulsado: ${this.etiqueta}`);
  }
};

// Si lo llamas directamente, funciona:
boton.manejarClic(); // "Botón pulsado: Enviar"

// Pero si lo pasas como referencia (por ejemplo a un event listener), pierdes el "this":
// elemento.addEventListener("click", boton.manejarClic); // this ya NO sería "boton"

// Solución típica: envolverlo en una arrow function para preservar el "this" correcto
// elemento.addEventListener("click", () => boton.manejarClic());
```

---

## 5. *Closures* (Clausuras)

Un **Closure** es la combinación de una función y el entorno léxico en el que fue declarada.
Permite a una función interna acceder al ámbito de su función externa incluso después de que
la función externa haya terminado de ejecutarse — el motor de JavaScript "recuerda" ese
entorno y no lo destruye mientras algo siga necesitándolo.

### Caso de Uso: Encapsulamiento y Variables Privadas

```js
function crearContador() {
  let contadorPrivado = 0; // Variable encapsulada (inaccesible desde fuera)

  return {
    incrementar: function() {
      contadorPrivado += 1;
      return contadorPrivado;
    },
    decrementar: function() {
      contadorPrivado -= 1;
      return contadorPrivado;
    },
    obtenerValor: function() {
      return contadorPrivado;
    }
  };
}

const miContador = crearContador();
console.log(miContador.incrementar()); // 1
console.log(miContador.incrementar()); // 2
console.log(miContador.obtenerValor());// 2
console.log(miContador.contadorPrivado); // undefined (Acceso directo bloqueado)
```

**¿Por qué funciona esto?** `contadorPrivado` vive dentro del scope de `crearContador()`. En
principio, cuando una función termina, sus variables locales deberían desaparecer. Pero como
los objetos que devolvemos (`incrementar`, `decrementar`, `obtenerValor`) siguen "usando"
`contadorPrivado`, el motor de JavaScript mantiene viva esa variable en memoria — es un
closure. Cada llamada a `crearContador()` crea un `contadorPrivado` **completamente nuevo e
independiente**:

```js
const contadorA = crearContador();
const contadorB = crearContador();
contadorA.incrementar();
contadorA.incrementar();
contadorB.incrementar();
console.log(contadorA.obtenerValor()); // 2
console.log(contadorB.obtenerValor()); // 1 -- totalmente independiente de contadorA
```

**Otros usos habituales de los closures** que verás más adelante en el curso: recordar
configuración entre llamadas a una función (por ejemplo, una función que "recuerda" un factor
de conversión), o crear funciones especializadas a partir de una más genérica.

---

## 6. Funciones de Alto Orden (*Higher-Order Functions*) y Callbacks

Una **Función de Alto Orden (HOF)** es una función que cumple al menos una de estas dos
condiciones: acepta otra función como argumento, o **devuelve** una función como resultado.

Un **Callback** es la función que se pasa como argumento a otra función para ser ejecutada
posteriormente, normalmente dentro del cuerpo de la función que la recibió.

```js
// Función de Alto Orden que recibe un Callback
function procesarEntradaUsuario(nombre, callback) {
  const nombreFormateado = nombre.trim().toUpperCase();
  callback(nombreFormateado);
}

// Invocación pasando una función flecha como callback
procesarEntradaUsuario("  juan pérez  ", (nombre) => {
  console.log(`Usuario registrado: ${nombre}`);
}); // Imprime: "Usuario registrado: JUAN PÉREZ"
```

**El otro tipo de HOF: una función que devuelve otra función.** Esto es extremadamente común
en JavaScript moderno y se apoya directamente en los closures que acabas de ver:

```js
// HOF que DEVUELVE una función, "recordando" el argumento con el que se creó
function crearMultiplicador(factor) {
  return function(numero) {
    return numero * factor; // "factor" se recuerda gracias al closure
  };
}

const duplicar = crearMultiplicador(2);
const triplicar = crearMultiplicador(3);

console.log(duplicar(5));  // 10
console.log(triplicar(5)); // 15
```

Ya conoces algunas HOF integradas en JavaScript sin saberlo — `setTimeout(callback, tiempo)`
es una HOF (recibe una función). En la próxima unidad verás varias más: `map()`, `filter()` y
`reduce()` son, todas ellas, funciones de alto orden que reciben un callback para decidir qué
hacer con cada elemento de un array.
