import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @navTrips.
  ///
  /// In es, this message translates to:
  /// **'Viajes'**
  String get navTrips;

  /// No description provided for @navMap.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get navMap;

  /// No description provided for @navAccount.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get navAccount;

  /// No description provided for @languageSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get languageSectionTitle;

  /// No description provided for @languageDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Elige un idioma'**
  String get languageDialogTitle;

  /// No description provided for @languageSystemDefault.
  ///
  /// In es, this message translates to:
  /// **'Automático (idioma del dispositivo)'**
  String get languageSystemDefault;

  /// No description provided for @tripTypeBeach.
  ///
  /// In es, this message translates to:
  /// **'Playa'**
  String get tripTypeBeach;

  /// No description provided for @tripTypeMountain.
  ///
  /// In es, this message translates to:
  /// **'Montaña'**
  String get tripTypeMountain;

  /// No description provided for @tripTypeCity.
  ///
  /// In es, this message translates to:
  /// **'Ciudad'**
  String get tripTypeCity;

  /// No description provided for @tripTypeBusiness.
  ///
  /// In es, this message translates to:
  /// **'Negocios'**
  String get tripTypeBusiness;

  /// No description provided for @tripTypeBackpacker.
  ///
  /// In es, this message translates to:
  /// **'Mochilero'**
  String get tripTypeBackpacker;

  /// No description provided for @tripActivityDiving.
  ///
  /// In es, this message translates to:
  /// **'Buceo'**
  String get tripActivityDiving;

  /// No description provided for @tripActivityHiking.
  ///
  /// In es, this message translates to:
  /// **'Senderismo'**
  String get tripActivityHiking;

  /// No description provided for @tripActivitySkiing.
  ///
  /// In es, this message translates to:
  /// **'Esquí'**
  String get tripActivitySkiing;

  /// No description provided for @tripActivitySurfing.
  ///
  /// In es, this message translates to:
  /// **'Surf'**
  String get tripActivitySurfing;

  /// No description provided for @tripActivityCycling.
  ///
  /// In es, this message translates to:
  /// **'Ciclismo'**
  String get tripActivityCycling;

  /// No description provided for @tripActivityCamping.
  ///
  /// In es, this message translates to:
  /// **'Camping'**
  String get tripActivityCamping;

  /// No description provided for @tripActivityPhotography.
  ///
  /// In es, this message translates to:
  /// **'Fotografía'**
  String get tripActivityPhotography;

  /// No description provided for @tripActivityRunning.
  ///
  /// In es, this message translates to:
  /// **'Running'**
  String get tripActivityRunning;

  /// No description provided for @packingCategoryClothing.
  ///
  /// In es, this message translates to:
  /// **'Ropa'**
  String get packingCategoryClothing;

  /// No description provided for @packingCategoryToiletries.
  ///
  /// In es, this message translates to:
  /// **'Higiene'**
  String get packingCategoryToiletries;

  /// No description provided for @packingCategoryElectronics.
  ///
  /// In es, this message translates to:
  /// **'Electrónica'**
  String get packingCategoryElectronics;

  /// No description provided for @packingCategoryDocuments.
  ///
  /// In es, this message translates to:
  /// **'Documentación'**
  String get packingCategoryDocuments;

  /// No description provided for @packingCategoryMisc.
  ///
  /// In es, this message translates to:
  /// **'Otros'**
  String get packingCategoryMisc;

  /// No description provided for @weatherConditionClear.
  ///
  /// In es, this message translates to:
  /// **'Despejado'**
  String get weatherConditionClear;

  /// No description provided for @weatherConditionPartlyCloudy.
  ///
  /// In es, this message translates to:
  /// **'Parcialmente nublado'**
  String get weatherConditionPartlyCloudy;

  /// No description provided for @weatherConditionCloudy.
  ///
  /// In es, this message translates to:
  /// **'Nublado'**
  String get weatherConditionCloudy;

  /// No description provided for @weatherConditionFog.
  ///
  /// In es, this message translates to:
  /// **'Niebla'**
  String get weatherConditionFog;

  /// No description provided for @weatherConditionRain.
  ///
  /// In es, this message translates to:
  /// **'Lluvia'**
  String get weatherConditionRain;

  /// No description provided for @weatherConditionStorm.
  ///
  /// In es, this message translates to:
  /// **'Tormenta'**
  String get weatherConditionStorm;

  /// No description provided for @weatherConditionSnow.
  ///
  /// In es, this message translates to:
  /// **'Nieve'**
  String get weatherConditionSnow;

  /// No description provided for @tripSummaryLine.
  ///
  /// In es, this message translates to:
  /// **'{dateRange} · {types} · {peopleCount, plural, one{1 persona} other{{peopleCount} personas}}'**
  String tripSummaryLine(String dateRange, String types, int peopleCount);

  /// No description provided for @commonCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get commonDelete;

  /// No description provided for @commonCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get commonCreate;

  /// No description provided for @commonSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get commonSave;

  /// No description provided for @commonAll.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get commonAll;

  /// No description provided for @commonAdd.
  ///
  /// In es, this message translates to:
  /// **'Añadir'**
  String get commonAdd;

  /// No description provided for @packingListAddItemTitle.
  ///
  /// In es, this message translates to:
  /// **'Añadir ítem'**
  String get packingListAddItemTitle;

  /// No description provided for @packingListItemNameHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre del artículo'**
  String get packingListItemNameHint;

  /// No description provided for @packingListAiChatFeatureName.
  ///
  /// In es, this message translates to:
  /// **'Chat de sugerencias de la IA'**
  String get packingListAiChatFeatureName;

  /// No description provided for @packingListAiChatTooltip.
  ///
  /// In es, this message translates to:
  /// **'Pedir ajustes a la IA'**
  String get packingListAiChatTooltip;

  /// No description provided for @packingListShareFeatureName.
  ///
  /// In es, this message translates to:
  /// **'Compartir viaje'**
  String get packingListShareFeatureName;

  /// No description provided for @packingListShareTooltip.
  ///
  /// In es, this message translates to:
  /// **'Compartir y más'**
  String get packingListShareTooltip;

  /// No description provided for @packingListSignInToShare.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión desde la pestaña Cuenta para compartir viajes'**
  String get packingListSignInToShare;

  /// No description provided for @packingListExportPdfFeatureName.
  ///
  /// In es, this message translates to:
  /// **'Exportar como PDF'**
  String get packingListExportPdfFeatureName;

  /// No description provided for @packingListWeatherDetailFeatureName.
  ///
  /// In es, this message translates to:
  /// **'Detalle diario del clima'**
  String get packingListWeatherDetailFeatureName;

  /// No description provided for @packingListTemplatesFeatureName.
  ///
  /// In es, this message translates to:
  /// **'Plantillas de equipaje'**
  String get packingListTemplatesFeatureName;

  /// No description provided for @packingListNewSuitcaseTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva maleta'**
  String get packingListNewSuitcaseTitle;

  /// No description provided for @packingListNewSuitcaseHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Maleta grande'**
  String get packingListNewSuitcaseHint;

  /// No description provided for @packingListDeleteSuitcaseTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar maleta'**
  String get packingListDeleteSuitcaseTitle;

  /// No description provided for @packingListDeleteSuitcaseBody.
  ///
  /// In es, this message translates to:
  /// **'Se eliminará \"{name}\". Los ítems asignados quedarán sin maleta.'**
  String packingListDeleteSuitcaseBody(String name);

  /// No description provided for @shareMenuInvite.
  ///
  /// In es, this message translates to:
  /// **'Compartir con acompañantes'**
  String get shareMenuInvite;

  /// No description provided for @shareMenuApplyTemplate.
  ///
  /// In es, this message translates to:
  /// **'Aplicar plantilla'**
  String get shareMenuApplyTemplate;

  /// No description provided for @shareMenuExportPdf.
  ///
  /// In es, this message translates to:
  /// **'Exportar como PDF'**
  String get shareMenuExportPdf;

  /// No description provided for @packingListProgressLine.
  ///
  /// In es, this message translates to:
  /// **'{packed} de {total} empacados'**
  String packingListProgressLine(int packed, int total);

  /// No description provided for @packingListEmptySuitcase.
  ///
  /// In es, this message translates to:
  /// **'No hay ítems en esta maleta todavía.'**
  String get packingListEmptySuitcase;

  /// No description provided for @templatesEmptyHint.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes plantillas guardadas. Guarda la lista de un viaje como plantilla para reutilizarla aquí.'**
  String get templatesEmptyHint;

  /// No description provided for @templateItemsCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{1 artículo} other{{count} artículos}}'**
  String templateItemsCount(int count);

  /// No description provided for @templateDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar plantilla'**
  String get templateDeleteTitle;

  /// No description provided for @templateDeleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres eliminar \"{name}\"?'**
  String templateDeleteConfirm(String name);

  /// No description provided for @aiThinking1.
  ///
  /// In es, this message translates to:
  /// **'La IA está pensando'**
  String get aiThinking1;

  /// No description provided for @aiThinking2.
  ///
  /// In es, this message translates to:
  /// **'Analizando el clima de tu destino'**
  String get aiThinking2;

  /// No description provided for @aiThinking3.
  ///
  /// In es, this message translates to:
  /// **'Decidiendo qué te hace falta'**
  String get aiThinking3;

  /// No description provided for @aiThinking4.
  ///
  /// In es, this message translates to:
  /// **'Afinando las cantidades'**
  String get aiThinking4;

  /// No description provided for @aiThinking5.
  ///
  /// In es, this message translates to:
  /// **'Ya casi está'**
  String get aiThinking5;

  /// No description provided for @aiGeneratingPleaseWait.
  ///
  /// In es, this message translates to:
  /// **'Esta acción puede tardar unos segundos, por favor espera'**
  String get aiGeneratingPleaseWait;

  /// No description provided for @templateApplyAllAlreadyIn.
  ///
  /// In es, this message translates to:
  /// **'Todos los artículos de \"{name}\" ya estaban en la lista'**
  String templateApplyAllAlreadyIn(String name);

  /// No description provided for @templateApplyAddedCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{Se añadió 1 artículo de \"{name}\"} other{Se añadieron {count} artículos de \"{name}\"}}'**
  String templateApplyAddedCount(int count, String name);

  /// No description provided for @tripsListTitle.
  ///
  /// In es, this message translates to:
  /// **'Tus viajes'**
  String get tripsListTitle;

  /// No description provided for @tripsListSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Prepara el equipaje perfecto para cada destino'**
  String get tripsListSubtitle;

  /// No description provided for @tripsListSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar por ciudad'**
  String get tripsListSearchHint;

  /// No description provided for @tripsFilterAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get tripsFilterAll;

  /// No description provided for @tripsFilterUpcoming.
  ///
  /// In es, this message translates to:
  /// **'Próximos'**
  String get tripsFilterUpcoming;

  /// No description provided for @tripsFilterPast.
  ///
  /// In es, this message translates to:
  /// **'Pasados'**
  String get tripsFilterPast;

  /// No description provided for @newTripButton.
  ///
  /// In es, this message translates to:
  /// **'Nuevo viaje'**
  String get newTripButton;

  /// No description provided for @duplicateTripNewDatesFor.
  ///
  /// In es, this message translates to:
  /// **'Nuevas fechas para {destination}'**
  String duplicateTripNewDatesFor(String destination);

  /// No description provided for @deleteTripTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar viaje'**
  String get deleteTripTitle;

  /// No description provided for @deleteTripConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres eliminar \"{destination}\"? Esta acción no se puede deshacer.'**
  String deleteTripConfirm(String destination);

  /// No description provided for @tripsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes viajes'**
  String get tripsEmptyTitle;

  /// No description provided for @tripsEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Crea tu primer viaje y genera una lista de equipaje a tu medida en segundos.'**
  String get tripsEmptyBody;

  /// No description provided for @tripsNoResults.
  ///
  /// In es, this message translates to:
  /// **'Ningún viaje coincide con tu búsqueda o filtro'**
  String get tripsNoResults;

  /// No description provided for @duplicateTripAction.
  ///
  /// In es, this message translates to:
  /// **'Duplicar viaje'**
  String get duplicateTripAction;

  /// No description provided for @commonChange.
  ///
  /// In es, this message translates to:
  /// **'Cambiar'**
  String get commonChange;

  /// No description provided for @commonManage.
  ///
  /// In es, this message translates to:
  /// **'Gestionar'**
  String get commonManage;

  /// No description provided for @newTripTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo viaje'**
  String get newTripTitle;

  /// No description provided for @newTripActivitiesFeatureName.
  ///
  /// In es, this message translates to:
  /// **'Actividades específicas'**
  String get newTripActivitiesFeatureName;

  /// No description provided for @newTripRemindersFeatureName.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios de viaje'**
  String get newTripRemindersFeatureName;

  /// No description provided for @newTripDestinationLabel.
  ///
  /// In es, this message translates to:
  /// **'Destino'**
  String get newTripDestinationLabel;

  /// No description provided for @newTripDestinationHint.
  ///
  /// In es, this message translates to:
  /// **'Busca una ciudad, ej. Roma'**
  String get newTripDestinationHint;

  /// No description provided for @newTripDatesLabel.
  ///
  /// In es, this message translates to:
  /// **'Fechas'**
  String get newTripDatesLabel;

  /// No description provided for @newTripSelectDates.
  ///
  /// In es, this message translates to:
  /// **'Selecciona las fechas del viaje'**
  String get newTripSelectDates;

  /// No description provided for @newTripTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo de viaje'**
  String get newTripTypeLabel;

  /// No description provided for @newTripMultiSelectHint.
  ///
  /// In es, this message translates to:
  /// **'Puedes elegir varios'**
  String get newTripMultiSelectHint;

  /// No description provided for @newTripActivitiesLabel.
  ///
  /// In es, this message translates to:
  /// **'Actividades (opcional)'**
  String get newTripActivitiesLabel;

  /// No description provided for @newTripActivitiesHint.
  ///
  /// In es, this message translates to:
  /// **'La IA afina el equipo para actividades concretas, p. ej. esquí o buceo'**
  String get newTripActivitiesHint;

  /// No description provided for @newTripTemplateLabel.
  ///
  /// In es, this message translates to:
  /// **'Plantilla (opcional)'**
  String get newTripTemplateLabel;

  /// No description provided for @newTripTemplateEmptyHint.
  ///
  /// In es, this message translates to:
  /// **'Crea una plantilla (p. ej. \"Negocios\") para añadir siempre lo mismo a tus viajes.'**
  String get newTripTemplateEmptyHint;

  /// No description provided for @newTripRemindersSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Aviso 3 días y 1 día antes de salir si aún te falta hacer la maleta'**
  String get newTripRemindersSubtitle;

  /// No description provided for @newTripPeopleLabel.
  ///
  /// In es, this message translates to:
  /// **'Número de personas'**
  String get newTripPeopleLabel;

  /// No description provided for @newTripPeopleCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{1 persona} other{{count} personas}}'**
  String newTripPeopleCount(int count);

  /// No description provided for @newTripCheckingWeather.
  ///
  /// In es, this message translates to:
  /// **'Consultando el clima…'**
  String get newTripCheckingWeather;

  /// No description provided for @newTripGenerateButton.
  ///
  /// In es, this message translates to:
  /// **'Generar lista de equipaje'**
  String get newTripGenerateButton;

  /// No description provided for @seasonWinter.
  ///
  /// In es, this message translates to:
  /// **'invierno'**
  String get seasonWinter;

  /// No description provided for @seasonSpring.
  ///
  /// In es, this message translates to:
  /// **'primavera'**
  String get seasonSpring;

  /// No description provided for @seasonSummer.
  ///
  /// In es, this message translates to:
  /// **'verano'**
  String get seasonSummer;

  /// No description provided for @seasonAutumn.
  ///
  /// In es, this message translates to:
  /// **'otoño'**
  String get seasonAutumn;

  /// No description provided for @weatherCardTitle.
  ///
  /// In es, this message translates to:
  /// **'Clima en {destination}'**
  String weatherCardTitle(String destination);

  /// No description provided for @weatherCardSouthernHemisphere.
  ///
  /// In es, this message translates to:
  /// **'hemisferio sur'**
  String get weatherCardSouthernHemisphere;

  /// No description provided for @weatherCardNoData.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay datos de clima disponibles para este destino.'**
  String get weatherCardNoData;

  /// No description provided for @weatherCardRainLikely.
  ///
  /// In es, this message translates to:
  /// **'probable que llueva ({pct}%)'**
  String weatherCardRainLikely(int pct);

  /// No description provided for @weatherCardRainPossible.
  ///
  /// In es, this message translates to:
  /// **'algo de lluvia posible ({pct}%)'**
  String weatherCardRainPossible(int pct);

  /// No description provided for @weatherCardRainUnlikely.
  ///
  /// In es, this message translates to:
  /// **'poca probabilidad de lluvia ({pct}%)'**
  String weatherCardRainUnlikely(int pct);

  /// No description provided for @weatherCardHistoricalNote.
  ///
  /// In es, this message translates to:
  /// **'Estimación orientativa basada en años anteriores — aún faltan más de 15 días para el viaje. Se actualizará automáticamente con la previsión real más cerca de la fecha.'**
  String get weatherCardHistoricalNote;

  /// No description provided for @weatherDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Clima día a día en {destination}'**
  String weatherDetailTitle(String destination);

  /// No description provided for @weatherDetailSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Previsión real de Open-Meteo para las fechas de tu viaje'**
  String get weatherDetailSubtitle;

  /// No description provided for @sharingSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Compartir viaje'**
  String get sharingSheetTitle;

  /// No description provided for @sharingSheetSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cada acompañante puede ver la lista y marcar lo que le asignes.'**
  String get sharingSheetSubtitle;

  /// No description provided for @sharingSheetEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no has invitado a nadie.'**
  String get sharingSheetEmpty;

  /// No description provided for @sharingSheetHasAccess.
  ///
  /// In es, this message translates to:
  /// **'Ya tiene acceso'**
  String get sharingSheetHasAccess;

  /// No description provided for @sharingSheetPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente de que inicie sesión'**
  String get sharingSheetPending;

  /// No description provided for @sharingSheetInviteHint.
  ///
  /// In es, this message translates to:
  /// **'Correo de la persona a invitar'**
  String get sharingSheetInviteHint;

  /// No description provided for @sharingSheetInviteError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo invitar (¿ya estaba invitado?)'**
  String get sharingSheetInviteError;

  /// No description provided for @sharingSheetInviteFootnote.
  ///
  /// In es, this message translates to:
  /// **'La persona debe tener (o crear) una cuenta con este mismo correo para acceder.'**
  String get sharingSheetInviteFootnote;

  /// No description provided for @assignSuitcaseTitle.
  ///
  /// In es, this message translates to:
  /// **'Asignar a maleta'**
  String get assignSuitcaseTitle;

  /// No description provided for @assignSuitcaseNone.
  ///
  /// In es, this message translates to:
  /// **'Sin maleta'**
  String get assignSuitcaseNone;

  /// No description provided for @assignSuitcaseEmptyHint.
  ///
  /// In es, this message translates to:
  /// **'Aún no has creado ninguna maleta. Añádela desde la parte superior de la lista.'**
  String get assignSuitcaseEmptyHint;

  /// No description provided for @assignPersonTitle.
  ///
  /// In es, this message translates to:
  /// **'Asignar a'**
  String get assignPersonTitle;

  /// No description provided for @assignPersonNone.
  ///
  /// In es, this message translates to:
  /// **'Sin asignar'**
  String get assignPersonNone;

  /// No description provided for @assignPersonYou.
  ///
  /// In es, this message translates to:
  /// **'Tú'**
  String get assignPersonYou;

  /// No description provided for @accountTitle.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get accountTitle;

  /// No description provided for @accountPremiumLockedTitle.
  ///
  /// In es, this message translates to:
  /// **'La cuenta es una función Premium'**
  String get accountPremiumLockedTitle;

  /// No description provided for @accountPremiumLockedDescription.
  ///
  /// In es, this message translates to:
  /// **'Crea una cuenta para gestionar tu perfil, con sincronización entre dispositivos más adelante.'**
  String get accountPremiumLockedDescription;

  /// No description provided for @accountFeedbackPrompt.
  ///
  /// In es, this message translates to:
  /// **'¿Algo no funciona o se te ocurre una mejora?'**
  String get accountFeedbackPrompt;

  /// No description provided for @accountSendFeedbackButton.
  ///
  /// In es, this message translates to:
  /// **'Enviar bug report o sugerencia'**
  String get accountSendFeedbackButton;

  /// No description provided for @accountNotifTestPrompt.
  ///
  /// In es, this message translates to:
  /// **'¿No sabes si te llegan las notificaciones?'**
  String get accountNotifTestPrompt;

  /// No description provided for @accountNotifTestSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Prueba a enviarte una ahora mismo — si aparece, tu dispositivo las tiene bien configuradas.'**
  String get accountNotifTestSubtitle;

  /// No description provided for @accountSendTestNotificationButton.
  ///
  /// In es, this message translates to:
  /// **'Enviar notificación de prueba'**
  String get accountSendTestNotificationButton;

  /// No description provided for @commonSignOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get commonSignOut;

  /// No description provided for @accountPrivacyPolicyButton.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get accountPrivacyPolicyButton;

  /// No description provided for @accountSignOutConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres cerrar sesión?'**
  String get accountSignOutConfirm;

  /// No description provided for @authErrorChooseUsername.
  ///
  /// In es, this message translates to:
  /// **'Elige un nombre de usuario'**
  String get authErrorChooseUsername;

  /// No description provided for @authErrorPasswordMismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get authErrorPasswordMismatch;

  /// No description provided for @authInfoAccountCreated.
  ///
  /// In es, this message translates to:
  /// **'Cuenta creada — revisa tu correo para confirmarla.'**
  String get authInfoAccountCreated;

  /// No description provided for @authErrorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Algo ha fallado. Inténtalo de nuevo.'**
  String get authErrorGeneric;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'Recuperar contraseña'**
  String get authForgotPasswordTitle;

  /// No description provided for @authEmailHint.
  ///
  /// In es, this message translates to:
  /// **'Tu correo electrónico'**
  String get authEmailHint;

  /// No description provided for @authSendCodeButton.
  ///
  /// In es, this message translates to:
  /// **'Enviar código'**
  String get authSendCodeButton;

  /// No description provided for @authEnterCodeTitle.
  ///
  /// In es, this message translates to:
  /// **'Introduce el código'**
  String get authEnterCodeTitle;

  /// No description provided for @authResetCodeSentBody.
  ///
  /// In es, this message translates to:
  /// **'Te hemos enviado un código de 8 dígitos a {email}. Introdúcelo para continuar (revisa también la carpeta de spam).'**
  String authResetCodeSentBody(String email);

  /// No description provided for @authCodeHint.
  ///
  /// In es, this message translates to:
  /// **'Código de 8 dígitos'**
  String get authCodeHint;

  /// No description provided for @commonUnderstood.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get commonUnderstood;

  /// No description provided for @authErrorSendEmailFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar el correo. Inténtalo de nuevo.'**
  String get authErrorSendEmailFailed;

  /// No description provided for @authErrorRateLimited.
  ///
  /// In es, this message translates to:
  /// **'Has excedido el límite de intentos. Prueba de nuevo dentro de un rato.'**
  String get authErrorRateLimited;

  /// No description provided for @authErrorWrongPasswordAttempts.
  ///
  /// In es, this message translates to:
  /// **'Contraseña incorrecta. Te quedan {count} intentos.'**
  String authErrorWrongPasswordAttempts(int count);

  /// No description provided for @authErrorLockedOut.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos fallidos. Vuelve a intentarlo en {minutes} minutos.'**
  String authErrorLockedOut(int minutes);

  /// No description provided for @authTitleSignUp.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get authTitleSignUp;

  /// No description provided for @authTitleSignIn.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get authTitleSignIn;

  /// No description provided for @authSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Con una cuenta podrás sincronizar tus viajes entre dispositivos más adelante.'**
  String get authSubtitle;

  /// No description provided for @authUsernameHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre de usuario'**
  String get authUsernameHint;

  /// No description provided for @authEmailFieldHint.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get authEmailFieldHint;

  /// No description provided for @authPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get authPasswordHint;

  /// No description provided for @authForgotPasswordLink.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get authForgotPasswordLink;

  /// No description provided for @authConfirmPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Repite la contraseña'**
  String get authConfirmPasswordHint;

  /// No description provided for @authToggleToSignIn.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta? Inicia sesión'**
  String get authToggleToSignIn;

  /// No description provided for @authToggleToSignUp.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? Créala'**
  String get authToggleToSignUp;

  /// No description provided for @accountErrorUploadPhoto.
  ///
  /// In es, this message translates to:
  /// **'No se pudo subir la foto. Inténtalo de nuevo.'**
  String get accountErrorUploadPhoto;

  /// No description provided for @accountErrorRemovePhoto.
  ///
  /// In es, this message translates to:
  /// **'No se pudo quitar la foto. Inténtalo de nuevo.'**
  String get accountErrorRemovePhoto;

  /// No description provided for @accountChangeUsernameTitle.
  ///
  /// In es, this message translates to:
  /// **'Cambiar nombre de usuario'**
  String get accountChangeUsernameTitle;

  /// No description provided for @accountChangeEmailTitle.
  ///
  /// In es, this message translates to:
  /// **'Cambiar correo'**
  String get accountChangeEmailTitle;

  /// No description provided for @accountNewEmailHint.
  ///
  /// In es, this message translates to:
  /// **'Nuevo correo electrónico'**
  String get accountNewEmailHint;

  /// No description provided for @accountChangeEmailSentNotice.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu correo (el actual y el nuevo) para confirmar el cambio'**
  String get accountChangeEmailSentNotice;

  /// No description provided for @accountChangePasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get accountChangePasswordTitle;

  /// No description provided for @accountCurrentPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actual'**
  String get accountCurrentPasswordHint;

  /// No description provided for @accountNewPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get accountNewPasswordHint;

  /// No description provided for @accountConfirmNewPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Repite la nueva contraseña'**
  String get accountConfirmNewPasswordHint;

  /// No description provided for @accountErrorNewPasswordMismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas nuevas no coinciden'**
  String get accountErrorNewPasswordMismatch;

  /// No description provided for @accountErrorFillAllFields.
  ///
  /// In es, this message translates to:
  /// **'Rellena todos los campos'**
  String get accountErrorFillAllFields;

  /// No description provided for @accountPasswordUpdated.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada'**
  String get accountPasswordUpdated;

  /// No description provided for @accountDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get accountDeleteTitle;

  /// No description provided for @accountDeleteBody.
  ///
  /// In es, this message translates to:
  /// **'Esta acción es irreversible. Se eliminarán de forma permanente tu cuenta, tus viajes, listas de equipaje, plantillas y cualquier otro dato asociado.'**
  String get accountDeleteBody;

  /// No description provided for @accountDeletePremiumWarning.
  ///
  /// In es, this message translates to:
  /// **' Perderás el acceso a Premium inmediatamente.'**
  String get accountDeletePremiumWarning;

  /// No description provided for @accountDeleteCodeNotice.
  ///
  /// In es, this message translates to:
  /// **'\n\nPara confirmarlo, te enviaremos un código a tu correo.'**
  String get accountDeleteCodeNotice;

  /// No description provided for @commonContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get commonContinue;

  /// No description provided for @accountDeletionCodeSent.
  ///
  /// In es, this message translates to:
  /// **'Te hemos enviado un código a tu correo'**
  String get accountDeletionCodeSent;

  /// No description provided for @accountErrorSendCode.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar el código. Inténtalo de nuevo.'**
  String get accountErrorSendCode;

  /// No description provided for @accountConfirmDeletionTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirma la eliminación'**
  String get accountConfirmDeletionTitle;

  /// No description provided for @accountConfirmDeletionBody.
  ///
  /// In es, this message translates to:
  /// **'Introduce el código de 6 dígitos que te hemos enviado por correo. Esta acción no se puede deshacer.'**
  String get accountConfirmDeletionBody;

  /// No description provided for @accountErrorEnterSixDigits.
  ///
  /// In es, this message translates to:
  /// **'Introduce los 6 dígitos'**
  String get accountErrorEnterSixDigits;

  /// No description provided for @accountDeletePermanentlyButton.
  ///
  /// In es, this message translates to:
  /// **'Eliminar definitivamente'**
  String get accountDeletePermanentlyButton;

  /// No description provided for @accountDeleteSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Esta acción es permanente e irreversible'**
  String get accountDeleteSubtitle;

  /// No description provided for @accountErrorDeleteAccount.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar la cuenta. Inténtalo de nuevo.'**
  String get accountErrorDeleteAccount;

  /// No description provided for @accountSignedInPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Sesión iniciada'**
  String get accountSignedInPlaceholder;

  /// No description provided for @accountTakePhoto.
  ///
  /// In es, this message translates to:
  /// **'Hacer una foto'**
  String get accountTakePhoto;

  /// No description provided for @accountChooseFromGallery.
  ///
  /// In es, this message translates to:
  /// **'Elegir de la galería'**
  String get accountChooseFromGallery;

  /// No description provided for @accountRemovePhoto.
  ///
  /// In es, this message translates to:
  /// **'Quitar foto'**
  String get accountRemovePhoto;

  /// No description provided for @feedbackSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Bug report o sugerencia'**
  String get feedbackSheetTitle;

  /// No description provided for @feedbackTypeBug.
  ///
  /// In es, this message translates to:
  /// **'Bug'**
  String get feedbackTypeBug;

  /// No description provided for @feedbackTypeSuggestion.
  ///
  /// In es, this message translates to:
  /// **'Sugerencia'**
  String get feedbackTypeSuggestion;

  /// No description provided for @feedbackMessageHint.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos qué ha pasado o qué te gustaría que tuviera la app'**
  String get feedbackMessageHint;

  /// No description provided for @feedbackEmailNote.
  ///
  /// In es, this message translates to:
  /// **'Tu correo se usará únicamente para contactarte si necesitamos más información sobre este reporte.'**
  String get feedbackEmailNote;

  /// No description provided for @feedbackConsentPrefix.
  ///
  /// In es, this message translates to:
  /// **'He leído y acepto la '**
  String get feedbackConsentPrefix;

  /// No description provided for @feedbackConsentLink.
  ///
  /// In es, this message translates to:
  /// **'política de privacidad'**
  String get feedbackConsentLink;

  /// No description provided for @feedbackSignedInContactNote.
  ///
  /// In es, this message translates to:
  /// **'Si fuera necesario, podríamos ponernos en contacto contigo a través del correo electrónico asociado a tu cuenta para solicitarte información adicional sobre este reporte.'**
  String get feedbackSignedInContactNote;

  /// No description provided for @feedbackSubmittedThanks.
  ///
  /// In es, this message translates to:
  /// **'¡Gracias! Lo hemos recibido.'**
  String get feedbackSubmittedThanks;

  /// No description provided for @feedbackErrorSubmit.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar. Inténtalo de nuevo.'**
  String get feedbackErrorSubmit;

  /// No description provided for @commonSend.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get commonSend;

  /// No description provided for @feedbackWaitSeconds.
  ///
  /// In es, this message translates to:
  /// **'Espera {seconds}s'**
  String feedbackWaitSeconds(int seconds);

  /// No description provided for @onboardingSkip.
  ///
  /// In es, this message translates to:
  /// **'Saltar'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get onboardingNext;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a Kipack'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In es, this message translates to:
  /// **'La app que prepara tu maleta por ti: una lista de equipaje pensada para tu destino, tus fechas y el clima real que te vas a encontrar — nada de listas genéricas.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingFeaturesTitle.
  ///
  /// In es, this message translates to:
  /// **'Todo lo que puedes hacer'**
  String get onboardingFeaturesTitle;

  /// No description provided for @onboardingFeatureAiListsTitle.
  ///
  /// In es, this message translates to:
  /// **'Listas con IA'**
  String get onboardingFeatureAiListsTitle;

  /// No description provided for @onboardingFeatureAiListsDescription.
  ///
  /// In es, this message translates to:
  /// **'Generadas según el clima real, tu destino y tus actividades'**
  String get onboardingFeatureAiListsDescription;

  /// No description provided for @onboardingFeatureMapTitle.
  ///
  /// In es, this message translates to:
  /// **'Mapa de viajes'**
  String get onboardingFeatureMapTitle;

  /// No description provided for @onboardingFeatureMapDescription.
  ///
  /// In es, this message translates to:
  /// **'Marca los países que has visitado o tienes programados'**
  String get onboardingFeatureMapDescription;

  /// No description provided for @onboardingFeatureTemplatesTitle.
  ///
  /// In es, this message translates to:
  /// **'Plantillas'**
  String get onboardingFeatureTemplatesTitle;

  /// No description provided for @onboardingFeatureTemplatesDescription.
  ///
  /// In es, this message translates to:
  /// **'Guarda listas reutilizables para tus tipos de viaje habituales'**
  String get onboardingFeatureTemplatesDescription;

  /// No description provided for @onboardingFeatureRemindersTitle.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios'**
  String get onboardingFeatureRemindersTitle;

  /// No description provided for @onboardingFeatureRemindersDescription.
  ///
  /// In es, this message translates to:
  /// **'Avisos antes de salir si aún te falta hacer la maleta'**
  String get onboardingFeatureRemindersDescription;

  /// No description provided for @onboardingFeatureSharedTitle.
  ///
  /// In es, this message translates to:
  /// **'Viajes compartidos'**
  String get onboardingFeatureSharedTitle;

  /// No description provided for @onboardingFeatureSharedDescription.
  ///
  /// In es, this message translates to:
  /// **'Invita a tus acompañantes y que cada uno marque lo suyo'**
  String get onboardingFeatureSharedDescription;

  /// No description provided for @onboardingFeaturePdfTitle.
  ///
  /// In es, this message translates to:
  /// **'Exportar en PDF'**
  String get onboardingFeaturePdfTitle;

  /// No description provided for @onboardingFeaturePdfDescription.
  ///
  /// In es, this message translates to:
  /// **'Comparte tu lista lista para imprimir o enviar'**
  String get onboardingFeaturePdfDescription;

  /// No description provided for @onboardingTourTitle.
  ///
  /// In es, this message translates to:
  /// **'Pruébalo tú mismo'**
  String get onboardingTourTitle;

  /// No description provided for @onboardingTourSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Así de fácil se prepara un viaje en Kipack'**
  String get onboardingTourSubtitle;

  /// No description provided for @onboardingDemoItemPassport.
  ///
  /// In es, this message translates to:
  /// **'Pasaporte'**
  String get onboardingDemoItemPassport;

  /// No description provided for @onboardingDemoItemRaincoat.
  ///
  /// In es, this message translates to:
  /// **'Chubasquero'**
  String get onboardingDemoItemRaincoat;

  /// No description provided for @onboardingDemoItemCharger.
  ///
  /// In es, this message translates to:
  /// **'Cargador'**
  String get onboardingDemoItemCharger;

  /// No description provided for @onboardingTourStep1Title.
  ///
  /// In es, this message translates to:
  /// **'1. Crea tu viaje'**
  String get onboardingTourStep1Title;

  /// No description provided for @onboardingDemoDestination.
  ///
  /// In es, this message translates to:
  /// **'Roma, Italia'**
  String get onboardingDemoDestination;

  /// No description provided for @onboardingDemoDates.
  ///
  /// In es, this message translates to:
  /// **'12 — 18 ago'**
  String get onboardingDemoDates;

  /// No description provided for @onboardingGenerateButton.
  ///
  /// In es, this message translates to:
  /// **'Generar mi lista'**
  String get onboardingGenerateButton;

  /// No description provided for @onboardingTourStep2Title.
  ///
  /// In es, this message translates to:
  /// **'2. La IA está pensando…'**
  String get onboardingTourStep2Title;

  /// No description provided for @onboardingTourStep3Title.
  ///
  /// In es, this message translates to:
  /// **'3. Marca lo que vas guardando'**
  String get onboardingTourStep3Title;

  /// No description provided for @onboardingTourStep3Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Toca cada artículo'**
  String get onboardingTourStep3Subtitle;

  /// No description provided for @onboardingSeeHowToShareButton.
  ///
  /// In es, this message translates to:
  /// **'Ver cómo compartir'**
  String get onboardingSeeHowToShareButton;

  /// No description provided for @onboardingTourStep4Title.
  ///
  /// In es, this message translates to:
  /// **'4. Comparte o exporta'**
  String get onboardingTourStep4Title;

  /// No description provided for @onboardingTourStep4Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Un solo botón para todo esto'**
  String get onboardingTourStep4Subtitle;

  /// No description provided for @onboardingShareWithCompanions.
  ///
  /// In es, this message translates to:
  /// **'Compartir con acompañantes'**
  String get onboardingShareWithCompanions;

  /// No description provided for @onboardingExportPdfRow.
  ///
  /// In es, this message translates to:
  /// **'Exportar como PDF'**
  String get onboardingExportPdfRow;

  /// No description provided for @onboardingTryAgainButton.
  ///
  /// In es, this message translates to:
  /// **'Volver a probar'**
  String get onboardingTryAgainButton;

  /// No description provided for @onboardingPremiumTitle.
  ///
  /// In es, this message translates to:
  /// **'Hazte Premium'**
  String get onboardingPremiumTitle;

  /// No description provided for @onboardingPremiumSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Desbloquea todo el potencial de Kipack'**
  String get onboardingPremiumSubtitle;

  /// No description provided for @onboardingPremiumNoAds.
  ///
  /// In es, this message translates to:
  /// **'Sin anuncios'**
  String get onboardingPremiumNoAds;

  /// No description provided for @onboardingPremiumMap.
  ///
  /// In es, this message translates to:
  /// **'Mapa de países visitados y programados'**
  String get onboardingPremiumMap;

  /// No description provided for @onboardingPremiumTemplates.
  ///
  /// In es, this message translates to:
  /// **'Plantillas de equipaje reutilizables'**
  String get onboardingPremiumTemplates;

  /// No description provided for @onboardingPremiumReminders.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios inteligentes antes de salir'**
  String get onboardingPremiumReminders;

  /// No description provided for @onboardingPremiumAiChat.
  ///
  /// In es, this message translates to:
  /// **'Chat con la IA para ajustar tu lista'**
  String get onboardingPremiumAiChat;

  /// No description provided for @onboardingPremiumSharedTrips.
  ///
  /// In es, this message translates to:
  /// **'Viajes compartidos y colaborativos'**
  String get onboardingPremiumSharedTrips;

  /// No description provided for @onboardingPremiumCloudBackup.
  ///
  /// In es, this message translates to:
  /// **'Copia de seguridad en la nube'**
  String get onboardingPremiumCloudBackup;

  /// No description provided for @onboardingPremiumExportPdf.
  ///
  /// In es, this message translates to:
  /// **'Exportar tu lista como PDF'**
  String get onboardingPremiumExportPdf;

  /// No description provided for @onboardingTryPremiumButton.
  ///
  /// In es, this message translates to:
  /// **'Probar Premium (demo)'**
  String get onboardingTryPremiumButton;

  /// No description provided for @onboardingContinueFreeButton.
  ///
  /// In es, this message translates to:
  /// **'Continuar con la versión gratis'**
  String get onboardingContinueFreeButton;

  /// No description provided for @mapTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu mapa'**
  String get mapTitle;

  /// No description provided for @mapSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Países visitados y programados'**
  String get mapSubtitle;

  /// No description provided for @mapLegendVisited.
  ///
  /// In es, this message translates to:
  /// **'Visitado'**
  String get mapLegendVisited;

  /// No description provided for @mapLegendPlanned.
  ///
  /// In es, this message translates to:
  /// **'Programado'**
  String get mapLegendPlanned;

  /// No description provided for @mapLegendManual.
  ///
  /// In es, this message translates to:
  /// **'Marcado'**
  String get mapLegendManual;

  /// No description provided for @mapVisitedCountriesCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{1 país visitado} other{{count} países visitados}}'**
  String mapVisitedCountriesCount(int count);

  /// No description provided for @mapPaywallTitle.
  ///
  /// In es, this message translates to:
  /// **'El mapa es una función Premium'**
  String get mapPaywallTitle;

  /// No description provided for @mapPaywallDescription.
  ///
  /// In es, this message translates to:
  /// **'Desbloquea el mapa de países visitados y programados, y marca destinos aunque no tengas un viaje planeado.'**
  String get mapPaywallDescription;

  /// No description provided for @premiumUpsellTitle.
  ///
  /// In es, this message translates to:
  /// **'{featureName} es Premium'**
  String premiumUpsellTitle(String featureName);

  /// No description provided for @premiumUpsellBody.
  ///
  /// In es, this message translates to:
  /// **'Desbloquea {featureName} y el resto de funciones Premium.'**
  String premiumUpsellBody(String featureName);

  /// No description provided for @premiumActivateButton.
  ///
  /// In es, this message translates to:
  /// **'Activar Premium (demo)'**
  String get premiumActivateButton;

  /// No description provided for @premiumNotNowButton.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get premiumNotNowButton;

  /// No description provided for @pendingInviteWithName.
  ///
  /// In es, this message translates to:
  /// **'{inviterName} te invitó al viaje a {destination}'**
  String pendingInviteWithName(String inviterName, String destination);

  /// No description provided for @pendingInviteWithoutName.
  ///
  /// In es, this message translates to:
  /// **'Te han invitado a un viaje a {destination}'**
  String pendingInviteWithoutName(String destination);

  /// No description provided for @pendingInviteAccept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get pendingInviteAccept;

  /// No description provided for @pendingInviteDecline.
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get pendingInviteDecline;

  /// No description provided for @pendingInviteActionError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo procesar la invitación. Inténtalo de nuevo.'**
  String get pendingInviteActionError;

  /// No description provided for @packingItemLocked.
  ///
  /// In es, this message translates to:
  /// **'Solo quien lo marcó puede desmarcarlo'**
  String get packingItemLocked;

  /// No description provided for @premiumSignInRequired.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión desde la pestaña Cuenta para suscribirte a Premium.'**
  String get premiumSignInRequired;

  /// No description provided for @premiumOffersUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los planes de Premium. Inténtalo más tarde.'**
  String get premiumOffersUnavailable;

  /// No description provided for @premiumOffersError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los planes de Premium. Comprueba tu conexión.'**
  String get premiumOffersError;

  /// No description provided for @premiumPurchaseError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo iniciar la compra. Inténtalo de nuevo.'**
  String get premiumPurchaseError;

  /// No description provided for @premiumOfferMonthly.
  ///
  /// In es, this message translates to:
  /// **'Mensual — {price}'**
  String premiumOfferMonthly(String price);

  /// No description provided for @premiumOfferAnnual.
  ///
  /// In es, this message translates to:
  /// **'Anual — {price}'**
  String premiumOfferAnnual(String price);

  /// No description provided for @premiumRestorePurchases.
  ///
  /// In es, this message translates to:
  /// **'Restaurar compras'**
  String get premiumRestorePurchases;

  /// No description provided for @premiumRestoreSuccess.
  ///
  /// In es, this message translates to:
  /// **'Compras restauradas'**
  String get premiumRestoreSuccess;

  /// No description provided for @premiumRestoreError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo restaurar la compra. Inténtalo de nuevo.'**
  String get premiumRestoreError;

  /// No description provided for @premiumSubscriptionActiveUntil.
  ///
  /// In es, this message translates to:
  /// **'Premium activo hasta {date}'**
  String premiumSubscriptionActiveUntil(String date);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
