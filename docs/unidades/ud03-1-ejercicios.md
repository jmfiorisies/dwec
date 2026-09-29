# UD 3.1 · Batería de Ejercicios: Control de Flujo, Bucles y Arrays

14 ejercicios principales (de truthy/falsy hasta `reduce`) + un bloque extra de 4 ejercicios
sobre `find`, `findIndex`, `some`, `every` e `includes`.

!!! tip "Antes de empezar"
    Repasa la [teoría de la UD3](ud03.md) y ten a mano la
    [tabla comparativa de métodos de arrays](ud03.md#7-tabla-comparativa-definitiva-de-metodos-de-arrays).
    Puedes resolver los ejercicios en la consola del navegador (`F12` → *Console*) o en un fichero
    `.js` ejecutado con Node.

---

## Bloque 1 · Condicionales

### Ejercicio 1 — Truthy / Falsy: predicción

Sin ejecutar nada todavía, escribe en un papel o comentario si cada `if` se ejecuta (`SÍ`/`NO`):

```javascript
if (0) console.log("A");
if ("0") console.log("B");
if ([]) console.log("C");
if (null) console.log("D");
if (" ") console.log("E");
if (NaN) console.log("F");
if (-1) console.log("G");
if (undefined) console.log("H");
```

Después ejecútalo y comprueba cuántos aciertos tuviste. Anota cuáles fallaste y por qué.

---

### Ejercicio 2 — if / else if / else: validador de acceso

Escribe una función `validarAcceso(edad, tieneEntrada)` que:

- Si `edad` es menor de 12 → devuelve `"Acceso gratuito"`.
- Si `edad` está entre 12 y 17 (inclusive) y `tieneEntrada` es `true` → devuelve `"Acceso con descuento"`.
- Si `edad` es 18 o más y `tieneEntrada` es `true` → devuelve `"Acceso normal"`.
- En cualquier otro caso → devuelve `"Acceso denegado"`.

Pruébala con al menos 4 combinaciones distintas de `edad`/`tieneEntrada`.

---

### Ejercicio 3 — Ternario (simple y anidado)

1. Usando el operador ternario, crea `mensaje` que valga `"Mayor de edad"` si `edad >= 18`,
   o `"Menor de edad"` en caso contrario, para `edad = 16`.
2. Ahora, con un ternario **anidado**, crea `categoria` que valga `"Bebé"` si `edad < 2`,
   `"Niño"` si `edad < 12`, `"Adolescente"` si `edad < 18`, o `"Adulto"` en cualquier otro caso.
   Pruébalo con `edad = 8`.

---

### Ejercicio 4 — Cortocircuitos `&&` / `||` y la trampa del `0`

Dado este objeto:

```javascript
const producto = {
  nombre: "Auriculares",
  stock: 0,
  descuento: false
};
```

1. Usa `||` para crear `stockMostrado` que muestre `producto.stock`, o `"Sin datos"` si no
   hubiera stock definido. Ejecútalo y observa qué sale.
2. Ahora repite el mismo cálculo pero con `??` en vez de `||`, llámalo `stockCorrecto`.
3. Explica en un comentario por qué los dos resultados son distintos.
4. Usa `&&` para que solo se ejecute `console.log("¡Aplica el descuento!")` cuando
   `producto.descuento` sea `true`.

---

### Ejercicio 5 — Optional chaining `?.`

Dado:

```javascript
const pedidos = [
  { id: 1, cliente: { nombre: "Marta", direccion: { ciudad: "Cádiz" } } },
  { id: 2, cliente: { nombre: "Luis" } }, // sin dirección
  { id: 3, cliente: null }
];
```

Escribe una función `ciudadDelPedido(pedido)` que devuelva la ciudad del cliente, o
`"Ciudad no especificada"` si en algún punto de la cadena (`cliente`, `direccion` o `ciudad`)
no existiera. Pruébala con los tres pedidos del array.

---

### Ejercicio 6 — switch con fall-through intencional

Escribe una función `diaDeLaSemana(numero)` que, usando `switch`, devuelva:

- `"Fin de semana"` si el número es 6 o 7.
- `"Día laboral"` si el número está entre 1 y 5.
- `"Número no válido"` en cualquier otro caso.

Tienes que aprovechar el fall-through (agrupar varios `case` sin `break` entre ellos) al menos
una vez en tu solución.

---

## Bloque 2 · Bucles clásicos

### Ejercicio 7 — while / do...while

1. Escribe un `while` que simule intentos de login: parte de `intentos = 0` y, mientras
   `intentos < 3`, imprime `` `Intento ${intentos + 1} de 3` `` e incrementa `intentos`.
2. Ahora escribe un `do...while` que pida (simuladamente, sin `prompt`, solo con una variable
   ya fijada como `contraseñaCorrecta = true`) al menos una vez, y explica en un comentario
   por qué un `do...while` garantiza esa primera ejecución y un `while` no.

---

### Ejercicio 8 — for clásico: suma de posiciones pares

Dado el array:

```javascript
const numeros = [5, 12, 8, 3, 20, 7, 14, 1];
```

Usa un `for` clásico (con índice) para sumar **solo los valores que están en una posición par**
del array (índices 0, 2, 4, 6...). Guarda el resultado en `sumaPosicionesPares`.

---

### Ejercicio 9 — for...of vs for...in: encuentra el bug

Este código tiene un bug. Ejecútalo, observa la salida "rara", y explica en un comentario
qué está pasando y cómo lo arreglarías:

```javascript
const carrito = ["Camiseta", "Pantalón", "Zapatos"];
carrito.descuentoAplicado = true; // propiedad añadida al array

for (const item in carrito) {
  console.log(item);
}
```

---

## Bloque 3 · Arrays: mutabilidad

### Ejercicio 10 — Mutadores vs inmutables: predicción

Antes de ejecutar, predice qué imprime cada `console.log`:

```javascript
const equipoA = ["Ana", "Bea"];
const equipoB = equipoA;
const equipoC = [...equipoA];

equipoB.push("Carla");
equipoC.push("Diana");

console.log(equipoA);
console.log(equipoB);
console.log(equipoC);
```

---

### Ejercicio 11 — El peligro de sort(): encuéntralo y arréglalo

```javascript
const precios = [100, 25, 9, 400, 3];
const precioMasBarato = precios.sort()[0];
console.log(precioMasBarato);
console.log(precios); // ¿sigue siendo el array original?
```

1. Ejecuta el código y anota qué sale realmente en las dos líneas.
2. Corrígelo para que `precioMasBarato` sea de verdad el precio más bajo, **sin mutar**
   el array `precios` original.

---

## Bloque 4 · Métodos funcionales

### Ejercicio 12 — map: transformar

Dado:

```javascript
const alumnos = [
  { nombre: "Marta", notaSobre10: 7 },
  { nombre: "Iván", notaSobre10: 5.5 },
  { nombre: "Nora", notaSobre10: 9 }
];
```

Usa `map()` para crear un nuevo array `alumnosConLetra` de objetos `{ nombre, letra }`, donde
`letra` sea `"A"` si la nota es ≥ 9, `"B"` si es ≥ 7, o `"C"` en cualquier otro caso. Comprueba
al final que `alumnos` no ha cambiado.

---

### Ejercicio 13 — filter: seleccionar

Usando el mismo array `alumnos` del ejercicio 12, crea `aprobados`, un array que contenga
solo los alumnos con `notaSobre10 >= 5`.

---

### Ejercicio 14 — reduce: acumular

Dado:

```javascript
const compras = [
  { producto: "Libro", precio: 15, cantidad: 2 },
  { producto: "Cuaderno", precio: 3, cantidad: 5 },
  { producto: "Bolígrafo", precio: 1, cantidad: 10 }
];
```

1. Usa `reduce()` para calcular `totalGastado`, la suma de `precio * cantidad` de todas
   las líneas.
2. **Extra:** usa `reduce()` para crear `resumen`, un objeto `{ producto: cantidad }` con
   la cantidad comprada de cada producto (pista: mira el ejemplo de "agrupar por
   departamento" en tus apuntes).

---

## Bloque extra · find, findIndex, some, every, includes

Usa este array para todo el bloque:

```javascript
const pedidosTienda = [
  { id: 1, cliente: "Marta", estado: "enviado", total: 45 },
  { id: 2, cliente: "Luis", estado: "pendiente", total: 120 },
  { id: 3, cliente: "Nora", estado: "entregado", total: 30 },
  { id: 4, cliente: "Iván", estado: "pendiente", total: 75 }
];
```

### Ejercicio 15 — find y findIndex

1. Usa `find()` para obtener el primer pedido con `estado === "pendiente"`.
2. Usa `findIndex()` para obtener la posición de ese mismo pedido dentro del array.

---

### Ejercicio 16 — some y every

1. Usa `some()` para comprobar si **hay algún** pedido con `total > 100`.
2. Usa `every()` para comprobar si **todos** los pedidos tienen `total > 10`.
3. Usa `every()` de nuevo para comprobar si **todos** los pedidos están `"entregado"`
   (debería dar `false`).

---

### Ejercicio 17 — includes

1. Crea un array `clientesVip = ["Marta", "Nora"]`.
2. Usa `includes()` para comprobar, para cada pedido de `pedidosTienda`, si su cliente es VIP,
   e imprime `` `${cliente} es VIP` `` o `` `${cliente} no es VIP` `` según el caso (puedes
   combinarlo con `forEach()` o `map()` de la UD3).

---

### Ejercicio 18 (integrador) — Todo junto

Usando `pedidosTienda`:

1. Filtra los pedidos que **no** estén `"entregado"`.
2. Comprueba con `some()` si entre esos pedidos filtrados hay alguno de más de 100€.
3. Calcula con `reduce()` el total acumulado de esos pedidos filtrados.
4. Busca con `find()` el pedido de mayor total entre todos (pista: puedes combinarlo con
   `reduce()` para comparar, o recorrer y comparar el `total`).
