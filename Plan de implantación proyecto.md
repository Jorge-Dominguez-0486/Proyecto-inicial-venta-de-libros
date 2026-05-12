Actúa como un Desarrollador Senior Full Stack experto en Flutter y Supabase. Tu objetivo es liderar la migración de una plataforma de librería digital llamada Booksbs (originalmente en Django) hacia un stack moderno. Debes trabajar bajo una metodología de "paso a paso" (Iterative Delivery), donde no avanzaremos a la siguiente fase hasta que el código de la anterior sea funcional y validado.

REGLAS DE ORO DEL PROYECTO:

Web-First Compliance: Toda la gestión de archivos y carga de medios (portadas, audios, documentos) debe realizarse exclusivamente mediante dart:html para asegurar compatibilidad total con Flutter Web; queda estrictamente prohibido el uso de image_picker.

Seguridad de Datos: La base de datos en Supabase debe estar blindada con Row Level Security (RLS). La tabla perfiles debe tener RLS desactivado para prevenir recursión, y se debe implementar un auth_guard que valide el rol is_admin.

Gestión de Estado: Utilizaremos Provider de forma centralizada. El carrito de compras será volátil (en memoria).

Integridad: Las transacciones de compra deben usar upsert para prevenir duplicados en la biblioteca del usuario.

ENTREGABLES SOLICITADOS POR FASE:
Para cada fase, debes proporcionar:

Esquema SQL: Código completo para tablas, relaciones, triggers de perfil automático y políticas RLS.

Modelos de Datos: Clases Dart con serialización fromMap.

UI & Lógica: Código completo de las pantallas (Screens) y servicios (Providers/Supabase Config).

Comandos: Instrucciones de terminal para dependencias y despliegue.

ALCANCE TÉCNICO:

Fases 1-3 (Core): Auth con metadatos, catálogo con filtros avanzados, lógica de "Ya obtenido" y flujo de carrito con IVA 16%.

Fase 4-5 (Experiencia de Usuario): Lector de imágenes (ebooks) con photo_view, reproductor de audio con just_audio y generación de facturas legales en PDF.

Fase 6 (Backoffice): Dashboard administrativo completo con ReorderableListView para contenido de libros y gestión de usuarios vía service_role_key.

¿Estás listo para comenzar con la Fase 1: Configuración de Base de Datos y Autenticación?

¿Por qué este prompt funciona?
Establece el Rol: Define quién soy (Senior Full Stack) para ajustar el tono y la calidad del código.

Delimita Restricciones: Al mencionar dart:html y RLS, evitas que la IA cometa errores comunes de principiante.

Estructura la Salida: Le dices exactamente cómo quieres que te responda (SQL, Modelos, Comandos), lo que evita que "alucine" o de respuestas incompletas.

Mantiene el Control: La frase final obliga a la IA a detenerse y pedir permiso antes de soltar 1,000 líneas de código de golpe :

---

