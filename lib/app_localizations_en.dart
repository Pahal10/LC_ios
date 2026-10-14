// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Let\'s Connect';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get continueLabel => 'Continue';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get save => 'Save';

  @override
  String get copy => 'Copy';

  @override
  String get logout => 'Logout';

  @override
  String errorWithDetail(String error) {
    return 'Error: $error';
  }

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get email => 'Email';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get logIn => 'Log in';

  @override
  String get or => 'or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get newHere => 'New here?';

  @override
  String get register => 'Register';

  @override
  String get signUp => 'Sign Up';

  @override
  String get loginEmptyFields => 'Please type a username and password or register';

  @override
  String get loginInvalid => 'Invalid username or password';

  @override
  String googleSignInFailed(String error) {
    return 'Google sign-in failed: $error';
  }

  @override
  String appleSignInFailed(String error) {
    return 'Apple sign-in failed: $error';
  }

  @override
  String get promoCodeOptional => 'Promo Code (Optional)';

  @override
  String get promoCodeTitle => 'Promo Code';

  @override
  String get promoCodeInfo => 'If you enter another user\'s promo code during registration, both of you will receive one Premium Reward at your registered email.';

  @override
  String get agreeCommunications => 'I agree to receive communications from you at this email';

  @override
  String get agreeCommunicationsOccasional => 'I agree to receive occasional communications from Let\'s Connect';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get mustAgreeCommunicationsEmail => 'Please agree to receive communications at your email to register';

  @override
  String get mustAgreeCommunications => 'Please agree to receive communications to continue';

  @override
  String get usernameExists => 'Username already exists';

  @override
  String get emailRegistered => 'Email already registered';

  @override
  String get registrationSuccessful => 'Registration successful';

  @override
  String get invalidPromoCode => 'Invalid promo code.';

  @override
  String get niceTry => 'Nice try 😊';

  @override
  String get chooseUsername => 'Choose a username';

  @override
  String get locationServicesDisabled => 'Location services are disabled.';

  @override
  String get locationPermissionDenied => 'Location permission denied.';

  @override
  String get locationPermissionDeniedForever => 'Location permission permanently denied.';

  @override
  String get locationUpdated => 'Location updated successfully. You can turn off Location Services now.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get getStartedPrompt => 'Enter your email and we\'ll send you a link to create your account.';

  @override
  String get sending => 'Sending...';

  @override
  String get enterYourEmail => 'Please enter your email.';

  @override
  String get checkYourEmail => 'Check your email';

  @override
  String get getStartedEmailSent => 'We\'ve sent you an email containing the link to create your Let\'s Connect account.';

  @override
  String get couldntSendEmail => 'Couldn\'t send email';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordPrompt => 'Enter the email linked to your account.';

  @override
  String get sendResetCode => 'Send Reset Code';

  @override
  String get emailNotFound => 'Email not found';

  @override
  String get resetCodeSent => 'Reset code sent';

  @override
  String get passwordResetEmailSent => 'Password reset email sent';

  @override
  String get verifyCodeTitle => 'Verify Code';

  @override
  String codeSentTo(String email) {
    return 'A code was sent to\n$email';
  }

  @override
  String get resetCode => 'Reset Code';

  @override
  String get newPassword => 'New Password';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get invalidCode => 'Invalid code';

  @override
  String get codeExpired => 'Code expired';

  @override
  String get passwordUpdated => 'Password updated';

  @override
  String get welcomeToLC => 'Welcome to Let\'s Connect';

  @override
  String get welcomeTagline => 'Please choose an option below, so that we can help you better.';

  @override
  String get wantToMakeFriends => 'I want to make friends';

  @override
  String get iFeelLonely => 'I feel lonely';

  @override
  String get stageSmallTalk => 'Small Talk';

  @override
  String get stageMediumTalk => 'Medium Talk';

  @override
  String get stageBigTalk => 'Big Talk';

  @override
  String get stageVoiceCall => 'Voice Call';

  @override
  String get stagePlayDate => 'Play Date';

  @override
  String get stageHygge => 'Hygge';

  @override
  String get chooseAStage => 'Choose a Stage';

  @override
  String get taskDone => 'Done';

  @override
  String get anotherTask => 'Another Task';

  @override
  String get shhInsiderInfo => 'Shh: insider info';

  @override
  String get bigTalkInsightTitle => '💡 Big Talk Insight';

  @override
  String get quickQuestion => 'Quick Question';

  @override
  String get feelMoreConnected => 'Do you feel more connected to other people?';

  @override
  String get comfortableQuestion => 'Were you comfortable doing it?';

  @override
  String get somewhat => 'Somewhat';

  @override
  String get couldntSendReward => 'Couldn\'t send reward.';

  @override
  String get couldntSendVerifyLink => 'Couldn\'t send Task Verification Link.';

  @override
  String get welcomeTitle => 'Welcome';

  @override
  String get introDialogBody => 'Loneliness, or the inability to connect with others, is a feeling, not a disease. So we will help you as a human journey rather than a pill you take every day. This app isn\'t a magic tool for not being lonely, but rather a helper in overcoming this feeling. Since you have downloaded this app, I think I can start this journey with you. We will start slowly with small talk, like asking someone what time it is. If you don\'t want to do a task, press \"Another Task\" and the app will randomly pick another one for you. This option is unlimited, but remember time isn\'t. So pick one and just try it out. When you are done, press the Done button to return to the main page. Remember: you are not compelled to do the tasks. We are just here to help you if you need it :)';

  @override
  String get letsBegin => 'Let\'s Begin';

  @override
  String get playDateIntroTitle => 'Welcome to Play Time';

  @override
  String get playDateIntroBody => 'So far on this journey, you\'ve practiced starting conversations and building connections with other people.\n\nConversations are powerful because they help us learn about another person\'s experiences, thoughts, and story. However, conversations alone don\'t create shared memories.\n\nMany friendships grow stronger through shared experiences: playing games, working on activities together, exploring new places, or simply spending time together.\n\nIn this stage, you\'ll receive suggestions for games and activities that can be done with other people.\n\nThese are only recommendations. You are never required to play a particular game, and you\'re always free to choose a different activity that feels more comfortable or enjoyable.\n\nThe goal isn\'t to complete a specific game, but rather to make jokes, tease each other and make memories.';

  @override
  String get hyggeIntroTitle => 'Welcome to Hygge';

  @override
  String get hyggeIntroBody => 'For several years, Scandinavian countries have topped the list of the happiest countries in the world. There can be speculation, but we believe the culture of Hygge (pronounced hoo-gah) is one reason.\nHygge is a Danish concept that, in short, means taking time out of your busy schedule for coziness and comfort with friends. It doesn\'t involve specific things to do, but rather simple routines like drinking hot chocolate and playing board games under warm lighting.\n\nIn Hygge, the setting of comfort and coziness is more important than the activity itself. We are going to give you some suggestions, but we also advise you to make your own routines and activities.\n\nP.S. This is the ultimate form of social connection.';

  @override
  String get bigTalkIntroTitle => 'Welcome to Big Talk';

  @override
  String get bigTalkIntroBody => 'Almost everyone knows about small talk. However, it leads to shallow connections. The deeper we go into a person\'s life, the more connected we feel with them. On this idea, an undergraduate (Kalina Silverman) came up with a solution to loneliness and named it along the lines of small talk: Big Talk. In the following section, you will be given prompts that go deeper than basic questions. We advise you to practice these conversations with someone you already know (to make you feel comfortable with Big Talk), and later try them with strangers. Another piece of advice is to keep the conversation going for at least 5 minutes, because it would be awkward for the other person (and for your brain) if you ask a deep question and end the conversation abruptly. Your brain will likely crash from deep connection to suddenly zero.\nTo keep the conversation going you can remember small talk topics or just ask other related things to the question you just asked. As always, if you feel you aren\'t able to do it at any point, you can opt out, but remember short-term anxiety and doubt won\'t solve your long-term loneliness.';

  @override
  String get congratulations => 'Congratulations 🎉';

  @override
  String get graduationBody => 'This marks the end of your journey through the guided stages. You started from small conversations and made it to the ultimate medium of social connection: Hygge. If your goal of connecting with others or feeling less lonely was not met, you can write us an email and we can help you directly. However, if you feel less lonely than before (it\'s fine if it isn\'t zero), we advise you to keep going down this road of maintaining and building connections. We suggest this because if you stop, your social connections will shrink, and a brain used to your current level of connection will feel socially hungry (aka lonely).\n\nWe do not ask you to keep using this app, but we can still help you if you need ideas. After this point, the Let\'s connect button on your main screen will open a page that gives you a button for each stage you went through. If you need it, you can choose a stage and take prompts from there.\n\nInstead of saying goodbye, we are going to ask you a self-reflection question. Do you feel less lonely after taking our help?';

  @override
  String get yesSmile => 'Yes :)';

  @override
  String get noSad => 'No :(';

  @override
  String get realityCheck1 => 'People usually enjoy conversations with strangers more than they expect.';

  @override
  String get realityCheck2 => 'People expect only 40% of strangers to respond in a friendly manner to a spontaneous conversation, but in fact 92% do.';

  @override
  String get realityCheck3 => 'At first meeting, people like you more than you think.';

  @override
  String get realityCheck4 => 'The anticipation of a conversation is often scarier than the conversation itself.';

  @override
  String get realityCheck5 => 'A brief conversation can improve both people\'s moods.';

  @override
  String get realityCheck6 => 'You never know what new way of living you will discover today. You might even find a full-time philosopher!';

  @override
  String get realityCheck7 => 'Deep connections start with talking, and talking starts with approaching someone on a random day.';

  @override
  String get realityCheck8 => 'A connection doesn\'t have to be perfect the first time you meet. Two people who absolutely hate each other have been known to become best friends.';

  @override
  String get realityCheck9 => 'Many people are hoping someone talks to them first.';

  @override
  String get realityCheck10 => 'When we are hungry and have food in front of us, we eat. Loneliness is social hunger. When you find a person in front of you, take a bite of the social pie (don\'t worry, I\'m not asking you to eat anyone).';

  @override
  String get realityCheck11 => 'Small talk isn\'t the opposite of connection. It\'s often the doorway to it.';

  @override
  String get realityCheck12 => 'Most people respond kindly to simple, respectful questions.';

  @override
  String get bigTalkInsight1 => 'Meaningful friendships rarely grow from small talk alone.';

  @override
  String get bigTalkInsight2 => 'Most people enjoy being asked thoughtful questions more than we expect.';

  @override
  String get bigTalkInsight3 => 'Many people wish conversations would go deeper but are waiting for someone else to start.';

  @override
  String get bigTalkInsight4 => 'Vulnerability often strengthens relationships rather than weakening them.';

  @override
  String get bigTalkInsight5 => 'Being interested is more important than being interesting.';

  @override
  String get bigTalkInsight6 => 'People usually remember how a conversation felt, not whether every word was perfect.';

  @override
  String get bigTalkInsight7 => 'A meaningful question can create more connection than an hour of casual conversation.';

  @override
  String get bigTalkInsight8 => 'Most people appreciate feeling genuinely listened to.';

  @override
  String get bigTalkInsight9 => 'The goal of Big Talk is understanding, not impressing.';

  @override
  String get bigTalkInsight10 => 'Connection grows when people share experiences, values, and perspectives.';

  @override
  String get taskSmallTalk1 => 'Ask someone what time it is';

  @override
  String get taskSmallTalk2 => 'Ask someone if there is a washroom nearby';

  @override
  String get taskSmallTalk3 => 'Ask someone for directions to a nearby coffee place';

  @override
  String get taskSmallTalk4 => 'Ask someone if there\'s an ATM nearby';

  @override
  String get taskSmallTalk5 => 'Ask someone what day or date it is';

  @override
  String get taskMediumTalk1 => 'Compliment someone on one of their accessories and ask where they got it from';

  @override
  String get taskMediumTalk2 => 'Talk about a personal memory';

  @override
  String get taskBigTalk1 => 'Ask someone about their biggest fear';

  @override
  String get taskBigTalk2 => 'Discuss life goals with someone';

  @override
  String get taskBigTalk3 => 'If you could throw your dream party with an unlimited budget, what would it look like?';

  @override
  String get taskBigTalk4 => 'What legacy do you want to leave behind?';

  @override
  String get taskBigTalk5 => 'What is a seasonal tradition that you look forward to every year?';

  @override
  String get taskBigTalk6 => 'When was one time in your life that you felt the bravest?';

  @override
  String get taskBigTalk7 => 'If you could build a team of 5 superheroes to fight alongside you against aliens, who would they be?';

  @override
  String get taskBigTalk8 => 'If you became the opposite gender for a day, how would you spend that day?';

  @override
  String get taskBigTalk9 => 'If you could change your country of birth and live the life of people there, which country would you choose and why?';

  @override
  String get taskBigTalk10 => 'If you could recreate a memory with me, which one would you want to recreate?';

  @override
  String get taskBigTalk11 => 'If you were suddenly given the job of a Netflix storywriter, what would your first story be?';

  @override
  String get taskBigTalk12 => 'What is one nonphysical scar from your childhood that you haven\'t shared with me?';

  @override
  String get taskVoiceCall1 => 'Call a friend and talk about topics of your choice for at least 5 minutes';

  @override
  String get taskPlayDate1 => 'Play the board game LIFE';

  @override
  String get taskPlayDate2 => 'Learn a new card game together and play it';

  @override
  String get taskPlayDate3 => 'Play an online game together (less recommended, because real-life games offer more connection)';

  @override
  String get taskPlayDate4 => 'Play Monopoly';

  @override
  String get taskPlayDate5 => 'Play Pictionary';

  @override
  String get taskPlayDate6 => 'Play antakshari (it\'s fine if you don\'t pronounce it well; if you don\'t know it, search it up)';

  @override
  String get taskPlayDate7 => 'Play charades';

  @override
  String get taskPlayDate8 => 'Search up \"Minute to Win It\" games';

  @override
  String get taskPlayDate9 => 'Try choreographing a song together and take a video of the final version (and behind-the-scenes if you want)';

  @override
  String get taskPlayDate10 => 'Play football or basketball';

  @override
  String get taskPlayDate11 => 'Play Cluedo';

  @override
  String get taskHygge1 => 'Lie on a couch with a hot chocolate (or a cold drink) and have a deep conversation';

  @override
  String get taskHygge2 => 'Cook or study together peacefully';

  @override
  String get taskHygge3 => 'Play a board game together';

  @override
  String get taskHygge4 => 'Start an intellectual conversation about economics or the world around you';

  @override
  String get questionnaire => 'Questionnaire';

  @override
  String get whyLonely => 'Why do you think you feel lonely?';

  @override
  String get reasonCantTalk => 'Not able to talk to people or make friends';

  @override
  String get reasonMoved => 'I moved to a new place without most of my close friends/go to people';

  @override
  String get reasonLoss => 'I recently lost someone close, and that left a hole in my social net';

  @override
  String get reasonNotUnderstood => 'People around me don\'t understand me';

  @override
  String get reasonOthers => 'Others';

  @override
  String get misunderstoodTitle => 'People do not understand me';

  @override
  String get misunderstoodBody => 'It is a tough feeling when people do not understand you...\n\nThis can occur either once/few times or frequently/always. If you tell us which one applies to you, we can help you.';

  @override
  String get onceFewTimes => 'Once/Few Times';

  @override
  String get frequentlyAlways => 'Frequently/Always';

  @override
  String get possibleReasonsTitle => 'Possible Reasons';

  @override
  String get possibleReasonsBody => 'If this problem occurred a limited number of times, then it could be due to 2 main reasons:\n\n1. Problem in the person\'s ability to understand you due to difference in opinion/their mood isn\'t right/etc.\n\n2. Language differences/accent problems/etc. with the person you talked to.';

  @override
  String get twoOptionsBody => 'In that case you have two options.\n\n1. Try explaining it to them again\n\n2. Find new people who would potentially understand you.';

  @override
  String get explainAgain => 'I will try explaining again';

  @override
  String get helpFindConnections => 'Help me find new connections';

  @override
  String get noDirectHelpBody => 'We do not have direct help within the app for that, but you can try translators or accent helpers.\n\nWe have suggested a few platforms below to guide you :)';

  @override
  String get whichIsTrue => 'Which of the following is true?';

  @override
  String get particularGroup => 'With a particular group of people';

  @override
  String get withEveryone => 'With everyone';

  @override
  String get newConnectionsTitle => 'New Connections';

  @override
  String get newConnectionsBody => 'Sometimes differences between people are so high that connections are not formed well.\n\nIn that case, our best bet is to move on and find new connections.\n\nDo you want to make new connections?';

  @override
  String get yesLetsConnect => 'Yes! Let\'s connect';

  @override
  String get noTryExplainingAgain => 'No. I want to try once again explaining them';

  @override
  String get othersDialogTitle => 'It is fine if you do not fit one of the options :)';

  @override
  String get othersDialogBody => 'Email at pahal.bhatti11@gmail.com to share your thoughts about why you feel lonely and get personalized assistance.';

  @override
  String get movingTitle => 'Moving to a New City';

  @override
  String get movingBody => 'When we move to a new place, many things change. One of them is our social connections. If we aren\'t able to match our social connections with our social hunger, we start feeling lonely. This is a very normal scenario and happens to almost anyone who moves to a new place.\n\nHow do we combat it? Mainly, there are two options. First, try retaining the relationships we have back home. Second, make new friends instantly and be as close with them as we were with our friends back home. When you reflect on these options, you realize that neither of them is perfectly possible (online connections with friends back home cannot suffice, and instantly making friends isn\'t really possible).\n\nSo, our best bet is to take a hybrid approach: stay connected with your close friends back home and try to make new friends. We can offer you reminders for the former and help you with the latter after you choose one of the following options.';

  @override
  String get canTalkToStrangers => 'I can talk to strangers (like the ability to start a conversation with the stranger next to me on a metro/subway or the ability to small talk in an elevator)';

  @override
  String get socialAnxiety => 'I have social anxiety, and I don\'t find it comfortable to go out and talk to strangers.';

  @override
  String get lossTitle => 'Loss and Loneliness';

  @override
  String get lossBody => 'I am terribly sorry to hear that…\n\nAs humans, it takes us time to move on from our losses. So, we encourage you to sit down, reflect on your feelings (with professional help if needed), and decide whether you are sad or feeling lonely.\n\nIf you think you are sad and need time to move on, we can wait until then :)\n\nHowever, if you feel lonely, then we might be able to help you. This is not going to be a quick medicine dose, but rather a sustained effort from you that slowly heals your hurt soul. We will be right here as a guide on your journey.\n\nBasics first. To stop feeling lonely, we need to connect with new people to satisfy our social hunger. The goal isn\'t to replace those you lost, but rather to make a new net of connections. To start, choose one of the following options.';

  @override
  String get nextTask => 'Next task';

  @override
  String get letsConnectButton => 'Let\'s connect';

  @override
  String get uclaScoreTest => 'UCLA loneliness\nscore test';

  @override
  String welcomeUser(String username) {
    return 'Welcome $username,\nWhat would you like to do today?';
  }

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get accountSettingsPrompt => 'What would you like to change?';

  @override
  String get changeUsername => 'Change Username';

  @override
  String get changePassword => 'Change Password';

  @override
  String get chooseDifferentReason => 'Choose Different Reason';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get contactBody => 'Got feedback, want to report problems or just need someone to talk to?\n\nEmail:\npahal.bhatti11@gmail.com';

  @override
  String get updateLocation => 'Update Location';

  @override
  String get updateLocationSubtitle => 'Needed only for reward verification';

  @override
  String get rateThisApp => 'Rate this app';

  @override
  String get myPromoCode => 'My promo code';

  @override
  String get myPromoCodeTitle => 'My Promo Code';

  @override
  String get myPromoCodeBody => 'While registering, if a new user enters your promo code, both of you will receive one Premium Reward.';

  @override
  String get promoCodeCopied => 'Promo code copied.';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteAccountConfirm => 'Are you sure you want to permanently delete your account?';

  @override
  String get logoutConfirm => 'Are you sure you want to sign out?';

  @override
  String get uclaScaleTitle => 'UCLA Loneliness Scale';

  @override
  String get uclaScalePopupBody => 'The UCLA Loneliness Scale is available online. Copy and paste this link in your favorite browser\nhttps://backend.fetzer.org/sites/default/files/images/stories/pdf/selfmeasures/Self_Measures_for_Love_and_Compassion_Research_LONELINESS_AND_INTERPERSONAL_PROBLEMS.pdf';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newUsername => 'New Username';

  @override
  String get incorrectPassword => 'Incorrect password';

  @override
  String get usernameUpdated => 'Username updated';

  @override
  String get changeReasonTitle => 'Change Reason?';

  @override
  String get changeReasonBody => 'You can retake the loneliness questionnaire and choose a different reason. Basically you will go back to the page where you chose the answer to the question \"Why do you think you feel lonely?\".';

  @override
  String get uclaTestTitle => 'UCLA Test';

  @override
  String scoreSaved(int score) {
    return 'Score saved: $score';
  }
}
