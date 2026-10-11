/// Content for the in-app "Política de privacidad" screen. Plain text with
/// simple section markers (parsed by PrivacyPolicyScreen) rather than
/// markdown, to avoid pulling in a markdown-rendering dependency for a
/// single static document.
///
/// NOTE: this is a standard GDPR-oriented template filled in with the data
/// the developer provided, not a substitute for legal review — recommend
/// having it checked by a professional before relying on it for real users
/// or Play Store submission.
const String privacyPolicyText = '''
Última actualización: octubre de 2026

# 1. Responsable del tratamiento

Jesús David Guerrero, como persona física responsable del desarrollo y explotación de la aplicación Kipack ("la App", "nosotros"), es el responsable del tratamiento de los datos personales que se describen en esta política.

Correo de contacto: fooserd@gmail.com

Para cualquier consulta relacionada con tus datos personales o el ejercicio de tus derechos, puedes escribirnos a la dirección anterior.

# 2. Qué datos tratamos

Kipack no tiene cuentas de usuario ni servidores propios. Tus viajes, listas de equipaje, maletas, plantillas y países marcados se guardan únicamente en tu dispositivo, y se borran si desinstalas la App. No tenemos acceso a ellos.

Para que algunas funciones funcionen, la App envía ciertos datos directamente a servicios de terceros:

- Generación de listas con IA: el destino, las fechas, el tipo de viaje, las actividades, el número de personas, el clima previsto y, si usas el chat, los mensajes que escribas, se envían a OpenRouter para generar o ajustar tu lista. No se envía tu nombre ni ningún dato que te identifique.
- Clima y búsqueda de destinos: el nombre del destino que escribes y sus coordenadas se envían a Open-Meteo para buscar la ciudad y obtener la previsión o el clima histórico.
- Publicidad: la App muestra anuncios mediante Google AdMob. Google puede tratar el identificador de publicidad de tu dispositivo, tu dirección IP, información técnica del dispositivo y datos de interacción con los anuncios.
- Compra "Quitar anuncios": si decides comprarla, el pago lo gestiona íntegramente Google Play. No recibimos tus datos de pago; la App solo consulta a Google Play si la compra está activa en tu cuenta.
- Reportes de errores o sugerencias: se envían desde tu propia aplicación de correo, por lo que recibimos tu dirección de correo electrónico y el contenido del mensaje.

No solicitamos ni tratamos categorías especiales de datos (salud, ideología, origen étnico, etc.).

# 3. Con qué finalidad tratamos tus datos

- Generar tu lista de equipaje y adaptarla al clima de tu destino.
- Mostrar anuncios, que es lo que permite que la App sea gratuita. Si estás en el Espacio Económico Europeo o en el Reino Unido, te pediremos tu consentimiento antes de mostrar anuncios personalizados; puedes cambiar tu elección en cualquier momento desde Ajustes > Privacidad de anuncios.
- Responder a tus reportes de errores, sugerencias y consultas de soporte.

# 4. Base legal

El tratamiento de tus datos se basa en:

- La prestación del servicio que solicitas al usar la App (art. 6.1.b RGPD), para la generación de listas y la consulta del clima.
- Tu consentimiento (art. 6.1.a RGPD) para la publicidad personalizada, que puedes retirar en cualquier momento.
- Tu consentimiento cuando nos escribes voluntariamente por correo electrónico.

# 5. Con quién compartimos tus datos

No vendemos tus datos. Los terceros que intervienen son:

- Google Ireland Ltd. (Google AdMob) — publicidad. Más información en https://policies.google.com/technologies/partner-sites
- OpenRouter, Inc. y el proveedor del modelo de IA que utilice — generación de listas de equipaje.
- Open-Meteo — previsión meteorológica y búsqueda de destinos.

Algunos de estos proveedores pueden estar ubicados fuera del Espacio Económico Europeo. En ese caso, la transferencia se ampara en garantías adecuadas conforme al RGPD (como las Cláusulas Contractuales Tipo de la Comisión Europea).

# 6. Cuánto tiempo conservamos tus datos

Los datos de tus viajes permanecen en tu dispositivo hasta que los borres o desinstales la App. Los correos que nos envíes se conservan el tiempo necesario para resolver la incidencia y, como máximo, 24 meses. Los datos tratados por los terceros indicados se rigen por sus propias políticas de conservación.

# 7. Tus derechos

Tienes derecho a acceder, rectificar y suprimir tus datos, así como a solicitar la limitación de su tratamiento, oponerte a él o ejercer tu derecho a la portabilidad, escribiéndonos a fooserd@gmail.com. También tienes derecho a presentar una reclamación ante la Agencia Española de Protección de Datos (www.aepd.es) si consideras que no hemos tratado tus datos correctamente.

# 8. Menores de edad

Kipack no está dirigida a menores de 14 años. Si eres menor de edad, necesitas el consentimiento de tu tutor legal para usar la App.

# 9. Seguridad

Todas las comunicaciones de la App con los servicios indicados se realizan de forma cifrada (HTTPS). Tus datos de viaje no salen de tu dispositivo salvo en los casos descritos en esta política.

# 10. Cambios en esta política

Podemos actualizar esta política de privacidad para reflejar cambios en la App o en la normativa aplicable. Te avisaremos de cualquier cambio relevante a través de la propia App.
''';
