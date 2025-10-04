import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chats;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @proofs.
  ///
  /// In en, this message translates to:
  /// **'Proofs'**
  String get proofs;

  /// No description provided for @sponsors.
  ///
  /// In en, this message translates to:
  /// **'Sponsors'**
  String get sponsors;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @lands.
  ///
  /// In en, this message translates to:
  /// **'Lands'**
  String get lands;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @conversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversations;

  /// No description provided for @plantDiseaseId.
  ///
  /// In en, this message translates to:
  /// **'Plant Disease Identification'**
  String get plantDiseaseId;

  /// No description provided for @takePhotosOfSickPlants.
  ///
  /// In en, this message translates to:
  /// **'Take photos of sick plants for diagnosis'**
  String get takePhotosOfSickPlants;

  /// No description provided for @irrigationAdvice.
  ///
  /// In en, this message translates to:
  /// **'Irrigation Advice'**
  String get irrigationAdvice;

  /// No description provided for @wateringSchedulesAndTechniques.
  ///
  /// In en, this message translates to:
  /// **'Watering schedules and techniques'**
  String get wateringSchedulesAndTechniques;

  /// No description provided for @cropCare.
  ///
  /// In en, this message translates to:
  /// **'Crop Care'**
  String get cropCare;

  /// No description provided for @fertilizersSoilNutrition.
  ///
  /// In en, this message translates to:
  /// **'Fertilizers and soil nutrition'**
  String get fertilizersSoilNutrition;

  /// No description provided for @pestControl.
  ///
  /// In en, this message translates to:
  /// **'Pest Control'**
  String get pestControl;

  /// No description provided for @identifyAndTreatPlantPests.
  ///
  /// In en, this message translates to:
  /// **'Identify and treat plant pests'**
  String get identifyAndTreatPlantPests;

  /// No description provided for @weatherTips.
  ///
  /// In en, this message translates to:
  /// **'Weather Tips'**
  String get weatherTips;

  /// No description provided for @weatherBasedFarmingGuidance.
  ///
  /// In en, this message translates to:
  /// **'Weather-based farming guidance'**
  String get weatherBasedFarmingGuidance;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @crop.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get crop;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voice;

  /// No description provided for @anUnexpectedErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get anUnexpectedErrorOccurred;

  /// No description provided for @applyChanges.
  ///
  /// In en, this message translates to:
  /// **'Apply Changes'**
  String get applyChanges;

  /// No description provided for @areYouSureYouWantToLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureYouWantToLogout;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @chooseAnImageSource.
  ///
  /// In en, this message translates to:
  /// **'Choose an image source'**
  String get chooseAnImageSource;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get completeProfile;

  /// No description provided for @completeYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get completeYourProfile;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get createAnAccount;

  /// No description provided for @currentSelectedThemeMode.
  ///
  /// In en, this message translates to:
  /// **'Current: {_selectedThemeMode}'**
  String currentSelectedThemeMode(Object _selectedThemeMode);

  /// No description provided for @dartTemplate.
  ///
  /// In en, this message translates to:
  /// **'Dart Template'**
  String get dartTemplate;

  /// No description provided for @dontHaveAnAccountSignUp.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get dontHaveAnAccountSignUp;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @enterTheSubjectOfYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter the subject of your message'**
  String get enterTheSubjectOfYourMessage;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @enterYourEmailToRecoverYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to recover your password'**
  String get enterYourEmailToRecoverYourPassword;

  /// No description provided for @enterYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter your message'**
  String get enterYourMessage;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @errorOccurredDuringSignup.
  ///
  /// In en, this message translates to:
  /// **'Error occurred during signup.'**
  String get errorOccurredDuringSignup;

  /// No description provided for @errorOccurredWhileUploadingTheImage.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while uploading the image: {e}'**
  String errorOccurredWhileUploadingTheImage(Object e);

  /// No description provided for @errorPostingComment.
  ///
  /// In en, this message translates to:
  /// **'Error posting comment: {e}'**
  String errorPostingComment(Object e);

  /// No description provided for @errorReauthenticatingUser.
  ///
  /// In en, this message translates to:
  /// **'Error reauthenticating user: {e}'**
  String errorReauthenticatingUser(Object e);

  /// No description provided for @errorSendingPasswordRecoveryEmail.
  ///
  /// In en, this message translates to:
  /// **'Error sending password recovery email: {e}'**
  String errorSendingPasswordRecoveryEmail(Object e);

  /// No description provided for @errorSigningOut.
  ///
  /// In en, this message translates to:
  /// **'Error signing out'**
  String get errorSigningOut;

  /// No description provided for @errorSubmittingSupportRequest.
  ///
  /// In en, this message translates to:
  /// **'Error submitting support request'**
  String get errorSubmittingSupportRequest;

  /// No description provided for @errorUpdatingPassword.
  ///
  /// In en, this message translates to:
  /// **'Error updating password: {e}'**
  String errorUpdatingPassword(Object e);

  /// No description provided for @errorUpdatingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile: {e}'**
  String errorUpdatingProfile(Object e);

  /// No description provided for @errorSnapshotError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorSnapshotError(Object error);

  /// No description provided for @failedToCreateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to create profile: {toString}'**
  String failedToCreateProfile(Object toString);

  /// No description provided for @failedToUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image'**
  String get failedToUploadImage;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @firstNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameIsRequired;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @genderIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Gender is required'**
  String get genderIsRequired;

  /// No description provided for @incorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get incorrectPassword;

  /// No description provided for @invalidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmailAddress;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @lastNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastNameIsRequired;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @loginFailedWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Login failed: {message}'**
  String loginFailedWithMessage(Object message);

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @noAccountFoundWithThisEmail.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email'**
  String get noAccountFoundWithThisEmail;

  /// No description provided for @noCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noCommentsYet;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPassword;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long and contain a number'**
  String get passwordRequirements;

  /// No description provided for @passwordUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdatedSuccessfully;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordsDoNotMatchExclamation.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match!'**
  String get passwordsDoNotMatchExclamation;

  /// No description provided for @personalAccount.
  ///
  /// In en, this message translates to:
  /// **'Personal Account'**
  String get personalAccount;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneNumberIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberIsRequired;

  /// No description provided for @pleaseConfirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmYourPassword;

  /// No description provided for @pleaseEnterLabel.
  ///
  /// In en, this message translates to:
  /// **'Please enter {label}'**
  String pleaseEnterLabel(Object label);

  /// No description provided for @pleaseEnterAPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseEnterAPassword;

  /// No description provided for @pleaseEnterAValidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterAValidEmailAddress;

  /// No description provided for @pleaseEnterAValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get pleaseEnterAValidPhoneNumber;

  /// No description provided for @pleaseEnterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail;

  /// No description provided for @pleaseEnterYourFirstName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get pleaseEnterYourFirstName;

  /// No description provided for @pleaseEnterYourLastName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your last name'**
  String get pleaseEnterYourLastName;

  /// No description provided for @pleaseFillInAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get pleaseFillInAllFields;

  /// No description provided for @pleaseSelectYourBirthdate.
  ///
  /// In en, this message translates to:
  /// **'Please select your birthdate'**
  String get pleaseSelectYourBirthdate;

  /// No description provided for @pleaseSelectYourGender.
  ///
  /// In en, this message translates to:
  /// **'Please select your gender'**
  String get pleaseSelectYourGender;

  /// No description provided for @postedBy.
  ///
  /// In en, this message translates to:
  /// **'Posted by'**
  String get postedBy;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @randomText.
  ///
  /// In en, this message translates to:
  /// **'Random text'**
  String get randomText;

  /// No description provided for @recoverPassword.
  ///
  /// In en, this message translates to:
  /// **'Recover Password'**
  String get recoverPassword;

  /// No description provided for @selectYourBirthdate.
  ///
  /// In en, this message translates to:
  /// **'Select Your Birthdate'**
  String get selectYourBirthdate;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signInToContinueYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your journey'**
  String get signInToContinueYourJourney;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @supportRequestSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Support request submitted successfully'**
  String get supportRequestSubmittedSuccessfully;

  /// No description provided for @tapAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Tap again to exit'**
  String get tapAgainToExit;

  /// No description provided for @textOnButton.
  ///
  /// In en, this message translates to:
  /// **'Text on Button'**
  String get textOnButton;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @thisAccountHasBeenDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled'**
  String get thisAccountHasBeenDisabled;

  /// No description provided for @thisPageIsAPlaceHolder.
  ///
  /// In en, this message translates to:
  /// **'This page is a place holder'**
  String get thisPageIsAPlaceHolder;

  /// No description provided for @tooManyFailedAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts. Please try again later'**
  String get tooManyFailedAttempts;

  /// No description provided for @typeYourOldPasswordAndTheNewOneToApplyChanges.
  ///
  /// In en, this message translates to:
  /// **'Type your old password and the new one to apply changes'**
  String get typeYourOldPasswordAndTheNewOneToApplyChanges;

  /// No description provided for @typeYourPasswordToApplyChanges.
  ///
  /// In en, this message translates to:
  /// **'Type your password to apply changes'**
  String get typeYourPasswordToApplyChanges;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// No description provided for @userNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in'**
  String get userNotLoggedIn;

  /// No description provided for @weNeedAFewMoreDetails.
  ///
  /// In en, this message translates to:
  /// **'We need a few more details to get you started'**
  String get weNeedAFewMoreDetails;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @wouldYouLikeToTakeAPictureOrChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Would you like to take a picture or choose from gallery?'**
  String get wouldYouLikeToTakeAPictureOrChooseFromGallery;

  /// No description provided for @writeAComment.
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get writeAComment;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get wrongPassword;

  /// No description provided for @youCanInteractWithMeInMultipleWays.
  ///
  /// In en, this message translates to:
  /// **'You can interact with me in multiple ways:'**
  String get youCanInteractWithMeInMultipleWays;

  /// No description provided for @hiThereImBBot.
  ///
  /// In en, this message translates to:
  /// **'👋 Hi there! I\'m B-BOT'**
  String get hiThereImBBot;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @farmerRoleDescription.
  ///
  /// In en, this message translates to:
  /// **'• Can add and manage lands\n• Can upload progress proofs\n• Can chat with sponsors\n• Can add new users (admin privileges)'**
  String get farmerRoleDescription;

  /// No description provided for @sponsorRoleDescription.
  ///
  /// In en, this message translates to:
  /// **'• Can browse and sponsor projects\n• Can chat with farmers\n• Can view progress updates'**
  String get sponsorRoleDescription;

  /// No description provided for @userWithPhoneNumberExists.
  ///
  /// In en, this message translates to:
  /// **'A user with this phone number already exists'**
  String get userWithPhoneNumberExists;

  /// No description provided for @activeLands.
  ///
  /// In en, this message translates to:
  /// **'Active Lands'**
  String get activeLands;

  /// No description provided for @activeProjects.
  ///
  /// In en, this message translates to:
  /// **'Active Projects'**
  String get activeProjects;

  /// No description provided for @activeSponsor.
  ///
  /// In en, this message translates to:
  /// **'Active Sponsor'**
  String get activeSponsor;

  /// No description provided for @addLand.
  ///
  /// In en, this message translates to:
  /// **'Add Land'**
  String get addLand;

  /// No description provided for @addNewUser.
  ///
  /// In en, this message translates to:
  /// **'Add New User'**
  String get addNewUser;

  /// No description provided for @addPhotosMax8.
  ///
  /// In en, this message translates to:
  /// **'Add Photos (Max 8)'**
  String get addPhotosMax8;

  /// No description provided for @addProgressPhotosMax3.
  ///
  /// In en, this message translates to:
  /// **'Add Progress Photos (Max 3)'**
  String get addProgressPhotosMax3;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// No description provided for @addYourFirstFarm.
  ///
  /// In en, this message translates to:
  /// **'Add Your First Farm'**
  String get addYourFirstFarm;

  /// No description provided for @addYourFirstLand.
  ///
  /// In en, this message translates to:
  /// **'Add Your First Land'**
  String get addYourFirstLand;

  /// No description provided for @addYourFirstLandToStart.
  ///
  /// In en, this message translates to:
  /// **'Add your first land to start seeking sponsorship'**
  String get addYourFirstLandToStart;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @aiChat.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get aiChat;

  /// No description provided for @almostComplete75_99.
  ///
  /// In en, this message translates to:
  /// **'Almost Complete (75-99%)'**
  String get almostComplete75_99;

  /// No description provided for @almostThere.
  ///
  /// In en, this message translates to:
  /// **'ALMOST THERE'**
  String get almostThere;

  /// No description provided for @amountMustBeGreaterThan0.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0'**
  String get amountMustBeGreaterThan0;

  /// No description provided for @amountRaised.
  ///
  /// In en, this message translates to:
  /// **'Amount Raised'**
  String get amountRaised;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @asAFarmerYouCanInvite.
  ///
  /// In en, this message translates to:
  /// **'As a farmer (admin), you can invite new users to join the platform'**
  String get asAFarmerYouCanInvite;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @browseProjectsAndMakeADifference.
  ///
  /// In en, this message translates to:
  /// **'Browse available projects and start making a difference in rural farming communities'**
  String get browseProjectsAndMakeADifference;

  /// No description provided for @browseProjects.
  ///
  /// In en, this message translates to:
  /// **'Browse Projects'**
  String get browseProjects;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Connecting women farmers with investors for sustainable agriculture'**
  String get appTagline;

  /// No description provided for @continueAsUser.
  ///
  /// In en, this message translates to:
  /// **'Continue as User'**
  String get continueAsUser;

  /// No description provided for @describeCurrentProgress.
  ///
  /// In en, this message translates to:
  /// **'Describe the current progress, any challenges, achievements, or observations...'**
  String get describeCurrentProgress;

  /// No description provided for @describeYourLand.
  ///
  /// In en, this message translates to:
  /// **'Describe your land, soil type, current condition...'**
  String get describeYourLand;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description *'**
  String get descriptionRequired;

  /// No description provided for @discoverFarmingOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Discover farming opportunities and support sustainable agriculture'**
  String get discoverFarmingOpportunities;

  /// No description provided for @dueSoon.
  ///
  /// In en, this message translates to:
  /// **'Due Soon'**
  String get dueSoon;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (Optional)'**
  String get emailOptional;

  /// No description provided for @enterSize.
  ///
  /// In en, this message translates to:
  /// **'Enter size'**
  String get enterSize;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter valid amount'**
  String get enterValidAmount;

  /// No description provided for @errorLoadingLands.
  ///
  /// In en, this message translates to:
  /// **'Error loading lands: {e}'**
  String errorLoadingLands(Object e);

  /// No description provided for @errorLoadingMessages.
  ///
  /// In en, this message translates to:
  /// **'Error loading messages'**
  String get errorLoadingMessages;

  /// No description provided for @errorLoadingMessagesWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Error loading messages: {error}'**
  String errorLoadingMessagesWithDetails(Object error);

  /// No description provided for @errorLoadingProjects.
  ///
  /// In en, this message translates to:
  /// **'Error loading projects: {e}'**
  String errorLoadingProjects(Object e);

  /// No description provided for @errorLoadingSponsoredLands.
  ///
  /// In en, this message translates to:
  /// **'Error loading sponsored lands: {e}'**
  String errorLoadingSponsoredLands(Object e);

  /// No description provided for @errorLoadingSponsorships.
  ///
  /// In en, this message translates to:
  /// **'Error loading sponsorships: {e}'**
  String errorLoadingSponsorships(Object e);

  /// No description provided for @errorLoadingUpdates.
  ///
  /// In en, this message translates to:
  /// **'Error loading updates: {e}'**
  String errorLoadingUpdates(Object e);

  /// No description provided for @errorLoadingYourLands.
  ///
  /// In en, this message translates to:
  /// **'Error loading your lands: {e}'**
  String errorLoadingYourLands(Object e);

  /// No description provided for @errorOccurredWhileUploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while uploading the image: {e}'**
  String errorOccurredWhileUploadingImage(Object e);

  /// No description provided for @errorPickingImages.
  ///
  /// In en, this message translates to:
  /// **'Error picking images: {e}'**
  String errorPickingImages(Object e);

  /// No description provided for @errorProcessingSponsorship.
  ///
  /// In en, this message translates to:
  /// **'Error processing sponsorship: {e}'**
  String errorProcessingSponsorship(Object e);

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {e}'**
  String errorGeneric(Object e);

  /// No description provided for @failedToLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get failedToLoadImage;

  /// No description provided for @failedToSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message: {e}'**
  String failedToSendMessage(Object e);

  /// No description provided for @failedToUpdateRole.
  ///
  /// In en, this message translates to:
  /// **'Failed to update role: {toString}'**
  String failedToUpdateRole(Object toString);

  /// No description provided for @failedToUploadImageAfterMultipleAttempts.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image after multiple attempts'**
  String get failedToUploadImageAfterMultipleAttempts;

  /// No description provided for @farmerRole.
  ///
  /// In en, this message translates to:
  /// **'Farmer Role:'**
  String get farmerRole;

  /// No description provided for @farmersHelped.
  ///
  /// In en, this message translates to:
  /// **'Farmers Helped'**
  String get farmersHelped;

  /// No description provided for @filterByCrop.
  ///
  /// In en, this message translates to:
  /// **'Filter by Crop'**
  String get filterByCrop;

  /// No description provided for @filterByFundingStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter by Funding Status'**
  String get filterByFundingStatus;

  /// No description provided for @filterProjects.
  ///
  /// In en, this message translates to:
  /// **'Filter Projects'**
  String get filterProjects;

  /// No description provided for @findProjectsToSupport.
  ///
  /// In en, this message translates to:
  /// **'Find Projects to Support'**
  String get findProjectsToSupport;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullyFunded.
  ///
  /// In en, this message translates to:
  /// **'Fully Funded'**
  String get fullyFunded;

  /// No description provided for @fundingBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Funding Breakdown'**
  String get fundingBreakdown;

  /// No description provided for @fundingNeedsTnd.
  ///
  /// In en, this message translates to:
  /// **'Funding Needs (TND)'**
  String get fundingNeedsTnd;

  /// No description provided for @fundingProgress.
  ///
  /// In en, this message translates to:
  /// **'Funding Progress'**
  String get fundingProgress;

  /// No description provided for @helpLandReachFundingGoal.
  ///
  /// In en, this message translates to:
  /// **'Help {title} reach its funding goal!'**
  String helpLandReachFundingGoal(Object title);

  /// No description provided for @helpProjectReachFundingGoal.
  ///
  /// In en, this message translates to:
  /// **'Help this project reach its funding goal!'**
  String get helpProjectReachFundingGoal;

  /// No description provided for @imAFarmer.
  ///
  /// In en, this message translates to:
  /// **'I\'m a Farmer'**
  String get imAFarmer;

  /// No description provided for @imAnInvestor.
  ///
  /// In en, this message translates to:
  /// **'I\'m an Investor'**
  String get imAnInvestor;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'IN PROGRESS'**
  String get inProgress;

  /// No description provided for @inProgress25_75.
  ///
  /// In en, this message translates to:
  /// **'In Progress (25-75%)'**
  String get inProgress25_75;

  /// No description provided for @intendedCropRequired.
  ///
  /// In en, this message translates to:
  /// **'Intended Crop *'**
  String get intendedCropRequired;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get invalidNumber;

  /// No description provided for @joinChat.
  ///
  /// In en, this message translates to:
  /// **'Join Chat'**
  String get joinChat;

  /// No description provided for @justStarted0_25.
  ///
  /// In en, this message translates to:
  /// **'Just Started (0-25%)'**
  String get justStarted0_25;

  /// No description provided for @landImages.
  ///
  /// In en, this message translates to:
  /// **'Land Images'**
  String get landImages;

  /// No description provided for @landInformation.
  ///
  /// In en, this message translates to:
  /// **'Land Information'**
  String get landInformation;

  /// No description provided for @landRegisteredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Land registered successfully!'**
  String get landRegisteredSuccessfully;

  /// No description provided for @landTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Land Title *'**
  String get landTitleRequired;

  /// No description provided for @loadedLandsCount.
  ///
  /// In en, this message translates to:
  /// **'Loaded {length} lands'**
  String loadedLandsCount(Object length);

  /// No description provided for @locationRequired.
  ///
  /// In en, this message translates to:
  /// **'Location *'**
  String get locationRequired;

  /// No description provided for @maximum3ImagesAllowedForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Maximum 3 images allowed for updates'**
  String get maximum3ImagesAllowedForUpdates;

  /// No description provided for @maximum8ImagesAllowed.
  ///
  /// In en, this message translates to:
  /// **'Maximum 8 images allowed'**
  String get maximum8ImagesAllowed;

  /// No description provided for @myFarmDashboard.
  ///
  /// In en, this message translates to:
  /// **'My Farm Dashboard'**
  String get myFarmDashboard;

  /// No description provided for @myLands.
  ///
  /// In en, this message translates to:
  /// **'My Lands'**
  String get myLands;

  /// No description provided for @mySponsorships.
  ///
  /// In en, this message translates to:
  /// **'My Sponsorships'**
  String get mySponsorships;

  /// No description provided for @nameMustBeAtLeast2Chars.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters long'**
  String get nameMustBeAtLeast2Chars;

  /// No description provided for @noActiveConversations.
  ///
  /// In en, this message translates to:
  /// **'No Active Conversations'**
  String get noActiveConversations;

  /// No description provided for @noAuthenticatedUser.
  ///
  /// In en, this message translates to:
  /// **'No authenticated user'**
  String get noAuthenticatedUser;

  /// No description provided for @noConversationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Conversations Available'**
  String get noConversationsAvailable;

  /// No description provided for @noFarmsToUploadProof.
  ///
  /// In en, this message translates to:
  /// **'No Farms to Upload Proof'**
  String get noFarmsToUploadProof;

  /// No description provided for @noLandsRegisteredYet.
  ///
  /// In en, this message translates to:
  /// **'No lands registered yet'**
  String get noLandsRegisteredYet;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @noPhotosAvailable.
  ///
  /// In en, this message translates to:
  /// **'No photos available'**
  String get noPhotosAvailable;

  /// No description provided for @noProjectsFound.
  ///
  /// In en, this message translates to:
  /// **'No projects found'**
  String get noProjectsFound;

  /// No description provided for @noSponsorshipsYet.
  ///
  /// In en, this message translates to:
  /// **'No sponsorships yet'**
  String get noSponsorshipsYet;

  /// No description provided for @noUpdates.
  ///
  /// In en, this message translates to:
  /// **'No updates'**
  String get noUpdates;

  /// No description provided for @noUpdatesYet.
  ///
  /// In en, this message translates to:
  /// **'No updates yet'**
  String get noUpdatesYet;

  /// No description provided for @onlyAdminsCanAddUsers.
  ///
  /// In en, this message translates to:
  /// **'Only farmers (admins) can add new users'**
  String get onlyAdminsCanAddUsers;

  /// No description provided for @onlyAdminsCanAddUsersPlatform.
  ///
  /// In en, this message translates to:
  /// **'Only farmers (admins) can add new users to the platform'**
  String get onlyAdminsCanAddUsersPlatform;

  /// No description provided for @pleaseAddAtLeastOneImage.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one image'**
  String get pleaseAddAtLeastOneImage;

  /// No description provided for @pleaseAddAtLeastOnePhoto.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one photo'**
  String get pleaseAddAtLeastOnePhoto;

  /// No description provided for @pleaseEnterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get pleaseEnterDescription;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @pleaseEnterLandTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title for your land'**
  String get pleaseEnterLandTitle;

  /// No description provided for @pleaseEnterLocation.
  ///
  /// In en, this message translates to:
  /// **'Please enter location'**
  String get pleaseEnterLocation;

  /// No description provided for @pleaseEnterTheUser.
  ///
  /// In en, this message translates to:
  /// **'Please enter the user\'s name'**
  String get pleaseEnterTheUser;

  /// No description provided for @pleaseProvideDetailedUpdate.
  ///
  /// In en, this message translates to:
  /// **'Please provide a more detailed update (at least 10 characters)'**
  String get pleaseProvideDetailedUpdate;

  /// No description provided for @pleaseProvideProgressUpdateNote.
  ///
  /// In en, this message translates to:
  /// **'Please provide a progress update note'**
  String get pleaseProvideProgressUpdateNote;

  /// No description provided for @pleaseSpecifyFundingNeed.
  ///
  /// In en, this message translates to:
  /// **'Please specify at least one funding need'**
  String get pleaseSpecifyFundingNeed;

  /// No description provided for @pleaseSpecifyCrop.
  ///
  /// In en, this message translates to:
  /// **'Please specify the crop you plan to grow'**
  String get pleaseSpecifyCrop;

  /// No description provided for @progressNote.
  ///
  /// In en, this message translates to:
  /// **'Progress Note'**
  String get progressNote;

  /// No description provided for @progressPhotos.
  ///
  /// In en, this message translates to:
  /// **'Progress Photos'**
  String get progressPhotos;

  /// No description provided for @projectChat.
  ///
  /// In en, this message translates to:
  /// **'Project Chat'**
  String get projectChat;

  /// No description provided for @projectDetails.
  ///
  /// In en, this message translates to:
  /// **'Project Details'**
  String get projectDetails;

  /// No description provided for @projectInformation.
  ///
  /// In en, this message translates to:
  /// **'Project Information'**
  String get projectInformation;

  /// No description provided for @projectName.
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get projectName;

  /// No description provided for @projectUpdates.
  ///
  /// In en, this message translates to:
  /// **'Project Updates'**
  String get projectUpdates;

  /// No description provided for @projectsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Projects Completed'**
  String get projectsCompleted;

  /// No description provided for @projectsYouSupportCount.
  ///
  /// In en, this message translates to:
  /// **'Projects You Support ({length})'**
  String projectsYouSupportCount(Object length);

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @quickAmounts.
  ///
  /// In en, this message translates to:
  /// **'Quick amounts:'**
  String get quickAmounts;

  /// No description provided for @recentUpdates.
  ///
  /// In en, this message translates to:
  /// **'Recent Updates'**
  String get recentUpdates;

  /// No description provided for @registerLand.
  ///
  /// In en, this message translates to:
  /// **'Register Land'**
  String get registerLand;

  /// No description provided for @registerNewLand.
  ///
  /// In en, this message translates to:
  /// **'Register New Land'**
  String get registerNewLand;

  /// No description provided for @remainingNeeded.
  ///
  /// In en, this message translates to:
  /// **'Remaining needed: TND {remainingAmount}'**
  String remainingNeeded(Object remainingAmount);

  /// No description provided for @searchProjects.
  ///
  /// In en, this message translates to:
  /// **'Search projects by name, location, or crop...'**
  String get searchProjects;

  /// No description provided for @seekingFunding.
  ///
  /// In en, this message translates to:
  /// **'SEEKING FUNDING'**
  String get seekingFunding;

  /// No description provided for @selectFarmToUploadProof.
  ///
  /// In en, this message translates to:
  /// **'Select a farm to upload progress proof and keep your sponsors updated'**
  String get selectFarmToUploadProof;

  /// No description provided for @selectProjectToChat.
  ///
  /// In en, this message translates to:
  /// **'Select a project to start or continue conversation with the farmer and other sponsors'**
  String get selectProjectToChat;

  /// No description provided for @selectConversation.
  ///
  /// In en, this message translates to:
  /// **'Select Conversation'**
  String get selectConversation;

  /// No description provided for @selectFarm.
  ///
  /// In en, this message translates to:
  /// **'Select Farm'**
  String get selectFarm;

  /// No description provided for @sendEncouragementOrAskQuestions.
  ///
  /// In en, this message translates to:
  /// **'Send encouragement or ask questions...'**
  String get sendEncouragementOrAskQuestions;

  /// No description provided for @sendInvitation.
  ///
  /// In en, this message translates to:
  /// **'Send Invitation'**
  String get sendInvitation;

  /// No description provided for @sendingInvitation.
  ///
  /// In en, this message translates to:
  /// **'Sending Invitation...'**
  String get sendingInvitation;

  /// No description provided for @shareAnUpdateWithSponsors.
  ///
  /// In en, this message translates to:
  /// **'Share an update with your sponsors...'**
  String get shareAnUpdateWithSponsors;

  /// No description provided for @shareLandOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Share your land opportunities and connect with investors to grow your farming business'**
  String get shareLandOpportunities;

  /// No description provided for @sizeInHectaresRequired.
  ///
  /// In en, this message translates to:
  /// **'Size (hectares) *'**
  String get sizeInHectaresRequired;

  /// No description provided for @specifyFundingNeeds.
  ///
  /// In en, this message translates to:
  /// **'Specify how much funding you need for each category'**
  String get specifyFundingNeeds;

  /// No description provided for @sponsorLandTitle.
  ///
  /// In en, this message translates to:
  /// **'Sponsor {title}'**
  String sponsorLandTitle(Object title);

  /// No description provided for @sponsorDashboard.
  ///
  /// In en, this message translates to:
  /// **'Sponsor Dashboard'**
  String get sponsorDashboard;

  /// No description provided for @sponsorNow.
  ///
  /// In en, this message translates to:
  /// **'Sponsor Now'**
  String get sponsorNow;

  /// No description provided for @sponsorProject.
  ///
  /// In en, this message translates to:
  /// **'Sponsor Project'**
  String get sponsorProject;

  /// No description provided for @sponsorRole.
  ///
  /// In en, this message translates to:
  /// **'Sponsor Role:'**
  String get sponsorRole;

  /// No description provided for @sponsorshipAmountUsd.
  ///
  /// In en, this message translates to:
  /// **'Sponsorship Amount (\$)'**
  String get sponsorshipAmountUsd;

  /// No description provided for @sponsorshipAmountTnd.
  ///
  /// In en, this message translates to:
  /// **'Sponsorship Amount (TND)'**
  String get sponsorshipAmountTnd;

  /// No description provided for @startConversationWithSponsors.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with your sponsors'**
  String get startConversationWithSponsors;

  /// No description provided for @startTheConversation.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation! Share updates, ask questions, or offer support.'**
  String get startTheConversation;

  /// No description provided for @submitUpdate.
  ///
  /// In en, this message translates to:
  /// **'Submit Update'**
  String get submitUpdate;

  /// No description provided for @supcomAddress.
  ///
  /// In en, this message translates to:
  /// **'Sup\'Com Raoued Km 3,5 - 2083, Ariana Tunisie'**
  String get supcomAddress;

  /// No description provided for @tapToChat.
  ///
  /// In en, this message translates to:
  /// **'Tap to chat'**
  String get tapToChat;

  /// No description provided for @tapToUploadProgressProof.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload progress proof'**
  String get tapToUploadProgressProof;

  /// No description provided for @thankYouForSupporting.
  ///
  /// In en, this message translates to:
  /// **'Thank you for supporting sustainable agriculture and empowering rural farmers! 🌱'**
  String get thankYouForSupporting;

  /// No description provided for @thankYouForSponsorship.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your sponsorship!'**
  String get thankYouForSponsorship;

  /// No description provided for @farmerWillPostUpdatesHere.
  ///
  /// In en, this message translates to:
  /// **'The farmer will post progress updates here'**
  String get farmerWillPostUpdatesHere;

  /// No description provided for @transparentGroupChatDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This is a transparent group chat. All messages are visible to project participants for safety and accountability.'**
  String get transparentGroupChatDisclaimer;

  /// No description provided for @tipShareProgress.
  ///
  /// In en, this message translates to:
  /// **'Tip: Share progress photos and updates to keep everyone engaged!'**
  String get tipShareProgress;

  /// No description provided for @totalContributed.
  ///
  /// In en, this message translates to:
  /// **'Total Contributed'**
  String get totalContributed;

  /// No description provided for @totalFunding.
  ///
  /// In en, this message translates to:
  /// **'Total Funding'**
  String get totalFunding;

  /// No description provided for @totalHectares.
  ///
  /// In en, this message translates to:
  /// **'Total Hectares'**
  String get totalHectares;

  /// No description provided for @totalLands.
  ///
  /// In en, this message translates to:
  /// **'Total Lands'**
  String get totalLands;

  /// No description provided for @totalNeeded.
  ///
  /// In en, this message translates to:
  /// **'Total Needed'**
  String get totalNeeded;

  /// No description provided for @totalRaised.
  ///
  /// In en, this message translates to:
  /// **'Total Raised'**
  String get totalRaised;

  /// No description provided for @tryAdjustingSearch.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search criteria'**
  String get tryAdjustingSearch;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;

  /// No description provided for @unknownFarmer.
  ///
  /// In en, this message translates to:
  /// **'Unknown Farmer'**
  String get unknownFarmer;

  /// No description provided for @updateSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Update submitted successfully!'**
  String get updateSubmittedSuccessfully;

  /// No description provided for @updateType.
  ///
  /// In en, this message translates to:
  /// **'Update Type'**
  String get updateType;

  /// No description provided for @userInformation.
  ///
  /// In en, this message translates to:
  /// **'User Information'**
  String get userInformation;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @weatherFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Weather feature coming soon!'**
  String get weatherFeatureComingSoon;

  /// No description provided for @weeklyUpdatesRecommended.
  ///
  /// In en, this message translates to:
  /// **'Weekly updates recommended'**
  String get weeklyUpdatesRecommended;

  /// No description provided for @youNeedAdminPrivileges.
  ///
  /// In en, this message translates to:
  /// **'You need farmer (admin) privileges to add new users'**
  String get youNeedAdminPrivileges;

  /// No description provided for @youNeedActiveFarmsToUpload.
  ///
  /// In en, this message translates to:
  /// **'You need to have active farms to upload progress proofs.'**
  String get youNeedActiveFarmsToUpload;

  /// No description provided for @youNeedActiveLandsToChat.
  ///
  /// In en, this message translates to:
  /// **'You need to have active lands with sponsors to start conversations.'**
  String get youNeedActiveLandsToChat;

  /// No description provided for @youNeedToSponsorToChat.
  ///
  /// In en, this message translates to:
  /// **'You need to sponsor projects to start conversations with farmers.'**
  String get youNeedToSponsorToChat;

  /// No description provided for @yourFarmsCount.
  ///
  /// In en, this message translates to:
  /// **'Your Farms ({length})'**
  String yourFarmsCount(Object length);

  /// No description provided for @yourImpact.
  ///
  /// In en, this message translates to:
  /// **'Your Impact'**
  String get yourImpact;

  /// No description provided for @newSponsorJoinedUsd.
  ///
  /// In en, this message translates to:
  /// **'🎉 New sponsor joined! A generous contribution of \${amount} has been made to support this project.'**
  String newSponsorJoinedUsd(Object amount);

  /// No description provided for @newSponsorJoinedTnd.
  ///
  /// In en, this message translates to:
  /// **'🎉 New sponsor joined! A generous contribution of TND{amount} has been made to support this project.'**
  String newSponsorJoinedTnd(Object amount);

  /// No description provided for @photosLength.
  ///
  /// In en, this message translates to:
  /// **'{length} photo(s)'**
  String photosLength(Object length);

  /// No description provided for @fundedPercentage.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% funded'**
  String fundedPercentage(Object percentage);

  /// No description provided for @loadingWeather.
  ///
  /// In en, this message translates to:
  /// **'Loading weather...'**
  String get loadingWeather;

  /// No description provided for @weatherError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load weather data'**
  String get weatherError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @wind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get wind;

  /// No description provided for @precipitation.
  ///
  /// In en, this message translates to:
  /// **'Precipitation'**
  String get precipitation;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @sunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get sunset;

  /// No description provided for @windSpeedUnit.
  ///
  /// In en, this message translates to:
  /// **'m/s'**
  String get windSpeedUnit;

  /// No description provided for @precipitationUnit.
  ///
  /// In en, this message translates to:
  /// **'mm'**
  String get precipitationUnit;

  /// No description provided for @appBarTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Farming Assistant'**
  String get appBarTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'🌱 Hello! I\'m your AI farming assistant. I can help you with:\n\n• Plant disease identification\n• Crop care advice\n• Soil and fertilizer recommendations\n• Irrigation guidance\n• Weather-based farming tips\n\nFeel free to ask questions or upload photos of your plants!'**
  String get welcomeMessage;

  /// No description provided for @aiBanner.
  ///
  /// In en, this message translates to:
  /// **'AI-powered plant disease identification • Crop care advice • Voice enabled • 24/7 availability'**
  String get aiBanner;

  /// No description provided for @aiAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'AI is analyzing...'**
  String get aiAnalyzing;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// No description provided for @askAnything.
  ///
  /// In en, this message translates to:
  /// **'Ask anything...'**
  String get askAnything;

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image: '**
  String get errorPickingImage;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while processing your message. Please try again.'**
  String get genericError;

  /// No description provided for @photoAnalysisRequest.
  ///
  /// In en, this message translates to:
  /// **'Photo analysis request'**
  String get photoAnalysisRequest;

  /// No description provided for @takePhotoForAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Take photo for analysis'**
  String get takePhotoForAnalysis;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant Help'**
  String get helpTitle;

  /// No description provided for @helpWhatCanHelp.
  ///
  /// In en, this message translates to:
  /// **'What can the AI help you with:'**
  String get helpWhatCanHelp;

  /// No description provided for @voiceFeatures.
  ///
  /// In en, this message translates to:
  /// **'Voice Features:'**
  String get voiceFeatures;

  /// No description provided for @tipsForBetterResults.
  ///
  /// In en, this message translates to:
  /// **'Tips for better results:'**
  String get tipsForBetterResults;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get gotIt;

  /// No description provided for @voiceFeaturesDesc.
  ///
  /// In en, this message translates to:
  /// **'• Tap microphone to speak your question\n• Toggle speaker icon to enable/disable voice responses\n• Supports English, French, and Arabic'**
  String get voiceFeaturesDesc;

  /// No description provided for @tipsDesc.
  ///
  /// In en, this message translates to:
  /// **'• Take clear, well-lit photos\n• Provide specific details about your problem\n• Mention your crop type and location\n• Ask follow-up questions for clarification'**
  String get tipsDesc;

  /// No description provided for @processingTrouble.
  ///
  /// In en, this message translates to:
  /// **'I\'m having trouble processing your request. Could you try again?'**
  String get processingTrouble;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
