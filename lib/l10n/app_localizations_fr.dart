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
  String get navAccount => 'Compte';

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
  String get commonSave => 'Enregistrer';

  @override
  String get commonAll => 'Tous';

  @override
  String get commonAdd => 'Ajouter';

  @override
  String get packingListAddItemTitle => 'Ajouter un article';

  @override
  String get packingListItemNameHint => 'Nom de l\'article';

  @override
  String get packingListAiChatFeatureName => 'Chat de suggestions IA';

  @override
  String get packingListAiChatTooltip => 'Demander des ajustements à l\'IA';

  @override
  String get packingListShareFeatureName => 'Partager le voyage';

  @override
  String get packingListShareTooltip => 'Partager et plus';

  @override
  String get packingListSignInToShare =>
      'Connecte-toi depuis l\'onglet Compte pour partager des voyages';

  @override
  String get packingListExportPdfFeatureName => 'Exporter en PDF';

  @override
  String get packingListWeatherDetailFeatureName => 'Détail météo quotidien';

  @override
  String get packingListTemplatesFeatureName => 'Modèles de bagages';

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
  String get shareMenuInvite => 'Partager avec des compagnons';

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
  String get newTripActivitiesFeatureName => 'Activités spécifiques';

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
  String get sharingSheetTitle => 'Partager le voyage';

  @override
  String get sharingSheetSubtitle =>
      'Chaque compagnon peut voir la liste et cocher ce que tu lui assignes.';

  @override
  String get sharingSheetEmpty => 'Tu n\'as encore invité personne.';

  @override
  String get sharingSheetHasAccess => 'A déjà accès';

  @override
  String get sharingSheetPending => 'En attente de connexion';

  @override
  String get sharingSheetInviteHint => 'E-mail de la personne à inviter';

  @override
  String get sharingSheetInviteError =>
      'Impossible d\'inviter (déjà invité·e ?)';

  @override
  String get sharingSheetInviteFootnote =>
      'Cette personne doit avoir (ou créer) un compte avec cette même adresse e-mail pour y accéder.';

  @override
  String get assignSuitcaseTitle => 'Assigner à une valise';

  @override
  String get assignSuitcaseNone => 'Aucune valise';

  @override
  String get assignSuitcaseEmptyHint =>
      'Tu n\'as pas encore créé de valise. Ajoutes-en une depuis le haut de la liste.';

  @override
  String get assignPersonTitle => 'Assigner à';

  @override
  String get assignPersonNone => 'Non assigné';

  @override
  String get assignPersonYou => 'Toi';

  @override
  String get accountTitle => 'Compte';

  @override
  String get accountPremiumLockedTitle =>
      'Le compte est une fonctionnalité Premium';

  @override
  String get accountPremiumLockedDescription =>
      'Crée un compte pour gérer ton profil, avec la synchronisation entre appareils à venir.';

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
  String get commonSignOut => 'Se déconnecter';

  @override
  String get accountPrivacyPolicyButton => 'Politique de confidentialité';

  @override
  String get accountSignOutConfirm => 'Es-tu sûr de vouloir te déconnecter ?';

  @override
  String get authErrorChooseUsername => 'Choisis un nom d\'utilisateur';

  @override
  String get authErrorPasswordMismatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get authInfoAccountCreated =>
      'Compte créé — vérifie ton e-mail pour le confirmer.';

  @override
  String get authErrorGeneric => 'Une erreur s\'est produite. Réessaie.';

  @override
  String get authForgotPasswordTitle => 'Récupérer le mot de passe';

  @override
  String get authEmailHint => 'Ton adresse e-mail';

  @override
  String get authSendLinkButton => 'Envoyer le lien';

  @override
  String get authCheckEmailTitle => 'Vérifie ton e-mail';

  @override
  String authResetEmailSentBody(String email) {
    return 'Tu as demandé la réinitialisation du mot de passe pour $email.\n\nSi cet e-mail est associé à un compte, tu recevras un lien pour choisir un nouveau mot de passe. Pense aussi à vérifier le dossier spam.';
  }

  @override
  String get commonUnderstood => 'Compris';

  @override
  String get authErrorSendEmailFailed =>
      'Impossible d\'envoyer l\'e-mail. Réessaie.';

  @override
  String get authTitleSignUp => 'Créer un compte';

  @override
  String get authTitleSignIn => 'Se connecter';

  @override
  String get authSubtitle =>
      'Avec un compte, tu pourras synchroniser tes voyages entre appareils plus tard.';

  @override
  String get authUsernameHint => 'Nom d\'utilisateur';

  @override
  String get authEmailFieldHint => 'Adresse e-mail';

  @override
  String get authPasswordHint => 'Mot de passe';

  @override
  String get authForgotPasswordLink => 'Mot de passe oublié ?';

  @override
  String get authConfirmPasswordHint => 'Répète le mot de passe';

  @override
  String get authToggleToSignIn => 'Tu as déjà un compte ? Connecte-toi';

  @override
  String get authToggleToSignUp => 'Pas encore de compte ? Crées-en un';

  @override
  String get accountErrorUploadPhoto =>
      'Impossible d\'envoyer la photo. Réessaie.';

  @override
  String get accountErrorRemovePhoto =>
      'Impossible de supprimer la photo. Réessaie.';

  @override
  String get accountChangeUsernameTitle => 'Changer le nom d\'utilisateur';

  @override
  String get accountChangeEmailTitle => 'Changer l\'e-mail';

  @override
  String get accountNewEmailHint => 'Nouvelle adresse e-mail';

  @override
  String get accountChangeEmailSentNotice =>
      'Vérifie tes e-mails (ancien et nouveau) pour confirmer le changement';

  @override
  String get accountChangePasswordTitle => 'Changer le mot de passe';

  @override
  String get accountCurrentPasswordHint => 'Mot de passe actuel';

  @override
  String get accountNewPasswordHint => 'Nouveau mot de passe';

  @override
  String get accountConfirmNewPasswordHint => 'Répète le nouveau mot de passe';

  @override
  String get accountErrorNewPasswordMismatch =>
      'Les nouveaux mots de passe ne correspondent pas';

  @override
  String get accountErrorFillAllFields => 'Remplis tous les champs';

  @override
  String get accountPasswordUpdated => 'Mot de passe mis à jour';

  @override
  String get accountDeleteTitle => 'Supprimer le compte';

  @override
  String get accountDeleteBody =>
      'Cette action est irréversible. Ton compte, tes voyages, listes de bagages, modèles et toute autre donnée associée seront définitivement supprimés.';

  @override
  String get accountDeletePremiumWarning =>
      ' Tu perdras immédiatement l\'accès à Premium.';

  @override
  String get accountDeleteCodeNotice =>
      '\n\nPour confirmer, nous t\'enverrons un code par e-mail.';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get accountDeletionCodeSent =>
      'Nous t\'avons envoyé un code par e-mail';

  @override
  String get accountErrorSendCode => 'Impossible d\'envoyer le code. Réessaie.';

  @override
  String get accountConfirmDeletionTitle => 'Confirme la suppression';

  @override
  String get accountConfirmDeletionBody =>
      'Entre le code à 6 chiffres que nous t\'avons envoyé par e-mail. Cette action est irréversible.';

  @override
  String get accountErrorEnterSixDigits => 'Entre les 6 chiffres';

  @override
  String get accountDeletePermanentlyButton => 'Supprimer définitivement';

  @override
  String get accountDeleteSubtitle =>
      'Cette action est permanente et irréversible';

  @override
  String get accountErrorDeleteAccount =>
      'Impossible de supprimer le compte. Réessaie.';

  @override
  String get accountSignedInPlaceholder => 'Connecté';

  @override
  String get accountTakePhoto => 'Prendre une photo';

  @override
  String get accountChooseFromGallery => 'Choisir depuis la galerie';

  @override
  String get accountRemovePhoto => 'Supprimer la photo';

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
  String get feedbackEmailNote =>
      'Ton e-mail ne sera utilisé que pour te contacter si nous avons besoin de plus d\'informations sur ce signalement.';

  @override
  String get feedbackConsentPrefix => 'J\'ai lu et j\'accepte la ';

  @override
  String get feedbackConsentLink => 'politique de confidentialité';

  @override
  String get feedbackSignedInContactNote =>
      'Si nécessaire, nous pourrions te contacter via l\'adresse e-mail associée à ton compte pour te demander des informations complémentaires sur ce signalement.';

  @override
  String get feedbackSubmittedThanks => 'Merci ! Nous l\'avons bien reçu.';

  @override
  String get feedbackErrorSubmit => 'Impossible de l\'envoyer. Réessaie.';

  @override
  String get commonSend => 'Envoyer';

  @override
  String feedbackWaitSeconds(int seconds) {
    return 'Attends ${seconds}s';
  }

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
  String get onboardingFeatureSharedTitle => 'Voyages partagés';

  @override
  String get onboardingFeatureSharedDescription =>
      'Invite tes compagnons de voyage pour que chacun coche ce qui lui revient';

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
  String get onboardingShareWithCompanions => 'Partager avec des compagnons';

  @override
  String get onboardingExportPdfRow => 'Exporter en PDF';

  @override
  String get onboardingTryAgainButton => 'Recommencer';

  @override
  String get onboardingPremiumTitle => 'Passe à Premium';

  @override
  String get onboardingPremiumSubtitle =>
      'Débloque tout le potentiel de Kipack';

  @override
  String get onboardingPremiumNoAds => 'Sans publicité';

  @override
  String get onboardingPremiumMap => 'Carte des pays visités et prévus';

  @override
  String get onboardingPremiumTemplates => 'Modèles de bagages réutilisables';

  @override
  String get onboardingPremiumReminders =>
      'Rappels intelligents avant de partir';

  @override
  String get onboardingPremiumAiChat => 'Chat avec l\'IA pour ajuster ta liste';

  @override
  String get onboardingPremiumSharedTrips =>
      'Voyages partagés et collaboratifs';

  @override
  String get onboardingPremiumCloudBackup => 'Sauvegarde dans le cloud';

  @override
  String get onboardingPremiumExportPdf => 'Exporter ta liste en PDF';

  @override
  String get onboardingTryPremiumButton => 'Essayer Premium (démo)';

  @override
  String get onboardingContinueFreeButton =>
      'Continuer avec la version gratuite';

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
  String get mapPaywallTitle => 'La carte est une fonctionnalité Premium';

  @override
  String get mapPaywallDescription =>
      'Débloque la carte des pays visités et prévus, et marque des destinations même sans voyage prévu.';

  @override
  String premiumUpsellTitle(String featureName) {
    return '$featureName est une fonctionnalité Premium';
  }

  @override
  String premiumUpsellBody(String featureName) {
    return 'Débloque $featureName et le reste des fonctionnalités Premium.';
  }

  @override
  String get premiumActivateButton => 'Activer Premium (démo)';

  @override
  String get premiumNotNowButton => 'Pas maintenant';

  @override
  String pendingInviteWithName(String inviterName, String destination) {
    return '$inviterName t\'a invité au voyage à $destination';
  }

  @override
  String pendingInviteWithoutName(String destination) {
    return 'Tu as été invité à un voyage à $destination';
  }

  @override
  String get pendingInviteAccept => 'Accepter';

  @override
  String get pendingInviteDecline => 'Refuser';

  @override
  String get pendingInviteActionError =>
      'Impossible de traiter l\'invitation. Réessaie.';

  @override
  String get packingItemLocked =>
      'Seule la personne qui l\'a rangé peut le décocher';

  @override
  String get premiumSignInRequired =>
      'Connecte-toi depuis l\'onglet Compte pour t\'abonner à Premium.';

  @override
  String get premiumOffersUnavailable =>
      'Impossible de charger les offres Premium. Réessaie plus tard.';

  @override
  String get premiumOffersError =>
      'Impossible de charger les offres Premium. Vérifie ta connexion.';

  @override
  String get premiumPurchaseError =>
      'Impossible de démarrer l\'achat. Réessaie.';

  @override
  String premiumOfferMonthly(String price) {
    return 'Mensuel — $price';
  }

  @override
  String premiumOfferAnnual(String price) {
    return 'Annuel — $price';
  }

  @override
  String get premiumRestorePurchases => 'Restaurer les achats';

  @override
  String get premiumRestoreSuccess => 'Achats restaurés';

  @override
  String get premiumRestoreError =>
      'Impossible de restaurer l\'achat. Réessaie.';

  @override
  String premiumSubscriptionActiveUntil(String date) {
    return 'Premium actif jusqu\'au $date';
  }
}
