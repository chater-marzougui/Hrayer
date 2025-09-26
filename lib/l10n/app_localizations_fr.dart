// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get anUnexpectedErrorOccurred => 'Une erreur inattendue s\'est produite';

  @override
  String get applyChanges => 'Appliquer les changements';

  @override
  String get areYouSureYouWantToLogout => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get chooseAnImageSource => 'Choisissez une source d\'image';

  @override
  String get completeProfile => 'Compléter le profil';

  @override
  String get completeYourProfile => 'Complétez votre profil';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get contactInformation => 'Informations de contact';

  @override
  String get contactSupport => 'Contacter le support';

  @override
  String get createAnAccount => 'Créer un compte';

  @override
  String currentSelectedThemeMode(Object mode) {
    return 'Actuel : $mode';
  }

  @override
  String get dartTemplate => 'Modèle Dart';

  @override
  String get dontHaveAnAccountSignUp => 'Vous n\'avez pas de compte ? S\'inscrire';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get emailAddress => 'Adresse e-mail';

  @override
  String get enableNotifications => 'Activer les notifications';

  @override
  String get enterTheSubjectOfYourMessage => 'Entrez le sujet de votre message';

  @override
  String get enterYourEmail => 'Entrez votre e-mail';

  @override
  String get enterYourEmailToRecoverYourPassword => 'Entrez votre e-mail pour récupérer votre mot de passe';

  @override
  String get enterYourMessage => 'Entrez votre message';

  @override
  String get enterYourName => 'Entrez votre nom';

  @override
  String get enterYourPassword => 'Entrez votre mot de passe';

  @override
  String get errorOccurredDuringSignup => 'Une erreur s\'est produite lors de l\'inscription.';

  @override
  String errorOccurredWhileUploadingTheImage(Object e) {
    return 'Une erreur s\'est produite lors du téléchargement de l\'image : $e';
  }

  @override
  String errorPostingComment(Object e) {
    return 'Erreur lors de la publication du commentaire : $e';
  }

  @override
  String errorReauthenticatingUser(Object e) {
    return 'Erreur lors de la réauthentification de l\'utilisateur : $e';
  }

  @override
  String errorSendingPasswordRecoveryEmail(Object e) {
    return 'Erreur lors de l\'envoi de l\'e-mail de récupération de mot de passe : $e';
  }

  @override
  String get errorSigningOut => 'Erreur lors de la déconnexion';

  @override
  String get errorSubmittingSupportRequest => 'Erreur lors de l\'envoi de la demande de support';

  @override
  String errorUpdatingPassword(Object e) {
    return 'Erreur lors de la mise à jour du mot de passe : $e';
  }

  @override
  String errorUpdatingProfile(Object e) {
    return 'Erreur lors de la mise à jour du profil : $e';
  }

  @override
  String errorSnapshotError(Object error) {
    return 'Erreur : $error';
  }

  @override
  String failedToCreateProfile(Object e) {
    return 'Échec de la création du profil : $e';
  }

  @override
  String get failedToUploadImage => 'Échec du téléchargement de l\'image';

  @override
  String get firstName => 'Prénom';

  @override
  String get firstNameIsRequired => 'Le prénom est requis';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get genderIsRequired => 'Le genre est requis';

  @override
  String get incorrectPassword => 'Mot de passe incorrect';

  @override
  String get invalidEmailAddress => 'Adresse e-mail invalide';

  @override
  String get lastName => 'Nom de famille';

  @override
  String get lastNameIsRequired => 'Le nom de famille est requis';

  @override
  String get loginFailed => 'Échec de la connexion';

  @override
  String loginFailedWithMessage(Object message) {
    return 'Échec de la connexion : $message';
  }

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get noAccountFoundWithThisEmail => 'Aucun compte trouvé avec cet e-mail';

  @override
  String get noCommentsYet => 'Aucun commentaire pour l\'instant';

  @override
  String get oldPassword => 'Ancien mot de passe';

  @override
  String get orContinueWith => 'Ou continuer avec';

  @override
  String get passwordRequirements => 'Le mot de passe doit comporter au moins 8 caractères et contenir un chiffre';

  @override
  String get passwordUpdatedSuccessfully => 'Mot de passe mis à jour avec succès';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get passwordsDoNotMatchExclamation => 'Les mots de passe ne correspondent pas !';

  @override
  String get personalAccount => 'Compte personnel';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get phoneNumberIsRequired => 'Le numéro de téléphone est requis';

  @override
  String get pleaseConfirmYourPassword => 'Veuillez confirmer votre mot de passe';

  @override
  String pleaseEnterLabel(Object label) {
    return 'Veuillez entrer $label';
  }

  @override
  String get pleaseEnterAPassword => 'Veuillez entrer un mot de passe';

  @override
  String get pleaseEnterAValidEmailAddress => 'Veuillez entrer une adresse e-mail valide';

  @override
  String get pleaseEnterAValidPhoneNumber => 'Veuillez entrer un numéro de téléphone valide';

  @override
  String get pleaseEnterYourEmail => 'Veuillez entrer votre e-mail';

  @override
  String get pleaseEnterYourFirstName => 'Veuillez entrer votre prénom';

  @override
  String get pleaseEnterYourLastName => 'Veuillez entrer votre nom de famille';

  @override
  String get pleaseFillInAllFields => 'Veuillez remplir tous les champs';

  @override
  String get pleaseSelectYourBirthdate => 'Veuillez sélectionner votre date de naissance';

  @override
  String get pleaseSelectYourGender => 'Veuillez sélectionner votre genre';

  @override
  String get postedBy => 'Publié par';

  @override
  String get profileUpdatedSuccessfully => 'Profil mis à jour avec succès';

  @override
  String get randomText => 'Texte aléatoire';

  @override
  String get recoverPassword => 'Récupérer le mot de passe';

  @override
  String get selectYourBirthdate => 'Sélectionnez votre date de naissance';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signInToContinueYourJourney => 'Connectez-vous pour continuer votre voyage';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get signingIn => 'Connexion en cours...';

  @override
  String get submitRequest => 'Envoyer la demande';

  @override
  String get supportRequestSubmittedSuccessfully => 'Demande de support envoyée avec succès';

  @override
  String get tapAgainToExit => 'Appuyez à nouveau pour quitter';

  @override
  String get textOnButton => 'Texte sur le bouton';

  @override
  String get themeMode => 'Mode du thème';

  @override
  String get thisAccountHasBeenDisabled => 'Ce compte a été désactivé';

  @override
  String get thisPageIsAPlaceHolder => 'Cette page est un espace réservé';

  @override
  String get tooManyFailedAttempts => 'Trop de tentatives échouées. Veuillez réessayer plus tard';

  @override
  String get typeYourOldPasswordAndTheNewOneToApplyChanges => 'Saisissez votre ancien mot de passe et le nouveau pour appliquer les changements';

  @override
  String get typeYourPasswordToApplyChanges => 'Saisissez votre mot de passe pour appliquer les changements';

  @override
  String get unknownUser => 'Utilisateur inconnu';

  @override
  String get userNotLoggedIn => 'Utilisateur non connecté';

  @override
  String get weNeedAFewMoreDetails => 'Nous avons besoin de quelques détails supplémentaires pour vous lancer';

  @override
  String get welcomeBack => 'Content de vous revoir !';

  @override
  String get wouldYouLikeToTakeAPictureOrChooseFromGallery => 'Voulez-vous prendre une photo ou choisir dans la galerie ?';

  @override
  String get writeAComment => 'Écrire un commentaire...';

  @override
  String get wrongPassword => 'Mauvais mot de passe';

  @override
  String get youCanInteractWithMeInMultipleWays => 'Vous pouvez interagir avec moi de plusieurs manières :';

  @override
  String get hiThereImBBot => '👋 Salut ! Je suis B-BOT';
}
