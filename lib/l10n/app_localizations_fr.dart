// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get navTrips => 'Voyages';

  @override
  String get navMap => 'Carte';

  @override
  String get navAccount => 'Réglages';

  @override
  String get languageSectionTitle => 'Langue';

  @override
  String get languageDialogTitle => 'Choisis une langue';

  @override
  String get languageSystemDefault => 'Automatique (langue de l\'appareil)';

  @override
  String get tripTypeBeach => 'Plage';

  @override
  String get tripTypeMountain => 'Montagne';

  @override
  String get tripTypeCity => 'Ville';

  @override
  String get tripTypeBusiness => 'Affaires';

  @override
  String get tripTypeBackpacker => 'Routard';

  @override
  String get tripActivityDiving => 'Plongée';

  @override
  String get tripActivityHiking => 'Randonnée';

  @override
  String get tripActivitySkiing => 'Ski';

  @override
  String get tripActivitySurfing => 'Surf';

  @override
  String get tripActivityCycling => 'Cyclisme';

  @override
  String get tripActivityCamping => 'Camping';

  @override
  String get tripActivityPhotography => 'Photographie';

  @override
  String get tripActivityRunning => 'Course à pied';

  @override
  String get packingCategoryClothing => 'Vêtements';

  @override
  String get packingCategoryToiletries => 'Hygiène';

  @override
  String get packingCategoryElectronics => 'Électronique';

  @override
  String get packingCategoryDocuments => 'Documents';

  @override
  String get packingCategoryMisc => 'Autres';

  @override
  String get weatherConditionClear => 'Dégagé';

  @override
  String get weatherConditionPartlyCloudy => 'Partiellement nuageux';

  @override
  String get weatherConditionCloudy => 'Nuageux';

  @override
  String get weatherConditionFog => 'Brouillard';

  @override
  String get weatherConditionRain => 'Pluie';

  @override
  String get weatherConditionStorm => 'Orage';

  @override
  String get weatherConditionSnow => 'Neige';

  @override
  String tripSummaryLine(String dateRange, String types, int peopleCount) {
    String _temp0 = intl.Intl.pluralLogic(
      peopleCount,
      locale: localeName,
      other: '$peopleCount personnes',
      one: '1 personne',
    );
    return '$dateRange · $types · $_temp0';
  }

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonCreate => 'Créer';

  @override
  String get commonAll => 'Tous';

  @override
  String get commonAdd => 'Ajouter';

  @override
  String get packingListAddItemTitle => 'Ajouter un article';

  @override
  String get packingListItemNameHint => 'Nom de l\'article';

  @override
  String get packingListAiChatTooltip => 'Demander des ajustements à l\'IA';

  @override
  String get packingListShareTooltip => 'Partager et plus';

  @override
  String get packingListNewSuitcaseTitle => 'Nouvelle valise';

  @override
  String get packingListNewSuitcaseHint => 'Ex. Grande valise';

  @override
  String get packingListDeleteSuitcaseTitle => 'Supprimer la valise';

  @override
  String packingListDeleteSuitcaseBody(String name) {
    return '\"$name\" sera supprimée. Les articles assignés resteront sans valise.';
  }

  @override
  String get shareMenuApplyTemplate => 'Appliquer un modèle';

  @override
  String get shareMenuExportPdf => 'Exporter en PDF';

  @override
  String packingListProgressLine(int packed, int total) {
    return '$packed sur $total emballés';
  }

  @override
  String get packingListEmptySuitcase =>
      'Aucun article dans cette valise pour le moment.';

  @override
  String get templatesEmptyHint =>
      'Tu n\'as pas encore de modèles enregistrés. Enregistre la liste d\'un voyage comme modèle pour la réutiliser ici.';

  @override
  String templateItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
    );
    return '$_temp0';
  }

  @override
  String get templateDeleteTitle => 'Supprimer le modèle';

  @override
  String templateDeleteConfirm(String name) {
    return 'Es-tu sûr de vouloir supprimer \"$name\" ?';
  }

  @override
  String get aiThinking1 => 'L\'IA réfléchit';

  @override
  String get aiThinking2 => 'Analyse de la météo à ta destination';

  @override
  String get aiThinking3 => 'Détermine ce dont tu as besoin';

  @override
  String get aiThinking4 => 'Ajustement des quantités';

  @override
  String get aiThinking5 => 'Presque terminé';

  @override
  String get aiGeneratingPleaseWait =>
      'Cela peut prendre quelques secondes, merci de patienter';

  @override
  String templateApplyAllAlreadyIn(String name) {
    return 'Tous les articles de \"$name\" étaient déjà dans la liste';
  }

  @override
  String templateApplyAddedCount(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles ajoutés depuis \"$name\"',
      one: '1 article ajouté depuis \"$name\"',
    );
    return '$_temp0';
  }

  @override
  String get tripsListTitle => 'Tes voyages';

  @override
  String get tripsListSubtitle =>
      'Prépare le bagage parfait pour chaque destination';

  @override
  String get tripsListSearchHint => 'Rechercher par ville';

  @override
  String get tripsFilterAll => 'Tous';

  @override
  String get tripsFilterUpcoming => 'À venir';

  @override
  String get tripsFilterPast => 'Passés';

  @override
  String get newTripButton => 'Nouveau voyage';

  @override
  String duplicateTripNewDatesFor(String destination) {
    return 'Nouvelles dates pour $destination';
  }

  @override
  String get deleteTripTitle => 'Supprimer le voyage';

  @override
  String deleteTripConfirm(String destination) {
    return 'Es-tu sûr de vouloir supprimer \"$destination\" ? Cette action est irréversible.';
  }

  @override
  String get tripsEmptyTitle => 'Aucun voyage pour le moment';

  @override
  String get tripsEmptyBody =>
      'Crée ton premier voyage et génère une liste de bagages sur mesure en quelques secondes.';

  @override
  String get tripsNoResults =>
      'Aucun voyage ne correspond à ta recherche ou à ton filtre';

  @override
  String get duplicateTripAction => 'Dupliquer le voyage';

  @override
  String get commonChange => 'Changer';

  @override
  String get commonManage => 'Gérer';

  @override
  String get newTripTitle => 'Nouveau voyage';

  @override
  String get newTripRemindersFeatureName => 'Rappels de voyage';

  @override
  String get newTripDestinationLabel => 'Destination';

  @override
  String get newTripDestinationHint => 'Cherche une ville, ex. Rome';

  @override
  String get newTripDatesLabel => 'Dates';

  @override
  String get newTripSelectDates => 'Sélectionne les dates du voyage';

  @override
  String get newTripTypeLabel => 'Type de voyage';

  @override
  String get newTripMultiSelectHint => 'Tu peux en choisir plusieurs';

  @override
  String get newTripActivitiesLabel => 'Activités (facultatif)';

  @override
  String get newTripActivitiesHint =>
      'L\'IA ajuste l\'équipement pour des activités précises, ex. ski ou plongée';

  @override
  String get newTripTemplateLabel => 'Modèle (facultatif)';

  @override
  String get newTripTemplateEmptyHint =>
      'Crée un modèle (ex. \"Affaires\") pour toujours ajouter les mêmes articles à tes voyages.';

  @override
  String get newTripRemindersSubtitle =>
      'Un rappel 3 jours et 1 jour avant le départ si tu n\'as pas encore fait ta valise';

  @override
  String get newTripPeopleLabel => 'Nombre de personnes';

  @override
  String newTripPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '1 personne',
    );
    return '$_temp0';
  }

  @override
  String get newTripCheckingWeather => 'Vérification de la météo…';

  @override
  String get newTripGenerateButton => 'Générer la liste de bagages';

  @override
  String get seasonWinter => 'hiver';

  @override
  String get seasonSpring => 'printemps';

  @override
  String get seasonSummer => 'été';

  @override
  String get seasonAutumn => 'automne';

  @override
  String weatherCardTitle(String destination) {
    return 'Météo à $destination';
  }

  @override
  String get weatherCardSouthernHemisphere => 'hémisphère sud';

  @override
  String get weatherCardNoData =>
      'Aucune donnée météo disponible pour cette destination pour le moment.';

  @override
  String weatherCardRainLikely(int pct) {
    return 'pluie probable ($pct%)';
  }

  @override
  String weatherCardRainPossible(int pct) {
    return 'un peu de pluie possible ($pct%)';
  }

  @override
  String weatherCardRainUnlikely(int pct) {
    return 'faible probabilité de pluie ($pct%)';
  }

  @override
  String get weatherCardHistoricalNote =>
      'Estimation indicative basée sur les années précédentes — il reste plus de 15 jours avant le voyage. Elle se mettra à jour automatiquement avec la prévision réelle à l\'approche de la date.';

  @override
  String weatherDetailTitle(String destination) {
    return 'Météo jour par jour à $destination';
  }

  @override
  String get weatherDetailSubtitle =>
      'Prévision réelle d\'Open-Meteo pour les dates de ton voyage';

  @override
  String get assignSuitcaseTitle => 'Assigner à une valise';

  @override
  String get assignSuitcaseNone => 'Aucune valise';

  @override
  String get assignSuitcaseEmptyHint =>
      'Tu n\'as pas encore créé de valise. Ajoutes-en une depuis le haut de la liste.';

  @override
  String get accountTitle => 'Réglages';

  @override
  String get accountFeedbackPrompt =>
      'Quelque chose ne fonctionne pas, ou une idée d\'amélioration ?';

  @override
  String get accountSendFeedbackButton =>
      'Envoyer un bug report ou une suggestion';

  @override
  String get accountNotifTestPrompt =>
      'Tu ne sais pas si les notifications t\'arrivent ?';

  @override
  String get accountNotifTestSubtitle =>
      'Essaie de t\'en envoyer une maintenant — si elle apparaît, ton appareil est bien configuré.';

  @override
  String get accountSendTestNotificationButton =>
      'Envoyer une notification de test';

  @override
  String get accountPrivacyPolicyButton => 'Politique de confidentialité';

  @override
  String get feedbackSheetTitle => 'Bug report ou suggestion';

  @override
  String get feedbackTypeBug => 'Bug';

  @override
  String get feedbackTypeSuggestion => 'Suggestion';

  @override
  String get feedbackMessageHint =>
      'Dis-nous ce qui s\'est passé ou ce que tu aimerais voir dans l\'appli';

  @override
  String get feedbackSignedInContactNote =>
      'Ton app de messagerie s\'ouvrira avec le message prêt à envoyer.';

  @override
  String get feedbackErrorSubmit =>
      'Aucune app de messagerie trouvée. Écris-nous à fooserd@gmail.com';

  @override
  String get commonSend => 'Envoyer';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingWelcomeTitle => 'Bienvenue sur Kipack';

  @override
  String get onboardingWelcomeBody =>
      'L\'appli qui prépare ta valise pour toi : une liste de bagages pensée pour ta destination, tes dates et la météo réelle que tu vas rencontrer — fini les listes génériques.';

  @override
  String get onboardingFeaturesTitle => 'Tout ce que tu peux faire';

  @override
  String get onboardingFeatureAiListsTitle => 'Listes générées par IA';

  @override
  String get onboardingFeatureAiListsDescription =>
      'Générées selon la météo réelle, ta destination et tes activités';

  @override
  String get onboardingFeatureMapTitle => 'Carte de voyages';

  @override
  String get onboardingFeatureMapDescription =>
      'Marque les pays que tu as visités ou que tu as prévus';

  @override
  String get onboardingFeatureTemplatesTitle => 'Modèles';

  @override
  String get onboardingFeatureTemplatesDescription =>
      'Enregistre des listes réutilisables pour tes types de voyage habituels';

  @override
  String get onboardingFeatureRemindersTitle => 'Rappels';

  @override
  String get onboardingFeatureRemindersDescription =>
      'Des alertes avant de partir s\'il te reste des bagages à faire';

  @override
  String get onboardingFeaturePdfTitle => 'Exporter en PDF';

  @override
  String get onboardingFeaturePdfDescription =>
      'Partage ta liste prête à imprimer ou à envoyer';

  @override
  String get onboardingTourTitle => 'Essaie toi-même';

  @override
  String get onboardingTourSubtitle =>
      'Voilà comme il est facile de préparer un voyage sur Kipack';

  @override
  String get onboardingDemoItemPassport => 'Passeport';

  @override
  String get onboardingDemoItemRaincoat => 'Imperméable';

  @override
  String get onboardingDemoItemCharger => 'Chargeur';

  @override
  String get onboardingTourStep1Title => '1. Crée ton voyage';

  @override
  String get onboardingDemoDestination => 'Rome, Italie';

  @override
  String get onboardingDemoDates => '12 — 18 août';

  @override
  String get onboardingGenerateButton => 'Générer ma liste';

  @override
  String get onboardingTourStep2Title => '2. L\'IA réfléchit…';

  @override
  String get onboardingTourStep3Title => '3. Coche ce que tu ranges';

  @override
  String get onboardingTourStep3Subtitle => 'Touche chaque article';

  @override
  String get onboardingSeeHowToShareButton => 'Voir comment partager';

  @override
  String get onboardingTourStep4Title => '4. Partage ou exporte';

  @override
  String get onboardingTourStep4Subtitle => 'Un seul bouton pour tout ça';

  @override
  String get onboardingExportPdfRow => 'Exporter en PDF';

  @override
  String get onboardingTryAgainButton => 'Recommencer';

  @override
  String get mapTitle => 'Ta carte';

  @override
  String get mapSubtitle => 'Pays visités et prévus';

  @override
  String get mapLegendVisited => 'Visité';

  @override
  String get mapLegendPlanned => 'Prévu';

  @override
  String get mapLegendManual => 'Marqué';

  @override
  String mapVisitedCountriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pays visités',
      one: '1 pays visité',
    );
    return '$_temp0';
  }

  @override
  String get settingsAdPrivacyButton => 'Confidentialité des annonces';

  @override
  String get onboardingStart => 'Commencer';

  @override
  String get themeSectionTitle => 'Thème';

  @override
  String get themeDialogTitle => 'Choisis un thème';

  @override
  String get themeSystem => 'Automatique (thème de l\'appareil)';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get settingsPreferencesHeader => 'Préférences';

  @override
  String get settingsHelpHeader => 'Aide';

  @override
  String get settingsPrivacyHeader => 'Confidentialité';
}
