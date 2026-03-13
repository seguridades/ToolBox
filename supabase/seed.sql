-- ============================================================
-- Toolbox de seguridades.org — Datos de ejemplo (seed)
-- Ejecutar DESPUÉS de schema.sql
-- Supabase > SQL Editor
-- ============================================================

-- -------------------------------------------------------
-- RECURSOS
-- -------------------------------------------------------

insert into resources (title, description, verdict, type, scope, category, tags, platforms, is_opensource, pricing, is_reviewed, show_review, has_audit, show_audit, official_url, repo_url) values

-- HERRAMIENTAS DIGITALES

(
  'Signal',
  'Aplicación de mensajería cifrada de extremo a extremo para mensajes, llamadas y videollamadas. Considerada el estándar de oro para comunicaciones privadas.',
  'Recomendada sin reservas para comunicaciones sensibles. Protocolo abierto, auditoría independiente, sin publicidad ni recolección de metadatos. Primera opción para periodistas y activistas.',
  'tool',
  array['digital']::resource_scope[],
  'Comunicación Segura',
  array['Mensajería', 'CifradoE2E', 'Llamadas', 'Periodismo'],
  array['android', 'ios', 'windows', 'linux', 'mac']::resource_platform[],
  true,
  'gratis',
  true, true, true, true,
  'https://signal.org',
  'https://github.com/signalapp'
),

(
  'KeePassXC',
  'Gestor de contraseñas local y de código abierto. Las contraseñas se guardan en un archivo cifrado en tu dispositivo, sin sincronización en la nube.',
  'Opción sólida para quienes prefieren no depender de servicios en la nube. Al ser local, el riesgo de exposición masiva es menor. Requiere disciplina para hacer respaldos del archivo de base de datos.',
  'tool',
  array['digital']::resource_scope[],
  'Gestión de Contraseñas',
  array['Contraseñas', 'CódigoAbierto', 'Local', 'SinNube'],
  array['windows', 'linux', 'mac']::resource_platform[],
  true,
  'gratis',
  true, true, false, false,
  'https://keepassxc.org',
  'https://github.com/keepassxreboot/keepassxc'
),

(
  'Bitwarden',
  'Gestor de contraseñas en la nube con opción de autoalojamiento. Código abierto, multiplataforma y con plan gratuito completo.',
  'Buena alternativa para equipos o personas que necesitan sincronización entre dispositivos. La opción de autoalojamiento la hace viable para organizaciones con mayor capacidad técnica.',
  'tool',
  array['digital']::resource_scope[],
  'Gestión de Contraseñas',
  array['Contraseñas', 'CódigoAbierto', 'Nube', 'Equipos'],
  array['web', 'android', 'ios', 'windows', 'linux', 'mac']::resource_platform[],
  true,
  'freemium',
  true, true, true, true,
  'https://bitwarden.com',
  'https://github.com/bitwarden'
),

(
  'Tor Browser',
  'Navegador basado en Firefox que enruta el tráfico a través de la red Tor para anonimizar la navegación y evadir censura y vigilancia.',
  'Herramienta esencial para contextos de vigilancia activa o censura. No recomendamos usarla como navegador principal para todo, sino de forma estratégica para tareas específicas de alto riesgo.',
  'tool',
  array['digital']::resource_scope[],
  'Anonimato y Navegación',
  array['Anonimato', 'Censura', 'Navegación', 'Tor'],
  array['windows', 'linux', 'mac', 'android']::resource_platform[],
  true,
  'gratis',
  true, true, false, false,
  'https://www.torproject.org',
  'https://gitlab.torproject.org/tpo/applications/tor-browser'
),

(
  'VeraCrypt',
  'Herramienta de cifrado de discos y particiones. Permite crear contenedores cifrados y cifrar dispositivos completos, incluyendo el disco del sistema.',
  'Indispensable para proteger datos en dispositivos que pueden ser decomisados o robados. El cifrado de disco completo es práctica básica para periodistas y activistas en contextos de riesgo.',
  'tool',
  array['digital']::resource_scope[],
  'Cifrado de Archivos y Dispositivos',
  array['Cifrado', 'Disco', 'CódigoAbierto', 'Decomiso'],
  array['windows', 'linux', 'mac']::resource_platform[],
  true,
  'gratis',
  true, true, false, false,
  'https://veracrypt.fr',
  'https://github.com/veracrypt/VeraCrypt'
),

