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
  String get navAccount => 'Account';

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
  String get commonSave => 'Save';

  @override
  String get commonAll => 'All';

  @override
  String get commonAdd => 'Add';

  @override
  String get packingListAddItemTitle => 'Add item';

  @override
  String get packingListItemNameHint => 'Item name';

  @override
  String get packingListAiChatFeatureName => 'AI suggestions chat';

  @override
  String get packingListAiChatTooltip => 'Ask the AI for adjustments';

  @override
  String get packingListShareFeatureName => 'Share trip';

  @override
  String get packingListShareTooltip => 'Share and more';

  @override
  String get packingListSignInToShare =>
      'Sign in from the Account tab to share trips';

  @override
  String get packingListExportPdfFeatureName => 'Export as PDF';

  @override
  String get packingListWeatherDetailFeatureName => 'Daily weather detail';

  @override
  String get packingListTemplatesFeatureName => 'Packing templates';

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
  String get shareMenuInvite => 'Share with companions';

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
  String get newTripActivitiesFeatureName => 'Specific activities';

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
  String get sharingSheetTitle => 'Share trip';

  @override
  String get sharingSheetSubtitle =>
      'Each companion can see the list and check off what you assign them.';

  @override
  String get sharingSheetEmpty => 'You haven\'t invited anyone yet.';

  @override
  String get sharingSheetHasAccess => 'Already has access';

  @override
  String get sharingSheetPending => 'Waiting for them to sign in';

  @override
  String get sharingSheetInviteHint => 'Email of the person to invite';

  @override
  String get sharingSheetInviteError =>
      'Couldn\'t invite them (already invited?)';

  @override
  String get sharingSheetInviteFootnote =>
      'They need to have (or create) an account with this same email to access it.';

  @override
  String get assignSuitcaseTitle => 'Assign to suitcase';

  @override
  String get assignSuitcaseNone => 'No suitcase';

  @override
  String get assignSuitcaseEmptyHint =>
      'You haven\'t created any suitcases yet. Add one from the top of the list.';

  @override
  String get assignPersonTitle => 'Assign to';

  @override
  String get assignPersonNone => 'Unassigned';

  @override
  String get assignPersonYou => 'You';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountPremiumLockedTitle => 'Account is a Premium feature';

  @override
  String get accountPremiumLockedDescription =>
      'Create an account to manage your profile, with cross-device sync coming later.';

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
  String get commonSignOut => 'Sign out';

  @override
  String get accountPrivacyPolicyButton => 'Privacy policy';

  @override
  String get accountSignOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get authErrorChooseUsername => 'Choose a username';

  @override
  String get authErrorPasswordMismatch => 'Passwords don\'t match';

  @override
  String get authInfoAccountCreated =>
      'Account created — check your email to confirm it.';

  @override
  String get authErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get authForgotPasswordTitle => 'Recover password';

  @override
  String get authEmailHint => 'Your email address';

  @override
  String get authSendCodeButton => 'Send code';

  @override
  String get authEnterCodeTitle => 'Enter the code';

  @override
  String authResetCodeSentBody(String email) {
    return 'We\'ve sent an 8-digit code to $email. Enter it to continue (check your spam folder too).';
  }

  @override
  String get authCodeHint => '8-digit code';

  @override
  String get commonUnderstood => 'Got it';

  @override
  String get authErrorSendEmailFailed =>
      'Couldn\'t send the email. Please try again.';

  @override
  String get authErrorRateLimited =>
      'You\'ve hit the attempt limit. Try again in a little while.';

  @override
  String authErrorWrongPasswordAttempts(int count) {
    return 'Wrong password. You have $count attempts left.';
  }

  @override
  String authErrorLockedOut(int minutes) {
    return 'Too many failed attempts. Try again in $minutes minutes.';
  }

  @override
  String get authTitleSignUp => 'Create account';

  @override
  String get authTitleSignIn => 'Sign in';

  @override
  String get authSubtitle =>
      'With an account you\'ll be able to sync your trips across devices later on.';

  @override
  String get authUsernameHint => 'Username';

  @override
  String get authEmailFieldHint => 'Email address';

  @override
  String get authPasswordHint => 'Password';

  @override
  String get authForgotPasswordLink => 'Forgot your password?';

  @override
  String get authConfirmPasswordHint => 'Repeat password';

  @override
  String get authToggleToSignIn => 'Already have an account? Sign in';

  @override
  String get authToggleToSignUp => 'Don\'t have an account? Create one';

  @override
  String get accountErrorUploadPhoto =>
      'Couldn\'t upload the photo. Please try again.';

  @override
  String get accountErrorRemovePhoto =>
      'Couldn\'t remove the photo. Please try again.';

  @override
  String get accountChangeUsernameTitle => 'Change username';

  @override
  String get accountChangeEmailTitle => 'Change email';

  @override
  String get accountNewEmailHint => 'New email address';

  @override
  String get accountChangeEmailSentNotice =>
      'Check your email (both old and new) to confirm the change';

  @override
  String get accountChangePasswordTitle => 'Change password';

  @override
  String get accountCurrentPasswordHint => 'Current password';

  @override
  String get accountNewPasswordHint => 'New password';

  @override
  String get accountConfirmNewPasswordHint => 'Repeat new password';

  @override
  String get accountErrorNewPasswordMismatch => 'New passwords don\'t match';

  @override
  String get accountErrorFillAllFields => 'Fill in all fields';

  @override
  String get accountPasswordUpdated => 'Password updated';

  @override
  String get accountDeleteTitle => 'Delete account';

  @override
  String get accountDeleteBody =>
      'This action is irreversible. Your account, trips, packing lists, templates and any other associated data will be permanently deleted.';

  @override
  String get accountDeletePremiumWarning =>
      ' You\'ll lose access to Premium immediately.';

  @override
  String get accountDeleteCodeNotice =>
      '\n\nTo confirm, we\'ll send a code to your email.';

  @override
  String get commonContinue => 'Continue';

  @override
  String get accountDeletionCodeSent => 'We\'ve sent a code to your email';

  @override
  String get accountErrorSendCode =>
      'Couldn\'t send the code. Please try again.';

  @override
  String get accountConfirmDeletionTitle => 'Confirm deletion';

  @override
  String get accountConfirmDeletionBody =>
      'Enter the 6-digit code we sent to your email. This action cannot be undone.';

  @override
  String get accountErrorEnterSixDigits => 'Enter all 6 digits';

  @override
  String get accountDeletePermanentlyButton => 'Delete permanently';

  @override
  String get accountDeleteSubtitle =>
      'This action is permanent and irreversible';

  @override
  String get accountErrorDeleteAccount =>
      'Couldn\'t delete the account. Please try again.';

  @override
  String get accountSignedInPlaceholder => 'Signed in';

  @override
  String get accountTakePhoto => 'Take a photo';

  @override
  String get accountChooseFromGallery => 'Choose from gallery';

  @override
  String get accountRemovePhoto => 'Remove photo';

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
  String get feedbackEmailNote =>
      'Your email will only be used to contact you if we need more information about this report.';

  @override
  String get feedbackConsentPrefix => 'I\'ve read and accept the ';

  @override
  String get feedbackConsentLink => 'privacy policy';

  @override
  String get feedbackSignedInContactNote =>
      'If needed, we may contact you through the email address linked to your account to ask for more information about this report.';

  @override
  String get feedbackSubmittedThanks => 'Thanks! We\'ve received it.';

  @override
  String get feedbackErrorSubmit => 'Couldn\'t send it. Please try again.';

  @override
  String get commonSend => 'Send';

  @override
  String feedbackWaitSeconds(int seconds) {
    return 'Wait ${seconds}s';
  }

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
  String get onboardingFeatureSharedTitle => 'Shared trips';

  @override
  String get onboardingFeatureSharedDescription =>
      'Invite your travel companions so everyone can check off their own items';

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
  String get onboardingShareWithCompanions => 'Share with companions';

  @override
  String get onboardingExportPdfRow => 'Export as PDF';

  @override
  String get onboardingTryAgainButton => 'Try it again';

  @override
  String get onboardingPremiumTitle => 'Go Premium';

  @override
  String get onboardingPremiumSubtitle => 'Unlock the full potential of Kipack';

  @override
  String get onboardingPremiumNoAds => 'No ads';

  @override
  String get onboardingPremiumMap => 'Map of visited and planned countries';

  @override
  String get onboardingPremiumTemplates => 'Reusable packing templates';

  @override
  String get onboardingPremiumReminders => 'Smart reminders before you leave';

  @override
  String get onboardingPremiumAiChat => 'AI chat to adjust your list';

  @override
  String get onboardingPremiumSharedTrips => 'Shared, collaborative trips';

  @override
  String get onboardingPremiumCloudBackup => 'Cloud backup';

  @override
  String get onboardingPremiumExportPdf => 'Export your list as PDF';

  @override
  String get onboardingTryPremiumButton => 'Try Premium (demo)';

  @override
  String get onboardingContinueFreeButton => 'Continue with the free version';

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
  String get mapPaywallTitle => 'The map is a Premium feature';

  @override
  String get mapPaywallDescription =>
      'Unlock the map of visited and planned countries, and mark destinations even without a planned trip.';

  @override
  String premiumUpsellTitle(String featureName) {
    return '$featureName is Premium';
  }

  @override
  String premiumUpsellBody(String featureName) {
    return 'Unlock $featureName and the rest of the Premium features.';
  }

  @override
  String get premiumActivateButton => 'Activate Premium (demo)';

  @override
  String get premiumNotNowButton => 'Not now';

  @override
  String pendingInviteWithName(String inviterName, String destination) {
    return '$inviterName invited you to the trip to $destination';
  }

  @override
  String pendingInviteWithoutName(String destination) {
    return 'You\'ve been invited to a trip to $destination';
  }

  @override
  String get pendingInviteAccept => 'Accept';

  @override
  String get pendingInviteDecline => 'Decline';

  @override
  String get pendingInviteActionError =>
      'Couldn\'t process the invite. Please try again.';

  @override
  String get packingItemLocked => 'Only whoever packed it can unpack it';

  @override
  String get premiumSignInRequired =>
      'Sign in from the Account tab to subscribe to Premium.';

  @override
  String get premiumOffersUnavailable =>
      'Couldn\'t load Premium plans. Please try again later.';

  @override
  String get premiumOffersError =>
      'Couldn\'t load Premium plans. Check your connection.';

  @override
  String get premiumPurchaseError =>
      'Couldn\'t start the purchase. Please try again.';

  @override
  String premiumOfferMonthly(String price) {
    return 'Monthly — $price';
  }

  @override
  String premiumOfferAnnual(String price) {
    return 'Annual — $price';
  }

  @override
  String get premiumRestorePurchases => 'Restore purchases';

  @override
  String get premiumRestoreSuccess => 'Purchases restored';

  @override
  String get premiumRestoreError =>
      'Couldn\'t restore your purchase. Please try again.';

  @override
  String premiumSubscriptionActiveUntil(String date) {
    return 'Premium active until $date';
  }
}
