# 📘 Plan de Implementación: Librería Cristiana Digital (Flutter + Firebase)

> ⚠️ **Nota preliminar:** No se incluye código en este documento. Este plan está diseñado para servir como hoja de ruta técnica y de producto. Cuando lo apruebes o requieras ajustes, procederé a generar el código correspondiente por fases.

---

## 🛠 1. Herramientas y Entorno de Desarrollo
| Herramienta | Propósito |
|-------------|-----------|
| **Flutter SDK + Dart** | Framework y lenguaje base |
| **VS Code** | IDE principal (recomendado por ligereza y extensiones) |
| **Android Studio** | Gestión de SDKs, emuladores y herramientas nativas (opcional pero recomendado) |
| **Extensiones VS Code** | Flutter, Dart, Firebase, Error Lens, GitLens, Pretty Diff |
| **Firebase CLI + Console** | Configuración de proyectos, reglas, hosting y emuladores |
| **Figma / Penpot** | Diseño UI/UX, prototipado interactivo y design tokens |
| **Git + GitHub/GitLab** | Control de versiones y colaboración |
| **Postman / Insomnia** | Pruebas de reglas de seguridad y flujos de datos (opcional) |

📌 *Aclaración:* "Antigravity" no es un IDE reconocido para Flutter. Se recomienda VS Code o Android Studio como entornos estándar compatibles con el ecosistema oficial.

---

## 🏗 2. Arquitectura y Estructura del Proyecto
Se adoptará una arquitectura **Feature-First + Clean Architecture simplificada** para escalabilidad y mantenimiento.

```
lib/
├── main.dart
├── core/
│   ├── constants/        # Colores, textos, rutas, keys
│   ├── utils/            # Validadores, formateadores, helpers
│   ├── theme/            # ThemeData, tipografía, dark/light mode
│   └── services/         # Firebase init, logger, analytics
├── providers/            # ChangeNotifiers (Auth, Books, UI, Cart)
├── features/
│   ├── auth/             # Login, Register, Reset, EmailVerification
│   ├── library/          # Catálogo, búsqueda, filtros, categorías
│   ├── book_detail/      # Vista de libro, lectura/descarga, reseñas
│   └── profile/          # Favoritos, historial, configuración, logout
├── widgets/              # Componentes reutilizables (botones, cards, loaders)
├── models/               # DTOs y entidades mapeadas a Firestore
└── routes/               # Navegación declarativa (GoRouter o similar)
```

---

## 🎨 3. Diseño UI/UX
### 🎯 Principios
- **Claridad y serenidad:** Paleta inspirada en tonos cálidos/neutros, alto contraste para lectura prolongada.
- **Accesibilidad:** Soporte para escalado de texto, modo oscuro, navegación por teclado/lector de pantalla.
- **Consistencia:** Design system con tokens reutilizables (spacing, radii, elevation, typography scale).
- **Flujo intuitivo:** Onboarding → Auth → Exploración → Detalle → Guardar/Descargar → Perfil.

### 🖼 Pantallas Clave
1. **Splash & Onboarding** (propósito de la app, términos, permisos)
2. **Autenticación** (Login, Registro, Recuperación, Verificación)
3. **Home/Catálogo** (Libros destacados, categorías, búsqueda global)
4. **Detalle de Libro** (Portada, sinopsis, autor, formato disponible, botón de acción)
5. **Biblioteca Personal** (Favoritos, descargados, historial de lectura)
6. **Perfil & Configuración** (Cuenta, preferencias de lectura, cierre de sesión)

### 🛠 Herramientas de Diseño
- Figma para wireframes → mockups → prototipo clickeable
- Exportación de assets optimizados (SVG/PNG, WebP para portadas)
- Validación de contraste WCAG AA

---

## 📦 4. Gestión de Dependencias (`pubspec.yaml`)
Se gestionarán mediante `flutter pub add`. Categorías conceptuales:

