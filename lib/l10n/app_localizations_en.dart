// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navTrips => 'Trips';

  @override
  String get navMap => 'Map';

  @override
  String get navAccount => 'Settings';

  @override
  String get languageSectionTitle => 'Language';

  @override
  String get languageDialogTitle => 'Choose a language';

  @override
  String get languageSystemDefault => 'Automatic (device language)';

  @override
  String get tripTypeBeach => 'Beach';

  @override
  String get tripTypeMountain => 'Mountain';

  @override
  String get tripTypeCity => 'City';

  @override
  String get tripTypeBusiness => 'Business';

  @override
  String get tripTypeBackpacker => 'Backpacking';

  @override
  String get tripActivityDiving => 'Diving';

  @override
  String get tripActivityHiking => 'Hiking';

  @override
  String get tripActivitySkiing => 'Skiing';

  @override
  String get tripActivitySurfing => 'Surfing';

  @override
  String get tripActivityCycling => 'Cycling';

  @override
  String get tripActivityCamping => 'Camping';

  @override
  String get tripActivityPhotography => 'Photography';

  @override
  String get tripActivityRunning => 'Running';

  @override
  String get packingCategoryClothing => 'Clothing';

  @override
  String get packingCategoryToiletries => 'Toiletries';

  @override
  String get packingCategoryElectronics => 'Electronics';

  @override
  String get packingCategoryDocuments => 'Documents';

  @override
  String get packingCategoryMisc => 'Other';

  @override
  String get weatherConditionClear => 'Clear';

  @override
  String get weatherConditionPartlyCloudy => 'Partly cloudy';

  @override
  String get weatherConditionCloudy => 'Cloudy';

  @override
  String get weatherConditionFog => 'Fog';

  @override
  String get weatherConditionRain => 'Rain';

  @override
  String get weatherConditionStorm => 'Storm';

  @override
  String get weatherConditionSnow => 'Snow';

  @override
  String tripSummaryLine(String dateRange, String types, int peopleCount) {
    String _temp0 = intl.Intl.pluralLogic(
      peopleCount,
      locale: localeName,
      other: '$peopleCount people',
      one: '1 person',
    );
    return '$dateRange · $types · $_temp0';
  }

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonAll => 'All';

  @override
  String get commonAdd => 'Add';

  @override
  String get packingListAddItemTitle => 'Add item';

  @override
  String get packingListItemNameHint => 'Item name';

  @override
  String get packingListAiChatTooltip => 'Ask the AI for adjustments';

  @override
  String get packingListShareTooltip => 'Share and more';

  @override
  String get packingListNewSuitcaseTitle => 'New suitcase';

  @override
  String get packingListNewSuitcaseHint => 'E.g. Large suitcase';

  @override
  String get packingListDeleteSuitcaseTitle => 'Delete suitcase';

  @override
  String packingListDeleteSuitcaseBody(String name) {
    return '\"$name\" will be deleted. Assigned items will be left unassigned.';
  }

  @override
  String get shareMenuApplyTemplate => 'Apply template';

  @override
  String get shareMenuExportPdf => 'Export as PDF';

  @override
  String packingListProgressLine(int packed, int total) {
    return '$packed of $total packed';
  }

  @override
  String get packingListEmptySuitcase => 'No items in this suitcase yet.';

  @override
  String get templatesEmptyHint =>
      'You don\'t have any saved templates yet. Save a trip\'s list as a template to reuse it here.';

  @override
  String templateItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get templateDeleteTitle => 'Delete template';

  @override
  String templateDeleteConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get aiThinking1 => 'The AI is thinking';

  @override
  String get aiThinking2 => 'Analyzing the weather at your destination';

  @override
  String get aiThinking3 => 'Deciding what you\'ll need';

  @override
  String get aiThinking4 => 'Fine-tuning the quantities';

  @override
  String get aiThinking5 => 'Almost there';

  @override
  String get aiGeneratingPleaseWait =>
      'This may take a few seconds, please wait';

  @override
  String templateApplyAllAlreadyIn(String name) {
    return 'All the items from \"$name\" were already in the list';
  }

  @override
  String templateApplyAddedCount(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Added $count items from \"$name\"',
      one: 'Added 1 item from \"$name\"',
    );
    return '$_temp0';
  }

  @override
  String get tripsListTitle => 'Your trips';

  @override
  String get tripsListSubtitle =>
      'Prepare the perfect packing for every destination';

  @override
  String get tripsListSearchHint => 'Search by city';

  @override
  String get tripsFilterAll => 'All';

  @override
  String get tripsFilterUpcoming => 'Upcoming';

  @override
  String get tripsFilterPast => 'Past';

  @override
  String get newTripButton => 'New trip';

  @override
  String duplicateTripNewDatesFor(String destination) {
    return 'New dates for $destination';
  }

  @override
  String get deleteTripTitle => 'Delete trip';

  @override
  String deleteTripConfirm(String destination) {
    return 'Are you sure you want to delete \"$destination\"? This action can\'t be undone.';
  }

  @override
  String get tripsEmptyTitle => 'No trips yet';

  @override
  String get tripsEmptyBody =>
      'Create your first trip and generate a tailored packing list in seconds.';

  @override
  String get tripsNoResults => 'No trips match your search or filter';

  @override
  String get duplicateTripAction => 'Duplicate trip';

  @override
  String get commonChange => 'Change';

  @override
  String get commonManage => 'Manage';

  @override
  String get newTripTitle => 'New trip';

  @override
  String get newTripRemindersFeatureName => 'Trip reminders';

  @override
  String get newTripDestinationLabel => 'Destination';

  @override
  String get newTripDestinationHint => 'Search for a city, e.g. Rome';

  @override
  String get newTripDatesLabel => 'Dates';

  @override
  String get newTripSelectDates => 'Select the trip dates';

  @override
  String get newTripTypeLabel => 'Trip type';

  @override
  String get newTripMultiSelectHint => 'You can pick several';

  @override
  String get newTripActivitiesLabel => 'Activities (optional)';

  @override
  String get newTripActivitiesHint =>
      'The AI fine-tunes your gear for specific activities, e.g. skiing or diving';

  @override
  String get newTripTemplateLabel => 'Template (optional)';

  @override
  String get newTripTemplateEmptyHint =>
      'Create a template (e.g. \"Business\") to always add the same items to your trips.';

  @override
  String get newTripRemindersSubtitle =>
      'A heads-up 3 days and 1 day before you leave if you still haven\'t packed';

  @override
  String get newTripPeopleLabel => 'Number of people';

  @override
  String newTripPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String get newTripCheckingWeather => 'Checking the weather…';

  @override
  String get newTripGenerateButton => 'Generate packing list';

  @override
  String get seasonWinter => 'winter';

  @override
  String get seasonSpring => 'spring';

  @override
  String get seasonSummer => 'summer';

  @override
  String get seasonAutumn => 'autumn';

  @override
  String weatherCardTitle(String destination) {
    return 'Weather in $destination';
  }

  @override
  String get weatherCardSouthernHemisphere => 'southern hemisphere';

  @override
  String get weatherCardNoData =>
      'No weather data available for this destination yet.';

  @override
  String weatherCardRainLikely(int pct) {
    return 'rain is likely ($pct%)';
  }

  @override
  String weatherCardRainPossible(int pct) {
    return 'some rain possible ($pct%)';
  }

  @override
  String weatherCardRainUnlikely(int pct) {
    return 'low chance of rain ($pct%)';
  }

  @override
  String get weatherCardHistoricalNote =>
      'Rough estimate based on previous years — the trip is still more than 15 days away. It\'ll update automatically to a real forecast closer to the date.';

  @override
  String weatherDetailTitle(String destination) {
    return 'Day-by-day weather in $destination';
  }

  @override
  String get weatherDetailSubtitle =>
      'Real Open-Meteo forecast for your trip dates';

  @override
  String get assignSuitcaseTitle => 'Assign to suitcase';

  @override
  String get assignSuitcaseNone => 'No suitcase';

  @override
  String get assignSuitcaseEmptyHint =>
      'You haven\'t created any suitcases yet. Add one from the top of the list.';

  @override
  String get accountTitle => 'Settings';

  @override
  String get accountFeedbackPrompt =>
      'Something not working, or an idea for an improvement?';

  @override
  String get accountSendFeedbackButton => 'Send bug report or suggestion';

  @override
  String get accountNotifTestPrompt => 'Not sure if notifications reach you?';

  @override
  String get accountNotifTestSubtitle =>
      'Try sending yourself one right now — if it shows up, your device is set up correctly.';

  @override
  String get accountSendTestNotificationButton => 'Send test notification';

  @override
  String get accountPrivacyPolicyButton => 'Privacy policy';

  @override
  String get feedbackSheetTitle => 'Bug report or suggestion';

  @override
  String get feedbackTypeBug => 'Bug';

  @override
  String get feedbackTypeSuggestion => 'Suggestion';

  @override
  String get feedbackMessageHint =>
      'Tell us what happened or what you\'d like the app to have';

  @override
  String get feedbackSignedInContactNote =>
      'Your email app will open with the message ready to send.';

  @override
  String get feedbackErrorSubmit =>
      'No email app found. Write to us at fooserd@gmail.com';

  @override
  String get commonSend => 'Send';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Kipack';

  @override
  String get onboardingWelcomeBody =>
      'The app that packs your suitcase for you: a packing list built for your destination, your dates, and the real weather you\'ll find there — no generic lists.';

  @override
  String get onboardingFeaturesTitle => 'Everything you can do';

  @override
  String get onboardingFeatureAiListsTitle => 'AI-generated lists';

  @override
  String get onboardingFeatureAiListsDescription =>
      'Generated based on real weather, your destination, and your activities';

  @override
  String get onboardingFeatureMapTitle => 'Trip map';

  @override
  String get onboardingFeatureMapDescription =>
      'Mark the countries you\'ve visited or have planned';

  @override
  String get onboardingFeatureTemplatesTitle => 'Templates';

  @override
  String get onboardingFeatureTemplatesDescription =>
      'Save reusable lists for your usual types of trips';

  @override
  String get onboardingFeatureRemindersTitle => 'Reminders';

  @override
  String get onboardingFeatureRemindersDescription =>
      'Alerts before you leave if you still haven\'t packed';

  @override
  String get onboardingFeaturePdfTitle => 'Export to PDF';

  @override
  String get onboardingFeaturePdfDescription =>
      'Share your list ready to print or send';

  @override
  String get onboardingTourTitle => 'Try it yourself';

  @override
  String get onboardingTourSubtitle =>
      'This is how easy it is to plan a trip in Kipack';

  @override
  String get onboardingDemoItemPassport => 'Passport';

  @override
  String get onboardingDemoItemRaincoat => 'Raincoat';

  @override
  String get onboardingDemoItemCharger => 'Charger';

  @override
  String get onboardingTourStep1Title => '1. Create your trip';

  @override
  String get onboardingDemoDestination => 'Rome, Italy';

  @override
  String get onboardingDemoDates => 'Aug 12 — 18';

  @override
  String get onboardingGenerateButton => 'Generate my list';

  @override
  String get onboardingTourStep2Title => '2. The AI is thinking…';

  @override
  String get onboardingTourStep3Title => '3. Check off what you pack';

  @override
  String get onboardingTourStep3Subtitle => 'Tap each item';

  @override
  String get onboardingSeeHowToShareButton => 'See how to share';

  @override
  String get onboardingTourStep4Title => '4. Share or export';

  @override
  String get onboardingTourStep4Subtitle => 'One button for all of this';

  @override
  String get onboardingExportPdfRow => 'Export as PDF';

  @override
  String get onboardingTryAgainButton => 'Try it again';

  @override
  String get mapTitle => 'Your map';

  @override
  String get mapSubtitle => 'Visited and planned countries';

  @override
  String get mapLegendVisited => 'Visited';

  @override
  String get mapLegendPlanned => 'Planned';

  @override
  String get mapLegendManual => 'Marked';

  @override
  String mapVisitedCountriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count countries visited',
      one: '1 country visited',
    );
    return '$_temp0';
  }

  @override
  String get settingsAdPrivacyButton => 'Ad privacy';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get themeSectionTitle => 'Theme';

  @override
  String get themeDialogTitle => 'Choose a theme';

  @override
  String get themeSystem => 'Automatic (device theme)';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsPreferencesHeader => 'Preferences';

  @override
  String get settingsHelpHeader => 'Help';

  @override
  String get settingsPrivacyHeader => 'Privacy';

  @override
  String get chatAdNotice => 'Each AI request requires watching a short ad.';

  @override
  String get chatAdDismissed =>
      'Watch the full ad to send your request to the AI.';

  @override
  String get chatSendWithAdTooltip => 'Watch ad and send';

  @override
  String get removeAdsTitle => 'Tired of ads?';

  @override
  String get removeAdsBody =>
      'Remove them forever with a one-time payment. No subscription.';

  @override
  String get removeAdsPerkNoAds => 'No ads anywhere in the app';

  @override
  String get removeAdsPerkAiChat => 'AI chat without watching ads';

  @override
  String get removeAdsPerkForever => 'One-time payment: yours forever';

  @override
  String removeAdsBuyButton(String price) {
    return 'Remove ads · $price';
  }

  @override
  String get removeAdsNotNow => 'Not now';

  @override
  String get removeAdsRestore => 'Restore purchase';

  @override
  String get removeAdsUnavailable =>
      'The purchase isn\'t available right now. Please try again later.';

  @override
  String get removeAdsThanks => 'Thank you! You won\'t see ads anymore.';

  @override
  String get removeAdsSettingsTitle => 'Remove ads';

  @override
  String removeAdsSettingsSubtitle(String price) {
    return 'One-time payment of $price';
  }

  @override
  String get removeAdsSettingsOwned => 'Ads removed. Thanks for your support!';

  @override
  String get settingsAdsHeader => 'Ads';
}
