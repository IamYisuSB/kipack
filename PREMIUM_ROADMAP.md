# Roadmap Premium

Funciones premium a implementar una por una. El mapa ya está hecho y gateado
(ver `lib/core/premium/premium_provider.dart` y `lib/features/map/screens/map_paywall_screen.dart`).
La versión free se queda como está salvo que se diga lo contrario.

Marca cada ítem como `[x]` cuando esté implementado y probado en el móvil.

- [x] Mapa de países visitados/programados (con marcado manual y panel de lista)
- [x] Plantillas de equipaje guardadas y reutilizables (p. ej. "negocios" o "playa", aplicables a cualquier viaje nuevo)
- [x] Recordatorios inteligentes ("faltan 3 días y no has hecho la maleta", "te falta marcar el cargador")
- [x] IA más fina: ajustar sugerencias por actividad concreta (buceo, senderismo, esquí) y no solo por tipo genérico de viaje, ademas un pequeño chat donde puedes pedir sugerencias a la IA por ejemplo (Para el viaje no llevo mucho espacio necesito que lo optimices o algo asi)
- [x] Listas compartidas/colaborativas para viajes en grupo (cada acompañante marca lo suyo)
- [ ] Checklist "antes de salir de casa" separado de la maleta (pasaporte, gas, enchufes)
- [x] Backup en la nube — viajes, artículos de equipaje y maletas sincronizan con Supabase para usuarios Premium con sesión iniciada (plantillas y países marcados manualmente, todavía no)
- [x] Exportar/compartir la lista como PDF o imagen
- [x] Crear un apartado de cuenta perfil etc para en la version premium gestionar tu usuario y demas (en la version free no es necesario por que trabajara en local seria por asi decirlo una sesion en modo invitado)

- [x] Crear una funcion de cuando le pulses a la tarjeta del clima (solo cuando el iaje este disponible el clima completo) te desgolse el tiempo de todos los dias lo que es porcentaje de agua, el sol si va a ser soleado, nubloso, etc y temperaturas. 

- [ ] Suscripciones reales con Google Play Billing (mensual y anual, con descuento en el anual) — pendiente de que se verifique la cuenta de desarrollador de Google Play para poder empezar a configurar los productos.



(esto es para toda la version tanto free como de pago añadi un bug report y ideas y mejoras)
## Notas
- Sin pasarela de pago real todavía — `premiumProvider` es una bandera local (SharedPreferences) con un botón "demo" en la pantalla del mapa. Cuando se monte cobro real (Google Play Billing), ese flag pasa a depender de la compra verificada.
- Ir tachando de uno en uno; no hace falta implementar varios a la vez.
- **Supabase ya está conectado** (proyecto `xvbtracxtlwpideblnvm`, MCP autorizado). Esquema: `trips`, `suitcases`, `packing_items`, `packing_templates`, `template_items`, `manually_visited_countries`, `profiles`, `feedback` — todas con RLS.
- **Sincronización real ya funciona** para `trips`, `packing_items` y `suitcases` (ver `lib/core/sync/sync_context.dart` y los providers correspondientes): con sesión iniciada + Premium, cada alta/baja/cambio se sube a Supabase, y al iniciar sesión se trae lo que ya hubiera en la nube (o se sube lo local si la nube estaba vacía). Sin resolución de conflictos fina — pensado para "mis viajes en mis dispositivos", no para edición simultánea multi-usuario todavía. Plantillas y países marcados a mano siguen siendo solo locales por ahora.
- **Listas compartidas ya funciona**: en la lista de equipaje, el icono de compartir (arriba a la derecha) abre un menú con "Compartir con acompañantes" (invitar por correo), "Aplicar plantilla" y "Exportar como PDF" — todo agrupado ahí, con sitio para lo que se vaya añadiendo. Al invitar se guarda en `trip_collaborators`; si esa persona inicia sesión con ese mismo correo, la invitación se "reclama" automáticamente (función `claim_trip_invites`) y a partir de ahí ve y edita ese viaje como si fuera suyo (RLS actualizada en `trips`/`suitcases`/`packing_items` para admitir dueño O colaborador). Cada artículo se puede asignar a una persona concreta (icono de persona en cada fila) — eso es el "cada acompañante marca lo suyo". Solo el dueño puede invitar/quitar gente y borrar el viaje; un colaborador solo ve y edita contenido.
- Limitación conocida: no hay envío de email de invitación ni tiempo real — el invitado tiene que enterarse por su cuenta y tener (o crear) cuenta con ese correo; y para ver cambios de otros hay que reabrir/reentrar en la lista (no hay actualización en vivo todavía).
- **Exportar PDF**: genera un PDF de la lista agrupado por categoría (con `[x]`/`[ ]` según empacado) y abre el panel nativo de compartir/guardar de Android (paquetes `pdf` + `printing`) — se puede mandar por WhatsApp, guardar en Drive, imprimir, etc.