(
  'Aegis Authenticator',
  'Aplicación de autenticación de dos factores (2FA) para Android. Código abierto, con respaldo cifrado de los tokens.',
  'La mejor opción de 2FA para Android en contextos de seguridad. A diferencia de Google Authenticator, permite exportar y cifrar los tokens. Solo para Android; en iOS recomendamos Raivo.',
  'tool',
  array['digital']::resource_scope[],
  'Autenticación',
  array['2FA', 'TOTP', 'Android', 'CódigoAbierto'],
  array['android']::resource_platform[],
  true,
  'gratis',
  true, true, false, false,
  'https://getaegis.app',
  'https://github.com/beemdevelopment/Aegis'
),

(
  'ProtonMail',
  'Servicio de correo electrónico con cifrado de extremo a extremo entre usuarios de Proton. Basado en Suiza, sujeto a leyes de privacidad europeas.',
  'Buena opción para correo seguro, especialmente para comunicación entre personas que también usan Proton. Para comunicaciones de máxima sensibilidad, preferimos Signal. El plan gratuito es funcional.',
  'tool',
  array['digital']::resource_scope[],
  'Comunicación Segura',
  array['Email', 'Cifrado', 'Privacidad', 'Suiza'],
  array['web', 'android', 'ios']::resource_platform[],
  false,
  'freemium',
  true, true, false, false,
  'https://proton.me/mail',
  null
),

-- GUÍAS

(
  'Guía de seguridad digital para periodistas — EFF',
  'Surveillance Self-Defense (SSD) de la Electronic Frontier Foundation. Guía completa y actualizada sobre herramientas y prácticas de seguridad digital para diferentes perfiles de riesgo.',
  'Referencia fundamental del campo. Bien estructurada por niveles de riesgo y escenarios. Recomendamos empezar por los "escenarios" según el perfil del taller antes de entrar a herramientas específicas.',
  'guide',
  array['digital']::resource_scope[],
  'Formación y Metodología',
  array['EFF', 'Periodismo', 'Referencia', 'ModeloDeAmenaza'],
  null,
  true,
  'gratis',
  true, true, false, false,
  'https://ssd.eff.org/es',
  null
),

(
  'Manual de cobertura en situaciones de riesgo — Art19',
  'Guía práctica para periodistas que cubren protestas, operativos y situaciones de conflicto. Incluye protocolos de comunicación, documentación de incidentes y medidas de protección física.',
  'Muy recomendado para talleres con periodistas en campo. Aborda tanto la dimensión digital como la física, lo que lo hace útil para discutir seguridad integral.',
  'guide',
  array['física', 'mixta']::resource_scope[],
  'Cobertura en Campo',
  array['Periodismo', 'Protestas', 'CoberturaEnCampo', 'Art19'],
  null,
  false,
  'gratis',
  true, true, false, false,
  'https://www.article19.org',
  null
),

(
  'Guía de seguridad para defensoras de derechos humanos — Front Line Defenders',
  'Manual orientado específicamente a mujeres defensoras de derechos humanos. Cubre análisis de riesgo, seguridad digital, física y psicosocial.',
  'Perspectiva de género integrada en el análisis de riesgo, algo que pocas guías del campo ofrecen. Útil para acompañamientos con organizaciones de mujeres y colectivos LGBTQ+.',
  'guide',
  array['digital', 'física', 'mixta']::resource_scope[],
  'Autocuidado',
  array['Género', 'DerechosHumanos', 'Defensoras', 'FrontLine'],
  null,
  false,
  'gratis',
  true, true, false, false,
  'https://www.frontlinedefenders.org',
  null
),

