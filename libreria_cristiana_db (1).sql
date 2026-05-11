-- =============================================================
--  LIBRERÍA CRISTIANA DIGITAL — Script de creación de BD
--  Motor: PostgreSQL 14+
--  Generado como parte del diseño de base de datos
-- =============================================================

-- Extensión para generación de UUIDs
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================
--  DOMINIO: USUARIOS
-- =============================================================

CREATE TABLE plan (
    id                   UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre               VARCHAR(80)   NOT NULL UNIQUE,
    precio_mensual       DECIMAL(10,2) NOT NULL,
    precio_anual         DECIMAL(10,2),
    libros_descarga      SMALLINT      NOT NULL DEFAULT 0,  -- -1 = ilimitado
    acceso_audiolibros   BOOLEAN       NOT NULL DEFAULT FALSE,
    acceso_devocionales  BOOLEAN       NOT NULL DEFAULT FALSE,
    max_dispositivos     SMALLINT      NOT NULL DEFAULT 1,
    activo               BOOLEAN       NOT NULL DEFAULT TRUE
);

CREATE TABLE usuario (
    id            UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre        VARCHAR(100)  NOT NULL,
    email         VARCHAR(150)  NOT NULL UNIQUE,
    password_hash VARCHAR(255)  NOT NULL,
    rol           VARCHAR(20)   NOT NULL DEFAULT 'usuario'
                                CHECK (rol IN ('admin', 'editor', 'usuario')),
    activo        BOOLEAN       NOT NULL DEFAULT TRUE,
    avatar_url    TEXT,
    created_at    TIMESTAMP     NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP     NOT NULL DEFAULT NOW()
);

CREATE TABLE suscripcion (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id      UUID        NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
    plan_id         UUID        NOT NULL REFERENCES plan(id),
    fecha_inicio    DATE        NOT NULL,
    fecha_fin       DATE        NOT NULL,
    estado          VARCHAR(20) NOT NULL DEFAULT 'activa'
                                CHECK (estado IN ('activa', 'vencida', 'cancelada')),
    renovacion_auto BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP   NOT NULL DEFAULT NOW()
);

CREATE TABLE dispositivo (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id    UUID        NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
    nombre        VARCHAR(100) NOT NULL,
    tipo          VARCHAR(20) NOT NULL CHECK (tipo IN ('ios', 'android', 'web')),
    token_push    TEXT        UNIQUE,
    ultimo_acceso TIMESTAMP,
    activo        BOOLEAN     NOT NULL DEFAULT TRUE
);

-- =============================================================
--  DOMINIO: CATÁLOGO
-- =============================================================

CREATE TABLE editorial (
    id        UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre    VARCHAR(150) NOT NULL UNIQUE,
    pais      VARCHAR(80),
    sitio_web VARCHAR(255),
    logo_url  TEXT
);

CREATE TABLE autor (
    id           UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre       VARCHAR(150) NOT NULL,
    biografia    TEXT,
    nacionalidad VARCHAR(80),
    foto_url     TEXT
);

CREATE TABLE categoria (
    id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    padre_id    UUID         REFERENCES categoria(id) ON DELETE SET NULL,
    nombre      VARCHAR(100) NOT NULL,
    slug        VARCHAR(120) NOT NULL UNIQUE,
    descripcion TEXT,
    icono       VARCHAR(80)
);

CREATE TABLE libro (
    id               UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    titulo           VARCHAR(255)  NOT NULL,
    subtitulo        VARCHAR(255),
    isbn             VARCHAR(20)   UNIQUE,
    editorial_id     UUID          REFERENCES editorial(id) ON DELETE SET NULL,
    sinopsis         TEXT,
    portada_url      TEXT,
    idioma           CHAR(2)       NOT NULL DEFAULT 'es',
    num_paginas      SMALLINT,
    anio_publicacion SMALLINT,
    precio           DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    disponible       BOOLEAN       NOT NULL DEFAULT TRUE,
    es_gratuito      BOOLEAN       NOT NULL DEFAULT FALSE,
    created_at       TIMESTAMP     NOT NULL DEFAULT NOW()
);

CREATE TABLE libro_autor (
    libro_id UUID       NOT NULL REFERENCES libro(id) ON DELETE CASCADE,
    autor_id UUID       NOT NULL REFERENCES autor(id) ON DELETE CASCADE,
    rol      VARCHAR(30) NOT NULL DEFAULT 'principal'
                         CHECK (rol IN ('principal', 'coautor', 'traductor', 'prologuista')),
    orden    SMALLINT   NOT NULL DEFAULT 1,
    PRIMARY KEY (libro_id, autor_id)
);

CREATE TABLE libro_categoria (
    libro_id    UUID NOT NULL REFERENCES libro(id) ON DELETE CASCADE,
    categoria_id UUID NOT NULL REFERENCES categoria(id) ON DELETE CASCADE,
    PRIMARY KEY (libro_id, categoria_id)
);