| Categoría | Paquetes sugeridos (sin versiones) |
|-----------|-----------------------------------|
| **Núcleo** | `provider`, `flutter`, `firebase_core` |
| **Autenticación** | `firebase_auth` |
| **Base de datos** | `cloud_firestore` |
| **Almacenamiento** | `firebase_storage` (si se gestionan PDFs/EPUBs) |
| **UI/UX** | `cached_network_image`, `shimmer`, `flutter_svg`, `google_fonts`, `intl` |
| **Navegación** | `go_router` o `auto_route` |
| **Seguridad/Config** | `flutter_secure_storage`, `envied` o `flutter_dotenv` |
| **Utilidades** | `uuid`, `logger`, `url_launcher`, `share_plus` |
| **Dev/Testing** | `flutter_lints`, `mocktail`, `flutter_test` |

🔒 *Nota:* Todas las versiones se fijarán en `pubspec.lock` y se actualizarán periódicamente con `flutter pub upgrade --major-versions`.

---

## 🔐 5. Autenticación (Email & Password)
### 🔹 Flujos
- Registro con validación de contraseña (mínimo 8 chars, mayúscula, número, símbolo)
- Verificación de correo electrónico obligatoria para activar cuenta
- Inicio de sesión con manejo de estados (loading, error, éxito)
- Recuperación de contraseña vía email
- Cierre de sesión seguro + limpieza de estado local

### 🔹 Seguridad
- Uso de `firebase_auth` con listeners de estado
- Validación de formularios antes de enviar a Firebase
- Manejo de excepciones específicas (email-already-in-use, weak-password, user-not-found)
- Sesiones persistentes pero con opción de revocación manual
- Opcional futuro: reCAPTCHA o autenticación por SMS si se escala

---

## 🗄 6. Base de Datos (Cloud Firestore)
### 🔹 Estructura de Colecciones
| Colección | Propósito | Campos clave |
|-----------|-----------|--------------|
| `users` | Perfiles y preferencias | `uid`, `displayName`, `email`, `role`, `favorites`, `downloadHistory`, `createdAt` |
| `books` | Catálogo público | `id`, `title`, `author`, `category`, `description`, `coverUrl`, `pdfUrl`, `isFree`, `rating`, `publishedAt` |
| `categories` | Filtros y navegación | `id`, `name`, `icon`, `order` |
| `reviews` | Comentarios moderados | `id`, `bookId`, `userId`, `text`, `rating`, `createdAt`, `status` |
| `admins` | Gestión de contenido | `uid`, `email`, `permissions` |

### 🔹 Reglas de Seguridad
- Lectura de `books` y `categories`: pública
- Escritura en `users`: solo el propio `uid`
- Modificación de `books`/`reviews`: solo usuarios con rol `admin` o verificados
- Validación de tipos y longitud de campos
- Índices compuestos para búsqueda por categoría + fecha + popularidad

### 🔹 Características Nativas
- Cache offline automático
- Sincronización en segundo plano
- Paginación con `limit()` + `startAfter()`

---

## 🔄 7. Gestión de Estado (Provider)
### 🔹 Proveedores Principales
- `AuthProvider`: estado de autenticación, validación de correo, perfil básico
- `LibraryProvider`: carga de libros, filtros, búsqueda, paginación
- `BookDetailProvider`: metadatos extendidos, estado de descarga/lectura, reseñas
- `UserPreferencesProvider`: tema, idioma, notificaciones, favoritos
- `UIProvider`: loaders globales, snackbars, diálogos de confirmación

### 🔹 Buenas Prácticas
- Uso de `ChangeNotifier` + `Provider.of` o `Consumer`
- Separación clara entre estado UI y estado de negocio
- Evitar `setState` para lógica compleja
- Manejo explícito de estados: `idle`, `loading`, `success`, `error`
- Inicialización asíncrona controlada en `main()` antes de `runApp()`

---

## 🧭 8. Fases de Desarrollo (Paso a Paso)