> Necesito que me ayudes a construir una aplicación completa de librería digital llamada **Booksbs** en **Flutter/Dart** con **Supabase** como backend. El proyecto es una migración de una app Django existente. Quiero que me guíes fase por fase, dándome los archivos exactos a crear, el código completo y los comandos necesarios.
>
> ---
>
> **STACK TECNOLÓGICO:**
> - Frontend: Flutter (Dart), compatible con Flutter Web y Android
> - Backend: Supabase (PostgreSQL + Auth + Storage)
> - State management: Provider
> - Subida de archivos en web: dart:html (NO image_picker)
>
> ---
>
> **BASE DE DATOS EN SUPABASE:**
> Crea el SQL completo para las siguientes 11 tablas, incluyendo relaciones con foreign keys, RLS activado, políticas de acceso por rol y un trigger automático que cree un perfil cada vez que un usuario se registra:
>
> - `generos` (id, nombre_genero, descripcion_genero)
> - `autores` (id, nombre_autor, biografia, foto)
> - `libros` (id, titulo, descripcion, precio, portada, estado_publicacion, formato, fecha_lanzamiento, duracion_minutos)
> - `libro_autores` (relación muchos a muchos entre libros y autores)
> - `libro_generos` (relación muchos a muchos entre libros y géneros)
> - `contenido_libros` (id, libro_id, tipo_contenido: 'imagen' o 'audio', archivo, orden)
> - `pedidos` (id, usuario_id, fecha_pedido, total_pagado, estado_pago)
> - `detalle_pedidos` (id, pedido_id, libro_id, precio_compra)
> - `biblioteca_usuarios` (id, usuario_id, libro_id, fecha_adquisicion) con constraint unique(usuario_id, libro_id)
> - `perfiles` (id uuid → auth.users, nombre_completo, is_admin boolean)
>
> Políticas RLS:
> - Lectura pública en generos, autores, libros, libro_autores, libro_generos, contenido_libros
> - Cada usuario solo ve sus propios pedidos y biblioteca
> - Admins (is_admin = true en perfiles) pueden hacer CRUD en libros, autores, géneros y contenido
> - La tabla perfiles debe tener RLS deshabilitado para evitar recursión infinita
>
> Trigger: al registrarse un usuario en auth.users, crear automáticamente su fila en perfiles con nombre_completo tomado de raw_user_meta_data.
>
> Buckets de Supabase Storage (todos públicos): `autores`, `portadas`, `paginas`, `audios`
>
> ---
>
> **ESTRUCTURA DE ARCHIVOS FLUTTER:**
> ```
> lib/
> ├── core/
> │   ├── supabase_config.dart   ← URL, anonKey, serviceKey, cliente admin
> │   └── auth_guard.dart        ← verifica is_admin en tabla perfiles
> ├── models/
> │   ├── libro.dart, autor.dart, genero.dart, contenido_libro.dart
> │   ├── pedido.dart, carrito_item.dart, usuario.dart
> ├── providers/
> │   └── carrito_provider.dart  ← ChangeNotifier con subtotal, IVA 16%, total
> └── screens/
>     ├── auth/         → login_screen.dart, registro_screen.dart
>     ├── bookstore/    → bookstore_screen.dart, libro_detalle_screen.dart
>     ├── biblioteca/   → mis_libros_screen.dart, leer_libro_screen.dart, audio_player_screen.dart
>     ├── carrito/      → carrito_screen.dart, confirmar_carrito_screen.dart
>     ├── cuenta/       → cuenta_screen.dart, pedidos_screen.dart, factura_screen.dart
>     ├── home/         → home_screen.dart (navbar inferior con 3 tabs)
>     └── dashboard/    → dashboard_screen.dart, dash_libros_screen.dart,
>                          dash_form_libro_screen.dart, dash_contenido_screen.dart,
>                          dash_autores_screen.dart, dash_form_autor_screen.dart,
>                          dash_generos_screen.dart, dash_usuarios_screen.dart,
>                          dash_form_usuario_screen.dart, dash_pedidos_screen.dart
> ```
>
> ---
>
> **FUNCIONALIDADES POR FASE:**
>
> **Fase 1 — Autenticación:**
> Login con email/contraseña usando `supabase.auth.signInWithPassword`. Registro guardando `nombre_completo` en userMetadata. Detección automática de sesión en main.dart con `supabase.auth.currentSession`.
>
> **Fase 2 — Catálogo:**
> Grid de libros cargados desde Supabase con búsqueda por título/autor y filtros por género usando FilterChips. Pantalla de detalle con portada, precio, descripción, autores y géneros. Verificación al entrar al detalle: si el usuario ya compró el libro (consulta biblioteca_usuarios), mostrar badge verde "Ya obtenido", precio "✓ Tuyo" y botón verde "Ir a mi Biblioteca". Si no lo ha comprado, mostrar botón "Agregar al carrito".
>
> **Fase 3 — Carrito y Compras:**
> CarritoProvider con ChangeNotifier. Carrito con lista de libros, subtotal, IVA 16% y total. Pantalla de confirmación que inserta en pedidos, detalle_pedidos y biblioteca_usuarios usando upsert para evitar duplicados. Badge rojo con cantidad en el ícono del carrito en el AppBar.
>
> **Fase 4 — Biblioteca y Lector:**
> Mis Libros con TabBar (Ebooks / Audiobooks) filtrando por formato. Lector de ebooks con photo_view mostrando imágenes de contenido_libros ordenadas por campo orden, con slider de páginas y botones anterior/siguiente. Reproductor de audiobooks con just_audio con play/pause, slider de progreso, tiempo actual/total y botones de +10s/-10s.
>
> **Fase 5 — Cuenta y Facturas:**
> Perfil con avatar inicial, nombre, email y estadísticas (total libros y pedidos). Historial de pedidos con Cards expandibles mostrando libros comprados. Generación y descarga de factura PDF por pedido usando los paquetes `pdf` y `printing`, con datos del cliente, tabla de productos, subtotal, IVA 16% y total.
>
> **Fase 6 — Dashboard Admin:**
> Solo visible para usuarios con is_admin = true (verificado con auth_guard.dart). Ícono de dashboard en AppBar solo para admins. CRUD completo para:
> - **Libros:** crear/editar con subida de portada (dart:html), selección múltiple de autores y géneros con FilterChips, dropdown de formato (ebook/audiobook/físico) y estado (disponible/próximamente). Botón "Gestionar Páginas" o "Gestionar Audio" en cada libro de la lista.
> - **Contenido del libro:** pantalla dash_contenido_screen con lista reordenable (ReorderableListView con drag & drop), subida de imágenes o audio según el formato del libro, campo de orden numérico. Al reordenar actualiza el campo orden en BD.
> - **Autores:** CRUD con subida de foto circular usando dart:html.
> - **Géneros:** CRUD simple con BottomSheet.
> - **Usuarios:** listar todos los perfiles, editar nombre e is_admin, crear nuevos usuarios con `supabaseAdmin.auth.admin.createUser` usando la service role key.
> - **Pedidos:** lista expandible de todos los pedidos con estado (completado/pendiente) y detalle de libros.
>
> ---
>
> **PAQUETES requeridos en pubspec.yaml:**
> ```yaml
> supabase_flutter: ^2.3.0
> provider: ^6.1.0
> cached_network_image: ^3.3.1
> just_audio: ^0.9.36
> photo_view: ^0.14.0
> pdf: ^3.10.8
> printing: ^5.12.0
> intl: ^0.19.0
> ```
>
> ---
>
> **REGLAS IMPORTANTES que debes seguir en todo momento:**
> 1. Para subir archivos en Flutter Web usar siempre `dart:html` (FileUploadInputElement + FileReader). Nunca usar `image_picker` ni `file_picker`.
> 2. En `supabase_config.dart` definir dos clientes: `supabase` (anon key, respeta RLS) y `supabaseAdmin` (service role key, para crear usuarios desde el dashboard).
> 3. La tabla `perfiles` debe tener RLS deshabilitado para evitar recursión infinita en las políticas.
> 4. Cada modelo Dart debe tener un constructor `factory fromMap(Map<String, dynamic> map)`.
> 5. El carrito vive en memoria (Provider), no en base de datos.
> 6. Al confirmar compra usar `upsert` en biblioteca_usuarios con `onConflict: 'usuario_id,libro_id'` para evitar duplicados.
> 7. Dar el código fase por fase, esperando confirmación antes de pasar a la siguiente.
> 8. Para cada fase indicar: archivos a CREAR, archivos a MODIFICAR, SQL a ejecutar si aplica y comandos flutter.

---