CREATE TABLE formato (
    id           UUID       PRIMARY KEY DEFAULT gen_random_uuid(),
    libro_id     UUID       NOT NULL REFERENCES libro(id) ON DELETE CASCADE,
    tipo         VARCHAR(10) NOT NULL CHECK (tipo IN ('epub', 'pdf', 'mp3', 'm4b')),
    url_archivo  TEXT       NOT NULL,
    tamano_mb    SMALLINT,
    duracion_min SMALLINT,  -- solo para audiolibros
    version      VARCHAR(20)
);

-- =============================================================
--  DOMINIO: COMERCIO
-- =============================================================

CREATE TABLE descuento (
    id             UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo         VARCHAR(50)   NOT NULL UNIQUE,
    tipo           VARCHAR(20)   NOT NULL CHECK (tipo IN ('porcentaje', 'monto_fijo')),
    valor          DECIMAL(10,2) NOT NULL,
    usos_maximos   SMALLINT,
    usos_actuales  SMALLINT      NOT NULL DEFAULT 0,
    fecha_inicio   DATE,
    fecha_fin      DATE,
    activo         BOOLEAN       NOT NULL DEFAULT TRUE
);

CREATE TABLE orden (
    id               UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id       UUID          NOT NULL REFERENCES usuario(id),
    descuento_id     UUID          REFERENCES descuento(id) ON DELETE SET NULL,
    subtotal         DECIMAL(10,2) NOT NULL,
    descuento_monto  DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total            DECIMAL(10,2) NOT NULL,
    estado           VARCHAR(20)   NOT NULL DEFAULT 'pendiente'
                                   CHECK (estado IN ('pendiente', 'pagada', 'cancelada', 'reembolsada')),
    created_at       TIMESTAMP     NOT NULL DEFAULT NOW()
);

CREATE TABLE detalle_orden (
    id              UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    orden_id        UUID          NOT NULL REFERENCES orden(id) ON DELETE CASCADE,
    libro_id        UUID          NOT NULL REFERENCES libro(id),
    precio_unitario DECIMAL(10,2) NOT NULL,
    formato_tipo    VARCHAR(10)   CHECK (formato_tipo IN ('epub', 'pdf', 'mp3', 'm4b'))
);

CREATE TABLE pago (
    id          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    orden_id    UUID          NOT NULL REFERENCES orden(id),
    metodo      VARCHAR(30)   NOT NULL CHECK (metodo IN ('tarjeta', 'paypal', 'oxxo', 'transferencia')),
    referencia  VARCHAR(255)  UNIQUE,
    monto       DECIMAL(10,2) NOT NULL,
    moneda      CHAR(3)       NOT NULL DEFAULT 'USD',
    estado      VARCHAR(20)   NOT NULL CHECK (estado IN ('aprobado', 'rechazado', 'reembolsado')),
    fecha       TIMESTAMP     NOT NULL DEFAULT NOW()
);

-- =============================================================
--  DOMINIO: BIBLIOTECA PERSONAL
-- =============================================================

CREATE TABLE biblioteca_usuario (
    id                 UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id         UUID        NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
    libro_id           UUID        NOT NULL REFERENCES libro(id),
    origen             VARCHAR(20) NOT NULL DEFAULT 'compra'
                                   CHECK (origen IN ('compra', 'suscripcion', 'regalo', 'gratuito')),
    fecha_adquisicion  TIMESTAMP   NOT NULL DEFAULT NOW(),
    permitir_offline   BOOLEAN     NOT NULL DEFAULT FALSE,
    UNIQUE (usuario_id, libro_id)
);

CREATE TABLE progreso_lectura (
    id                 UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
    biblioteca_id      UUID      NOT NULL REFERENCES biblioteca_usuario(id) ON DELETE CASCADE,
    dispositivo_id     UUID      REFERENCES dispositivo(id) ON DELETE SET NULL,
    pagina_actual      INT       NOT NULL DEFAULT 0,
    porcentaje         FLOAT     NOT NULL DEFAULT 0.0 CHECK (porcentaje BETWEEN 0 AND 1),
    tiempo_lectura_min INT       NOT NULL DEFAULT 0,
    actualizado_en     TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (biblioteca_id, dispositivo_id)
);

CREATE TABLE anotacion (
    id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    biblioteca_id    UUID        NOT NULL REFERENCES biblioteca_usuario(id) ON DELETE CASCADE,
    tipo             VARCHAR(20) NOT NULL DEFAULT 'nota'
                                 CHECK (tipo IN ('marcador', 'subrayado', 'nota')),
    pagina           INT         NOT NULL,
    posicion_inicio  INT,
    posicion_fin     INT,
    contenido        TEXT,
    color            VARCHAR(20) DEFAULT '#FFFF00',
    created_at       TIMESTAMP   NOT NULL DEFAULT NOW()
);

CREATE TABLE resena (
    id           UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id   UUID      NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
    libro_id     UUID      NOT NULL REFERENCES libro(id) ON DELETE CASCADE,
    calificacion SMALLINT  NOT NULL CHECK (calificacion BETWEEN 1 AND 5),
    comentario   TEXT,
    visible      BOOLEAN   NOT NULL DEFAULT FALSE,
    created_at   TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (usuario_id, libro_id)
);

