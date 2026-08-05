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
Última actualización: agosto de 2026

# 1. Responsable del tratamiento

Jesús David Guerrero (DNI 74537721B), como persona física responsable del desarrollo y explotación de la aplicación Kipack ("la App", "nosotros"), es el responsable del tratamiento de los datos personales que se describen en esta política.

Correo de contacto: info@fooserd.com
Teléfono de contacto: 642355835

Para cualquier consulta relacionada con tus datos personales o el ejercicio de tus derechos, puedes escribirnos a la dirección anterior.

# 2. Qué datos tratamos

Según cómo uses Kipack, podemos tratar los siguientes datos:

- Datos de cuenta: correo electrónico, nombre de usuario y contraseña (almacenada de forma cifrada, nunca en texto plano).
- Foto de perfil, si decides subir una.
- Datos de tus viajes: destino, fechas, tipo de viaje, actividades, número de acompañantes y las listas de equipaje que generes o edites.
- Datos de viajes compartidos: si invitas a otras personas a colaborar en un viaje, tratamos el correo electrónico que nos facilites de esa persona con esa única finalidad.
- Reportes de errores o sugerencias que nos envíes, y el correo electrónico de contacto que nos facilites si nos escribes sin haber iniciado sesión.
- Datos técnicos básicos generados por el uso de la App y necesarios para su funcionamiento (por ejemplo, registros de acceso a nuestros servidores).

No solicitamos ni tratamos categorías especiales de datos (salud, ideología, origen étnico, etc.).

# 3. Con qué finalidad tratamos tus datos

- Crear y gestionar tu cuenta de usuario.
- Generar y sincronizar tus listas de equipaje y viajes entre tus dispositivos.
- Permitirte compartir viajes con otras personas si así lo decides.
- Responder a tus reportes de errores, sugerencias y consultas de soporte, incluyendo contactarte por correo electrónico si necesitamos más información para resolver tu incidencia.
- Garantizar la seguridad, el correcto funcionamiento y la mejora continua de la App.

# 4. Base legal

El tratamiento de tus datos se basa en:

- La ejecución del contrato/relación de uso que aceptas al crear una cuenta o usar la App (art. 6.1.b RGPD).
- Tu consentimiento expreso cuando nos facilitas datos de forma voluntaria (por ejemplo, tu correo al enviar un reporte sin haber iniciado sesión), que puedes retirar en cualquier momento.
- Nuestro interés legítimo en mantener la seguridad del servicio y responder a incidencias.

# 5. Con quién compartimos tus datos

No vendemos ni cedemos tus datos a terceros con fines comerciales. Para poder prestar el servicio, trabajamos con los siguientes encargados de tratamiento, que solo acceden a los datos estrictamente necesarios para prestarnos sus servicios:

- Supabase Inc. — base de datos, autenticación y almacenamiento de archivos (fotos de perfil), alojados sobre infraestructura de Amazon Web Services (AWS).
- Resend — envío de correos electrónicos transaccionales (confirmación de cuenta, restablecimiento de contraseña, avisos).

Algunos de estos proveedores pueden estar ubicados fuera del Espacio Económico Europeo. En ese caso, nos aseguramos de que la transferencia cuente con garantías adecuadas conforme al RGPD (como las Cláusulas Contractuales Tipo de la Comisión Europea).

# 6. Cuánto tiempo conservamos tus datos

Conservamos tus datos mientras mantengas tu cuenta activa. Si eliminas tu cuenta, o nos solicitas la supresión de tus datos, los eliminaremos salvo que debamos conservarlos por obligación legal. Los reportes de errores o sugerencias se conservan el tiempo necesario para resolver la incidencia y, como máximo, 24 meses.

# 7. Tus derechos

Tienes derecho a acceder, rectificar y suprimir tus datos, así como a solicitar la limitación de su tratamiento, oponerte a él o ejercer tu derecho a la portabilidad, escribiéndonos a info@fooserd.com. También tienes derecho a presentar una reclamación ante la Agencia Española de Protección de Datos (www.aepd.es) si consideras que no hemos tratado tus datos correctamente.

# 8. Menores de edad

Kipack no está dirigida a menores de 14 años. Si eres menor de edad, necesitas el consentimiento de tu tutor legal para usar la App.

# 9. Seguridad

Aplicamos medidas técnicas y organizativas razonables (cifrado en tránsito, contraseñas cifradas, control de acceso) para proteger tus datos frente a accesos no autorizados, pérdida o alteración.

# 10. Cambios en esta política

Podemos actualizar esta política de privacidad para reflejar cambios en la App o en la normativa aplicable. Te avisaremos de cualquier cambio relevante a través de la propia App.
''';
