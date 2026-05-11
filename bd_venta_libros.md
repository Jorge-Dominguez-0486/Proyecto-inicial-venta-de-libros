actua como un administrador de base de datos para un proyecto consistente en una app movil para una libreria cristiana digital, que entidades se necesitan para su gestion?
Como DBA, aquí están las entidades principales para una librería cristiana digital, agrupadas por dominio funcional:
<img width="1171" height="561" alt="image" src="https://github.com/user-attachments/assets/ea5829f7-2e52-465b-9d10-23873b69e79f" />


**Catálogo** — el corazón de la app: `libro`, `autor`, `categoria`, `editorial`, `formato` (epub, pdf, audio).

**Usuarios y acceso** — `usuario`, `suscripcion`, `plan`, `dispositivo` (para controlar en cuántos dispositivos se lee).

**Comercio** — `orden`, `detalle_orden`, `pago`, `descuento`, `lista_deseos`.

**Biblioteca personal** — `biblioteca_usuario` (libros adquiridos/descargados), `progreso_lectura`, `marcador`, `anotacion`.

**Contenido adicional** — `devocional`, `serie_devocional`, `recurso_gratuito` (muestras, capítulos gratis).

**Comunidad** — `resena`, `calificacion`, `lista_lectura` (para compartir).

**Administración** — `rol`, `permiso`, `notificacion`, `reporte_ventas`.

Aquí el diagrama ERD con las entidades principales y sus relaciones:Algunas decisiones de diseño clave desde la perspectiva de DBA:

`LIBRO_AUTOR` y `LIBRO_CATEGORIA` son tablas de unión para manejar las relaciones muchos-a-muchos, ya que un libro puede tener varios autores y pertenecer a varias categorías (Biblia, Teología, Devocional, etc.).

`BIBLIOTECA_USUARIO` es central: distingue entre libros *adquiridos* (compra) y *suscritos* (por plan), usando el campo `origen`. Todo el progreso y las anotaciones cuelgan de aquí, no del libro directamente.

`PROGRESO_LECTURA` se vincula también a `DISPOSITIVO` para sincronización multi-dispositivo, lo cual es esencial en una app móvil donde el usuario puede leer desde el teléfono y la tablet.

`CATEGORIA` tiene una FK hacia sí misma (`padre_id`) para soportar jerarquía: por ejemplo, *Teología > Soteriología*, o *Música > Himnarios*.

`SUSCRIPCION` se separa del usuario para soportar cambios de plan, historial y renovaciones sin alterar el registro del usuario.

¿Quieres que profundice en algún dominio específico, como el modelo de suscripciones, la gestión de descargas offline o los permisos de roles?


podrias promocionarme las entidades con sus atributos y tipo de dato en forma de tabla por favor

## Tablas
<img width="833" height="402" alt="image" src="https://github.com/user-attachments/assets/54c20c7f-9421-4abf-933a-6e393ee47261" />
<img width="823" height="389" alt="image" src="https://github.com/user-attachments/assets/095f40a7-7700-4869-a0ca-317e242cfb70" />
<img width="766" height="344" alt="image" src="https://github.com/user-attachments/assets/9c626e6f-98d3-4e42-b4f1-229442be7883" />
<img width="780" height="302" alt="image" src="https://github.com/user-attachments/assets/90071217-4ce5-4a66-aa42-2175ea47969a" />
<img width="779" height="255" alt="image" src="https://github.com/user-attachments/assets/a8f4ba43-0795-4f2f-983d-28826ae4988f" />
<img width="775" height="247" alt="image" src="https://github.com/user-attachments/assets/ce8dcfbd-1538-495c-a2ed-6050f8830419" />
<img width="765" height="282" alt="image" src="https://github.com/user-attachments/assets/75fa1500-9348-46c1-ae12-9cf22b5e8049" />
<img width="807" height="538" alt="image" src="https://github.com/user-attachments/assets/60981887-886d-4648-a4cf-07dbfbdfafa5" />
<img width="771" height="381" alt="image" src="https://github.com/user-attachments/assets/e9ca3ef3-483e-4274-a862-9596b7eb05ce" />
<img width="756" height="650" alt="image" src="https://github.com/user-attachments/assets/49826d08-568e-49fd-8579-ea1391638738" />
<img width="778" height="604" alt="image" src="https://github.com/user-attachments/assets/6e24a3df-5cbf-436a-9a96-e3636c0683c9" />
<img width="788" height="666" alt="image" src="https://github.com/user-attachments/assets/fa778821-3cc2-4f01-a54b-fdc1eb102f4c" />