-- =============================================================
--  DOMINIO: CONTENIDO (DEVOCIONALES)
-- =============================================================

CREATE TABLE serie_devocional (
    id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    titulo      VARCHAR(200) NOT NULL,
    descripcion TEXT,
    total_dias  SMALLINT     NOT NULL,
    portada_url TEXT,
    activa      BOOLEAN      NOT NULL DEFAULT TRUE
);

CREATE TABLE devocional (
    id                UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    serie_id          UUID         NOT NULL REFERENCES serie_devocional(id) ON DELETE CASCADE,
    dia_numero        SMALLINT     NOT NULL,
    titulo            VARCHAR(200) NOT NULL,
    versiculo_ref     VARCHAR(100),
    contenido         TEXT         NOT NULL,
    oracion           TEXT,
    fecha_publicacion DATE,
    es_premium        BOOLEAN      NOT NULL DEFAULT FALSE,
    UNIQUE (serie_id, dia_numero)
);

-- =============================================================
--  ÍNDICES RECOMENDADOS
-- =============================================================

-- Usuario
CREATE INDEX idx_usuario_email          ON usuario(email);
CREATE INDEX idx_suscripcion_usuario    ON suscripcion(usuario_id);
CREATE INDEX idx_suscripcion_estado     ON suscripcion(estado);
CREATE INDEX idx_dispositivo_usuario    ON dispositivo(usuario_id);

-- Catálogo
CREATE INDEX idx_libro_editorial        ON libro(editorial_id);
CREATE INDEX idx_libro_disponible       ON libro(disponible);
CREATE INDEX idx_libro_idioma           ON libro(idioma);
CREATE INDEX idx_formato_libro          ON formato(libro_id);
CREATE INDEX idx_categoria_padre        ON categoria(padre_id);

-- Comercio
CREATE INDEX idx_orden_usuario          ON orden(usuario_id);
CREATE INDEX idx_orden_estado           ON orden(estado);
CREATE INDEX idx_detalle_orden_orden    ON detalle_orden(orden_id);
CREATE INDEX idx_detalle_orden_libro    ON detalle_orden(libro_id);
CREATE INDEX idx_pago_orden             ON pago(orden_id);

-- Biblioteca
CREATE INDEX idx_biblioteca_usuario     ON biblioteca_usuario(usuario_id);
CREATE INDEX idx_biblioteca_libro       ON biblioteca_usuario(libro_id);
CREATE INDEX idx_progreso_biblioteca    ON progreso_lectura(biblioteca_id);
CREATE INDEX idx_anotacion_biblioteca   ON anotacion(biblioteca_id);
CREATE INDEX idx_resena_libro           ON resena(libro_id);
CREATE INDEX idx_resena_visible         ON resena(visible);

-- Devocionales
CREATE INDEX idx_devocional_serie       ON devocional(serie_id);
CREATE INDEX idx_devocional_publicacion ON devocional(fecha_publicacion);

-- =============================================================
--  DATOS SEMILLA (SEED)
-- =============================================================

-- Planes
INSERT INTO plan (nombre, precio_mensual, precio_anual, libros_descarga, acceso_audiolibros, acceso_devocionales, max_dispositivos) VALUES
    ('Gratuito',    0.00,   0.00,   0,  FALSE, FALSE, 1),
    ('Básico',      4.99,  49.99,   5,  FALSE, TRUE,  2),
    ('Premium',     9.99,  99.99,  -1,  TRUE,  TRUE,  5),
    ('Ministerial', 19.99, 199.99, -1,  TRUE,  TRUE,  10);

-- Categorías raíz
INSERT INTO categoria (nombre, slug, descripcion) VALUES
    ('Biblia y comentarios', 'biblia-comentarios',   'Estudio bíblico y comentarios exegéticos'),
    ('Teología',             'teologia',              'Doctrina cristiana y teología sistemática'),
    ('Devocional',           'devocional',            'Libros de crecimiento espiritual personal'),
    ('Predicación',          'predicacion',           'Recursos para predicadores y pastores'),
    ('Música cristiana',     'musica-cristiana',      'Himnarios, cancioneros y partituras'),
    ('Niños y jóvenes',      'ninos-jovenes',         'Literatura cristiana infantil y juvenil'),
    ('Consejería',           'consejeria',            'Orientación familiar y pastoral');

-- Subcategorías de Teología
INSERT INTO categoria (padre_id, nombre, slug) VALUES
    ((SELECT id FROM categoria WHERE slug = 'teologia'), 'Soteriología',  'soteriologia'),
    ((SELECT id FROM categoria WHERE slug = 'teologia'), 'Escatología',   'escatologia'),
    ((SELECT id FROM categoria WHERE slug = 'teologia'), 'Eclesiología',  'eclesiologia'),
    ((SELECT id FROM categoria WHERE slug = 'teologia'), 'Cristología',   'cristologia');

-- Usuario administrador de prueba (password: Admin1234!)
INSERT INTO usuario (nombre, email, password_hash, rol) VALUES
    ('Administrador', 'admin@libreriacristiana.com',
     '$2a$10$examplehashfordemopurposesonly123456789012345678', 'admin');