(
  'Protocolo de protección para viajes de alto riesgo',
  'Guía de preparación, conducta y respuesta para periodistas y activistas que viajan a zonas con alto nivel de vigilancia, control fronterizo o riesgo de decomiso de dispositivos.',
  'Útil para talleres previos a coberturas o viajes a contextos hostiles. Cubre tanto la preparación de dispositivos como los protocolos de check-in y respuesta a emergencias.',
  'guide',
  array['digital', 'física', 'mixta']::resource_scope[],
  'Protocolos de Viaje',
  array['Viajes', 'Frontera', 'Decomiso', 'Preparación'],
  null,
  false,
  'gratis',
  false, false, false, false,
  null,
  null
),

-- RECURSOS

(
  'Directorio de organizaciones de ayuda legal para periodistas — IFEX',
  'Base de datos de organizaciones que brindan asistencia legal a periodistas y defensores de derechos humanos en América Latina y el mundo.',
  'Recurso de referencia para incluir en maletas de taller cuando se trabaja con periodistas o activistas en riesgo legal. Recomendamos filtrar por país antes de compartir.',
  'resource',
  array['otra']::resource_scope[],
  'Legislación y Derechos',
  array['Legal', 'AméricaLatina', 'IFEX', 'Directorio'],
  null,
  false,
  'gratis',
  true, true, false, false,
  'https://ifex.org',
  null
),

(
  'Security in a Box — Frontline Defenders & Tactical Tech',
  'Repositorio de guías prácticas sobre herramientas de seguridad digital. Incluye instrucciones paso a paso para instalar y configurar herramientas en distintos sistemas operativos.',
  'Complemento ideal de SSD para talleres más técnicos. Las guías paso a paso son útiles para facilitadores que trabajan con poblaciones con menor experiencia tecnológica.',
  'resource',
  array['digital']::resource_scope[],
  'Formación y Metodología',
  array['Guías', 'PasoAPaso', 'TacticalTech', 'Referencia'],
  null,
  false,
  'gratis',
  true, true, false, false,
  'https://securityinabox.org/es',
  null
),

(
  'Repositorio de legislación de vigilancia — Access Now',
  'Recopilación de leyes y marcos normativos sobre vigilancia, interceptación de comunicaciones y protección de datos en países de América Latina.',
  'Útil para contextualizar talleres con el marco legal local. Permite mostrar qué protecciones legales existen (o no) en cada país antes de hablar de herramientas técnicas.',
  'resource',
  array['otra', 'digital']::resource_scope[],
  'Legislación y Derechos',
  array['Legislación', 'Vigilancia', 'AccessNow', 'AméricaLatina'],
  null,
  false,
  'gratis',
  false, false, false, false,
  'https://www.accessnow.org',
  null
);

-- -------------------------------------------------------
-- MANUALES DE USO (tool_manuals)
-- -------------------------------------------------------

insert into tool_manuals (tool_id, title, url, source) values

(
  (select id from resources where title = 'Signal' limit 1),
  'Cómo usar Signal — Surveillance Self-Defense',
  'https://ssd.eff.org/module/how-to-use-signal-on-android',
  'EFF'
),
(
  (select id from resources where title = 'Signal' limit 1),
  'Signal: Mensajería privada y segura — Security in a Box',
  'https://securityinabox.org/es/communication/signal/',
  'Frontline Defenders & Tactical Tech'
),
(
  (select id from resources where title = 'KeePassXC' limit 1),
  'Cómo usar KeePassXC — Security in a Box',
  'https://securityinabox.org/es/passwords/keepassxc/',
  'Frontline Defenders & Tactical Tech'
),
(
  (select id from resources where title = 'Tor Browser' limit 1),
  'Cómo usar Tor Browser — Surveillance Self-Defense',
  'https://ssd.eff.org/module/how-to-use-tor-for-windows',
  'EFF'
),
(
  (select id from resources where title = 'VeraCrypt' limit 1),
  'Cifrado de dispositivos con VeraCrypt — Security in a Box',
  'https://securityinabox.org/es/files/veracrypt/',
  'Frontline Defenders & Tactical Tech'
),
(
  (select id from resources where title = 'Bitwarden' limit 1),
  'Primeros pasos con Bitwarden',
  'https://bitwarden.com/learning/getting-started-individual-user/',
  'Bitwarden'
);
