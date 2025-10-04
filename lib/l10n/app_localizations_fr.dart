// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get chats => 'Discussions';

  @override
  String get profile => 'Profil';

  @override
  String get proofs => 'Preuves';

  @override
  String get sponsors => 'Sponsors';

  @override
  String get settings => 'Paramètres';

  @override
  String get lands => 'Terrains';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get cancel => 'Annuler';

  @override
  String get close => 'Fermer';

  @override
  String get conversations => 'Les Conversations';

  @override
  String get plantDiseaseId => 'Identification des maladies des plantes';

  @override
  String get takePhotosOfSickPlants => 'Prendre des photos de plantes malades pour diagnostic';

  @override
  String get irrigationAdvice => 'Conseils d’irrigation';

  @override
  String get wateringSchedulesAndTechniques => 'Horaires et techniques d’arrosage';

  @override
  String get cropCare => 'Entretien des cultures';

  @override
  String get fertilizersSoilNutrition => 'Engrais et nutrition du sol';

  @override
  String get pestControl => 'Lutte contre les parasites';

  @override
  String get identifyAndTreatPlantPests => 'Identifier et traiter les parasites des plantes';

  @override
  String get weatherTips => 'Conseils météo';

  @override
  String get weatherBasedFarmingGuidance => 'Conseils agricoles basés sur la météo';

  @override
  String get title => 'Titre';

  @override
  String get size => 'Superficie';

  @override
  String get crop => 'Culture';

  @override
  String get location => 'Emplacement';

  @override
  String get progress => 'Progression';

  @override
  String get voice => 'Voix';

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
  String currentSelectedThemeMode(Object _selectedThemeMode) {
    return 'Actuel : $_selectedThemeMode';
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
    return 'Erreur de réauthentification de l\'utilisateur : $e';
  }

  @override
  String errorSendingPasswordRecoveryEmail(Object e) {
    return 'Erreur d\'envoi de l\'e-mail de récupération de mot de passe : $e';
  }

  @override
  String get errorSigningOut => 'Erreur lors de la déconnexion';

  @override
  String get errorSubmittingSupportRequest => 'Erreur lors de l\'envoi de la demande de support';

  @override
  String errorUpdatingPassword(Object e) {
    return 'Erreur de mise à jour du mot de passe : $e';
  }

  @override
  String errorUpdatingProfile(Object e) {
    return 'Erreur de mise à jour du profil : $e';
  }

  @override
  String errorSnapshotError(Object error) {
    return 'Erreur : $error';
  }

  @override
  String failedToCreateProfile(Object toString) {
    return 'Échec de la création du profil : $toString';
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

  @override
  String get camera => 'Caméra';

  @override
  String get gallery => 'Galerie';

  @override
  String get farmerRoleDescription => '• Peut ajouter et gérer des terres\n• Peut télécharger des preuves de progression\n• Peut discuter avec les sponsors\n• Peut ajouter de nouveaux utilisateurs (privilèges d\'administrateur)';

  @override
  String get sponsorRoleDescription => '• Peut parcourir et sponsoriser des projets\n• Peut discuter avec les agriculteurs\n• Peut voir les mises à jour de progression';

  @override
  String get userWithPhoneNumberExists => 'Un utilisateur avec ce numéro de téléphone existe déjà';

  @override
  String get activeLands => 'Terres Actives';

  @override
  String get activeProjects => 'Projets Actifs';

  @override
  String get activeSponsor => 'Sponsor Actif';

  @override
  String get addLand => 'Ajouter une Terre';

  @override
  String get addNewUser => 'Ajouter un Nouvel Utilisateur';

  @override
  String get addPhotosMax8 => 'Ajouter des Photos (Max 8)';

  @override
  String get addProgressPhotosMax3 => 'Ajouter des Photos de Progression (Max 3)';

  @override
  String get addUser => 'Ajouter un Utilisateur';

  @override
  String get addYourFirstFarm => 'Ajoutez Votre Première Ferme';

  @override
  String get addYourFirstLand => 'Ajoutez Votre Première Terre';

  @override
  String get addYourFirstLandToStart => 'Ajoutez votre première terre pour commencer à chercher des sponsors';

  @override
  String get aiAssistant => 'Assistant IA';

  @override
  String get aiChat => 'Chat IA';

  @override
  String get almostComplete75_99 => 'Presque Terminé (75-99%)';

  @override
  String get almostThere => 'PRESQUE FINI';

  @override
  String get amountMustBeGreaterThan0 => 'Le montant doit être supérieur à 0';

  @override
  String get amountRaised => 'Montant Collecté';

  @override
  String get applyFilters => 'Appliquer les Filtres';

  @override
  String get asAFarmerYouCanInvite => 'En tant qu\'agriculteur (admin), vous pouvez inviter de nouveaux utilisateurs à rejoindre la plateforme';

  @override
  String get basicInformation => 'Informations de Base';

  @override
  String get browseProjectsAndMakeADifference => 'Parcourez les projets disponibles et commencez à faire une différence dans les communautés agricoles rurales';

  @override
  String get browseProjects => 'Parcourir les Projets';

  @override
  String get clearFilters => 'Effacer les Filtres';

  @override
  String get appTagline => 'Connecter les agricultrices avec des investisseurs pour une agriculture durable';

  @override
  String get continueAsUser => 'Continuer en tant qu\'Utilisateur';

  @override
  String get describeCurrentProgress => 'Décrivez la progression actuelle, les défis, les réussites ou les observations...';

  @override
  String get describeYourLand => 'Décrivez votre terre, le type de sol, l\'état actuel...';

  @override
  String get descriptionRequired => 'Description *';

  @override
  String get discoverFarmingOpportunities => 'Découvrez des opportunités agricoles et soutenez l\'agriculture durable';

  @override
  String get dueSoon => 'Bientôt Échéant';

  @override
  String get emailOptional => 'Email (Optionnel)';

  @override
  String get enterSize => 'Entrez la taille';

  @override
  String get enterValidAmount => 'Entrez un montant valide';

  @override
  String errorLoadingLands(Object e) {
    return 'Erreur de chargement des terres : $e';
  }

  @override
  String get errorLoadingMessages => 'Erreur de chargement des messages';

  @override
  String errorLoadingMessagesWithDetails(Object error) {
    return 'Erreur de chargement des messages : $error';
  }

  @override
  String errorLoadingProjects(Object e) {
    return 'Erreur de chargement des projets : $e';
  }

  @override
  String errorLoadingSponsoredLands(Object e) {
    return 'Erreur de chargement des terres sponsorisées : $e';
  }

  @override
  String errorLoadingSponsorships(Object e) {
    return 'Erreur de chargement des sponsorings : $e';
  }

  @override
  String errorLoadingUpdates(Object e) {
    return 'Erreur de chargement des mises à jour : $e';
  }

  @override
  String errorLoadingYourLands(Object e) {
    return 'Erreur de chargement de vos terres : $e';
  }

  @override
  String errorOccurredWhileUploadingImage(Object e) {
    return 'Une erreur est survenue lors du téléchargement de l\'image : $e';
  }

  @override
  String errorPickingImages(Object e) {
    return 'Erreur lors de la sélection des images : $e';
  }

  @override
  String errorProcessingSponsorship(Object e) {
    return 'Erreur lors du traitement du sponsoring : $e';
  }

  @override
  String errorGeneric(Object e) {
    return 'Erreur : $e';
  }

  @override
  String get failedToLoadImage => 'Échec du chargement de l\'image';

  @override
  String failedToSendMessage(Object e) {
    return 'Échec de l\'envoi du message : $e';
  }

  @override
  String failedToUpdateRole(Object toString) {
    return 'Échec de la mise à jour du rôle : $toString';
  }

  @override
  String get failedToUploadImageAfterMultipleAttempts => 'Échec du téléchargement de l\'image après plusieurs tentatives';

  @override
  String get farmerRole => 'Rôle Agriculteur :';

  @override
  String get farmersHelped => 'Agriculteurs Aidés';

  @override
  String get filterByCrop => 'Filtrer par Culture';

  @override
  String get filterByFundingStatus => 'Filtrer par Statut de Financement';

  @override
  String get filterProjects => 'Filtrer les Projets';

  @override
  String get findProjectsToSupport => 'Trouver des Projets à Soutenir';

  @override
  String get fullName => 'Nom Complet';

  @override
  String get fullyFunded => 'Entièrement Financé';

  @override
  String get fundingBreakdown => 'Répartition du Financement';

  @override
  String get fundingNeedsTnd => 'Besoins de Financement (TND)';

  @override
  String get fundingProgress => 'Progression du Financement';

  @override
  String helpLandReachFundingGoal(Object title) {
    return 'Aidez $title à atteindre son objectif de financement !';
  }

  @override
  String get helpProjectReachFundingGoal => 'Aidez ce projet à atteindre son objectif de financement !';

  @override
  String get imAFarmer => 'Je suis un Agriculteur';

  @override
  String get imAnInvestor => 'Je suis un Investisseur';

  @override
  String get inProgress => 'EN COURS';

  @override
  String get inProgress25_75 => 'En Cours (25-75%)';

  @override
  String get intendedCropRequired => 'Culture Prévue *';

  @override
  String get invalidNumber => 'Numéro invalide';

  @override
  String get joinChat => 'Rejoindre la Discussion';

  @override
  String get justStarted0_25 => 'Vient de Commencer (0-25%)';

  @override
  String get landImages => 'Images de la Terre';

  @override
  String get landInformation => 'Informations sur la Terre';

  @override
  String get landRegisteredSuccessfully => 'Terre enregistrée avec succès !';

  @override
  String get landTitleRequired => 'Titre de la Terre *';

  @override
  String loadedLandsCount(Object length) {
    return '$length terres chargées';
  }

  @override
  String get locationRequired => 'Emplacement *';

  @override
  String get maximum3ImagesAllowedForUpdates => 'Maximum 3 images autorisées pour les mises à jour';

  @override
  String get maximum8ImagesAllowed => 'Maximum 8 images autorisées';

  @override
  String get myFarmDashboard => 'Tableau de Bord de ma Ferme';

  @override
  String get myLands => 'Mes Terres';

  @override
  String get mySponsorships => 'Mes Sponsorings';

  @override
  String get nameMustBeAtLeast2Chars => 'Le nom doit contenir au moins 2 caractères';

  @override
  String get noActiveConversations => 'Aucune Conversation Active';

  @override
  String get noAuthenticatedUser => 'Aucun utilisateur authentifié';

  @override
  String get noConversationsAvailable => 'Aucune Conversation Disponible';

  @override
  String get noFarmsToUploadProof => 'Aucune Ferme pour Télécharger une Preuve';

  @override
  String get noLandsRegisteredYet => 'Aucune terre enregistrée pour le moment';

  @override
  String get noMessagesYet => 'Aucun message pour l\'instant';

  @override
  String get noPhotosAvailable => 'Aucune photo disponible';

  @override
  String get noProjectsFound => 'Aucun projet trouvé';

  @override
  String get noSponsorshipsYet => 'Aucun sponsoring pour le moment';

  @override
  String get noUpdates => 'Aucune mise à jour';

  @override
  String get noUpdatesYet => 'Aucune mise à jour pour le moment';

  @override
  String get onlyAdminsCanAddUsers => 'Seuls les agriculteurs (admins) peuvent ajouter de nouveaux utilisateurs';

  @override
  String get onlyAdminsCanAddUsersPlatform => 'Seuls les agriculteurs (admins) peuvent ajouter de nouveaux utilisateurs à la plateforme';

  @override
  String get pleaseAddAtLeastOneImage => 'Veuillez ajouter au moins une image';

  @override
  String get pleaseAddAtLeastOnePhoto => 'Veuillez ajouter au moins une photo';

  @override
  String get pleaseEnterDescription => 'Veuillez entrer une description';

  @override
  String get pleaseEnterPhoneNumber => 'Veuillez entrer un numéro de téléphone';

  @override
  String get pleaseEnterLandTitle => 'Veuillez entrer un titre pour votre terre';

  @override
  String get pleaseEnterLocation => 'Veuillez entrer un emplacement';

  @override
  String get pleaseEnterTheUser => 'Veuillez entrer le nom de l\'utilisateur';

  @override
  String get pleaseProvideDetailedUpdate => 'Veuillez fournir une mise à jour plus détaillée (au moins 10 caractères)';

  @override
  String get pleaseProvideProgressUpdateNote => 'Veuillez fournir une note de mise à jour';

  @override
  String get pleaseSpecifyFundingNeed => 'Veuillez spécifier au moins un besoin de financement';

  @override
  String get pleaseSpecifyCrop => 'Veuillez spécifier la culture que vous prévoyez de faire pousser';

  @override
  String get progressNote => 'Note de Progression';

  @override
  String get progressPhotos => 'Photos de Progression';

  @override
  String get projectChat => 'Discussion du Projet';

  @override
  String get projectDetails => 'Détails du Projet';

  @override
  String get projectInformation => 'Informations sur le Projet';

  @override
  String get projectName => 'Nom du Projet';

  @override
  String get projectUpdates => 'Mises à Jour du Projet';

  @override
  String get projectsCompleted => 'Projets Terminés';

  @override
  String projectsYouSupportCount(Object length) {
    return 'Projets que Vous Soutenez ($length)';
  }

  @override
  String get quickActions => 'Actions Rapides';

  @override
  String get quickAmounts => 'Montants rapides :';

  @override
  String get recentUpdates => 'Mises à Jour Récentes';

  @override
  String get registerLand => 'Enregistrer une Terre';

  @override
  String get registerNewLand => 'Enregistrer une Nouvelle Terre';

  @override
  String remainingNeeded(Object remainingAmount) {
    return 'Reste nécessaire : TND $remainingAmount';
  }

  @override
  String get searchProjects => 'Rechercher des projets par nom, lieu ou culture...';

  @override
  String get seekingFunding => 'EN RECHERCHE DE FINANCEMENT';

  @override
  String get selectFarmToUploadProof => 'Sélectionnez une ferme pour télécharger une preuve de progression et tenir vos sponsors informés';

  @override
  String get selectProjectToChat => 'Sélectionnez un projet pour commencer ou continuer la conversation avec l\'agriculteur et les autres sponsors';

  @override
  String get selectConversation => 'Sélectionner la Conversation';

  @override
  String get selectFarm => 'Sélectionner la Ferme';

  @override
  String get sendEncouragementOrAskQuestions => 'Envoyez des encouragements ou posez des questions...';

  @override
  String get sendInvitation => 'Envoyer une Invitation';

  @override
  String get sendingInvitation => 'Envoi de l\'invitation...';

  @override
  String get shareAnUpdateWithSponsors => 'Partagez une mise à jour avec vos sponsors...';

  @override
  String get shareLandOpportunities => 'Partagez vos opportunités foncières et connectez-vous avec des investisseurs pour développer votre entreprise agricole';

  @override
  String get sizeInHectaresRequired => 'Taille (hectares) *';

  @override
  String get specifyFundingNeeds => 'Spécifiez le montant du financement dont vous avez besoin pour chaque catégorie';

  @override
  String sponsorLandTitle(Object title) {
    return 'Sponsoriser $title';
  }

  @override
  String get sponsorDashboard => 'Tableau de Bord du Sponsor';

  @override
  String get sponsorNow => 'Sponsoriser Maintenant';

  @override
  String get sponsorProject => 'Sponsoriser le Projet';

  @override
  String get sponsorRole => 'Rôle Sponsor :';

  @override
  String get sponsorshipAmountUsd => 'Montant du Sponsoring (\$)';

  @override
  String get sponsorshipAmountTnd => 'Montant du Sponsoring (TND)';

  @override
  String get startConversationWithSponsors => 'Commencez une conversation avec vos sponsors';

  @override
  String get startTheConversation => 'Commencez la conversation ! Partagez des mises à jour, posez des questions ou offrez votre soutien.';

  @override
  String get submitUpdate => 'Soumettre la Mise à Jour';

  @override
  String get supcomAddress => 'Sup\'Com Raoued Km 3,5 - 2083, Ariana Tunisie';

  @override
  String get tapToChat => 'Appuyez pour discuter';

  @override
  String get tapToUploadProgressProof => 'Appuyez pour télécharger la preuve de progression';

  @override
  String get thankYouForSupporting => 'Merci de soutenir l\'agriculture durable et d\'autonomiser les agriculteurs ruraux ! 🌱';

  @override
  String get thankYouForSponsorship => 'Merci pour votre sponsoring !';

  @override
  String get farmerWillPostUpdatesHere => 'L\'agriculteur publiera les mises à jour de progression ici';

  @override
  String get transparentGroupChatDisclaimer => 'Ceci est une discussion de groupe transparente. Tous les messages sont visibles par les participants au projet pour la sécurité et la responsabilité.';

  @override
  String get tipShareProgress => 'Astuce : Partagez des photos et des mises à jour de progression pour maintenir l\'engagement de tous !';

  @override
  String get totalContributed => 'Total Contribué';

  @override
  String get totalFunding => 'Financement Total';

  @override
  String get totalHectares => 'Hectares Totaux';

  @override
  String get totalLands => 'Terres Totales';

  @override
  String get totalNeeded => 'Total Nécessaire';

  @override
  String get totalRaised => 'Total Collecté';

  @override
  String get tryAdjustingSearch => 'Essayez d\'ajuster vos critères de recherche';

  @override
  String get typeAMessage => 'Écrire un message...';

  @override
  String get unknownFarmer => 'Agriculteur Inconnu';

  @override
  String get updateSubmittedSuccessfully => 'Mise à jour soumise avec succès !';

  @override
  String get updateType => 'Type de Mise à Jour';

  @override
  String get userInformation => 'Informations Utilisateur';

  @override
  String get viewDetails => 'Voir les Détails';

  @override
  String get weatherFeatureComingSoon => 'Fonctionnalité météo bientôt disponible !';

  @override
  String get weeklyUpdatesRecommended => 'Mises à jour hebdomadaires recommandées';

  @override
  String get youNeedAdminPrivileges => 'Vous avez besoin des privilèges d\'agriculteur (admin) pour ajouter de nouveaux utilisateurs';

  @override
  String get youNeedActiveFarmsToUpload => 'Vous devez avoir des fermes actives pour télécharger des preuves de progression.';

  @override
  String get youNeedActiveLandsToChat => 'Vous devez avoir des terres actives avec des sponsors pour démarrer des conversations.';

  @override
  String get youNeedToSponsorToChat => 'Vous devez sponsoriser des projets pour démarrer des conversations avec les agriculteurs.';

  @override
  String yourFarmsCount(Object length) {
    return 'Vos Fermes ($length)';
  }

  @override
  String get yourImpact => 'Votre Impact';

  @override
  String newSponsorJoinedUsd(Object amount) {
    return '🎉 Nouveau sponsor a rejoint ! Une contribution généreuse de \$$amount a été faite pour soutenir ce projet.';
  }

  @override
  String newSponsorJoinedTnd(Object amount) {
    return '🎉 Nouveau sponsor a rejoint ! Une contribution généreuse de TND$amount a été faite pour soutenir ce projet';
  }

  @override
  String photosLength(Object length) {
    return '$length photo(s)';
  }

  @override
  String fundedPercentage(Object percentage) {
    return '$percentage% financé';
  }

  @override
  String get loadingWeather => 'Chargement météo...';

  @override
  String get weatherError => 'Impossible de charger les données météo';

  @override
  String get retry => 'Réessayer';

  @override
  String get currentLocation => 'Position actuelle';

  @override
  String get temperature => 'Température';

  @override
  String get humidity => 'Humidité';

  @override
  String get wind => 'Vent';

  @override
  String get precipitation => 'Précipitations';

  @override
  String get sunrise => 'Lever du soleil';

  @override
  String get sunset => 'Coucher du soleil';

  @override
  String get windSpeedUnit => 'm/s';

  @override
  String get precipitationUnit => 'mm';

  @override
  String get appBarTitle => 'Assistant Agricole IA';

  @override
  String get welcomeMessage => '🌱 Bonjour ! Je suis ton assistant agricole intelligent. Je peux t’aider avec :\n\n• L’identification des maladies des plantes\n• Des conseils sur l’entretien des cultures\n• Des recommandations sur le sol et les engrais\n• Des conseils d’irrigation\n• Des astuces agricoles basées sur la météo\n\nN’hésite pas à poser des questions ou à envoyer des photos de tes plantes !';

  @override
  String get aiBanner => 'Identification des maladies • Conseils agricoles • Commande vocale • Disponible 24h/24';

  @override
  String get aiAnalyzing => 'L’IA analyse...';

  @override
  String get listening => 'Écoute...';

  @override
  String get askAnything => 'Demande ce que tu veux...';

  @override
  String get errorPickingImage => 'Erreur lors du choix de l’image : ';

  @override
  String get genericError => 'Une erreur est survenue lors du traitement de ton message. Réessaie.';

  @override
  String get photoAnalysisRequest => 'Demande d’analyse de photo';

  @override
  String get takePhotoForAnalysis => 'Prendre une photo pour analyse';

  @override
  String get helpTitle => 'Aide de l’assistant IA';

  @override
  String get helpWhatCanHelp => 'Ce que l’IA peut faire pour toi :';

  @override
  String get voiceFeatures => 'Fonctionnalités vocales :';

  @override
  String get tipsForBetterResults => 'Conseils pour de meilleurs résultats :';

  @override
  String get gotIt => 'Compris !';

  @override
  String get voiceFeaturesDesc => '• Appuie sur le micro pour poser ta question\n• Active ou désactive les réponses vocales avec l’icône du haut-parleur\n• Prend en charge l’anglais, le français et l’arabe';

  @override
  String get tipsDesc => '• Prends des photos claires et bien éclairées\n• Donne des détails précis sur ton problème\n• Mentionne ton type de culture et ta localisation\n• Pose des questions de suivi si besoin';

  @override
  String get processingTrouble => 'J’ai du mal à traiter ta demande. Peux-tu réessayer ?';
}
