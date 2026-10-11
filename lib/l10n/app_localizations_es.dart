// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get navTrips => 'Viajes';

  @override
  String get navMap => 'Mapa';

  @override
  String get navAccount => 'Ajustes';

  @override
  String get languageSectionTitle => 'Idioma';

  @override
  String get languageDialogTitle => 'Elige un idioma';

  @override
  String get languageSystemDefault => 'Automático (idioma del dispositivo)';

  @override
  String get tripTypeBeach => 'Playa';

  @override
  String get tripTypeMountain => 'Montaña';

  @override
  String get tripTypeCity => 'Ciudad';

  @override
  String get tripTypeBusiness => 'Negocios';

  @override
  String get tripTypeBackpacker => 'Mochilero';

  @override
  String get tripActivityDiving => 'Buceo';

  @override
  String get tripActivityHiking => 'Senderismo';

  @override
  String get tripActivitySkiing => 'Esquí';

  @override
  String get tripActivitySurfing => 'Surf';

  @override
  String get tripActivityCycling => 'Ciclismo';

  @override
  String get tripActivityCamping => 'Camping';

  @override
  String get tripActivityPhotography => 'Fotografía';

  @override
  String get tripActivityRunning => 'Running';

  @override
  String get packingCategoryClothing => 'Ropa';

  @override
  String get packingCategoryToiletries => 'Higiene';

  @override
  String get packingCategoryElectronics => 'Electrónica';

  @override
  String get packingCategoryDocuments => 'Documentación';

  @override
  String get packingCategoryMisc => 'Otros';

  @override
  String get weatherConditionClear => 'Despejado';

  @override
  String get weatherConditionPartlyCloudy => 'Parcialmente nublado';

  @override
  String get weatherConditionCloudy => 'Nublado';

  @override
  String get weatherConditionFog => 'Niebla';

  @override
  String get weatherConditionRain => 'Lluvia';

  @override
  String get weatherConditionStorm => 'Tormenta';

  @override
  String get weatherConditionSnow => 'Nieve';

  @override
  String tripSummaryLine(String dateRange, String types, int peopleCount) {
    String _temp0 = intl.Intl.pluralLogic(
      peopleCount,
      locale: localeName,
      other: '$peopleCount personas',
      one: '1 persona',
    );
    return '$dateRange · $types · $_temp0';
  }

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonCreate => 'Crear';

  @override
  String get commonAll => 'Todas';

  @override
  String get commonAdd => 'Añadir';

  @override
  String get packingListAddItemTitle => 'Añadir ítem';

  @override
  String get packingListItemNameHint => 'Nombre del artículo';

  @override
  String get packingListAiChatTooltip => 'Pedir ajustes a la IA';

  @override
  String get packingListShareTooltip => 'Compartir y más';

  @override
  String get packingListNewSuitcaseTitle => 'Nueva maleta';

  @override
  String get packingListNewSuitcaseHint => 'Ej. Maleta grande';

  @override
  String get packingListDeleteSuitcaseTitle => 'Eliminar maleta';

  @override
  String packingListDeleteSuitcaseBody(String name) {
    return 'Se eliminará \"$name\". Los ítems asignados quedarán sin maleta.';
  }

  @override
  String get shareMenuApplyTemplate => 'Aplicar plantilla';

  @override
  String get shareMenuExportPdf => 'Exportar como PDF';

  @override
  String packingListProgressLine(int packed, int total) {
    return '$packed de $total empacados';
  }

  @override
  String get packingListEmptySuitcase => 'No hay ítems en esta maleta todavía.';

  @override
  String get templatesEmptyHint =>
      'Aún no tienes plantillas guardadas. Guarda la lista de un viaje como plantilla para reutilizarla aquí.';

  @override
  String templateItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artículos',
      one: '1 artículo',
    );
    return '$_temp0';
  }

  @override
  String get templateDeleteTitle => 'Eliminar plantilla';

  @override
  String templateDeleteConfirm(String name) {
    return '¿Seguro que quieres eliminar \"$name\"?';
  }

  @override
  String get aiThinking1 => 'La IA está pensando';

  @override
  String get aiThinking2 => 'Analizando el clima de tu destino';

  @override
  String get aiThinking3 => 'Decidiendo qué te hace falta';

  @override
  String get aiThinking4 => 'Afinando las cantidades';

  @override
  String get aiThinking5 => 'Ya casi está';

  @override
  String get aiGeneratingPleaseWait =>
      'Esta acción puede tardar unos segundos, por favor espera';

  @override
  String templateApplyAllAlreadyIn(String name) {
    return 'Todos los artículos de \"$name\" ya estaban en la lista';
  }

  @override
  String templateApplyAddedCount(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se añadieron $count artículos de \"$name\"',
      one: 'Se añadió 1 artículo de \"$name\"',
    );
    return '$_temp0';
  }

  @override
  String get tripsListTitle => 'Tus viajes';

  @override
  String get tripsListSubtitle =>
      'Prepara el equipaje perfecto para cada destino';

  @override
  String get tripsListSearchHint => 'Buscar por ciudad';

  @override
  String get tripsFilterAll => 'Todos';

  @override
  String get tripsFilterUpcoming => 'Próximos';

  @override
  String get tripsFilterPast => 'Pasados';

  @override
  String get newTripButton => 'Nuevo viaje';

  @override
  String duplicateTripNewDatesFor(String destination) {
    return 'Nuevas fechas para $destination';
  }

  @override
  String get deleteTripTitle => 'Eliminar viaje';

  @override
  String deleteTripConfirm(String destination) {
    return '¿Seguro que quieres eliminar \"$destination\"? Esta acción no se puede deshacer.';
  }

  @override
  String get tripsEmptyTitle => 'Aún no tienes viajes';

  @override
  String get tripsEmptyBody =>
      'Crea tu primer viaje y genera una lista de equipaje a tu medida en segundos.';

  @override
  String get tripsNoResults => 'Ningún viaje coincide con tu búsqueda o filtro';

  @override
  String get duplicateTripAction => 'Duplicar viaje';

  @override
  String get commonChange => 'Cambiar';

  @override
  String get commonManage => 'Gestionar';

  @override
  String get newTripTitle => 'Nuevo viaje';

  @override
  String get newTripRemindersFeatureName => 'Recordatorios de viaje';

  @override
  String get newTripDestinationLabel => 'Destino';

  @override
  String get newTripDestinationHint => 'Busca una ciudad, ej. Roma';

  @override
  String get newTripDatesLabel => 'Fechas';

  @override
  String get newTripSelectDates => 'Selecciona las fechas del viaje';

  @override
  String get newTripTypeLabel => 'Tipo de viaje';

  @override
  String get newTripMultiSelectHint => 'Puedes elegir varios';

  @override
  String get newTripActivitiesLabel => 'Actividades (opcional)';

  @override
  String get newTripActivitiesHint =>
      'La IA afina el equipo para actividades concretas, p. ej. esquí o buceo';

  @override
  String get newTripTemplateLabel => 'Plantilla (opcional)';

  @override
  String get newTripTemplateEmptyHint =>
      'Crea una plantilla (p. ej. \"Negocios\") para añadir siempre lo mismo a tus viajes.';

  @override
  String get newTripRemindersSubtitle =>
      'Aviso 3 días y 1 día antes de salir si aún te falta hacer la maleta';

  @override
  String get newTripPeopleLabel => 'Número de personas';

  @override
  String newTripPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas',
      one: '1 persona',
    );
    return '$_temp0';
  }

  @override
  String get newTripCheckingWeather => 'Consultando el clima…';

  @override
  String get newTripGenerateButton => 'Generar lista de equipaje';

  @override
  String get seasonWinter => 'invierno';

  @override
  String get seasonSpring => 'primavera';

  @override
  String get seasonSummer => 'verano';

  @override
  String get seasonAutumn => 'otoño';

  @override
  String weatherCardTitle(String destination) {
    return 'Clima en $destination';
  }

  @override
  String get weatherCardSouthernHemisphere => 'hemisferio sur';

  @override
  String get weatherCardNoData =>
      'Aún no hay datos de clima disponibles para este destino.';

  @override
  String weatherCardRainLikely(int pct) {
    return 'probable que llueva ($pct%)';
  }

  @override
  String weatherCardRainPossible(int pct) {
    return 'algo de lluvia posible ($pct%)';
  }

  @override
  String weatherCardRainUnlikely(int pct) {
    return 'poca probabilidad de lluvia ($pct%)';
  }

  @override
  String get weatherCardHistoricalNote =>
      'Estimación orientativa basada en años anteriores — aún faltan más de 15 días para el viaje. Se actualizará automáticamente con la previsión real más cerca de la fecha.';

  @override
  String weatherDetailTitle(String destination) {
    return 'Clima día a día en $destination';
  }

  @override
  String get weatherDetailSubtitle =>
      'Previsión real de Open-Meteo para las fechas de tu viaje';

  @override
  String get assignSuitcaseTitle => 'Asignar a maleta';

  @override
  String get assignSuitcaseNone => 'Sin maleta';

  @override
  String get assignSuitcaseEmptyHint =>
      'Aún no has creado ninguna maleta. Añádela desde la parte superior de la lista.';

  @override
  String get accountTitle => 'Ajustes';

  @override
  String get accountFeedbackPrompt =>
      '¿Algo no funciona o se te ocurre una mejora?';

  @override
  String get accountSendFeedbackButton => 'Enviar bug report o sugerencia';

  @override
  String get accountNotifTestPrompt =>
      '¿No sabes si te llegan las notificaciones?';

  @override
  String get accountNotifTestSubtitle =>
      'Prueba a enviarte una ahora mismo — si aparece, tu dispositivo las tiene bien configuradas.';

  @override
  String get accountSendTestNotificationButton =>
      'Enviar notificación de prueba';

  @override
  String get accountPrivacyPolicyButton => 'Política de privacidad';

  @override
  String get feedbackSheetTitle => 'Bug report o sugerencia';

  @override
  String get feedbackTypeBug => 'Bug';

  @override
  String get feedbackTypeSuggestion => 'Sugerencia';

  @override
  String get feedbackMessageHint =>
      'Cuéntanos qué ha pasado o qué te gustaría que tuviera la app';

  @override
  String get feedbackSignedInContactNote =>
      'Se abrirá tu app de correo con el mensaje listo para enviar.';

  @override
  String get feedbackErrorSubmit =>
      'No se encontró ninguna app de correo. Escríbenos a fooserd@gmail.com';

  @override
  String get commonSend => 'Enviar';

  @override
  String get onboardingSkip => 'Saltar';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingWelcomeTitle => 'Bienvenido a Kipack';

  @override
  String get onboardingWelcomeBody =>
      'La app que prepara tu maleta por ti: una lista de equipaje pensada para tu destino, tus fechas y el clima real que te vas a encontrar — nada de listas genéricas.';

  @override
  String get onboardingFeaturesTitle => 'Todo lo que puedes hacer';

  @override
  String get onboardingFeatureAiListsTitle => 'Listas con IA';

  @override
  String get onboardingFeatureAiListsDescription =>
      'Generadas según el clima real, tu destino y tus actividades';

  @override
  String get onboardingFeatureMapTitle => 'Mapa de viajes';

  @override
  String get onboardingFeatureMapDescription =>
      'Marca los países que has visitado o tienes programados';

  @override
  String get onboardingFeatureTemplatesTitle => 'Plantillas';

  @override
  String get onboardingFeatureTemplatesDescription =>
      'Guarda listas reutilizables para tus tipos de viaje habituales';

  @override
  String get onboardingFeatureRemindersTitle => 'Recordatorios';

  @override
  String get onboardingFeatureRemindersDescription =>
      'Avisos antes de salir si aún te falta hacer la maleta';

  @override
  String get onboardingFeaturePdfTitle => 'Exportar en PDF';

  @override
  String get onboardingFeaturePdfDescription =>
      'Comparte tu lista lista para imprimir o enviar';

  @override
  String get onboardingTourTitle => 'Pruébalo tú mismo';

  @override
  String get onboardingTourSubtitle =>
      'Así de fácil se prepara un viaje en Kipack';

  @override
  String get onboardingDemoItemPassport => 'Pasaporte';

  @override
  String get onboardingDemoItemRaincoat => 'Chubasquero';

  @override
  String get onboardingDemoItemCharger => 'Cargador';

  @override
  String get onboardingTourStep1Title => '1. Crea tu viaje';

  @override
  String get onboardingDemoDestination => 'Roma, Italia';

  @override
  String get onboardingDemoDates => '12 — 18 ago';

  @override
  String get onboardingGenerateButton => 'Generar mi lista';

  @override
  String get onboardingTourStep2Title => '2. La IA está pensando…';

  @override
  String get onboardingTourStep3Title => '3. Marca lo que vas guardando';

  @override
  String get onboardingTourStep3Subtitle => 'Toca cada artículo';

  @override
  String get onboardingSeeHowToShareButton => 'Ver cómo compartir';

  @override
  String get onboardingTourStep4Title => '4. Comparte o exporta';

  @override
  String get onboardingTourStep4Subtitle => 'Un solo botón para todo esto';

  @override
  String get onboardingExportPdfRow => 'Exportar como PDF';

  @override
  String get onboardingTryAgainButton => 'Volver a probar';

  @override
  String get mapTitle => 'Tu mapa';

  @override
  String get mapSubtitle => 'Países visitados y programados';

  @override
  String get mapLegendVisited => 'Visitado';

  @override
  String get mapLegendPlanned => 'Programado';

  @override
  String get mapLegendManual => 'Marcado';

  @override
  String mapVisitedCountriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count países visitados',
      one: '1 país visitado',
    );
    return '$_temp0';
  }

  @override
  String get settingsAdPrivacyButton => 'Privacidad de anuncios';

  @override
  String get onboardingStart => 'Empezar';

  @override
  String get themeSectionTitle => 'Tema';

  @override
  String get themeDialogTitle => 'Elige un tema';

  @override
  String get themeSystem => 'Automático (tema del dispositivo)';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get settingsPreferencesHeader => 'Preferencias';

  @override
  String get settingsHelpHeader => 'Ayuda';

  @override
  String get settingsPrivacyHeader => 'Privacidad';
}