### 🟢 Fase 1: Configuración Inicial
1. Instalar Flutter, Dart y configurar PATH
2. Crear proyecto en VS Code (`flutter create libreria_cristiana_digital`)
3. Configurar Firebase Console (proyecto, apps iOS/Android/Web, descargar configs)
4. Instalar Firebase CLI y vincular proyecto (`firebase init`)
5. Configurar `.gitignore` y estructura de carpetas

### 🟡 Fase 2: UI/UX y Componentes Base
1. Definir paleta, tipografía y tokens en Figma
2. Implementar `ThemeData` (claro/oscuro) y `GoogleFonts`
3. Crear widgets reutilizables: botones, cards, loaders, empty states
4. Montar navegación base (shell, bottom nav, rutas protegidas)

### 🟠 Fase 3: Sistema de Autenticación
1. Configurar `firebase_auth` y `firebase_core`
2. Implementar formularios de login/registro con validación
3. Conectar flujos a Firebase y manejar excepciones
4. Añadir verificación de email y recuperación de contraseña
5. Crear `AuthProvider` y proteger rutas no autenticadas

### 🔵 Fase 4: Integración con Firestore
1. Definir modelos de datos y mapeo JSON ↔ Dart
2. Crear servicios de lectura/escritura para `books`, `categories`, `users`
3. Implementar paginación y búsqueda básica
4. Configurar reglas de seguridad en Firebase Console
5. Probar con emuladores de Firebase

### 🟣 Fase 5: Estado y Lógica de Negocio
1. Implementar `LibraryProvider` y `BookDetailProvider`
2. Conectar proveedores a vistas con `Consumer`/`Provider`
3. Manejar estados de carga, error y vacío
4. Implementar favoritos y historial local + sincronización

### 🟤 Fase 6: Funcionalidades Core
1. Vista de detalle de libro con portada, sinopsis y acciones
2. Sistema de categorías y filtros combinados
3. Integración de visualización/descarga de contenido (PDF/EPUB)
4. Perfil de usuario con gestión de cuenta y preferencias

### ⚫ Fase 7: Pruebas y Optimización
1. Pruebas unitarias (servicios, modelos, validadores)
2. Pruebas de widget (UI components, states)
3. Pruebas de integración (flujos completos auth → library)
4. Optimización de rendimiento (lazy loading, cache, reduce rebuilds)
5. Auditoría de accesibilidad y rendimiento con DevTools

### 🌐 Fase 8: Despliegue y Monitoreo
1. Configurar Firebase Crashlytics y Analytics
2. Preparar builds firmados (Android App Bundle, iOS Archive)
3. Subir a Play Console y App Store Connect
4. Configurar CI/CD (GitHub Actions o Codemagic)
5. Plan de lanzamiento por etapas y recolección de feedback

---

## 🔒 9. Seguridad, Cumplimiento y Mantenimiento
- **Privacidad:** Política de datos clara, cumplimiento GDPR/CCPA, minimización de datos
- **Contenido:** Moderación de reseñas, validación de metadatos, derechos de autor verificados
- **Backup:** Exportación periódica de Firestore, versionado de reglas de seguridad
- **Actualizaciones:** Changelog público, notificaciones de nuevas versiones, soporte LTS de Flutter
- **Escalabilidad:** Preparar estructura para pagos, suscripciones, lecturas offline con DRM, y roles multi-nivel

---

## ✅ Próximos Pasos
1. ¿Deseas que ajuste algún apartado (arquitectura, dependencias, flujos de auth, estructura de Firestore)?
2. ¿Prefieres comenzar con la **Fase 1 (Configuración)** o quieres que genere el esqueleto de carpetas y `pubspec.yaml` conceptual antes de pasar a código?
3. Indica si la app incluirá contenido gratuito, de pago o mixto, para adaptar las reglas de Firestore y los flujos de usuario.

Cuando lo apruebes, generaré el código por fases, comenzando por la configuración y autenticación, manteniendo el enfoque modular y listo para producción.
