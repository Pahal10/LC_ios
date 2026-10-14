import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

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
    Locale('en'),
    Locale('es'),
    Locale('pt')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Connect'**
  String get appName;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @errorWithDetail.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithDetail(String error);

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @newHere.
  ///
  /// In en, this message translates to:
  /// **'New here?'**
  String get newHere;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @loginEmptyFields.
  ///
  /// In en, this message translates to:
  /// **'Please type a username and password or register'**
  String get loginEmptyFields;

  /// No description provided for @loginInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get loginInvalid;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed: {error}'**
  String googleSignInFailed(String error);

  /// No description provided for @appleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in failed: {error}'**
  String appleSignInFailed(String error);

  /// No description provided for @promoCodeOptional.
  ///
  /// In en, this message translates to:
  /// **'Promo Code (Optional)'**
  String get promoCodeOptional;

  /// No description provided for @promoCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Promo Code'**
  String get promoCodeTitle;

  /// No description provided for @promoCodeInfo.
  ///
  /// In en, this message translates to:
  /// **'If you enter another user\'s promo code during registration, both of you will receive one Premium Reward at your registered email.'**
  String get promoCodeInfo;

  /// No description provided for @agreeCommunications.
  ///
  /// In en, this message translates to:
  /// **'I agree to receive communications from you at this email'**
  String get agreeCommunications;

  /// No description provided for @agreeCommunicationsOccasional.
  ///
  /// In en, this message translates to:
  /// **'I agree to receive occasional communications from Let\'s Connect'**
  String get agreeCommunicationsOccasional;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @mustAgreeCommunicationsEmail.
  ///
  /// In en, this message translates to:
  /// **'Please agree to receive communications at your email to register'**
  String get mustAgreeCommunicationsEmail;

  /// No description provided for @mustAgreeCommunications.
  ///
  /// In en, this message translates to:
  /// **'Please agree to receive communications to continue'**
  String get mustAgreeCommunications;

  /// No description provided for @usernameExists.
  ///
  /// In en, this message translates to:
  /// **'Username already exists'**
  String get usernameExists;

  /// No description provided for @emailRegistered.
  ///
  /// In en, this message translates to:
  /// **'Email already registered'**
  String get emailRegistered;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get registrationSuccessful;

  /// No description provided for @invalidPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid promo code.'**
  String get invalidPromoCode;

  /// No description provided for @niceTry.
  ///
  /// In en, this message translates to:
  /// **'Nice try 😊'**
  String get niceTry;

  /// No description provided for @chooseUsername.
  ///
  /// In en, this message translates to:
  /// **'Choose a username'**
  String get chooseUsername;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled.'**
  String get locationServicesDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied.'**
  String get locationPermissionDeniedForever;

  /// No description provided for @locationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Location updated successfully. You can turn off Location Services now.'**
  String get locationUpdated;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @getStartedPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to create your account.'**
  String get getStartedPrompt;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email.'**
  String get enterYourEmail;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkYourEmail;

  /// No description provided for @getStartedEmailSent.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent you an email containing the link to create your Let\'s Connect account.'**
  String get getStartedEmailSent;

  /// No description provided for @couldntSendEmail.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send email'**
  String get couldntSendEmail;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter the email linked to your account.'**
  String get forgotPasswordPrompt;

  /// No description provided for @sendResetCode.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Code'**
  String get sendResetCode;

  /// No description provided for @emailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Email not found'**
  String get emailNotFound;

  /// No description provided for @resetCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Reset code sent'**
  String get resetCodeSent;

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent'**
  String get passwordResetEmailSent;

  /// No description provided for @verifyCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get verifyCodeTitle;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'A code was sent to\n{email}'**
  String codeSentTo(String email);

  /// No description provided for @resetCode.
  ///
  /// In en, this message translates to:
  /// **'Reset Code'**
  String get resetCode;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code'**
  String get invalidCode;

  /// No description provided for @codeExpired.
  ///
  /// In en, this message translates to:
  /// **'Code expired'**
  String get codeExpired;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get passwordUpdated;

  /// No description provided for @welcomeToLC.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Let\'s Connect'**
  String get welcomeToLC;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Please choose an option below, so that we can help you better.'**
  String get welcomeTagline;

  /// No description provided for @wantToMakeFriends.
  ///
  /// In en, this message translates to:
  /// **'I want to make friends'**
  String get wantToMakeFriends;

  /// No description provided for @iFeelLonely.
  ///
  /// In en, this message translates to:
  /// **'I feel lonely'**
  String get iFeelLonely;

  /// No description provided for @stageSmallTalk.
  ///
  /// In en, this message translates to:
  /// **'Small Talk'**
  String get stageSmallTalk;

  /// No description provided for @stageMediumTalk.
  ///
  /// In en, this message translates to:
  /// **'Medium Talk'**
  String get stageMediumTalk;

  /// No description provided for @stageBigTalk.
  ///
  /// In en, this message translates to:
  /// **'Big Talk'**
  String get stageBigTalk;

  /// No description provided for @stageVoiceCall.
  ///
  /// In en, this message translates to:
  /// **'Voice Call'**
  String get stageVoiceCall;

  /// No description provided for @stagePlayDate.
  ///
  /// In en, this message translates to:
  /// **'Play Date'**
  String get stagePlayDate;

  /// No description provided for @stageHygge.
  ///
  /// In en, this message translates to:
  /// **'Hygge'**
  String get stageHygge;

  /// No description provided for @chooseAStage.
  ///
  /// In en, this message translates to:
  /// **'Choose a Stage'**
  String get chooseAStage;

  /// No description provided for @taskDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get taskDone;

  /// No description provided for @anotherTask.
  ///
  /// In en, this message translates to:
  /// **'Another Task'**
  String get anotherTask;

  /// No description provided for @shhInsiderInfo.
  ///
  /// In en, this message translates to:
  /// **'Shh: insider info'**
  String get shhInsiderInfo;

  /// No description provided for @bigTalkInsightTitle.
  ///
  /// In en, this message translates to:
  /// **'💡 Big Talk Insight'**
  String get bigTalkInsightTitle;

  /// No description provided for @quickQuestion.
  ///
  /// In en, this message translates to:
  /// **'Quick Question'**
  String get quickQuestion;

  /// No description provided for @feelMoreConnected.
  ///
  /// In en, this message translates to:
  /// **'Do you feel more connected to other people?'**
  String get feelMoreConnected;

  /// No description provided for @comfortableQuestion.
  ///
  /// In en, this message translates to:
  /// **'Were you comfortable doing it?'**
  String get comfortableQuestion;

  /// No description provided for @somewhat.
  ///
  /// In en, this message translates to:
  /// **'Somewhat'**
  String get somewhat;

  /// No description provided for @couldntSendReward.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send reward.'**
  String get couldntSendReward;

  /// No description provided for @couldntSendVerifyLink.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send Task Verification Link.'**
  String get couldntSendVerifyLink;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeTitle;

  /// No description provided for @introDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Loneliness, or the inability to connect with others, is a feeling, not a disease. So we will help you as a human journey rather than a pill you take every day. This app isn\'t a magic tool for not being lonely, but rather a helper in overcoming this feeling. Since you have downloaded this app, I think I can start this journey with you. We will start slowly with small talk, like asking someone what time it is. If you don\'t want to do a task, press \"Another Task\" and the app will randomly pick another one for you. This option is unlimited, but remember time isn\'t. So pick one and just try it out. When you are done, press the Done button to return to the main page. Remember: you are not compelled to do the tasks. We are just here to help you if you need it :)'**
  String get introDialogBody;

  /// No description provided for @letsBegin.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Begin'**
  String get letsBegin;

  /// No description provided for @playDateIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Play Time'**
  String get playDateIntroTitle;

  /// No description provided for @playDateIntroBody.
  ///
  /// In en, this message translates to:
  /// **'So far on this journey, you\'ve practiced starting conversations and building connections with other people.\n\nConversations are powerful because they help us learn about another person\'s experiences, thoughts, and story. However, conversations alone don\'t create shared memories.\n\nMany friendships grow stronger through shared experiences: playing games, working on activities together, exploring new places, or simply spending time together.\n\nIn this stage, you\'ll receive suggestions for games and activities that can be done with other people.\n\nThese are only recommendations. You are never required to play a particular game, and you\'re always free to choose a different activity that feels more comfortable or enjoyable.\n\nThe goal isn\'t to complete a specific game, but rather to make jokes, tease each other and make memories.'**
  String get playDateIntroBody;

  /// No description provided for @hyggeIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Hygge'**
  String get hyggeIntroTitle;

  /// No description provided for @hyggeIntroBody.
  ///
  /// In en, this message translates to:
  /// **'For several years, Scandinavian countries have topped the list of the happiest countries in the world. There can be speculation, but we believe the culture of Hygge (pronounced hoo-gah) is one reason.\nHygge is a Danish concept that, in short, means taking time out of your busy schedule for coziness and comfort with friends. It doesn\'t involve specific things to do, but rather simple routines like drinking hot chocolate and playing board games under warm lighting.\n\nIn Hygge, the setting of comfort and coziness is more important than the activity itself. We are going to give you some suggestions, but we also advise you to make your own routines and activities.\n\nP.S. This is the ultimate form of social connection.'**
  String get hyggeIntroBody;

  /// No description provided for @bigTalkIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Big Talk'**
  String get bigTalkIntroTitle;

  /// No description provided for @bigTalkIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Almost everyone knows about small talk. However, it leads to shallow connections. The deeper we go into a person\'s life, the more connected we feel with them. On this idea, an undergraduate (Kalina Silverman) came up with a solution to loneliness and named it along the lines of small talk: Big Talk. In the following section, you will be given prompts that go deeper than basic questions. We advise you to practice these conversations with someone you already know (to make you feel comfortable with Big Talk), and later try them with strangers. Another piece of advice is to keep the conversation going for at least 5 minutes, because it would be awkward for the other person (and for your brain) if you ask a deep question and end the conversation abruptly. Your brain will likely crash from deep connection to suddenly zero.\nTo keep the conversation going you can remember small talk topics or just ask other related things to the question you just asked. As always, if you feel you aren\'t able to do it at any point, you can opt out, but remember short-term anxiety and doubt won\'t solve your long-term loneliness.'**
  String get bigTalkIntroBody;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations 🎉'**
  String get congratulations;

  /// No description provided for @graduationBody.
  ///
  /// In en, this message translates to:
  /// **'This marks the end of your journey through the guided stages. You started from small conversations and made it to the ultimate medium of social connection: Hygge. If your goal of connecting with others or feeling less lonely was not met, you can write us an email and we can help you directly. However, if you feel less lonely than before (it\'s fine if it isn\'t zero), we advise you to keep going down this road of maintaining and building connections. We suggest this because if you stop, your social connections will shrink, and a brain used to your current level of connection will feel socially hungry (aka lonely).\n\nWe do not ask you to keep using this app, but we can still help you if you need ideas. After this point, the Let\'s connect button on your main screen will open a page that gives you a button for each stage you went through. If you need it, you can choose a stage and take prompts from there.\n\nInstead of saying goodbye, we are going to ask you a self-reflection question. Do you feel less lonely after taking our help?'**
  String get graduationBody;

  /// No description provided for @yesSmile.
  ///
  /// In en, this message translates to:
  /// **'Yes :)'**
  String get yesSmile;

  /// No description provided for @noSad.
  ///
  /// In en, this message translates to:
  /// **'No :('**
  String get noSad;

  /// No description provided for @realityCheck1.
  ///
  /// In en, this message translates to:
  /// **'People usually enjoy conversations with strangers more than they expect.'**
  String get realityCheck1;

  /// No description provided for @realityCheck2.
  ///
  /// In en, this message translates to:
  /// **'People expect only 40% of strangers to respond in a friendly manner to a spontaneous conversation, but in fact 92% do.'**
  String get realityCheck2;

  /// No description provided for @realityCheck3.
  ///
  /// In en, this message translates to:
  /// **'At first meeting, people like you more than you think.'**
  String get realityCheck3;

  /// No description provided for @realityCheck4.
  ///
  /// In en, this message translates to:
  /// **'The anticipation of a conversation is often scarier than the conversation itself.'**
  String get realityCheck4;

  /// No description provided for @realityCheck5.
  ///
  /// In en, this message translates to:
  /// **'A brief conversation can improve both people\'s moods.'**
  String get realityCheck5;

  /// No description provided for @realityCheck6.
  ///
  /// In en, this message translates to:
  /// **'You never know what new way of living you will discover today. You might even find a full-time philosopher!'**
  String get realityCheck6;

  /// No description provided for @realityCheck7.
  ///
  /// In en, this message translates to:
  /// **'Deep connections start with talking, and talking starts with approaching someone on a random day.'**
  String get realityCheck7;

  /// No description provided for @realityCheck8.
  ///
  /// In en, this message translates to:
  /// **'A connection doesn\'t have to be perfect the first time you meet. Two people who absolutely hate each other have been known to become best friends.'**
  String get realityCheck8;

  /// No description provided for @realityCheck9.
  ///
  /// In en, this message translates to:
  /// **'Many people are hoping someone talks to them first.'**
  String get realityCheck9;

  /// No description provided for @realityCheck10.
  ///
  /// In en, this message translates to:
  /// **'When we are hungry and have food in front of us, we eat. Loneliness is social hunger. When you find a person in front of you, take a bite of the social pie (don\'t worry, I\'m not asking you to eat anyone).'**
  String get realityCheck10;

  /// No description provided for @realityCheck11.
  ///
  /// In en, this message translates to:
  /// **'Small talk isn\'t the opposite of connection. It\'s often the doorway to it.'**
  String get realityCheck11;

  /// No description provided for @realityCheck12.
  ///
  /// In en, this message translates to:
  /// **'Most people respond kindly to simple, respectful questions.'**
  String get realityCheck12;

  /// No description provided for @bigTalkInsight1.
  ///
  /// In en, this message translates to:
  /// **'Meaningful friendships rarely grow from small talk alone.'**
  String get bigTalkInsight1;

  /// No description provided for @bigTalkInsight2.
  ///
  /// In en, this message translates to:
  /// **'Most people enjoy being asked thoughtful questions more than we expect.'**
  String get bigTalkInsight2;

  /// No description provided for @bigTalkInsight3.
  ///
  /// In en, this message translates to:
  /// **'Many people wish conversations would go deeper but are waiting for someone else to start.'**
  String get bigTalkInsight3;

  /// No description provided for @bigTalkInsight4.
  ///
  /// In en, this message translates to:
  /// **'Vulnerability often strengthens relationships rather than weakening them.'**
  String get bigTalkInsight4;

  /// No description provided for @bigTalkInsight5.
  ///
  /// In en, this message translates to:
  /// **'Being interested is more important than being interesting.'**
  String get bigTalkInsight5;

  /// No description provided for @bigTalkInsight6.
  ///
  /// In en, this message translates to:
  /// **'People usually remember how a conversation felt, not whether every word was perfect.'**
  String get bigTalkInsight6;

  /// No description provided for @bigTalkInsight7.
  ///
  /// In en, this message translates to:
  /// **'A meaningful question can create more connection than an hour of casual conversation.'**
  String get bigTalkInsight7;

  /// No description provided for @bigTalkInsight8.
  ///
  /// In en, this message translates to:
  /// **'Most people appreciate feeling genuinely listened to.'**
  String get bigTalkInsight8;

  /// No description provided for @bigTalkInsight9.
  ///
  /// In en, this message translates to:
  /// **'The goal of Big Talk is understanding, not impressing.'**
  String get bigTalkInsight9;

  /// No description provided for @bigTalkInsight10.
  ///
  /// In en, this message translates to:
  /// **'Connection grows when people share experiences, values, and perspectives.'**
  String get bigTalkInsight10;

  /// No description provided for @taskSmallTalk1.
  ///
  /// In en, this message translates to:
  /// **'Ask someone what time it is'**
  String get taskSmallTalk1;

  /// No description provided for @taskSmallTalk2.
  ///
  /// In en, this message translates to:
  /// **'Ask someone if there is a washroom nearby'**
  String get taskSmallTalk2;

  /// No description provided for @taskSmallTalk3.
  ///
  /// In en, this message translates to:
  /// **'Ask someone for directions to a nearby coffee place'**
  String get taskSmallTalk3;

  /// No description provided for @taskSmallTalk4.
  ///
  /// In en, this message translates to:
  /// **'Ask someone if there\'s an ATM nearby'**
  String get taskSmallTalk4;

  /// No description provided for @taskSmallTalk5.
  ///
  /// In en, this message translates to:
  /// **'Ask someone what day or date it is'**
  String get taskSmallTalk5;

  /// No description provided for @taskMediumTalk1.
  ///
  /// In en, this message translates to:
  /// **'Compliment someone on one of their accessories and ask where they got it from'**
  String get taskMediumTalk1;

  /// No description provided for @taskMediumTalk2.
  ///
  /// In en, this message translates to:
  /// **'Talk about a personal memory'**
  String get taskMediumTalk2;

  /// No description provided for @taskBigTalk1.
  ///
  /// In en, this message translates to:
  /// **'Ask someone about their biggest fear'**
  String get taskBigTalk1;

  /// No description provided for @taskBigTalk2.
  ///
  /// In en, this message translates to:
  /// **'Discuss life goals with someone'**
  String get taskBigTalk2;

  /// No description provided for @taskBigTalk3.
  ///
  /// In en, this message translates to:
  /// **'If you could throw your dream party with an unlimited budget, what would it look like?'**
  String get taskBigTalk3;

  /// No description provided for @taskBigTalk4.
  ///
  /// In en, this message translates to:
  /// **'What legacy do you want to leave behind?'**
  String get taskBigTalk4;

  /// No description provided for @taskBigTalk5.
  ///
  /// In en, this message translates to:
  /// **'What is a seasonal tradition that you look forward to every year?'**
  String get taskBigTalk5;

  /// No description provided for @taskBigTalk6.
  ///
  /// In en, this message translates to:
  /// **'When was one time in your life that you felt the bravest?'**
  String get taskBigTalk6;

  /// No description provided for @taskBigTalk7.
  ///
  /// In en, this message translates to:
  /// **'If you could build a team of 5 superheroes to fight alongside you against aliens, who would they be?'**
  String get taskBigTalk7;

  /// No description provided for @taskBigTalk8.
  ///
  /// In en, this message translates to:
  /// **'If you became the opposite gender for a day, how would you spend that day?'**
  String get taskBigTalk8;

  /// No description provided for @taskBigTalk9.
  ///
  /// In en, this message translates to:
  /// **'If you could change your country of birth and live the life of people there, which country would you choose and why?'**
  String get taskBigTalk9;

  /// No description provided for @taskBigTalk10.
  ///
  /// In en, this message translates to:
  /// **'If you could recreate a memory with me, which one would you want to recreate?'**
  String get taskBigTalk10;

  /// No description provided for @taskBigTalk11.
  ///
  /// In en, this message translates to:
  /// **'If you were suddenly given the job of a Netflix storywriter, what would your first story be?'**
  String get taskBigTalk11;

  /// No description provided for @taskBigTalk12.
  ///
  /// In en, this message translates to:
  /// **'What is one nonphysical scar from your childhood that you haven\'t shared with me?'**
  String get taskBigTalk12;

  /// No description provided for @taskVoiceCall1.
  ///
  /// In en, this message translates to:
  /// **'Call a friend and talk about topics of your choice for at least 5 minutes'**
  String get taskVoiceCall1;

  /// No description provided for @taskPlayDate1.
  ///
  /// In en, this message translates to:
  /// **'Play the board game LIFE'**
  String get taskPlayDate1;

  /// No description provided for @taskPlayDate2.
  ///
  /// In en, this message translates to:
  /// **'Learn a new card game together and play it'**
  String get taskPlayDate2;

  /// No description provided for @taskPlayDate3.
  ///
  /// In en, this message translates to:
  /// **'Play an online game together (less recommended, because real-life games offer more connection)'**
  String get taskPlayDate3;

  /// No description provided for @taskPlayDate4.
  ///
  /// In en, this message translates to:
  /// **'Play Monopoly'**
  String get taskPlayDate4;

  /// No description provided for @taskPlayDate5.
  ///
  /// In en, this message translates to:
  /// **'Play Pictionary'**
  String get taskPlayDate5;

  /// No description provided for @taskPlayDate6.
  ///
  /// In en, this message translates to:
  /// **'Play antakshari (it\'s fine if you don\'t pronounce it well; if you don\'t know it, search it up)'**
  String get taskPlayDate6;

  /// No description provided for @taskPlayDate7.
  ///
  /// In en, this message translates to:
  /// **'Play charades'**
  String get taskPlayDate7;

  /// No description provided for @taskPlayDate8.
  ///
  /// In en, this message translates to:
  /// **'Search up \"Minute to Win It\" games'**
  String get taskPlayDate8;

  /// No description provided for @taskPlayDate9.
  ///
  /// In en, this message translates to:
  /// **'Try choreographing a song together and take a video of the final version (and behind-the-scenes if you want)'**
  String get taskPlayDate9;

  /// No description provided for @taskPlayDate10.
  ///
  /// In en, this message translates to:
  /// **'Play football or basketball'**
  String get taskPlayDate10;

  /// No description provided for @taskPlayDate11.
  ///
  /// In en, this message translates to:
  /// **'Play Cluedo'**
  String get taskPlayDate11;

  /// No description provided for @taskHygge1.
  ///
  /// In en, this message translates to:
  /// **'Lie on a couch with a hot chocolate (or a cold drink) and have a deep conversation'**
  String get taskHygge1;

  /// No description provided for @taskHygge2.
  ///
  /// In en, this message translates to:
  /// **'Cook or study together peacefully'**
  String get taskHygge2;

  /// No description provided for @taskHygge3.
  ///
  /// In en, this message translates to:
  /// **'Play a board game together'**
  String get taskHygge3;

  /// No description provided for @taskHygge4.
  ///
  /// In en, this message translates to:
  /// **'Start an intellectual conversation about economics or the world around you'**
  String get taskHygge4;

  /// No description provided for @questionnaire.
  ///
  /// In en, this message translates to:
  /// **'Questionnaire'**
  String get questionnaire;

  /// No description provided for @whyLonely.
  ///
  /// In en, this message translates to:
  /// **'Why do you think you feel lonely?'**
  String get whyLonely;

  /// No description provided for @reasonCantTalk.
  ///
  /// In en, this message translates to:
  /// **'Not able to talk to people or make friends'**
  String get reasonCantTalk;

  /// No description provided for @reasonMoved.
  ///
  /// In en, this message translates to:
  /// **'I moved to a new place without most of my close friends/go to people'**
  String get reasonMoved;

  /// No description provided for @reasonLoss.
  ///
  /// In en, this message translates to:
  /// **'I recently lost someone close, and that left a hole in my social net'**
  String get reasonLoss;

  /// No description provided for @reasonNotUnderstood.
  ///
  /// In en, this message translates to:
  /// **'People around me don\'t understand me'**
  String get reasonNotUnderstood;

  /// No description provided for @reasonOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get reasonOthers;

  /// No description provided for @misunderstoodTitle.
  ///
  /// In en, this message translates to:
  /// **'People do not understand me'**
  String get misunderstoodTitle;

  /// No description provided for @misunderstoodBody.
  ///
  /// In en, this message translates to:
  /// **'It is a tough feeling when people do not understand you...\n\nThis can occur either once/few times or frequently/always. If you tell us which one applies to you, we can help you.'**
  String get misunderstoodBody;

  /// No description provided for @onceFewTimes.
  ///
  /// In en, this message translates to:
  /// **'Once/Few Times'**
  String get onceFewTimes;

  /// No description provided for @frequentlyAlways.
  ///
  /// In en, this message translates to:
  /// **'Frequently/Always'**
  String get frequentlyAlways;

  /// No description provided for @possibleReasonsTitle.
  ///
  /// In en, this message translates to:
  /// **'Possible Reasons'**
  String get possibleReasonsTitle;

  /// No description provided for @possibleReasonsBody.
  ///
  /// In en, this message translates to:
  /// **'If this problem occurred a limited number of times, then it could be due to 2 main reasons:\n\n1. Problem in the person\'s ability to understand you due to difference in opinion/their mood isn\'t right/etc.\n\n2. Language differences/accent problems/etc. with the person you talked to.'**
  String get possibleReasonsBody;

  /// No description provided for @twoOptionsBody.
  ///
  /// In en, this message translates to:
  /// **'In that case you have two options.\n\n1. Try explaining it to them again\n\n2. Find new people who would potentially understand you.'**
  String get twoOptionsBody;

  /// No description provided for @explainAgain.
  ///
  /// In en, this message translates to:
  /// **'I will try explaining again'**
  String get explainAgain;

  /// No description provided for @helpFindConnections.
  ///
  /// In en, this message translates to:
  /// **'Help me find new connections'**
  String get helpFindConnections;

  /// No description provided for @noDirectHelpBody.
  ///
  /// In en, this message translates to:
  /// **'We do not have direct help within the app for that, but you can try translators or accent helpers.\n\nWe have suggested a few platforms below to guide you :)'**
  String get noDirectHelpBody;

  /// No description provided for @whichIsTrue.
  ///
  /// In en, this message translates to:
  /// **'Which of the following is true?'**
  String get whichIsTrue;

  /// No description provided for @particularGroup.
  ///
  /// In en, this message translates to:
  /// **'With a particular group of people'**
  String get particularGroup;

  /// No description provided for @withEveryone.
  ///
  /// In en, this message translates to:
  /// **'With everyone'**
  String get withEveryone;

  /// No description provided for @newConnectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'New Connections'**
  String get newConnectionsTitle;

  /// No description provided for @newConnectionsBody.
  ///
  /// In en, this message translates to:
  /// **'Sometimes differences between people are so high that connections are not formed well.\n\nIn that case, our best bet is to move on and find new connections.\n\nDo you want to make new connections?'**
  String get newConnectionsBody;

  /// No description provided for @yesLetsConnect.
  ///
  /// In en, this message translates to:
  /// **'Yes! Let\'s connect'**
  String get yesLetsConnect;

  /// No description provided for @noTryExplainingAgain.
  ///
  /// In en, this message translates to:
  /// **'No. I want to try once again explaining them'**
  String get noTryExplainingAgain;

  /// No description provided for @othersDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'It is fine if you do not fit one of the options :)'**
  String get othersDialogTitle;

  /// No description provided for @othersDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Email at pahal.bhatti11@gmail.com to share your thoughts about why you feel lonely and get personalized assistance.'**
  String get othersDialogBody;

  /// No description provided for @movingTitle.
  ///
  /// In en, this message translates to:
  /// **'Moving to a New City'**
  String get movingTitle;

  /// No description provided for @movingBody.
  ///
  /// In en, this message translates to:
  /// **'When we move to a new place, many things change. One of them is our social connections. If we aren\'t able to match our social connections with our social hunger, we start feeling lonely. This is a very normal scenario and happens to almost anyone who moves to a new place.\n\nHow do we combat it? Mainly, there are two options. First, try retaining the relationships we have back home. Second, make new friends instantly and be as close with them as we were with our friends back home. When you reflect on these options, you realize that neither of them is perfectly possible (online connections with friends back home cannot suffice, and instantly making friends isn\'t really possible).\n\nSo, our best bet is to take a hybrid approach: stay connected with your close friends back home and try to make new friends. We can offer you reminders for the former and help you with the latter after you choose one of the following options.'**
  String get movingBody;

  /// No description provided for @canTalkToStrangers.
  ///
  /// In en, this message translates to:
  /// **'I can talk to strangers (like the ability to start a conversation with the stranger next to me on a metro/subway or the ability to small talk in an elevator)'**
  String get canTalkToStrangers;

  /// No description provided for @socialAnxiety.
  ///
  /// In en, this message translates to:
  /// **'I have social anxiety, and I don\'t find it comfortable to go out and talk to strangers.'**
  String get socialAnxiety;

  /// No description provided for @lossTitle.
  ///
  /// In en, this message translates to:
  /// **'Loss and Loneliness'**
  String get lossTitle;

  /// No description provided for @lossBody.
  ///
  /// In en, this message translates to:
  /// **'I am terribly sorry to hear that…\n\nAs humans, it takes us time to move on from our losses. So, we encourage you to sit down, reflect on your feelings (with professional help if needed), and decide whether you are sad or feeling lonely.\n\nIf you think you are sad and need time to move on, we can wait until then :)\n\nHowever, if you feel lonely, then we might be able to help you. This is not going to be a quick medicine dose, but rather a sustained effort from you that slowly heals your hurt soul. We will be right here as a guide on your journey.\n\nBasics first. To stop feeling lonely, we need to connect with new people to satisfy our social hunger. The goal isn\'t to replace those you lost, but rather to make a new net of connections. To start, choose one of the following options.'**
  String get lossBody;

  /// No description provided for @nextTask.
  ///
  /// In en, this message translates to:
  /// **'Next task'**
  String get nextTask;

  /// No description provided for @letsConnectButton.
  ///
  /// In en, this message translates to:
  /// **'Let\'s connect'**
  String get letsConnectButton;

  /// No description provided for @uclaScoreTest.
  ///
  /// In en, this message translates to:
  /// **'UCLA loneliness\nscore test'**
  String get uclaScoreTest;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome {username},\nWhat would you like to do today?'**
  String welcomeUser(String username);

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @accountSettingsPrompt.
  ///
  /// In en, this message translates to:
  /// **'What would you like to change?'**
  String get accountSettingsPrompt;

  /// No description provided for @changeUsername.
  ///
  /// In en, this message translates to:
  /// **'Change Username'**
  String get changeUsername;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @chooseDifferentReason.
  ///
  /// In en, this message translates to:
  /// **'Choose Different Reason'**
  String get chooseDifferentReason;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @contactBody.
  ///
  /// In en, this message translates to:
  /// **'Got feedback, want to report problems or just need someone to talk to?\n\nEmail:\npahal.bhatti11@gmail.com'**
  String get contactBody;

  /// No description provided for @updateLocation.
  ///
  /// In en, this message translates to:
  /// **'Update Location'**
  String get updateLocation;

  /// No description provided for @updateLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Needed only for reward verification'**
  String get updateLocationSubtitle;

  /// No description provided for @rateThisApp.
  ///
  /// In en, this message translates to:
  /// **'Rate this app'**
  String get rateThisApp;

  /// No description provided for @myPromoCode.
  ///
  /// In en, this message translates to:
  /// **'My promo code'**
  String get myPromoCode;

  /// No description provided for @myPromoCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'My Promo Code'**
  String get myPromoCodeTitle;

  /// No description provided for @myPromoCodeBody.
  ///
  /// In en, this message translates to:
  /// **'While registering, if a new user enters your promo code, both of you will receive one Premium Reward.'**
  String get myPromoCodeBody;

  /// No description provided for @promoCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Promo code copied.'**
  String get promoCodeCopied;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete your account?'**
  String get deleteAccountConfirm;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get logoutConfirm;

  /// No description provided for @uclaScaleTitle.
  ///
  /// In en, this message translates to:
  /// **'UCLA Loneliness Scale'**
  String get uclaScaleTitle;

  /// No description provided for @uclaScalePopupBody.
  ///
  /// In en, this message translates to:
  /// **'The UCLA Loneliness Scale is available online. Copy and paste this link in your favorite browser\nhttps://backend.fetzer.org/sites/default/files/images/stories/pdf/selfmeasures/Self_Measures_for_Love_and_Compassion_Research_LONELINESS_AND_INTERPERSONAL_PROBLEMS.pdf'**
  String get uclaScalePopupBody;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newUsername.
  ///
  /// In en, this message translates to:
  /// **'New Username'**
  String get newUsername;

  /// No description provided for @incorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get incorrectPassword;

  /// No description provided for @usernameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Username updated'**
  String get usernameUpdated;

  /// No description provided for @changeReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Reason?'**
  String get changeReasonTitle;

  /// No description provided for @changeReasonBody.
  ///
  /// In en, this message translates to:
  /// **'You can retake the loneliness questionnaire and choose a different reason. Basically you will go back to the page where you chose the answer to the question \"Why do you think you feel lonely?\".'**
  String get changeReasonBody;

  /// No description provided for @uclaTestTitle.
  ///
  /// In en, this message translates to:
  /// **'UCLA Test'**
  String get uclaTestTitle;

  /// No description provided for @scoreSaved.
  ///
  /// In en, this message translates to:
  /// **'Score saved: {score}'**
  String scoreSaved(int score);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
