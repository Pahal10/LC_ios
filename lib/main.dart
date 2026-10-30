import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:video_player/video_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://xvhljedviahxqlvcguvm.supabase.co',
    anonKey: 'sb_publishable_MUFwmhE4b09yDVMJ3gE7ZA_IhmTP05B',
  );
  runApp(const MyApp());
}
const Map<String, int> stageOrder = {
  "smalltalk": 1,
  "mediumtalk": 2,
  "bigtalk": 3,
  "playdate": 4,
  "hygge": 5,
};

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
	// 1. Define the four localization delegates
      
localizationsDelegates: [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],


      // 2. Set the supported locales to English, Portuguese, and Spanish
      supportedLocales: const [
        Locale('en'), // English
        Locale('pt'), // Portuguese
        Locale('es'), // Spanish
      ],
      home: const SplashScreen(),
    );
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final VideoPlayerController _video;
  bool _ready = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _video = VideoPlayerController.asset('asset/intro.mp4');

    _video.initialize().then((_) {
      if (!mounted) return;
      setState(() => _ready = true);
      _video.play();
    }).catchError((_) => _goNext());

    _video.addListener(() {
      final v = _video.value;
      if (v.isInitialized && v.position >= v.duration) _goNext();
    });

    // Safety net: never get stuck on the splash
    Future.delayed(const Duration(seconds: 10), _goNext);
  }

  Future<void> _goNext() async {
    if (_navigated || !mounted) return;
    _navigated = true;
    _video.pause();

    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool("loggedIn") ?? false;
    if (!mounted) return;

    if (loggedIn) {
      Session.username = prefs.getString("username") ?? "";
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) =>
            loggedIn ? const MainPage() : const LoginPage(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _video.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // match your video's background color
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_ready)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _video.value.size.width,
                height: _video.value.size.height,
                child: VideoPlayer(_video),
              ),
            ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: TextButton(
                  onPressed: _goNext,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.15),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                  ),
                  child: const Text('Skip intro'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController usernameController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final supabase = Supabase.instance.client;
  bool _hidePassword = true;

  Future<void> loginUser() async {

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please type a username and password or register",
          ),
        ),
      );

      return;
    }

    try {

      final response = await supabase
          .from('users')
          .select()
          .eq('username', username)
          .eq('password', password);

      if (response.isNotEmpty) {

        final prefs = await SharedPreferences.getInstance();

        await prefs.setBool(
          "loggedIn",
          true,
        );

        await prefs.setString(
          "username",
          username,
        );

        final deviceId =
        await DeviceService.getDeviceId();

        Session.username = username;
        Session.deviceId = deviceId;
        Session.promoCode = response.first["promo_code"];
        Session.verifyShow = response.first["verifyshow"] ?? true;

        await supabase
            .from("users")
            .update({

          "device_id": deviceId,

        })
            .eq(
          "username",
          username,
        );
        final introCompleted =
            response.first["intro_completed"] ?? false;

        if (!introCompleted) {

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const WelcomePage(),
            ),
          );

        } else {

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const MainPage(),
            ),
          );

        }
      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid username or password"),
          ),
        );

      }

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );

    }
  }
  // --- inside _LoginPageState, after loginUser() ---

  Future<void> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        serverClientId: '97930640325-2lovusk7nfpd1ffklp7pnib5rcu4p0vg.apps.googleusercontent.com',
      );
      final googleUser = await googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) throw 'No ID Token found.';

      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      await _handlePostOAuthLogin();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google sign-in failed: $e")),
      );
    }
  }
  Future<void> signInWithApple() async {
  try {
    final rawNonce = supabase.auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final idToken = credential.identityToken;
    if (idToken == null) throw 'No ID Token found.';

    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
    await _handlePostOAuthLogin();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Apple sign-in failed: $e")),
    );
  }
}

  Future<void> _handlePostOAuthLogin() async {
    final authUid = supabase.auth.currentUser!.id;

    final existing = await supabase
        .from('users')
        .select()
        .eq('auth_uid', authUid)
        .maybeSingle();

    if (!mounted) return;

    if (existing != null) {
      // returning OAuth user — log them in exactly like loginUser() does
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("loggedIn", true);
      await prefs.setString("username", existing['username']);

      Session.username = existing['username'];
      Session.deviceId = await DeviceService.getDeviceId();
      Session.promoCode = existing["promo_code"];
      Session.verifyShow = existing["verifyshow"] ?? true;

      await supabase.from("users").update({"device_id": Session.deviceId})
          .eq("username", existing['username']);

      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => (existing["intro_completed"] ?? false)
              ? const MainPage() : const WelcomePage()));
    } else {
      // brand-new OAuth user — send them to pick a username
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => ChooseUsernamePage(authUid: authUid)));
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF24B65E),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 30,
            right: 30,
            top: 40,
            bottom:
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
            child:Column(
            mainAxisSize: MainAxisSize.min,

            children: [

              /// IMAGE
              Image.asset(
                'asset/LCLogo2.png',
                height: 120,
              ),

              const SizedBox(height: 60),

              /// USERNAME
              TextField(
                controller: usernameController,

                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              /// PASSWORD
              /*TextField(
                controller: passwordController,
                obscureText: true,

                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),*/
              TextField(
                controller: passwordController,
                obscureText: _hidePassword,

                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Password',
                  border: const OutlineInputBorder(),

                  suffixIcon: IconButton(
                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),

                    onPressed: () {
                      setState(() {
                        _hidePassword = !_hidePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

                children: [

                  const Text(
                    "",
                  ),

                  GestureDetector(

                    onTap: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                          const ForgotPasswordPage(),
                        ),
                      );
                    },

                    child: const Text(

                      "Forgot Password?",

                      style: TextStyle(

                        color: Colors.white,

                        fontSize: 14,

                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /*Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "We use your location only to verify tasks with other users nearby.",
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),*/

              /// LOGIN BUTTON
              SizedBox(
  width: double.infinity,
  height: 60,
  child: DecoratedBox(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF007AFF), // Vibrant modern blue
          Color(0xFF00C6FF), // Bright accent blue
        ],
      ),
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF007AFF).withOpacity(0.35), // Updated shadow to match blue
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: loginUser,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Log in",
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  ),
),

              const SizedBox(height: 30),

              /// OR
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.white,
                      thickness: 2,
                      endIndent: 10,
                    ),
                  ),

                  const Text(
                    "or",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Expanded(
                    child: Divider(
                      color: Colors.white,
                      thickness: 2,
                      indent: 10,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// GOOGLE SIGN IN BUTTON
              SizedBox(
                            width: double.infinity,
                            height: 40,

                            child: Material(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(17),

                              child: InkWell(
                                borderRadius:
                                BorderRadius.circular(17),

                                onTap: signInWithGoogle,

                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,

                                  children: [

                                    Image.asset(
                                      'asset/Glogo.png',
                                      height: 21,
                                      width: 21,
                                    ),

                                    const SizedBox(width: 12),

                                    const Text(
                                      "Continue with Google",
                                      style: TextStyle(
                                        color: Color(0xFF202124),
                                        fontSize: 15.5,
                                        fontWeight:
                                        FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
              if (Theme.of(context).platform == TargetPlatform.iOS) ...[
                const SizedBox(height: 20),
                SignInWithAppleButton(
                  onPressed: signInWithApple,
                  style: SignInWithAppleButtonStyle.black,
                  borderRadius: BorderRadius.circular(20),
                ),
              ],
              const SizedBox(height: 30),
              Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,

                            children: [

                              Text(
                                "New here?",
                                style: TextStyle(
                                  color:
                                  Colors.white,
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(width: 8),

                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const RegisterPage(),
                                    ),
                                  );
                                },

                                child: const Row(
                                  children: [

                                    Text(
                                      "Register",
                                      style: TextStyle(
                                        color:
                                        Colors.white,
                                        fontSize: 15.5,
                                        fontWeight:
                                        FontWeight.w700,
                                      ),
                                    ),

                                    SizedBox(width: 5),

                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color:
                                      Colors.white,
                                      size: 19,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
            ],
          ),
        ),
      ),
      );
  }
}

Future<void> updateCurrentLocation() async {

  bool serviceEnabled =
  await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    throw Exception("Location services are disabled.");
  }

  LocationPermission permission =
  await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {

    permission =
    await Geolocator.requestPermission();

  }

  if (permission == LocationPermission.denied) {
    throw Exception("Location permission denied.");
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception(
      "Location permission permanently denied.",
    );
  }

  Position position =
  await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  await Supabase.instance.client
      .from("users")
      .update({

    "last_latitude": position.latitude,
    "last_longitude": position.longitude,
    "last_location_update": DateTime.now().toUtc().toIso8601String(),
  })
      .eq(
    "username",
    Session.username,
  );
}

class Session {

  static String username = "";
  static String promoCode = "";
  static String deviceId = "";
  static bool verifyShow = true;
}
class _ConnectionsTab extends StatelessWidget {
  final VoidCallback onNewConnection;
  final VoidCallback onExistingConnection;
  const _ConnectionsTab({required this.onNewConnection, required this.onExistingConnection});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
    children: [
      const Text('Your connections', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      Text('Choose whether you are meeting someone new or growing a relationship you already have.',
          style: TextStyle(color: Colors.white.withOpacity(.78), fontSize: 15, height: 1.4)),
      const SizedBox(height: 25),
      _FeaturePanel(
        icon: Icons.person_add_alt_1_rounded,
        eyebrow: 'START SOMETHING NEW',
        title: 'A new connection',
        description: 'Get help starting a conversation and finding a natural way to keep it going.',
        buttonText: 'Meet someone new',
        onTap: onNewConnection,
      ),
      const SizedBox(height: 16),
      _FeaturePanel(
        icon: Icons.people_alt_rounded,
        eyebrow: 'KEEP BUILDING',
        title: 'An existing connection',
        description: 'Work on familiarity, shared interests, follow-ups and spending time together.',
        buttonText: 'Build a friendship',
        onTap: onExistingConnection,
      ),
      const SizedBox(height: 18),
      const _TipCard(
        title: 'A note about friendships',
        body: 'A connection grows through repeated, mutual interactions. You do not have to rush intimacy or force every conversation to become deep.',
      ),
    ],
  );
}

class _FeaturePanel extends StatelessWidget {
  final IconData icon;
  final String eyebrow, title, description, buttonText;
  final VoidCallback onTap;
  const _FeaturePanel({required this.icon, required this.eyebrow, required this.title, required this.description, required this.buttonText, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2C9858), Color(0xFF176B3A)]),
      borderRadius: BorderRadius.circular(26),
      border: Border.all(color: Colors.white.withOpacity(.2)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.15), blurRadius: 20, offset: const Offset(0, 9))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: const Color(0xFFB8F4CE), size: 32),
      const SizedBox(height: 20),
      Text(eyebrow, style: const TextStyle(color: Color(0xFFB8F4CE), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
      const SizedBox(height: 6),
      Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      Text(description, style: TextStyle(color: Colors.white.withOpacity(.84), fontSize: 14, height: 1.4)),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF176B3A),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
      ),
    ]),
  );
}

class _TipCard extends StatelessWidget {
  final String title, body;
  const _TipCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.09),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(.12)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
      const SizedBox(height: 7),
      Text(body, style: TextStyle(color: Colors.white.withOpacity(.76), height: 1.45)),
    ]),
  );
}


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final TextEditingController usernameController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final TextEditingController confirmPasswordController =
  TextEditingController();

  final promoCodeController =
  TextEditingController();

  final supabase = Supabase.instance.client;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _agreedToCommunications = false;

  @override
  void dispose() {

    usernameController.dispose();

    passwordController.dispose();

    promoCodeController.dispose();

    super.dispose();

  }

  String generatePromoCode() {

    const chars =
        "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

    final random = Random();

    String code = "LC";

    for (int i = 0; i < 6; i++) {

      code += chars[random.nextInt(chars.length)];

    }

    return code;

  }

  Future<void> registerUser() async {

    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword =
    confirmPasswordController.text.trim();
    final enteredPromo = promoCodeController.text.trim().toUpperCase();

    /// EMAIL FORMAT CHECK
final emailRegex = RegExp(r'^[\w\.\-+]+@[\w\-]+\.[\w\.\-]+$');
if (!emailRegex.hasMatch(email)) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Please enter a valid email address")),
  );
  return;
}

    /// PASSWORD MATCH CHECK
    if (password != confirmPassword) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
        ),
      );

      return;
    }
    /// COMMUNICATIONS CONSENT CHECK
if (!_agreedToCommunications) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Please agree to receive communications at your email to register"),
    ),
  );
  return;
}

    try {

      /// CHECK IF USERNAME ALREADY EXISTS
      final existingUser = await supabase
          .from('users')
          .select()
          .eq('username', username)
          .maybeSingle();
        if (existingUser != null) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Username already exists"),
          ),
        );

        return;
      }
      final existingEmail = await supabase
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (existingEmail != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email already registered"),
          ),
        );
        return;
      }

      /// INSERT USER
      await supabase.from('users').insert({
        'username': username,
        'password': password,
        'email': email,
        'current_stage': 'smalltalk',
        'stage_progress': 0,

        'intro_completed': false,

        'bigtalk_intro_seen': false,
        'playdate_intro_seen': false,
        'hygge_intro_seen': false,

        'graduated': false,
        'graduation_seen': false,

        'lonely_yes': 0,
        'lonely_total': 0,
        'premium': false,
        'promo_code': generatePromoCode(),
        'pending_rewards': 0
      });
      if (enteredPromo.isNotEmpty) {

        await checkPromoCode(
          enteredPromo,
        );

      }

      Session.username = username;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration successful"),
        ),
      );

      /// GO TO NEXT PAGE
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const WelcomePage(),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );

    }
  }
  Future<void> checkPromoCode(
      String enteredPromo,
      ) async {

    try {

      final response = await supabase

          .from("users")

          .select()

          .eq(
        "promo_code",
        enteredPromo,
      );

      if (response.isEmpty) {

        ScaffoldMessenger.of(context).showSnackBar(

          const SnackBar(

            content: Text(
              "Invalid promo code.",
            ),

          ),

        );

        return;

      }

      final owner = response.first;

      if (owner["username"] == Session.username) {

        return;

      }

      if (owner["device_id"] == Session.deviceId) {

        ScaffoldMessenger.of(context).showSnackBar(

          const SnackBar(

            content: Text(
              "Nice try 😊",
            ),

          ),

        );

        return;

      }

      /// Reward owner

      await supabase

          .from("users")

          .update({

        "pending_rewards":
        owner["pending_rewards"] + 1,

      })

          .eq(
        "username",
        owner["username"],
      );

      /// Reward new user

      final currentUser = await supabase

          .from("users")

          .select("pending_rewards")

          .eq(
        "username",
        Session.username,
      )

          .single();
      await supabase

          .from("users")

          .update({

        "pending_rewards":
        currentUser["pending_rewards"] + 1,

      })

          .eq(
        "username",
        Session.username,
      );

    }

    catch (e) {

      debugPrint(e.toString());

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF24B65E),

      appBar: AppBar(
        centerTitle: true,

        title: const Text(
          'Sign Up',

          style: TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),

        backgroundColor: const Color(0xFF388E3C),
      ),

        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {

              return SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,

                padding: EdgeInsets.only(
                  left: 30,
                  right: 30,
                  bottom:
                  MediaQuery.of(context).viewInsets.bottom + 20,
                ),

                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),

                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,

                      children: [

                        TextField(
                          controller: usernameController,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 15),

                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 15),

                        TextField(
                          controller: passwordController,
                          obscureText: _hidePassword,

                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Password',
                            border: const OutlineInputBorder(),

                            suffixIcon: IconButton(
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),

                              onPressed: () {
                                setState(() {
                                  _hidePassword = !_hidePassword;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        TextField(
                          controller: confirmPasswordController,
                          obscureText: _hideConfirmPassword,

                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Confirm Password',
                            border: const OutlineInputBorder(),

                            suffixIcon: IconButton(
                              icon: Icon(
                                _hideConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),

                              onPressed: () {
                                setState(() {
                                  _hideConfirmPassword =
                                  !_hideConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height:20),

                        TextField(

                          controller: promoCodeController,

                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "Promo Code (Optional)",

                            suffixIcon: IconButton(

                              icon: const Icon(Icons.info_outline),

                              onPressed: () {

                                showDialog(

                                  context: context,

                                  builder: (_) => const AlertDialog(

                                    title: Text(
                                      "Promo Code",
                                    ),

                                    content: Text(

                                      "If you enter another user's promo code during registration, both of you will receive one Premium Reward at your registered email.",

                                    ),

                                  ),

                                );

                              },

                            ),

                          ),

                        ),

                        const SizedBox(height: 25),

Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Checkbox(
      value: _agreedToCommunications,
      fillColor: WidgetStateProperty.resolveWith((states) => Colors.white),
      checkColor: const Color(0xFF24B65E),
      onChanged: (value) {
        setState(() {
          _agreedToCommunications = value ?? false;
        });
      },
    ),
    Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _agreedToCommunications = !_agreedToCommunications;
          });
        },
        child: const Padding(
          padding: EdgeInsets.only(top: 14),
          child: Text(
            "I agree to receive communications from you at this email",
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ),
    ),
  ],
),

                        const SizedBox(height: 25),


                        ElevatedButton(
                          onPressed: registerUser,
                          child: const Text("Sign Up"),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
    );
  }
}

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() =>
      _GetStartedPageState();
}

class _GetStartedPageState
    extends State<GetStartedPage> {

  final emailController =
  TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
  Future<void> sendGetStartedEmail(String email) async {

    final response =
    await Supabase.instance.client.functions.invoke(
      'get-started',
      body: {
        'email': email,
      },
    );

    if (response.status != 200) {
      throw Exception("Couldn't send email");
    }

  }

  Future<void> sendEmail() async {

    final email =
    emailController.text.trim();

    if (email.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text(
            "Please enter your email.",
          ),

        ),

      );

      return;
    }

    setState(() {
      loading = true;
    });

    try {

      await sendGetStartedEmail(email);

      if (!mounted) return;

      showDialog(

        context: context,

        builder: (_) => AlertDialog(

          title: const Text(
            "Check your email",
          ),

          content: const Text(

            "We've sent you an email containing the link to create your Let's Connect account.",

          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(context);

                Navigator.pop(context);

              },

              child: const Text(
                "OK",
              ),

            )

          ],

        ),

      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content: Text("$e"),
        ),

      );

    }

    setState(() {

      loading = false;

    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFF24B65E),

      appBar: AppBar(

        backgroundColor:
        const Color(0xFF388E3C),

        title: const Text(
          "Get Started",
        ),

      ),

      body: Padding(

        padding:
        const EdgeInsets.all(30),

        child: SingleChildScrollView(
          child: Column(

          children: [

            const SizedBox(height:40),

            Image.asset(

              "asset/LCLogo2.png",

              height:120,

            ),

            const SizedBox(height:40),

            const Text(

              "Enter your email and we'll send you a link to create your account.",

              textAlign: TextAlign.center,

              style: TextStyle(

                color: Colors.white,

                fontSize:18,

              ),

            ),

            const SizedBox(height:40),

            TextField(

              controller:
              emailController,

              keyboardType:
              TextInputType.emailAddress,

              decoration:
              const InputDecoration(

                filled:true,

                fillColor: Colors.white,

                labelText:"Email",

                border:
                OutlineInputBorder(),

              ),

            ),

            const SizedBox(height:40),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed:
                loading
                    ? null
                    : sendEmail,

                child: Text(

                  loading
                      ? "Sending..."
                      : "Get Started",

                ),

              ),

            )

          ],

        ),

      ),
      ),

    );

  }

}



final List<String> stages = [

  "smalltalk",
  "mediumtalk",
  "bigtalk",
  "voicecall",
  "playdate",
  "hygge",

];

final List<String> realityChecks = [

  "People usually enjoy conversations with strangers more than they expect.",

  "people feel only 40% strangers respond in a friendly manner to a spontaneous conversation but in fact 92% strangers do.",

  "At first meeting, people like you more than you think.",

  "The anticipation of a conversation is often scarier than the conversation itself.",

  "A brief conversation can improve both people's moods.",

  "you never know what new way of living you will discover today. You might even find a full-time philosopher!",

  "Deep connections start with talking, and talking starts with approaching on a random day.",

  "connection doesn't have to be perfect in the first meet. You might have heard two people who absolutely hate each other become best friends.",

  "Many people are hoping someone talks to them first.",

  "when we are hungry and have food in front of us, we eat. Loneliness is social hunger. When you find a person in front of you take a bite of the social pie (don't tell me you thought i would ask you to eat them).",

  "Small talk isn't the opposite of connection. It's often the doorway to it.",

  "Most people respond kindly to simple, respectful questions.",

];

final List<String> bigTalkInsights = [

  "Meaningful friendships rarely grow from small talk alone.",

  "Most people enjoy being asked thoughtful questions more than we expect.",

  "Many people wish conversations would go deeper but are waiting for someone else to start.",

  "Vulnerability often strengthens relationships rather than weakening them.",

  "Being interested is more important than being interesting.",

  "People usually remember how a conversation felt, not whether every word was perfect.",

  "A meaningful question can create more connection than an hour of casual conversation.",

  "Most people appreciate feeling genuinely listened to.",

  "The goal of Big Talk is understanding, not impressing.",

  "Connection grows when people share experiences, values, and perspectives.",

];

final Map<String, List<String>> stageTasks = {

  "smalltalk": [
    "Ask someone what the time is",
    "Ask someone if there is a washroom near by",
    "ask someone directions for a nearby coffee place",
    "Do you know if there's an ATM nearby?",
    "Ask someone what day or date it is",
  ],

  "mediumtalk": [

    "compliment someone about one of their accessories and ask where they got it from",
    "Talk about a personal memory",

  ],

  "bigtalk": [

    "Ask someone about their biggest fear",
    "Discuss life goals with someone",
    "if you could throw your dream party with an unlimited budget, what would it look like?",
    "What legacy do you want to leave behind",
    "What is a seasonal tradition that you look forward to every year?",
    "where was one instance in your life that you felt the bravest?",
    "if you could build a team of 5 superheroes to assemble and fight alongside you in fighting aliens, who would they be?",
    "if you became of the opposite gender for a day, how would you spend that day",
    "if you could change your country of birth and live the life of people like there, which country would you choose and why?",
    "if you could recreate a memory with me, which one would you want to recreate?",
    "if you were suddenly given the job of a Netflix storywriter, what would your first story be?",
    "What is one nonphysical scar from your childhood that you haven't shared with me",

  ],

  "voicecall": [

    "Call a friend and talk about topics of your choice for atleast 5 mins",

  ],

  "playdate": [
    "Play the game of LIFE (the board game)",
    "Learn a new card game together and play it",
    "Play an online game together (lesser suggested option because real life games offer more connection)",
    "play monopoly",
    "play pictionary",
    "play antakshari (it's fine if you dont pronounce it well. if you don't know it, search.",
    "play charades",
    "search up minute to win it games",
    "try choreographing a song together and take a video of the final version (and BTS if you want)",
    "play football or basketball",
    "play cluedo",
  ],

  "hygge": [

    "Lay on a couch with a hot chocolate (or cold drinks) and have a deep convo",
    "Cook or study together peacefully",
    "play a board game together",
    "start an intellectual conversation about economics or the world around"

  ],
};
final supabase = Supabase.instance.client;
String getRandomTask(String stage) {

  final random = Random();

  final tasks = stageTasks[stage]!;

  return tasks[random.nextInt(tasks.length)];
}

class LonelyPage extends StatelessWidget {
  const LonelyPage({super.key});

  void showUnderstandMePopup(BuildContext context) {
    bool hoverPrimary = false;
    bool hoverSecondary = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),

              backgroundColor: Colors.white,

              title: const Text(
                'People do not understand me',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),

              content: const Text(
                'It is a tough feeling when people do not understand you..\n\n'
                    'This can occur either once/few times or frequently/always. '
                    'If you tell us which one applies to you, we can help you.',
                style: TextStyle(fontSize: 18),
              ),

              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),

              actions: [

                // Primary Button
                MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      hoverPrimary = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      hoverPrimary = false;
                    });
                  },

                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        hoverPrimary ? Colors.blue : Colors.grey.shade300,

                        foregroundColor:
                        hoverPrimary ? Colors.white : Colors.black,

                        padding: const EdgeInsets.symmetric(vertical: 16),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),

                      onPressed: () {
                        Navigator.pop(context);


                        bool hoverOne = false;
                        bool hoverTwo = false;

                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),

                                  title: const Text(
                                    'Possible Reasons',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),

                                  content: const Text(
                                    'If this problem occurred a limited number of times, '
                                        'then it could be due to 2 main reasons:\n\n'

                                        '1. Problem in the person\'s ability to understand you '
                                        'due to difference in opinion/their mood isn\'t right/etc.\n\n'

                                        '2. Language differences/accent problems/etc. '
                                        'with the person you talked to.',
                                    style: TextStyle(fontSize: 18),
                                  ),

                                  actionsPadding:
                                  const EdgeInsets.fromLTRB(20, 0, 20, 20),

                                  actions: [

                                    // Button 1
                                    MouseRegion(
                                      onEnter: (_) {
                                        setState(() {
                                          hoverOne = true;
                                        });
                                      },

                                      onExit: (_) {
                                        setState(() {
                                          hoverOne = false;
                                        });
                                      },

                                      child: SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            hoverOne ? Colors.blue : Colors.grey.shade300,

                                            foregroundColor:
                                            hoverOne ? Colors.white : Colors.black,

                                            padding: const EdgeInsets.symmetric(vertical: 16),

                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                          ),

                                          onPressed: () {
                                            Navigator.pop(context);

                                            bool hoverExplain = false;
                                            bool hoverConnections = false;

                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return StatefulBuilder(
                                                  builder: (context, setState) {
                                                    return AlertDialog(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(25),
                                                      ),

                                                      content: const Text(
                                                        'In that case you have two options.\n\n'

                                                            '1. Try explaining it to them again\n\n'

                                                            '2. Find new people who would potentially understand you.',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                        ),
                                                      ),

                                                      actionsPadding:
                                                      const EdgeInsets.fromLTRB(20, 0, 20, 20),

                                                      actions: [

                                                        // Explain Again Button
                                                        MouseRegion(
                                                          onEnter: (_) {
                                                            setState(() {
                                                              hoverExplain = true;
                                                            });
                                                          },

                                                          onExit: (_) {
                                                            setState(() {
                                                              hoverExplain = false;
                                                            });
                                                          },

                                                          child: SizedBox(
                                                            width: double.infinity,
                                                            child: ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                hoverExplain
                                                                    ? Colors.blue
                                                                    : Colors.grey.shade300,

                                                                foregroundColor:
                                                                hoverExplain
                                                                    ? Colors.white
                                                                    : Colors.black,

                                                                padding: const EdgeInsets.symmetric(
                                                                  vertical: 16,
                                                                ),

                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(30),
                                                                ),
                                                              ),

                                                              onPressed: () {
                                                                Navigator.pop(context);

                                                                // Add logic here
                                                              },

                                                              child: const Text(
                                                                'I will try explaining again',
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(fontSize: 16),
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                        const SizedBox(height: 12),

                                                        // New Connections Button
                                                        MouseRegion(
                                                          onEnter: (_) {
                                                            setState(() {
                                                              hoverConnections = true;
                                                            });
                                                          },

                                                          onExit: (_) {
                                                            setState(() {
                                                              hoverConnections = false;
                                                            });
                                                          },

                                                          child: SizedBox(
                                                            width: double.infinity,
                                                            child: ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                hoverConnections
                                                                    ? Colors.blue
                                                                    : Colors.grey.shade300,

                                                                foregroundColor:
                                                                hoverConnections
                                                                    ? Colors.white
                                                                    : Colors.black,

                                                                padding: const EdgeInsets.symmetric(
                                                                  vertical: 16,
                                                                ),

                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(30),
                                                                ),
                                                              ),

                                                              onPressed: () {
                                                                Navigator.pop(context);

                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => const TaskPage(),
                                                                  ),
                                                                );
                                                              },

                                                              child: const Text(
                                                                'Help me find new connections',
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(fontSize: 16),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          },

                                          child: const Text(
                                            '1',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Button 2
                                    MouseRegion(
                                      onEnter: (_) {
                                        setState(() {
                                          hoverTwo = true;
                                        });
                                      },

                                      onExit: (_) {
                                        setState(() {
                                          hoverTwo = false;
                                        });
                                      },

                                      child: SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            hoverTwo ? Colors.blue : Colors.grey.shade300,

                                            foregroundColor:
                                            hoverTwo ? Colors.white : Colors.black,

                                            padding: const EdgeInsets.symmetric(vertical: 16),

                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                          ),

                                          onPressed: () {
                                            Navigator.pop(context);

                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(25),
                                                  ),

                                                  content: const Text(
                                                    'We do not have direct help within the app for that, '
                                                        'but you can try translators or accent helpers.\n\n'

                                                        'We have suggested a few platforms below to guide you :)',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  ),

                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },

                                                      child: const Text(
                                                        'OK',
                                                        style: TextStyle(fontSize: 16),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },

                                          child: const Text(
                                            '2',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },

                      child: const Text(
                        'Once/Few Times',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Secondary Button
                MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      hoverSecondary = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      hoverSecondary = false;
                    });
                  },

                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        hoverSecondary ? Colors.blue : Colors.grey.shade300,

                        foregroundColor:
                        hoverSecondary ? Colors.white : Colors.black,

                        padding: const EdgeInsets.symmetric(vertical: 16),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),

                      onPressed: () {
                        Navigator.pop(context);

                        bool hoverGroup = false;
                        bool hoverEveryone = false;

                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),

                                  title: const Text(
                                    'Which of the following is true?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),

                                  actionsPadding:
                                  const EdgeInsets.fromLTRB(20, 0, 20, 20),

                                  actions: [

                                    // Button 1
                                    MouseRegion(
                                      onEnter: (_) {
                                        setState(() {
                                          hoverGroup = true;
                                        });
                                      },

                                      onExit: (_) {
                                        setState(() {
                                          hoverGroup = false;
                                        });
                                      },

                                      child: SizedBox(
                                        width: double.infinity,

                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            hoverGroup
                                                ? Colors.blue
                                                : Colors.grey.shade300,

                                            foregroundColor:
                                            hoverGroup
                                                ? Colors.white
                                                : Colors.black,

                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),

                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                          ),

                                          onPressed: () {
                                            Navigator.pop(context);

                                            bool hoverConnect = false;
                                            bool hoverExplainAgain = false;

                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return StatefulBuilder(
                                                  builder: (context, setState) {
                                                    return AlertDialog(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(25),
                                                      ),

                                                      title: const Text(
                                                        'New Connections',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 24,
                                                        ),
                                                      ),

                                                      content: const Text(
                                                        'Sometimes differences between people are so high '
                                                            'that connections are not formed well.\n\n'

                                                            'In that case, our best bet is to move on and find '
                                                            'new connections.\n\n'

                                                            'Do you want to make new connections?',

                                                        style: TextStyle(
                                                          fontSize: 18,
                                                        ),
                                                      ),

                                                      actionsPadding:
                                                      const EdgeInsets.fromLTRB(20, 0, 20, 20),

                                                      actions: [

                                                        // YES BUTTON
                                                        MouseRegion(
                                                          onEnter: (_) {
                                                            setState(() {
                                                              hoverConnect = true;
                                                            });
                                                          },

                                                          onExit: (_) {
                                                            setState(() {
                                                              hoverConnect = false;
                                                            });
                                                          },

                                                          child: SizedBox(
                                                            width: double.infinity,

                                                            child: ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                hoverConnect
                                                                    ? Colors.blue
                                                                    : Colors.grey.shade300,

                                                                foregroundColor:
                                                                hoverConnect
                                                                    ? Colors.white
                                                                    : Colors.black,

                                                                padding: const EdgeInsets.symmetric(
                                                                  vertical: 16,
                                                                ),

                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(30),
                                                                ),
                                                              ),

                                                              onPressed: () {
                                                                Navigator.pop(context);

                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => const TaskPage(),
                                                                  ),
                                                                );
                                                              },

                                                              child: const Text(
                                                                "Yes! Let's connect",
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(fontSize: 16),
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                        const SizedBox(height: 12),

                                                        // NO BUTTON
                                                        MouseRegion(
                                                          onEnter: (_) {
                                                            setState(() {
                                                              hoverExplainAgain = true;
                                                            });
                                                          },

                                                          onExit: (_) {
                                                            setState(() {
                                                              hoverExplainAgain = false;
                                                            });
                                                          },

                                                          child: SizedBox(
                                                            width: double.infinity,

                                                            child: ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                hoverExplainAgain
                                                                    ? Colors.blue
                                                                    : Colors.grey.shade300,

                                                                foregroundColor:
                                                                hoverExplainAgain
                                                                    ? Colors.white
                                                                    : Colors.black,

                                                                padding: const EdgeInsets.symmetric(
                                                                  vertical: 16,
                                                                ),

                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(30),
                                                                ),
                                                              ),

                                                              onPressed: () {
                                                                Navigator.pop(context);

                                                                // Add retry explanation logic here
                                                              },

                                                              child: const Text(
                                                                'No. I want to try once again explaining them',
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(fontSize: 16),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          },

                                          child: const Text(
                                            'With a particular group of people',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Button 2
                                    MouseRegion(
                                      onEnter: (_) {
                                        setState(() {
                                          hoverEveryone = true;
                                        });
                                      },

                                      onExit: (_) {
                                        setState(() {
                                          hoverEveryone = false;
                                        });
                                      },

                                      child: SizedBox(
                                        width: double.infinity,

                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            hoverEveryone
                                                ? Colors.blue
                                                : Colors.grey.shade300,

                                            foregroundColor:
                                            hoverEveryone
                                                ? Colors.white
                                                : Colors.black,

                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),

                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                          ),

                                          onPressed: () {
                                            Navigator.pop(context);

                                            // Add logic here
                                          },

                                          child: const Text(
                                            'With everyone',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },

                      child: const Text(
                        'Frequently/Always',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('It is fine if you do not fit one of the options :)'),
        content: const Text(
          'Email at pahal.bhatti11@gmail.com to share your thoughts about why you feel lonely and get personalized assistance.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF24B65E),

      appBar: AppBar(
        title: const Text('Questionnaire'),
        backgroundColor: const Color(0xFF388E3C),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Question Label
            const Text(
              'Why do you think you feel lonely?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 40),

            // Option 1
            ElevatedButton(
              onPressed: () async {
                await supabase
                    .from("users")
                    .update({
                  "intro_completed": true,
                })
                    .eq(
                  "username",
                  Session.username,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TaskPage(),
                  ),
                );
              },
              child: const Text(
                'Not able to talk to people or make friends',
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 15),

            // Option 2
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MoveCityPage(),
                  ),
                );
              },
              child: const Text(
                'I moved to a new place without most of my close friends/go to people',
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 15),

            // Option 2
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LossPage(),
                  ),
                );
              },
              child: const Text(
                'I recently lost someone close, and that left a hole in my social net',
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 15),

            // Option 3
            ElevatedButton(
              onPressed: () {
                showUnderstandMePopup(context);
              },
              child: const Text(
                'People around me don\'t understand me',
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 15),

            // Option 4
            ElevatedButton(
              onPressed: () {
                showMessage(context);
              },
              child: const Text(
                'Others',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MoveCityPage extends StatelessWidget {
  const MoveCityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF24B65E),

      appBar: AppBar(
        title: const Text('Moving to a New City'),
        backgroundColor: const Color(0xFF388E3C),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            // Scrollable text section
            Expanded(
              child: SingleChildScrollView(
                child: const Text(
                  'When we move to a new place, many things change. One of them includes our social connections. If we aren\'t able to match our social connections with our social hunger, we start feeling lonely. This is a very normal scenario and occurs to almost anyone who moves to a new place.\n\n'

                      'How do we combat it? Mainly, there are two options. First, try retaining the relationships we have back home. Second, make new friends instantly and be as close with them as we were with our friends back home. When you try reflecting on these options, you would realize that neither of them is perfectly possible (online connections with friends back home cannot suffice, and instantly making friends isn’t really possible).\n\n'

                      'So, our best bet is to take a hybrid approach: stay connected with your close friends back home and try to make new friends. We can offer you reminders for the former and help you with the latter after you choose one of the following options.',

                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Button 1
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TaskPage(),
                  ),
                );
              },
              child: const Text(
                'I can talk to strangers (like the ability to start a conversation with the stranger next to me on a metro/subway or the ability to small talk in an elevator)',
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 15),

            // Button 2
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TaskPage(),
                  ),
                );
              },
              child: const Text(
                'I have social anxiety, and I don’t find it comfortable to go out and talk to strangers.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LossPage extends StatelessWidget {
  const LossPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF24B65E),

      appBar: AppBar(
        title: const Text('Loss and Loneliness'),
        backgroundColor: const Color(0xFF388E3C),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            // Scrollable text
            Expanded(
              child: SingleChildScrollView(
                child: const Text(
                  'I am terribly sorry to hear that…\n\n'

                      'As humans, it takes us time to move on from our losses. So, we encourage you to sit down, reflect on your feelings (with professional help if needed), and decide whether you are sad or feeling lonely.\n\n'

                      'If you think you are sad and need time to move on, we can wait until then :)\n\n'

                      'However, if you feel lonely, then we might able to help you. This is not going to be a quick medicine dose, but rather a sustained effort from you that slowly heals your hurt soul. We will be just here as a guide in your journey.\n\n'

                      'Basics first. To stop feeling lonely, we need to connect with new people to satisfy our social hunger. The goal isn’t to replace those you lost, but rather to make a new net of connections. To start, choose one of the following options.',

                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Button 1
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TaskPage(),
                  ),
                );
              },
              child: const Text(
                'I can talk to strangers (like the ability to start a conversation with the stranger next to me on a metro/subway or the ability to small talk in an elevator)',
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 15),

            // Button 2
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TaskPage(),
                  ),
                );
              },
              child: const Text(
                'I have social anxiety, and I don’t find it comfortable to go out and talk to strangers.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class TaskPage extends StatefulWidget {

  final String? forcedStage;

  const TaskPage({

    super.key,

    this.forcedStage,

  });
  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {

  final supabase = Supabase.instance.client;

  String currentStage = "";
  int progress = 0;
  String currentTask = "";

  bool hoverDone = false;
  bool hoverAnother = false;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadTask();
  }
  final Random random = Random();
  late String realityCheck;
  late String bigTalkInsight;
  void generateRealityCheck() {

    realityCheck =
    realityChecks[
    random.nextInt(realityChecks.length)
    ];
  }
  void generateBigTalkInsight() {

    bigTalkInsight =
    bigTalkInsights[
    random.nextInt(
      bigTalkInsights.length,
    )
    ];
  }

  Future<void> handleRewardFlow() async {

    final user = await supabase
        .from("users")
        .select("premium")
        .eq("username", Session.username)
        .single();

    final premium = user["premium"] ?? false;

    if (premium) {

      final response =
      await supabase.functions.invoke(
        "send-reward",
        body: {
          "username": Session.username,
        },
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainPage(),
        ),
      );

      if (response.status != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't send reward."),
          ),
        );
      }

    } else {
      final user = await supabase
          .from("users")
          .select("shown_imdb, email")
          .eq("username", Session.username)
          .single();

      if (user["shown_imdb"] == false) {
        final String email = user["email"];

        await Supabase.instance.client.functions.invoke(
          "first-free-reward",
          body: {
            "email": user["email"],
            "username": Session.username,
          },
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainPage(),
          ),
        );
      }
      else {
        final response =
        await supabase.functions.invoke(
          "send-verify",
          body: {
            "username": Session.username,
          },
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainPage(),
          ),
        );

        if (response.status != 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Couldn't send Task Verification Link."),
            ),
          );
        }
      }

    }

  }

  Future<bool> askConnectionQuestion() async {

    final result =
    await showDialog<bool>(

      context: context,

      barrierDismissible: false,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Quick Question",
          ),

          content: const Text(
            "Do you feel more connected to other people?",
          ),

          actions: [

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },

              child: const Text(
                "Yes",
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },

              child: const Text(
                "No",
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> showPlayDateIntro() async {

    await showDialog(

      context: context,

      barrierDismissible: false,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Welcome to Play Time",
          ),

          content: const SizedBox(

            width: 500,
            height: 300,

            child: SingleChildScrollView(

              child: Text(

                "So far on this journey, you've practiced "
                    "starting conversations and building "
                    "connections with other people.\n\n"

                    "Conversations are powerful because they "
                    "help us learn about another person's "
                    "experiences, thoughts, and story. "
                    "However, conversations alone don't create "
                    "shared memories.\n\n"

                    "Many friendships grow stronger through "
                    "shared experiences: playing games, working "
                    "on activities together, exploring new "
                    "places, or simply spending time together.\n\n"

                    "In this stage, you'll receive suggestions "
                    "for games and activities that can be done "
                    "with other people.\n\n"

                    "These are only recommendations. You are "
                    "never required to play a particular game, "
                    "and you're always free to choose a "
                    "different activity that feels more "
                    "comfortable or enjoyable.\n\n"

                    "The goal isn't to complete a specific "
                    "game, but rather make jokes, tease each other and make memories."
              ),
            ),
          ),

          actions: [

            ElevatedButton(

              onPressed: () async {

                await markPlayDateSeen();

                Navigator.pop(context);
              },

              child: const Text(
                "Continue",
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> markPlayDateSeen() async {

    await supabase
        .from('users')
        .update({

      'playdate_intro_seen': true,

    })
        .eq(
      'username',
      Session.username,
    );
  }

  Future<void> showHyggeIntro() async {

    await showDialog(

      context: context,

      barrierDismissible: false,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Welcome to Hygge",
          ),

          content: const SizedBox(

            width: 500,
            height: 350,

            child: SingleChildScrollView(

              child: Text("Since several years, Scandanavian countries top the list as the happiest countries in the world. There can be speculations, but we believe that the culture of Hygge (pronounced hoo-gah) is a reason for that.\nHygge is a danish concept that, in short, symbolizes taking time out of your busy schedule for coziness and comfort with friends. It doesn't include specific things to do but rather simple routines like drinking hot chocolate and playing board games with warm lighting.\n\nIn hygge, the setting of comfort and coziness is more important than the activity itself. We are gonna give you some suggestions, but we also advice you to make your own routines and activities.\n\nP.S. This is the ultimate form of social connection.",
              ),
            ),
          ),

          actions: [

            ElevatedButton(

              onPressed: () async {

                await markHyggeSeen();

                Navigator.pop(context);
              },

              child: const Text(
                "Continue",
              ),
            ),
          ],
        );
      },
    );
  }
  Future<void> markHyggeSeen() async {

    await supabase
        .from('users')
        .update({

      'hygge_intro_seen': true,

    })
        .eq(
      'username',
      Session.username,
    );
  }
  Future<void> saveFinalFeedback(
      bool feelsLessLonely,
      ) async {

    await supabase
        .from('feedback')
        .insert({

      'username': Session.username,

      'less_lonely': feelsLessLonely,

      'stage_completed': 'hygge',

    });
  }

  Future<void> showBigTalkIntro() async {

    await showDialog(

      context: context,

      barrierDismissible: false,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Welcome to Big Talk",
          ),

          content: const SingleChildScrollView(

            child: Text(
                "almost everyone knows about small talk. However, that leads to shallow connections. The more deeper we go into a person's life, the more connected we feel with them. On this idea, an undergraduate (Kalina silverman) came up with a solution to loneliness and named it on the lines of small talk: big talk. in the following section, you will be given prompts that go deeper than basic questions. We advice you to exercise these conversations with someone you already know (to make you feel comfortable with big talk), and later go to strangers and perform this exercise. Another advice is to keep the conversation going for atleast 5 minutes, because it would be awkward if you ask a deep question and end the conversation abruptly for the other person and for your brain. Your brain will likely crash from deep connection to suddenly zero. \n To keep the conversation going you can remember small talk topics or just ask other relatded things to the question you just asked. As always, if you feel you aren't able to do it at any point, you can opt out, but remember short-term anxiety and doubt won't solve your long-term loneliness.",
            ),
          ),

          actions: [

            ElevatedButton(

              onPressed: () async {

                await markBigTalkSeen();

                Navigator.pop(context);
              },

              child: const Text(
                "Continue",
              ),
            ),
          ],
        );
      },
    );
  }
  Future<void> showGraduationDialog() async {

    await showDialog(

      context: context,

      barrierDismissible: false,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Congratulations 🎉",
          ),

          content: const SingleChildScrollView(

            child: Text(

              "This marks the end of your journey through the guided stages. You had started from small conversation, and managed to go to the ultimate medium of social connection: hygge. If your goal of connecting with others or feeling less lonely was not satisfied, you can write an email to us and we can help you directly. However, if you feel that you don't feel lonely as much as you did before (it's fine if it isn't zero), we would advice to keep going down this journey of mainitaining and building connections. We suggest this because if you stop, your social connections will go down, and the brain used to your current level of connections will feel socially hunger (aka lonely). \n\nWe do not ask you to keep using this app, but we can still help you if you need ideas. After this point, the Let's connect button on your main screen will open to a page that gives you a button to each stage you went through. In case you need it, you can choose the stage and take prompts from there. \n\nInstead of saying good bye, we are gonna ask you a self-reflection question. Do you feel less lonely by taking our help?"
            ),
          ),

          actions: [

            ElevatedButton(

              onPressed: () async {
                await saveFinalFeedback(true);
                Navigator.pop(context);
              },

              child: const Text(
                "Yes :)",
              ),
            ),
            ElevatedButton(
                onPressed: () async {
                  await saveFinalFeedback(false);
                  Navigator.pop(context);
                }, child: const Text("No :("))
          ],
        );
      },
    );
  }
  Future<void> markBigTalkSeen() async {

    await supabase
        .from('users')
        .update({

      'bigtalk_intro_seen': true,

    })
        .eq(
      'username',
      Session.username,
    );
  }
  Future<void> updateLonelinessStats(
      bool answeredYes,
      ) async {

    final data = await supabase
        .from('users')
        .select(
      'lonely_yes, lonely_total',
    )
        .eq(
      'username',
      Session.username,
    )
        .single();

    int yes =
    data['lonely_yes'];

    int total =
    data['lonely_total'];

    total++;

    if (answeredYes) {
      yes++;
    }

    await supabase
        .from('users')
        .update({

      'lonely_yes': yes,
      'lonely_total': total,

    })
        .eq(
      'username',
      Session.username,
    );
  }
  Future<void> loadTask() async {
      final data = await supabase
          .from('users')
          .select()
          .eq('username', Session.username)
          .single();

      currentStage =
          widget.forcedStage ?? (data['current_stage'] ?? 'smalltalk');
      bool bigTalkSeen = data['bigtalk_intro_seen'] ?? false;
      bool playDateSeen = data['playdate_intro_seen'] ?? false;
      bool hyggeSeen = data['hygge_intro_seen'] ?? false;
      progress = data['stage_progress'] ?? 0;
      final bool introCompleted = data['intro_completed'] ?? false;

      if (
      currentStage == "bigtalk" &&
          !bigTalkSeen
      ) {
        Future.delayed(
          const Duration(milliseconds: 500),
              () => showBigTalkIntro(),
        );
      }

      if (
      currentStage == "playdate" &&
          !playDateSeen
      ) {
        Future.delayed(
          const Duration(milliseconds: 500),
              () => showPlayDateIntro(),
        );
      }

      if (
      currentStage == "hygge" &&
          !hyggeSeen
      ) {
        Future.delayed(
          const Duration(milliseconds: 500),
              () => showHyggeIntro(),
        );
      }

      if (!introCompleted) {
        Future.delayed(
          const Duration(milliseconds: 500),
              () => showIntroDialog(),
        );
      }

      if (currentStage == "smalltalk") {
        generateRealityCheck();
      }
      else if (currentStage == "bigtalk") {
        generateBigTalkInsight();
      }
      generateTask();

      setState(() {
        loading = false;
      });
    }

  Future<void> showIntroDialog() async {

    showDialog(
      context: context,

      barrierDismissible: false,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Welcome",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: const SingleChildScrollView(
            child: Text(
                "loneliness or inability to connect with others is a feeling, not a disease. Therefore, we are going to help you as if it is a human journey over taking 1 pill every day. This app isn't a magic tool for not being lonely, but rather a helper in overcoming this feeling. since you have downloaded this app, I think I can start with this journey of yours. We are gonna start slowly from small talk or short talk conversations like asking what the time is to someone. In case you feel you don't want to do it you can press I want another task and the app will randomly pick another option for you. This option is unlimited but remember time isn't. So, pick one and just try it out. When you are done you can press on the done button to guide yourself to the main page. Remember: you are not compelled to do the tasks. We are just here to help you if you need it :)"
            ),
          ),

          actions: [

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                "Let's Begin",
              ),
            ),
          ],
        );
      },
    );
  }

  void generateTask() async {

    currentTask = getRandomTask(currentStage);

    setState(() {});
  }
  
Future<void> showFriendInteractionDialog(
  BuildContext context,
  String completedStage,
) async {
  final username = Session.username;

  List<Map<String, dynamic>> friends = [];
  int? selectedFriendId;
  bool addNewFriend = false;
  bool loadingFriends = true;
  bool saving = false;

  int comfort = 3;
  int happiness = 3;

  final nameController = TextEditingController();
  final notesController = TextEditingController();

  try {
    final response = await supabase
        .from('friends')
        .select('id, display_name')
        .eq('username', username)
        .order('display_name');

    friends = List<Map<String, dynamic>>.from(response);
    loadingFriends = false;

    if (friends.isEmpty) {
      addNewFriend = true;
    }
  } catch (e) {
    debugPrint('Could not load friends: $e');
    loadingFriends = false;
    addNewFriend = true;
  }

  if (!mounted) return;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, updateDialog) {
          Widget ratingSection({
            required String title,
            required String description,
            required int value,
            required ValueChanged<int> onChanged,
            required IconData icon,
          }) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: const Color(0xFF176B3A)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF263C2C),
                        ),
                      ),
                    ),
                    Text(
                      '$value/5',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF176B3A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                Slider(
                  value: value.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  activeColor: const Color(0xFF176B3A),
                  label: '$value',
                  onChanged: onChanged,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('1 · Low', style: TextStyle(fontSize: 11)),
                    Text('5 · High', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ],
            );
          }

          Future<void> saveInteraction() async {
            if (saving) return;

            final name = nameController.text.trim();

            if (addNewFriend && name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter your friend’s name.'),
                ),
              );
              return;
            }

            if (!addNewFriend && selectedFriendId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select a friend.'),
                ),
              );
              return;
            }

            updateDialog(() => saving = true);

            try {
              dynamic friendId = selectedFriendId;

              if (addNewFriend) {
                final newFriend = await supabase
                    .from('friends')
                    .insert({
                      'username': username,
                      'display_name': name,
                      'comfort_rating': comfort,
                      'happiness_rating': happiness,
                      'highest_stage': completedStage,
                      'last_interaction_at':
                          DateTime.now().toIso8601String(),
                    })
                    .select('id')
                    .single();

                friendId = newFriend['id'];
              }

              await supabase.from('friend_interactions').insert({
                'username': username,
                'friend_id': friendId,
                'stage': completedStage,
                'comfort_rating': comfort,
                'happiness_rating': happiness,
                'notes': notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
              });

              if (!addNewFriend) {
                final existingFriend = friends.firstWhere(
                  (friend) => friend['id'] == selectedFriendId,
                );

                final oldStage =
                    existingFriend['highest_stage'] as String? ??
                    'smalltalk';

                final oldOrder = stageOrder[oldStage] ?? 1;
                final newOrder = stageOrder[completedStage] ?? 1;

                final update = <String, dynamic>{
                  'comfort_rating': comfort,
                  'happiness_rating': happiness,
                  'last_interaction_at':
                      DateTime.now().toIso8601String(),
                };

                if (newOrder > oldOrder) {
                  update['highest_stage'] = completedStage;
                }

                await supabase
                    .from('friends')
                    .update(update)
                    .eq('id', friendId)
                    .eq('username', username);
              }

              if (!dialogContext.mounted) return;

              Navigator.pop(dialogContext);
            } catch (e) {
              debugPrint('Error saving friend interaction: $e');

              updateDialog(() => saving = false);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Could not save interaction: $e'),
                ),
              );
            }
          }

          return AlertDialog(
            backgroundColor: const Color(0xFFF8FCF8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              'How did it go?',
              style: TextStyle(
                color: Color(0xFF176B3A),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Who did you interact with?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF263C2C),
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (loadingFriends)
                      const Center(
                        child: CircularProgressIndicator(),
                      )
                    else ...[
                      if (friends.isNotEmpty)
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Add a new friend',
                            style: TextStyle(fontSize: 14),
                          ),
                          value: addNewFriend,
                          activeColor: const Color(0xFF176B3A),
                          onChanged: (value) {
                            updateDialog(() {
                              addNewFriend = value;
                              if (!value && friends.isNotEmpty) {
                                selectedFriendId ??= friends.first['id'] as int;
                              }
                            });
                          },
                        ),

                      if (addNewFriend)
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Friend’s name',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      else
                        DropdownButtonFormField<int>(
                          value: selectedFriendId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Select a friend',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: friends.map((friend) {
                            return DropdownMenuItem<int>(
                              value: friend['id'] as int,
                              child: Text(
                                friend['display_name'] ?? 'Friend',
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            updateDialog(() {
                              selectedFriendId = value;
                            });
                          },
                        ),
                    ],

                    const SizedBox(height: 22),

                    ratingSection(
                      title: 'How comfortable did you feel?',
                      description:
                          'Think about how natural and relaxed the interaction felt.',
                      value: comfort,
                      icon: Icons.favorite_outline,
                      onChanged: (value) {
                        updateDialog(() => comfort = value);
                      },
                    ),

                    const SizedBox(height: 18),

                    ratingSection(
                      title: 'How happy did you feel afterwards?',
                      description:
                          'Did the interaction leave you feeling positive?',
                      value: happiness,
                      icon: Icons.sentiment_satisfied_alt,
                      onChanged: (value) {
                        updateDialog(() => happiness = value);
                      },
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Anything you want to remember? (Optional)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF263C2C),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'A little about how it went...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: saving ? null : saveInteraction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF176B3A),
                  foregroundColor: Colors.white,
                ),
                child: saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save interaction'),
              ),
            ],
          );
        },
      );
    },
  );

  nameController.dispose();
  notesController.dispose();
}

  
Future<void> completeTask() async {
  try {
    await showFriendInteractionDialog(
      context,
      currentStage,
    );

    if (!mounted) return;

    await handleRewardFlow();
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Something went wrong: $e'),
      ),
    );
  }
}


  Future<void> increaseProgress(
      int amount,
      ) async {

    await supabase
        .from('users')
        .update({
      'intro_completed': true,
    })
        .eq(
      'username',
      Session.username,
    );

    progress += amount;

    /// STAGE ADVANCEMENT
    if (progress >= 6) {
      if (currentStage == "hygge") {
        await supabase
            .from('users')
            .update({

          'graduated': true,
          'graduation_seen': true,

        })
            .eq(
          'username',
          Session.username,
        );

        await showGraduationDialog();
      }
      if (currentStage == "mediumtalk") {
        final user = await supabase
            .from("users")
            .select("email")
            .eq("username", Session.username)
            .single();

        final email = user["email"];

          final response =
          await Supabase.instance.client.functions.invoke(
            'PMF-feedback',
            body: {
              'email': email,
            },
          );

          if (response.status != 200) {
            throw Exception("Couldn't send email");
          }
      }

      final answeredYes =
      await askConnectionQuestion();

      await updateLonelinessStats(
        answeredYes,
      );

      final currentIndex =
      stages.indexOf(currentStage);

      if (currentIndex <
          stages.length - 1) {

        currentStage =
        stages[currentIndex + 1];

        progress = 0;


      }
    }

    /// UPDATE DATABASE
    await supabase
        .from('users')
        .update({

      'current_stage': currentStage,
      'stage_progress': progress,
      'verifyshow': true

    })
        .eq(
      'username',
      Session.username,
    );
    /*Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const MainPage(),
      ),
    );*/
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      backgroundColor:
      const Color(0xFF24B65E),

      appBar: AppBar(

        title: Text(
          currentStage.toUpperCase(),

          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        centerTitle: true,

        backgroundColor:
        const Color(0xFF24B65E),
      ),

      body: SingleChildScrollView(

        physics:
        const BouncingScrollPhysics(),

        child: Center(

          child: Padding(
            padding:
            const EdgeInsets.all(25),

            child: Container(

              width: MediaQuery.of(context).size.width * 0.9,

              padding:
              const EdgeInsets.all(30),

              decoration: BoxDecoration(

                color:
                const Color(0xFFFFFFFF),

                borderRadius:
                BorderRadius.circular(25),

                border: Border.all(
                  color:
                  Colors.green.shade700,
                  width: 3,
                ),

                boxShadow: [

                  BoxShadow(
                    color:
                    Colors.black.withOpacity(
                      0.2,
                    ),

                    blurRadius: 15,

                    offset:
                    const Offset(0, 8),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize:
                MainAxisSize.min,

                children: [

                  Image.asset(
                    'asset/LCLogo2.png',
                    height: 120,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  /// STAGE LABEL
                  /*Text(
                    currentStage,

                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight:
                      FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),*/

                  const SizedBox(
                    height: 25,
                  ),

                if (currentStage == "smalltalk") ...[
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(15),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),

                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 2,
                      ),
                    ),

                    child: Column(
                      children: [

                        const Text(
                          "Shh: insider info",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          realityCheck,
                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  )],

                  if (currentStage == "bigtalk") ...[

                    Container(

                      width: double.infinity,

                      padding: const EdgeInsets.all(15),

                      decoration: BoxDecoration(

                        color: Colors.white,

                        borderRadius:
                        BorderRadius.circular(15),

                        border: Border.all(
                          color: Colors.purple.shade200,
                          width: 2,
                        ),
                      ),

                      child: Column(

                        children: [

                          const Text(

                            "💡 Big Talk Insight",

                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.purple,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(

                            bigTalkInsight,

                            textAlign: TextAlign.center,

                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                  ],


                  const SizedBox(height: 25),

                  /// TASK
                  Text(
                    currentTask,

                    textAlign:
                    TextAlign.center,

                    style:
                    const TextStyle(
                      fontSize: 24,
                      height: 1.5,
                      color:
                      Colors.black87,
                    ),
                  ),

                  const SizedBox(
                    height: 40,
                  ),

                  /// DONE BUTTON
                  MouseRegion(

                    onEnter: (_) {

                      setState(() {
                        hoverDone = true;
                      });
                    },

                    onExit: (_) {

                      setState(() {
                        hoverDone = false;
                      });
                    },

                    child: SizedBox(

                      width: 220,

                      child: ElevatedButton(

                        style:
                        ElevatedButton
                            .styleFrom(

                          backgroundColor:

                          hoverDone
                              ? Colors.blue
                              : Colors.green,

                          foregroundColor:
                          Colors.white,

                          padding:
                          const EdgeInsets
                              .symmetric(
                            vertical: 18,
                          ),

                          shape:
                          RoundedRectangleBorder(

                            borderRadius:
                            BorderRadius.circular(
                              15,
                            ),
                          ),
                        ),

                        onPressed:
                        completeTask,

                        child: const Text(

                          "Done",

                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  /// ANOTHER TASK
                  MouseRegion(

                    onEnter: (_) {

                      setState(() {
                        hoverAnother = true;
                      });
                    },

                    onExit: (_) {

                      setState(() {
                        hoverAnother = false;
                      });
                    },

                    child: SizedBox(

                      width: 220,

                      child: ElevatedButton(

                        style:
                        ElevatedButton
                            .styleFrom(

                          backgroundColor:

                          hoverAnother
                              ? Colors.blue
                              : Colors.green,

                          foregroundColor:
                          Colors.white,

                          padding:
                          const EdgeInsets
                              .symmetric(
                            vertical: 18,
                          ),

                          shape:
                          RoundedRectangleBorder(

                            borderRadius:
                            BorderRadius.circular(
                              15,
                            ),
                          ),
                        ),

                        onPressed:
                        generateTask,

                        child: const Text(

                          "Another Task",

                          textAlign:
                          TextAlign.center,

                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});


  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final PageController controller = PageController();
  final supabase = Supabase.instance.client;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int currentPage = 0;
  bool isPremium = false;
  int pendingRewards = 0;

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      final page = controller.page?.round() ?? 0;

      if (page != currentPage) {
        setState(() {
          currentPage = page;
        });
      }
    });
	    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        ReviewService.maybeRequestReview();
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  Future<void> openTask() async {
  try {
    final data = await supabase
        .from('users')
        .select('graduated')
        .eq('username', Session.username)
        .single();

    final graduated = data['graduated'] ?? false;

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => graduated
            ? const StageSelectionPage()
            : const TaskPage(),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unable to open task: $e')),
    );
  }
}


  Future<void> openLink(String url) async {
    final uri = Uri.parse(url);

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }


  Future<void> showAccountSettingsDialog() async {

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: const Text(
            "Account Settings",
          ),

          content: const Text(
            "What would you like to change?",
          ),

          actions: [

            ElevatedButton(
              onPressed: () {

                Navigator.pop(context);

                showChangeUsernameDialog();
              },

              child: const Text(
                "Username",
              ),
            ),

            ElevatedButton(
              onPressed: () {

                Navigator.pop(context);

                showChangePasswordDialog();
              },

              child: const Text(
                "Password",
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> showLogoutDialog() async {

    final prefs = await SharedPreferences.getInstance();

    showDialog(
      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Logout",
          ),

          content: const Text(
            "Are you sure you want to sign out?",
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                "Cancel",
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                await prefs.setBool(
                  "loggedIn",
                  false,
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const LoginPage(),
                  ),
                      (route) => false,
                );
              },

              child: const Text(
                "Logout",
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> showPdfLinkPopup(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("UCLA Loneliness Scale"),
        content: const Text(
          "The UCLA Loneliness Scale is available online. Copy and paste this link in your favorite browser\nhttps://backend.fetzer.org/sites/default/files/images/stories/pdf/selfmeasures/Self_Measures_for_Love_and_Compassion_Research_LONELINESS_AND_INTERPERSONAL_PROBLEMS.pdf",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Ok"),
          ),
        ],
      ),
    );
  }

  Future<void> showChangeUsernameDialog() async {

    final currentPasswordController =
    TextEditingController();

    final newUsernameController =
    TextEditingController();

    final supabase =
        Supabase.instance.client;

    showDialog(
      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Change Username",
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [

              TextField(
                controller:
                currentPasswordController,

                obscureText: true,

                decoration:
                const InputDecoration(
                  labelText:
                  "Current Password",
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller:
                newUsernameController,

                decoration:
                const InputDecoration(
                  labelText:
                  "New Username",
                ),
              ),
            ],
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                "Cancel",
              ),
            ),

            ElevatedButton(
              onPressed: () async {

                final user =
                await supabase
                    .from('users')
                    .select()
                    .eq(
                  'username',
                  Session.username,
                )
                    .eq(
                  'password',
                  currentPasswordController
                      .text
                      .trim(),
                )
                    .maybeSingle();

                if (user == null) {

                  ScaffoldMessenger.of(
                      context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Incorrect password",
                      ),
                    ),
                  );

                  return;
                }

                await supabase
                    .from('users')
                    .update({
                  'username':
                  newUsernameController
                      .text
                      .trim(),
                })
                    .eq(
                  'username',
                  Session.username,
                );

                Session.username =
                    newUsernameController
                        .text
                        .trim();

                Navigator.pop(context);

                ScaffoldMessenger.of(
                    context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Username updated",
                    ),
                  ),
                );
              },

              child: const Text(
                "Save",
              ),
            ),
          ],
        );
      },
    );
  }
  void showContactDialog() {

    showDialog(

      context: context,

      builder: (context) => AlertDialog(

        title: const Text(
          "Contact Us",
        ),

        content: const Text(
          "Got feedback, want to report problems or just need someone to talk to?\n\n"
              "Email:\n"
              "pahal.bhatti11@gmail.com",
        ),

        actions: [

          TextButton(

            onPressed: () {
              Navigator.pop(context);
            },

            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
  void showReasonDialog() {

    showDialog(

      context: context,

      builder: (context) => AlertDialog(

        title: const Text(
          "Change Reason?",
        ),

        content: const Text(
          "You can retake the loneliness questionnaire and choose a different reason. Basically you will go back to the page where you chose the answer to the question 'why do you think you feel lonely'.",
        ),

        actions: [

          TextButton(

            onPressed: () {
              Navigator.pop(context);
            },

            child: const Text("Cancel"),
          ),

          TextButton(

            onPressed: () {

              Navigator.pop(context);

              Navigator.push(

                context,

                MaterialPageRoute(
                  builder: (_) =>
                  const LonelyPage(),
                ),
              );
            },

            child: const Text("Continue"),
          ),
        ],
      ),
    );
  }
  Future<void> deleteAccount() async {
 
    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Delete Account"),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            "Are you sure you want to permanently delete your account?",
          ),
        ),
        actions: [
 
          CupertinoDialogAction(
            child: const Text("No"),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
 
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Yes"),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
 
        ],
      ),
    );
 
    if (confirm != true) return;
 
    try {
 
      await supabase
          .from("users")
          .delete()
          .eq("username", Session.username);
 
      final prefs =
      await SharedPreferences.getInstance();
 
      await prefs.clear();
 
      if (!mounted) return;
 
      Navigator.pushAndRemoveUntil(
 
        context,
 
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
 
            (route) => false,
 
      );
 
    } catch (e) {
 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$e"),
        ),
      );
 
    }
 
  }
  void showPromoCodeDialog(BuildContext context) {

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          title: const Text(
            "My Promo Code",
          ),

          content: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              const Text(

                "While registering, if a new user enters your promo code, both of you will receive one Premium Reward.\n\n",

                textAlign: TextAlign.center,

              ),

              const SizedBox(height: 25),

              SelectableText(

                Session.promoCode,

                style: const TextStyle(

                  fontSize: 28,

                  fontWeight: FontWeight.bold,

                  letterSpacing: 2,

                ),

              ),

            ],

          ),

          actions: [

            TextButton.icon(

              onPressed: () async {

                await Clipboard.setData(

                  ClipboardData(
                    text: Session.promoCode,
                  ),

                );

                if (!context.mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(

                  const SnackBar(

                    content: Text(
                      "Promo code copied.",
                    ),

                  ),

                );

              },

              icon: const Icon(Icons.copy),

              label: const Text("Copy"),

            ),

          ],

        );

      },

    );

  }
  Future<void> showChangePasswordDialog() async {

    final currentPasswordController =
    TextEditingController();

    final newPasswordController =
    TextEditingController();

    final supabase = Supabase.instance.client;

    showDialog(
      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Change Password",
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [

              TextField(
                controller:
                currentPasswordController,

                obscureText: true,

                decoration:
                const InputDecoration(
                  labelText:
                  "Current Password",
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller:
                newPasswordController,

                obscureText: true,

                decoration:
                const InputDecoration(
                  labelText:
                  "New Password",
                ),
              ),
            ],
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                "Cancel",
              ),
            ),

            ElevatedButton(
              onPressed: () async {

                final user =
                await supabase
                    .from('users')
                    .select()
                    .eq(
                  'username',
                  Session.username,
                )
                    .eq(
                  'password',
                  currentPasswordController
                      .text
                      .trim(),
                )
                    .maybeSingle();

                if (user == null) {

                  ScaffoldMessenger.of(
                      context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Incorrect password",
                      ),
                    ),
                  );

                  return;
                }

                await supabase
                    .from('users')
                    .update({
                  'password':
                  newPasswordController
                      .text
                      .trim(),
                })
                    .eq(
                  'username',
                  Session.username,
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(
                    context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Password updated",
                    ),
                  ),
                );
              },

              child: const Text(
                "Save",
              ),
            ),
          ],
        );
      },
    );
  }

  
Widget buildDrawer() {
  return Drawer(
    backgroundColor: const Color(0xFFF5FAF6),
    child: SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 30),

          const CircleAvatar(
            radius: 38,
            backgroundImage: AssetImage('asset/LCicon.png'),
          ),

          const SizedBox(height: 15),

          Text(
            'Welcome, ${Session.username}',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: Color(0xFF104D2C),
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'One connection at a time.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 30),

          const Divider(),

          ListTile(
            leading: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF176B3A),
            ),
            title: const Text('My Profile'),
            subtitle: const Text('Account and preferences'),
            onTap: () {
              Navigator.pop(context);

              controller.animateToPage(
                3,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
              );
            },
          ),

          ListTile(
            leading: const Icon(
              Icons.task_alt_rounded,
              color: Color(0xFF176B3A),
            ),
            title: const Text('My Tasks'),
            onTap: () {
              Navigator.pop(context);

              controller.animateToPage(
                0,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
              );
            },
          ),

          ListTile(
            leading: const Icon(
              Icons.psychology_alt_rounded,
              color: Color(0xFF176B3A),
            ),
            title: const Text('Conversation Gym'),
            onTap: () {
              Navigator.pop(context);

              controller.animateToPage(
                2,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
              );
            },
          ),

          const Spacer(),

          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'LC • LET’S CONNECT',
              style: TextStyle(
                color: Colors.black38,
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
        return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B8A4C), Color(0xFF115C34), Color(0xFF082A1B)],
        ),
      ),
      child: Scaffold(
      key: _scaffoldKey,
      drawer: buildDrawer(),
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
		scrolledUnderElevation: 0,

        
        title: const CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage("asset/LCicon.png"),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
              size: 24,
            ),
            tooltip: 'Open menu',
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],

        /*actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),

            onSelected: (value) {

              if (value == "reason") {
                showReasonDialog();
              }

              else if (value == "account") {
                showAccountSettingsDialog();
              }

              else if (value == "contact") {
                showContactDialog();
              }

              else if (value == "logout") {
                showLogoutDialog();
              }
            },

            itemBuilder: (context) => [

              const PopupMenuItem(
                value: "reason",
                child: Text(
                  "Choose Different Reason for loneliness",
                ),
              ),

              const PopupMenuItem(
                value: "account",
                child: Text(
                  "Change Username / Password",
                ),
              ),

              const PopupMenuItem(
                value: "contact",
                child: Text(
                  "Contact Us",
                ),
              ),

              const PopupMenuItem(
                value: "logout",
                child: Text(
                  "Logout",
                ),
              ),
            ],
          ),
        ],*/
      ),
      
body: SafeArea(
  bottom: false,
  child: PageView(
    controller: controller,
    onPageChanged: (index) {
      setState(() {
        currentPage = index;
      });
    },
    children: [
      // 0 — TASK
      _TaskHomeTab(
        onStart: openTask,
      ),

      // 1 — FRIENDS
      _ConnectionsTab(
        onNewConnection: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const TaskPage(
        forcedStage: 'smalltalk',
      ),
    ),
  );
},
        onExistingConnection: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const StageSelectionPage(),
            ),
          );
        },
      ),

      // 2 — EXERCISES
      const ExercisesPage(),

      // 3 — PROFILE
      _ProfileTab(
        username: Session.username,

        onLonelinessTest: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const UCLAPage(),
            ),
          );
        },

        onAccountSettings: showAccountSettingsDialog,
        onReason: showReasonDialog,

        onPromoCode: () {
          showPromoCodeDialog(context);
        },

        onContact: showContactDialog,

        onLocation: () async {
          try {
            await updateCurrentLocation();

            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location updated successfully.'),
              ),
            );
          } catch (e) {
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString())),
            );
          }
        },

        onRate: () {
          ReviewService.openStoreListing();
        },

        onDelete: deleteAccount,
        onLogout: showLogoutDialog,
      ),
    ],
  ),
),

bottomNavigationBar: SafeArea(
  top: false,
  child: _GlassBottomNavigation(
    currentIndex: currentPage,
    onSelected: (index) {
      controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    },
  ),
),
),
    );
  }
}

class _GlassBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelected;

  const _GlassBottomNavigation({
    required this.currentIndex,
    required this.onSelected,
  });

  static const items = [
    (Icons.task_alt_rounded, 'Task'),
    (Icons.people_alt_rounded, 'Friends'),
    (Icons.psychology_alt_rounded, 'Exercise'),
    (Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 5, 14, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 25,
            sigmaY: 25,
          ),
          child: Container(
            height: 76,
            decoration: BoxDecoration(
				color: Colors.white.withOpacity(0.10),
				borderRadius: BorderRadius.circular(35),
              border: Border.all(
                color: Colors.white.withOpacity(0.19),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.22),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / 4;

                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      left: currentIndex * itemWidth + 5,
                      top: 5,
                      bottom: 5,
                      width: itemWidth - 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFB8F4CE)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: const Color(0xFFB8F4CE)
                                .withOpacity(0.25),
                          ),
                        ),
                      ),
                    ),

                    Row(
                      children: List.generate(4, (index) {
                        final selected = currentIndex == index;

                        return Expanded(
                          child: InkWell(
                            onTap: () => onSelected(index),
                            borderRadius: BorderRadius.circular(30),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedScale(
                                  duration: const Duration(milliseconds: 250),
                                  scale: selected ? 1.12 : 1,
                                  child: Icon(
                                    items[index].$1,
                                    size: 25,
                                    color: selected
                                        ? const Color(0xFF86EBAA)
                                        : Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  items[index].$2,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: selected
                                        ? FontWeight.w900
                                        : FontWeight.w600,
                                    color: selected
                                        ? const Color(0xFF86EBAA)
                                        : Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskHomeTab extends StatefulWidget {
  final VoidCallback onStart;
  const _TaskHomeTab({required this.onStart});
  @override
  State<_TaskHomeTab> createState() => _TaskHomeTabState();
}

class _TaskHomeTabState extends State<_TaskHomeTab> {
  String stage = 'smalltalk';
  int progress = 0;
  late final String tip =
      realityChecks[Random().nextInt(realityChecks.length)];

  static const labels = {
    'smalltalk': 'Small Talk',
    'mediumtalk': 'Medium Talk',
    'bigtalk': 'Big Talk',
    'voicecall': 'Voice Call',
    'playdate': 'Play Time',
    'hygge': 'Hygge',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await Supabase.instance.client
          .from('users')
          .select('current_stage, stage_progress')
          .eq('username', Session.username)
          .single();
      if (!mounted) return;
      setState(() {
        stage = d['current_stage'] ?? 'smalltalk';
        progress = d['stage_progress'] ?? 0;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final idx = stages.indexOf(stage).clamp(0, stages.length - 1);
    final overall = ((idx * 6) + progress) / (stages.length * 6);

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
      children: [
        _FadeSlide(
          delay: 0,
          child: Text('Hey, ${Session.username} 👋',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.75), fontSize: 15)),
        ),
        const SizedBox(height: 6),
        const _FadeSlide(
          delay: 80,
          child: Text('One small step\ntoday.',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  height: 1.1,
                  fontWeight: FontWeight.w900)),
        ),
        const SizedBox(height: 28),

        // HERO CARD
        _FadeSlide(
          delay: 160,
          child: _LCGlassCard(
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 84,
                      height: 84,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox.expand(
                            child: CircularProgressIndicator(
                              value: overall,
                              strokeWidth: 7,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation(
                                  Color(0xFFB8F4CE)),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Text('${(overall * 100).round()}%',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CURRENT STAGE',
                              style: TextStyle(
                                  color: Color(0xFFB8F4CE),
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w900)),
                          const SizedBox(height: 6),
                          Text(labels[stage] ?? stage,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text('${progress.clamp(0, 6)} of 6 points',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _LCPrimaryButton(
                  text: 'Let’s connect',
                  icon: Icons.arrow_forward_rounded,
                  onTap: widget.onStart,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        // JOURNEY STEPPER
        _FadeSlide(
          delay: 240,
          child: _LCGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('YOUR JOURNEY',
                    style: TextStyle(
                        color: Color(0xFFB8F4CE),
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                Row(
                  children: List.generate(stages.length, (i) {
                    final done = i < idx;
                    final current = i == idx;
                    return Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: current ? 16 : 12,
                            height: current ? 16 : 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: done || current
                                  ? const Color(0xFFB8F4CE)
                                  : Colors.white24,
                              boxShadow: current
                                  ? [
                                      BoxShadow(
                                          color: const Color(0xFFB8F4CE)
                                              .withOpacity(0.6),
                                          blurRadius: 12)
                                    ]
                                  : null,
                            ),
                          ),
                          if (i < stages.length - 1)
                            Expanded(
                              child: Container(
                                height: 2,
                                color: done
                                    ? const Color(0xFFB8F4CE)
                                    : Colors.white24,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        // REALITY CHECK
        _FadeSlide(
          delay: 320,
          child: _LCGlassCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    color: Color(0xFFB8F4CE), size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Shh: insider info',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                      const SizedBox(height: 6),
                      Text(tip,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              height: 1.45,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Staggered entrance animation
class _FadeSlide extends StatelessWidget {
  final Widget child;
  final int delay;
  const _FadeSlide({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOutCubic,
      builder: (_, t, c) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 24 * (1 - t)), child: c),
      ),
      child: child,
    );
  }
}

class _FriendsHomeTab extends StatelessWidget {
  final VoidCallback onNewConnection;
  final VoidCallback onExistingConnection;

  const _FriendsHomeTab({
    required this.onNewConnection,
    required this.onExistingConnection,
  });

  @override
  Widget build(BuildContext context) {
    return _LCPageBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(23, 30, 23, 35),
        children: [
          const Text(
            'Your connections.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            'Every friendship begins somewhere.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 35),

          _LCConnectionCard(
            icon: Icons.person_add_alt_1_rounded,
            title: 'Someone new',
            subtitle:
                'Practice starting a conversation with someone you just met.',
            button: 'Start a new connection',
            onTap: onNewConnection,
          ),

          const SizedBox(height: 18),

          _LCConnectionCard(
            icon: Icons.people_alt_rounded,
            title: 'Someone you know',
            subtitle:
                'Continue building a connection with an existing friend.',
            button: 'Continue a connection',
            onTap: onExistingConnection,
          ),

          const SizedBox(height: 28),

          Text(
            'A good connection doesn’t happen in one conversation. '
            'Give it time.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _LCConnectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String button;
  final VoidCallback onTap;

  const _LCConnectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.button,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _LCGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFB8F4CE).withOpacity(0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFB8F4CE),
              size: 29,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.73),
              height: 1.5,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 23),

          _LCPrimaryButton(
            text: button,
            icon: Icons.arrow_forward_rounded,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final String username;

  final VoidCallback onLonelinessTest;
  final VoidCallback onAccountSettings;
  final VoidCallback onReason;
  final VoidCallback onPromoCode;
  final VoidCallback onContact;
  final VoidCallback onLocation;
  final VoidCallback onRate;
  final VoidCallback onDelete;
  final VoidCallback onLogout;

  const _ProfileTab({
    required this.username,
    required this.onLonelinessTest,
    required this.onAccountSettings,
    required this.onReason,
    required this.onPromoCode,
    required this.onContact,
    required this.onLocation,
    required this.onRate,
    required this.onDelete,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return _LCPageBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 27, 22, 35),
        children: [
          const Text(
            'Your space.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 33,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'Your account, your journey.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 27),

          // IDENTITY CARD
          _LCGlassCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF8DE9AB),
                      width: 2,
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF1B7541),
                    backgroundImage: AssetImage(
                      'asset/LCicon.png',
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'YOUR LC ACCOUNT',
                        style: TextStyle(
                          color: Color(0xFFB8F4CE),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'One connection at a time.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.spa_rounded,
                  color: Color(0xFF8DE9AB),
                  size: 27,
                ),
              ],
            ),
          ),

          const SizedBox(height: 29),

          _profileHeading('WELLBEING'),

          _ProfileAction(
            icon: Icons.psychology_alt_rounded,
            title: 'UCLA Loneliness Scale',
            subtitle: 'Reflect on your social connection',
            onTap: onLonelinessTest,
          ),

          _ProfileAction(
            icon: Icons.favorite_outline_rounded,
            title: 'My reason',
            subtitle: 'Update why you want to connect',
            onTap: onReason,
          ),

          const SizedBox(height: 22),

          _profileHeading('ACCOUNT'),

          _ProfileAction(
            icon: Icons.manage_accounts_rounded,
            title: 'Account settings',
            subtitle: 'Change username and password',
            onTap: onAccountSettings,
          ),

          _ProfileAction(
            icon: Icons.location_on_outlined,
            title: 'Update location',
            subtitle: 'Used for reward verification',
            onTap: onLocation,
          ),

          _ProfileAction(
            icon: Icons.card_giftcard_rounded,
            title: 'My promo code',
            subtitle: 'View and share your code',
            onTap: onPromoCode,
          ),

          const SizedBox(height: 22),

          _profileHeading('SUPPORT'),

          _ProfileAction(
            icon: Icons.mail_outline_rounded,
            title: 'Contact LC',
            subtitle: 'Questions, feedback and support',
            onTap: onContact,
          ),

          _ProfileAction(
            icon: Icons.star_outline_rounded,
            title: 'Rate LC',
            subtitle: 'Help others discover LC',
            onTap: onRate,
          ),

          const SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white70,
                  ),
                  title: const Text(
                    'Log out',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: onLogout,
                ),

                Divider(
                  height: 1,
                  color: Colors.white.withOpacity(0.12),
                ),

                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    'Delete account',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: onDelete,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Center(
            child: Text(
              'LC • LET’S CONNECT',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 10,
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileHeading(String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 12),
      child: Text(
        value,
        style: const TextStyle(
          color: Color(0xFFB8F4CE),
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.09),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB8F4CE).withOpacity(0.13),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFFB8F4CE),
                    size: 23,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.62),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.white54,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LCPageBackground extends StatelessWidget {
  final Widget child;
  const _LCPageBackground({required this.child});
  @override
  Widget build(BuildContext context) => child;
}

class _LCGlassCard extends StatelessWidget {
  final Widget child;

  const _LCGlassCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 20,
          sigmaY: 20,
        ),
        child: Container(
          padding: const EdgeInsets.all(21),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.105),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.19),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _LCPrimaryButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _LCPrimaryButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB8F4CE),
          foregroundColor: const Color(0xFF104D2C),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 9),
            Icon(icon, size: 19),
          ],
        ),
      ),
    );
  }
}

class LCExercise {
  final int id;
  final String category;
  final String title;
  final String scenario;
  final String question;
  final List<String> options;
  final int bestAnswer;
  final String explanation;

  const LCExercise({
    required this.id,
    required this.category,
    required this.title,
    required this.scenario,
    required this.question,
    required this.options,
    required this.bestAnswer,
    required this.explanation,
  });
}

const List<LCExercise> lcExercises = [
  // STARTING
  LCExercise(
    id: 1,
    category: 'Starting',
    title: 'The First Hello',
    scenario: 'You are sitting next to someone before class begins.',
    question: 'What is a natural way to start?',
    options: [
      'Hey, is this seat taken?',
      'Tell me everything about yourself.',
      'Why are you sitting here?',
      'Stay silent and wait.',
    ],
    bestAnswer: 0,
    explanation: 'A simple situational question creates an easy opening.',
  ),

  LCExercise(
    id: 2,
    category: 'Starting',
    title: 'At a Campus Event',
    scenario: 'You arrive at an event where you recognize nobody.',
    question: 'What could you say?',
    options: [
      'I hate coming to these events.',
      'Have you been to one of these before?',
      'Can you introduce me to everyone?',
      'Nothing. Leave immediately.',
    ],
    bestAnswer: 1,
    explanation: 'The shared environment gives both people something to talk about.',
  ),

  LCExercise(
    id: 3,
    category: 'Starting',
    title: 'The Compliment',
    scenario: 'Someone has a book you have always wanted to read.',
    question: 'How do you approach them?',
    options: [
      'That book is terrible.',
      'Give me that book.',
      "I've been meaning to read that. How are you finding it?",
      'Ignore the book.',
    ],
    bestAnswer: 2,
    explanation: 'A genuine observation followed by a question opens conversation.',
  ),

  LCExercise(
    id: 4,
    category: 'Starting',
    title: 'The Dining Hall',
    scenario: 'You notice someone sitting alone at lunch.',
    question: 'What is a respectful approach?',
    options: [
      'Why are you alone?',
      'Mind if I join you?',
      'You look lonely.',
      'Sit down without asking.',
    ],
    bestAnswer: 1,
    explanation: 'Asking gives them the freedom to accept or decline.',
  ),

  LCExercise(
    id: 5,
    category: 'Starting',
    title: 'The Introduction',
    scenario: 'A mutual friend introduces you to someone.',
    question: 'What should you do next?',
    options: [
      'Say nothing.',
      'Ask for their phone number immediately.',
      'Say hello and ask how they know your mutual friend.',
      'Talk only to your mutual friend.',
    ],
    bestAnswer: 2,
    explanation: 'A shared connection is an easy conversational starting point.',
  ),

  LCExercise(
    id: 6,
    category: 'Starting',
    title: 'The Classmate',
    scenario: 'You see the same person in class every week.',
    question: 'What is a good opener?',
    options: [
      "Did you understand today's lecture?",
      'Why do you always come here?',
      'You should talk more.',
      'I know everything about this class.',
    ],
    bestAnswer: 0,
    explanation: 'Shared routines make excellent low-pressure conversation starters.',
  ),

  LCExercise(
    id: 7,
    category: 'Starting',
    title: 'The Long Queue',
    scenario: 'You are waiting in a long queue with someone.',
    question: 'What could you say?',
    options: [
      'This is taking forever. Have you been here before?',
      'Move faster.',
      'I hate everyone here.',
      'Tell me your life story.',
    ],
    bestAnswer: 0,
    explanation: 'A shared observation can naturally lead to a conversation.',
  ),

  LCExercise(
    id: 8,
    category: 'Starting',
    title: 'The Club Meeting',
    scenario: 'You attend your first club meeting.',
    question: 'How could you connect?',
    options: [
      'I am better than everyone here.',
      'What made you join this club?',
      'Give me your position.',
      'Leave without speaking.',
    ],
    bestAnswer: 1,
    explanation: 'People often enjoy talking about their interests and motivations.',
  ),

  LCExercise(
    id: 9,
    category: 'Starting',
    title: 'The Group Project',
    scenario: 'You have just been assigned a group project.',
    question: 'What is a friendly opener?',
    options: [
      'I will do everything myself.',
      "Let's divide everything without talking.",
      'Hey, what do you think we should start with?',
      "I don't want to work with you.",
    ],
    bestAnswer: 2,
    explanation: 'Collaborative questions create a shared purpose.',
  ),

  LCExercise(
    id: 10,
    category: 'Starting',
    title: 'The Awkward Silence',
    scenario: 'You are introduced to someone and neither of you speaks.',
    question: 'What is a useful next step?',
    options: [
      'Panic and leave.',
      'Make a small observation about where you are.',
      'Apologize repeatedly.',
      'Ask ten questions at once.',
    ],
    bestAnswer: 1,
    explanation: 'You can restart with something simple and relevant to the moment.',
  ),

  // KEEPING IT GOING
  LCExercise(
    id: 11,
    category: 'Keeping it going',
    title: 'The Follow-up',
    scenario: 'Someone says they spent their weekend hiking.',
    question: 'What is a good follow-up?',
    options: [
      'Okay.',
      'Why?',
      'That sounds fun. Where did you go?',
      'I hate hiking.',
    ],
    bestAnswer: 2,
    explanation: 'A specific follow-up shows that you are listening.',
  ),

  LCExercise(
    id: 12,
    category: 'Keeping it going',
    title: 'The Short Answer',
    scenario: 'You ask someone how their day was. They say, "Good."',
    question: 'What could you try?',
    options: [
      'Why are you so boring?',
      'Nice! Anything interesting happen?',
      'Goodbye.',
      'Ask the exact same question again.',
    ],
    bestAnswer: 1,
    explanation: 'A gentle follow-up gives them another opportunity to share.',
  ),

  LCExercise(
    id: 13,
    category: 'Keeping it going',
    title: 'Show Interest',
    scenario: 'Someone tells you they have started learning guitar.',
    question: 'What response encourages conversation?',
    options: [
      "That's interesting. What made you start?",
      'Guitar is easy.',
      "I don't care.",
      'You should learn piano instead.',
    ],
    bestAnswer: 0,
    explanation: 'Curiosity encourages the other person to expand on their experience.',
  ),

  LCExercise(
    id: 14,
    category: 'Keeping it going',
    title: 'The Shared Experience',
    scenario: 'Someone mentions that they are nervous about an exam.',
    question: 'What is a supportive response?',
    options: [
      "That's nothing.",
      "You'll probably fail.",
      'I get that. Which part are you most worried about?',
      'Stop worrying.',
    ],
    bestAnswer: 2,
    explanation: 'Acknowledging their feeling before asking a question helps them feel heard.',
  ),

  LCExercise(
    id: 15,
    category: 'Keeping it going',
    title: 'The Story',
    scenario: 'Someone starts telling you about a funny incident.',
    question: 'What should you do?',
    options: [
      'Interrupt with your own story.',
      'Listen and let them finish.',
      'Look at your phone.',
      'Change the subject immediately.',
    ],
    bestAnswer: 1,
    explanation: 'Listening without interrupting helps build conversational comfort.',
  ),

  LCExercise(
    id: 16,
    category: 'Keeping it going',
    title: 'The Detail',
    scenario: 'Someone says they recently visited Japan.',
    question: 'Which question is most engaging?',
    options: [
      'Was it expensive?',
      'Did you enjoy it?',
      'What was your favorite part of the trip?',
      'Why Japan?',
    ],
    bestAnswer: 2,
    explanation: 'Open-ended questions invite stories rather than one-word answers.',
  ),

  LCExercise(
    id: 17,
    category: 'Keeping it going',
    title: 'The Conversation Loop',
    scenario: 'Someone says they enjoy cooking.',
    question: 'What is a natural response?',
    options: [
      'What do you usually like making?',
      'Cooking is boring.',
      'Okay.',
      'I never cook.',
    ],
    bestAnswer: 0,
    explanation: 'Following the topic they introduced keeps the conversation flowing.',
  ),

  LCExercise(
    id: 18,
    category: 'Keeping it going',
    title: 'Avoiding Interrogation',
    scenario: 'You have asked someone three questions in a row.',
    question: 'What should you do next?',
    options: [
      'Ask five more questions.',
      'Share something about yourself too.',
      'Leave immediately.',
      'Ask why they are not asking questions.',
    ],
    bestAnswer: 1,
    explanation: 'Good conversations involve both asking and sharing.',
  ),

  LCExercise(
    id: 19,
    category: 'Keeping it going',
    title: 'The Different Opinion',
    scenario: 'Someone disagrees with your opinion about a movie.',
    question: 'How should you respond?',
    options: [
      "You're wrong.",
      "That's interesting. What did you like about it?",
      'Stop talking.',
      'Make fun of their taste.',
    ],
    bestAnswer: 1,
    explanation: 'You can explore a different opinion without turning it into an argument.',
  ),

  LCExercise(
    id: 20,
    category: 'Keeping it going',
    title: 'The Natural Pause',
    scenario: 'There is a brief silence during a conversation.',
    question: 'What is the healthiest response?',
    options: [
      'Panic.',
      'Apologize for being awkward.',
      'Allow the pause and introduce another topic when appropriate.',
      'Talk continuously.',
    ],
    bestAnswer: 2,
    explanation: 'Silence is normal. Conversations do not need constant talking.',
  ),

  // COMMON GROUND
  LCExercise(
    id: 21,
    category: 'Common ground',
    title: 'Finding Interests',
    scenario: 'You discover someone enjoys watching movies.',
    question: 'What could you ask?',
    options: [
      'What genres do you usually enjoy?',
      'Movies are a waste of time.',
      'You must watch my favorite movie.',
      'Why do you watch movies?',
    ],
    bestAnswer: 0,
    explanation: 'Exploring interests helps you discover shared preferences.',
  ),

  LCExercise(
    id: 22,
    category: 'Common ground',
    title: 'The Music Connection',
    scenario: 'Someone mentions their favorite artist.',
    question: 'How could you build on that?',
    options: [
      'That artist is terrible.',
      'Have you seen them perform live?',
      'Stop listening to them.',
      'Only my music is good.',
    ],
    bestAnswer: 1,
    explanation: 'A related question can reveal experiences and shared interests.',
  ),

  LCExercise(
    id: 23,
    category: 'Common ground',
    title: 'The Hobby',
    scenario: 'You discover that both of you enjoy photography.',
    question: 'What could you say?',
    options: [
      'You are probably better than me.',
      'What do you usually like taking pictures of?',
      'Photography is expensive.',
      "Let's compete.",
    ],
    bestAnswer: 1,
    explanation: 'A shared hobby gives you an opportunity to exchange experiences.',
  ),

  LCExercise(
    id: 24,
    category: 'Common ground',
    title: 'The Favorite Place',
    scenario: 'Someone tells you they love visiting coffee shops.',
    question: 'What is a useful follow-up?',
    options: [
      'Which places do you recommend around here?',
      'Coffee is unhealthy.',
      "Why don't you stay home?",
      'I never go outside.',
    ],
    bestAnswer: 0,
    explanation: 'Local recommendations can create opportunities for future interactions.',
  ),

  LCExercise(
    id: 25,
    category: 'Common ground',
    title: 'The Unexpected Similarity',
    scenario: 'Someone mentions they grew up in a different country, just like you.',
    question: 'What could you ask?',
    options: [
      'Which country is better?',
      'What was it like growing up there?',
      'You must have had a difficult life.',
      "Let's stop talking about that.",
    ],
    bestAnswer: 1,
    explanation: 'Shared experiences can create a meaningful point of connection.',
  ),

  LCExercise(
    id: 26,
    category: 'Common ground',
    title: 'The Food Debate',
    scenario: 'You discover you both love trying new food.',
    question: 'What is a natural continuation?',
    options: [
      'What is the best thing you have tried recently?',
      'My food choices are better.',
      'Food is not interesting.',
      'Why eat new things?',
    ],
    bestAnswer: 0,
    explanation: 'Experiences and recommendations are easy topics to exchange.',
  ),

  LCExercise(
    id: 27,
    category: 'Common ground',
    title: 'The Weekend Plan',
    scenario: 'Someone says they enjoy exploring the city.',
    question: 'What might you ask?',
    options: [
      'Why do you waste time outside?',
      'Have you found any interesting places lately?',
      'You should stay home.',
      'I already know everything.',
    ],
    bestAnswer: 1,
    explanation: 'You can discover shared activities and potential plans.',
  ),

  LCExercise(
    id: 28,
    category: 'Common ground',
    title: 'The Sports Connection',
    scenario: 'Someone says they follow basketball.',
    question: 'What is a good question?',
    options: [
      'Which team do you support?',
      'Basketball is pointless.',
      'You should watch football.',
      "I don't understand sports.",
    ],
    bestAnswer: 0,
    explanation: 'Specific questions make it easier to find common ground.',
  ),

  LCExercise(
    id: 29,
    category: 'Common ground',
    title: 'The Learning Journey',
    scenario: 'Someone is learning a new language.',
    question: 'What could you ask?',
    options: [
      'Why bother?',
      'How did you decide to learn it?',
      "You probably won't become fluent.",
      'Languages are useless.',
    ],
    bestAnswer: 1,
    explanation: 'Understanding someone\'s motivation can lead to a more interesting discussion.',
  ),

  LCExercise(
    id: 30,
    category: 'Common ground',
    title: 'Planning Together',
    scenario: 'You both discover you enjoy visiting museums.',
    question: 'What could you suggest?',
    options: [
      "We should visit one sometime if you're interested.",
      'You must come with me tomorrow.',
      'I will decide everything.',
      'Never mind.',
    ],
    bestAnswer: 0,
    explanation: 'A low-pressure invitation creates an opportunity without demanding agreement.',
  ),

  // DEEPER CONNECTION
  LCExercise(
    id: 31,
    category: 'Deeper connection',
    title: 'Beyond Small Talk',
    scenario: 'You have spoken to someone several times and feel comfortable.',
    question: 'What is a suitable question?',
    options: [
      "What is something you've been looking forward to lately?",
      'Tell me your biggest secret.',
      'Why are you still talking to me?',
      'How much money do you have?',
    ],
    bestAnswer: 0,
    explanation: 'Personal but approachable questions help conversations become more meaningful.',
  ),

  LCExercise(
    id: 32,
    category: 'Deeper connection',
    title: 'Showing Empathy',
    scenario: 'Someone says they have been having a difficult week.',
    question: 'What should you say?',
    options: [
      'Everyone has problems.',
      'That sounds difficult. Do you want to talk about it?',
      'Forget about it.',
      'My week was worse.',
    ],
    bestAnswer: 1,
    explanation: 'Offering space to talk is often more helpful than immediately giving advice.',
  ),

  LCExercise(
    id: 33,
    category: 'Deeper connection',
    title: 'Sharing Something Personal',
    scenario: 'Someone shares a personal challenge with you.',
    question: 'How can you respond?',
    options: [
      'Judge them.',
      'Dismiss their feelings.',
      'Thank them for trusting you and listen.',
      'Immediately tell everyone else.',
    ],
    bestAnswer: 2,
    explanation: 'Respect and trust are essential to deeper connections.',
  ),

  LCExercise(
    id: 34,
    category: 'Deeper connection',
    title: 'The Future',
    scenario: 'You are discussing life beyond college.',
    question: 'What could you ask?',
    options: [
      'What kind of life are you hoping to build?',
      'How much will you earn?',
      'You should follow my plan.',
      'Why think about the future?',
    ],
    bestAnswer: 0,
    explanation: 'A thoughtful question can invite someone to share their aspirations.',
  ),

  LCExercise(
    id: 35,
    category: 'Deeper connection',
    title: 'A Meaningful Memory',
    scenario: 'You are having a relaxed conversation with a friend.',
    question: 'What could you ask?',
    options: [
      'What is one memory that always makes you smile?',
      'What is your most embarrassing secret?',
      'Why are you so quiet?',
      'Can we talk about something else?',
    ],
    bestAnswer: 0,
    explanation: 'Positive memories can help people connect through personal stories.',
  ),

  LCExercise(
    id: 36,
    category: 'Deeper connection',
    title: 'The Vulnerability',
    scenario: 'You want to share something you have struggled with.',
    question: 'What is a healthy approach?',
    options: [
      'Share gradually when you feel comfortable.',
      'Tell everything immediately.',
      'Pretend you have never struggled.',
      'Force the other person to share too.',
    ],
    bestAnswer: 0,
    explanation: 'Vulnerability should be mutual, voluntary and appropriate to the relationship.',
  ),

  LCExercise(
    id: 37,
    category: 'Deeper connection',
    title: 'Celebrating Others',
    scenario: 'Someone tells you they achieved a personal goal.',
    question: 'How should you respond?',
    options: [
      'That is not impressive.',
      'Nice! What did it take to get there?',
      'I achieved something better.',
      'Change the subject.',
    ],
    bestAnswer: 1,
    explanation: "Genuine enthusiasm shows that you value the other person's experiences.",
  ),

  LCExercise(
    id: 38,
    category: 'Deeper connection',
    title: 'Understanding Feelings',
    scenario: 'A friend says they feel out of place at college.',
    question: 'What is a thoughtful response?',
    options: [
      "You'll get over it.",
      'Why are you so sensitive?',
      'That can feel isolating. What has been making it difficult?',
      'Just make friends.',
    ],
    bestAnswer: 2,
    explanation: 'Understanding their experience is more useful than minimizing it.',
  ),

  LCExercise(
    id: 39,
    category: 'Deeper connection',
    title: 'The Different Perspective',
    scenario: 'A friend explains a decision you would not personally make.',
    question: 'What could you ask?',
    options: [
      'How did you arrive at that decision?',
      'That makes no sense.',
      'You should think like me.',
      'I refuse to understand.',
    ],
    bestAnswer: 0,
    explanation: 'Curiosity helps you understand someone without needing to agree.',
  ),

  LCExercise(
    id: 40,
    category: 'Deeper connection',
    title: 'Being Present',
    scenario: 'A friend is talking about something important to them.',
    question: 'What is the best approach?',
    options: [
      'Think about your next response.',
      'Listen carefully and respond to what they actually say.',
      'Interrupt frequently.',
      'Check your notifications.',
    ],
    bestAnswer: 1,
    explanation: 'Being present is a social skill that makes others feel valued.',
  ),

  // FRIENDSHIP
  LCExercise(
    id: 41,
    category: 'Friendship',
    title: 'The Follow-up Message',
    scenario: 'You had a nice conversation with someone yesterday.',
    question: 'What could you send?',
    options: [
      'Hey, enjoyed talking yesterday. How did the rest of your day go?',
      "Why haven't you messaged me?",
      'We need to talk every day.',
      'Nothing. Never speak again.',
    ],
    bestAnswer: 0,
    explanation: 'A friendly follow-up helps turn a one-time interaction into an ongoing connection.',
  ),

  LCExercise(
    id: 42,
    category: 'Friendship',
    title: 'Making Plans',
    scenario: 'You and someone have discussed visiting a new restaurant.',
    question: 'What could you suggest?',
    options: [
      "Let's go sometime if you're free this week.",
      'You have to come tomorrow.',
      'I will book everything without asking.',
      'Forget it.',
    ],
    bestAnswer: 0,
    explanation: 'A specific but flexible invitation makes plans easier.',
  ),

  LCExercise(
    id: 43,
    category: 'Friendship',
    title: 'Remembering Details',
    scenario: 'Your friend mentioned an important presentation next week.',
    question: 'How can you show you remember?',
    options: [
      'Ask how their presentation went.',
      'Ignore it.',
      'Ask what they are doing next month.',
      'Tell them presentations are easy.',
    ],
    bestAnswer: 0,
    explanation: 'Remembering small details communicates genuine interest.',
  ),

  LCExercise(
    id: 44,
    category: 'Friendship',
    title: 'The Invitation',
    scenario: 'You want to invite a new friend to an activity.',
    question: 'What is a considerate invitation?',
    options: [
      'You must come.',
      'A few of us are going bowling. Would you like to join?',
      "Why don't you ever come out?",
      'I already decided for you.',
    ],
    bestAnswer: 1,
    explanation: 'A clear invitation with room to decline respects the other person\'s choice.',
  ),

  LCExercise(
    id: 45,
    category: 'Friendship',
    title: 'The Cancelled Plan',
    scenario: 'A friend cancels your plans at the last minute.',
    question: 'What is a reasonable response?',
    options: [
      "You clearly don't care about me.",
      'No worries. Is everything okay?',
      'Never speak to me again.',
      'Tell everyone they are unreliable.',
    ],
    bestAnswer: 1,
    explanation: 'Responding calmly allows room for circumstances you may not know about.',
  ),

  LCExercise(
    id: 46,
    category: 'Friendship',
    title: 'Reconnecting',
    scenario: 'You have not spoken to an old friend in several months.',
    question: 'How could you reconnect?',
    options: [
      "Hey, it's been a while! How have you been?",
      'Why did you abandon me?',
      'You forgot about me.',
      'Wait another year.',
    ],
    bestAnswer: 0,
    explanation: 'A warm, simple message can reopen a connection without pressure.',
  ),

  LCExercise(
    id: 47,
    category: 'Friendship',
    title: 'The Boundary',
    scenario: 'A friend says they cannot meet because they need time alone.',
    question: 'How should you respond?',
    options: [
      'You are a bad friend.',
      'Respect that and suggest another time.',
      'Keep insisting.',
      'Make them feel guilty.',
    ],
    bestAnswer: 1,
    explanation: 'Respecting boundaries is part of building healthy friendships.',
  ),

  LCExercise(
    id: 48,
    category: 'Friendship',
    title: 'The Misunderstanding',
    scenario: 'You realize something you said may have upset a friend.',
    question: 'What should you do?',
    options: [
      'Pretend nothing happened.',
      'Blame them.',
      'Check in, acknowledge it and listen.',
      'Stop speaking to them.',
    ],
    bestAnswer: 2,
    explanation: 'Healthy friendships involve communication and accountability.',
  ),

  LCExercise(
    id: 49,
    category: 'Friendship',
    title: 'Being Supportive',
    scenario: 'A friend is going through an important life change.',
    question: 'What is a supportive response?',
    options: [
      'Ask how you can support them.',
      'Tell them exactly what to do.',
      'Make the situation about yourself.',
      'Ignore the change.',
    ],
    bestAnswer: 0,
    explanation: 'Offering support while respecting their autonomy strengthens trust.',
  ),

  LCExercise(
    id: 50,
    category: 'Friendship',
    title: 'Maintaining Connection',
    scenario: 'You have developed a friendship and want it to continue.',
    question: 'What matters most?',
    options: [
      'Only contact them when you need something.',
      'Expect constant communication.',
      'Make consistent, genuine efforts to stay connected.',
      'Never disagree.',
    ],
    bestAnswer: 2,
    explanation: 'Friendships grow through mutual effort, trust and respect over time.',
  ),
];
class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  String selectedCategory = 'All';

  final supabase = Supabase.instance.client;

  Set<int> completed = {};
  Set<int> attempted = {};

  bool progressLoading = true;
  bool savingProgress = false;

  @override
  void initState() {
    super.initState();
    loadExerciseProgress();
  }

  Future<void> loadExerciseProgress() async {
    try {
      final data = await supabase
          .from('users')
          .select('exercise_completed, exercise_attempted')
          .eq('username', Session.username)
          .single();

      if (!mounted) return;

      setState(() {
        completed = Set<int>.from(
          (data['exercise_completed'] ?? []).map(
            (value) => (value as num).toInt(),
          ),
        );

        attempted = Set<int>.from(
          (data['exercise_attempted'] ?? []).map(
            (value) => (value as num).toInt(),
          ),
        );

        progressLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        progressLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load exercise progress: $e'),
        ),
      );
    }
  }

  Future<void> saveExerciseProgress() async {
    if (savingProgress) return;

    savingProgress = true;

    try {
      await supabase
          .from('users')
          .update({
            'exercise_completed': completed.toList(),
            'exercise_attempted': attempted.toList(),
          })
          .eq('username', Session.username);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save exercise progress: $e'),
          ),
        );
      }
    } finally {
      savingProgress = false;
    }
  }

  final categories = const [
    'All',
    'Starting',
    'Keeping it going',
    'Common ground',
    'Deeper connection',
    'Friendship',
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = lcExercises.where((exercise) {
      return selectedCategory == 'All' ||
          exercise.category == selectedCategory;
    }).toList();

    final progress = completed.length / lcExercises.length;
	if (progressLoading) {
    	return const Center(
      		child: CircularProgressIndicator(),
    	);
  	}
    return _LCPageBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conversation Gym',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Build your social muscle.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 53,
                  width: 53,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.psychology_alt_rounded,
                    color: Color(0xFFB8F4CE),
                    size: 28,
                  ),
                ),
              ],
            ),
          ),

          // PROGRESS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 18,
                  sigmaY: 18,
                ),
                child: Container(
                  padding: const EdgeInsets.all(19),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF42B977).withOpacity(0.55),
                        Colors.white.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(23),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'YOUR JOURNEY',
                            style: TextStyle(
                              color: Color(0xFFB8F4CE),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            '${completed.length}/50',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 9,
                          backgroundColor: Colors.white24,
                          valueColor:
                              const AlwaysStoppedAnimation(
                            Color(0xFF9CF2BA),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        completed.isEmpty
                            ? 'Start with your first exercise.'
                            : completed.length == 50
                                ? 'All 50 exercises completed!'
                                : '${50 - completed.length} exercises left. Keep going!',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 22),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 22),
            child: Text(
              'Explore skills',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // FILTERS
          SizedBox(
            height: 43,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories[index];
                final selected =
                    selectedCategory == category;

                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  backgroundColor:
                      Colors.white.withOpacity(0.10),
                  selectedColor: const Color(0xFFB8F4CE),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.15),
                  ),
                  labelStyle: TextStyle(
                    color: const Color(0xFF104D2C),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // EXERCISES
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 3, 18, 25),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final exercise = filtered[index];

                final isCompleted =
                    completed.contains(exercise.id);

                final wasAttempted =
                    attempted.contains(exercise.id);

                return Container(
                  margin: const EdgeInsets.only(bottom: 11),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.095),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCompleted
                          ? const Color(0xFF8DE9AB)
                          : Colors.white.withOpacity(0.13),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _openExercise(exercise),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          children: [
                            Container(
                              width: 47,
                              height: 47,
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? const Color(0xFFB8F4CE)
                                    : Colors.white.withOpacity(0.12),
                                borderRadius:
                                    BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: isCompleted
                                    ? const Icon(
                                        Icons.check_rounded,
                                        color: Color(0xFF104D2C),
                                      )
                                    : Text(
                                        exercise.id
                                            .toString()
                                            .padLeft(2, '0'),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    exercise.category,
                                    style: const TextStyle(
                                      color: Color(0xFFB8F4CE),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),

                                  if (wasAttempted)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Practiced',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            Icon(
                              isCompleted
                                  ? Icons.check_circle_rounded
                                  : Icons.arrow_forward_ios_rounded,
                              color: isCompleted
                                  ? const Color(0xFF8DE9AB)
                                  : Colors.white54,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openExercise(LCExercise exercise) async {
    int? selectedAnswer;
    bool checked = false;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, updateSheet) {
            final correct =
                selectedAnswer == exercise.bestAnswer;

            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.65,
              maxChildSize: 0.96,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F9F5),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      22, 14, 22, 35,
                    ),
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Text(
                        'EXERCISE ${exercise.id} OF 50',
                        style: const TextStyle(
                          color: Color(0xFF176B3A),
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),

                      const SizedBox(height: 9),

                      Text(
                        exercise.title,
                        style: const TextStyle(
                          color: Color(0xFF153B24),
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 22),

                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2F3E7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'THE SITUATION',
                              style: TextStyle(
                                color: Color(0xFF176B3A),
                                fontSize: 10,
                                letterSpacing: 1.3,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              exercise.scenario,
                              style: const TextStyle(
                                color: Color(0xFF294B34),
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        exercise.question,
                        style: const TextStyle(
                          color: Color(0xFF153B24),
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 16),

                      ...List.generate(
                        exercise.options.length,
                        (index) {
                          final isSelected =
                              selectedAnswer == index;

                          final isCorrect =
                              index == exercise.bestAnswer;

                          final showCorrect =
                              checked && isCorrect;

                          final showWrong =
                              checked && isSelected && !isCorrect;

                          Color background = Colors.white;
                          Color border =
                              const Color(0xFFDCE8DF);

                          if (showCorrect) {
                            background =
                                const Color(0xFFE1F5E8);
                            border = const Color(0xFF239653);
                          } else if (showWrong) {
                            background =
                                const Color(0xFFFFEBE7);
                            border = Colors.redAccent;
                          } else if (isSelected) {
                            background =
                                const Color(0xFFEAF3EC);
                            border = const Color(0xFF176B3A);
                          }

                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: 11),
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(17),
                              onTap: checked
                                  ? null
                                  : () {
                                      updateSheet(() {
                                        selectedAnswer = index;
                                      });
                                    },
                              child: AnimatedContainer(
                                duration: const Duration(
                                  milliseconds: 180,
                                ),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: background,
                                  borderRadius:
                                      BorderRadius.circular(17),
                                  border: Border.all(
                                    color: border,
                                    width: isSelected || showCorrect
                                        ? 1.7
                                        : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${String.fromCharCode(65 + index)}. ${exercise.options[index]}',
                                        style: const TextStyle(
                                          color: Color(0xFF263C2C),
                                          fontSize: 14,
                                          height: 1.45,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    if (showCorrect)
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFF176B3A),
                                      )
                                    else if (showWrong)
                                      const Icon(
                                        Icons.cancel_rounded,
                                        color: Colors.redAccent,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      if (checked) ...[
                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.all(17),
                          decoration: BoxDecoration(
                            color: correct
                                ? const Color(0xFFE1F5E8)
                                : const Color(0xFFFFF1E3),
                            borderRadius: BorderRadius.circular(19),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                correct
                                    ? 'Great instinct!'
                                    : 'Here is another perspective',
                                style: TextStyle(
                                  color: correct
                                      ? const Color(0xFF176B3A)
                                      : Colors.brown.shade800,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(height: 9),

                              Text(
                                exercise.explanation,
                                style: const TextStyle(
                                  color: Color(0xFF35513D),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 22),

                      SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: selectedAnswer == null
                              ? null
                              : () {
                                  if (!checked) {
                                    updateSheet(() {
                                      checked = true;
                                    });
                                  } else {
                                    Navigator.pop(
                                      sheetContext,
                                      true,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF176B3A),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                Colors.black12,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(17),
                            ),
                          ),
                          child: Text(
                            checked
                                ? 'Finish exercise'
                                : 'Check my answer',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );

    if (!mounted) return;

    if (result == true) {
      setState(() {
        attempted.add(exercise.id);
        completed.add(exercise.id);
      });
	    await saveExerciseProgress();
    }
  }
}

class StageSelectionPage extends StatelessWidget {

  const StageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFF24B65E),

      appBar: AppBar(
        title: const Text(
          "Choose a Stage",
        ),
        centerTitle: true,
      ),

      body: Center(

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 20,
            children: [
              buildStageButton(
                context,
                "Small Talk",
                "smalltalk",
                Colors.white,
              ),

              buildStageButton(
                context,
                "Medium Talk",
                "mediumtalk",
                Colors.white,
              ),

              buildStageButton(
                context,
                "Big Talk",
                "bigtalk",
                Colors.white,
              ),

              buildStageButton(
                context,
                "Play Date",
                "playdate",
                Colors.white,
              ),

              buildStageButton(
                context,
                "Hygge",
                "hygge",
                Colors.white,
              ),
            ],
          )          ],
        ),
      ),
    );
  }
}

Widget buildStageButton(

    BuildContext context,

    String label,

    String stage,

    Color color,

    ) {

  return SizedBox(

    width: MediaQuery.of(context).size.width * 0.35,
    height: 60,

    child: ElevatedButton(

      style: ElevatedButton.styleFrom(

        backgroundColor: color,

        shape: RoundedRectangleBorder(

          borderRadius:
          BorderRadius.circular(15),

          side: const BorderSide(
            color: Colors.white,
            width: 2,
          ),
        ),
      ),

      onPressed: () {

        Navigator.push(

          context,

          MaterialPageRoute(

            builder: (_) => TaskPage(

              forcedStage: stage,

            ),
          ),
        );
      },

      child: Text(
        label,
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class ForgotPasswordPage
    extends StatefulWidget {

  const ForgotPasswordPage({
    super.key,
  });

  @override
  State<ForgotPasswordPage>
  createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {

  final supabase =
      Supabase.instance.client;

  final TextEditingController
  emailController =
  TextEditingController();

  String generateCode() {

    final random = Random();

    return (100000 +
        random.nextInt(900000))
        .toString();
  }

  Future<void> sendCode() async { final email = emailController.text.trim(); try { final user = await supabase .from('users') .select() .eq('email', email) .maybeSingle(); if (user == null) { ScaffoldMessenger.of(context) .showSnackBar( const SnackBar( content: Text( "Email not found", ), ), ); return; } final code = generateCode(); await supabase .from('users') .update({ 'reset_code': code, 'reset_code_expiry': DateTime.now() .add( const Duration( minutes: 10, ), ) .toIso8601String(), }) .eq( 'email', email, ); await supabase.functions .invoke( 'resend-email', body: { 'email': email, 'code': code, }, ); ScaffoldMessenger.of(context) .showSnackBar( const SnackBar( content: Text( "Reset code sent", ), ), );
  if (!mounted) return;

  Navigator.push( context, MaterialPageRoute( builder: (_) => VerifyCodePage( email: email, ), ), ); } catch (e) { ScaffoldMessenger.of(context) .showSnackBar( SnackBar( content: Text( "Error: $e", ), ), ); } }

  Future<void> sendResetEmail() async {
    final email = emailController.text.trim();

    try {
      await supabase.auth.resetPasswordForEmail(
        email,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset email sent"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(

      backgroundColor:
      const Color(0xFF24B65E),

      appBar: AppBar(

        title: const Text(
          "Forgot Password",
        ),

        centerTitle: true,
      ),

      body: Center(

        child: Padding(

          padding:
          const EdgeInsets.all(30),

          child: Column(

            mainAxisSize:
            MainAxisSize.min,

            children: [

              const Text(

                "Enter the email linked to your account.",

                textAlign:
                TextAlign.center,

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              TextField(

                controller:
                emailController,

                decoration:
                const InputDecoration(

                  filled: true,

                  fillColor:
                  Colors.white,

                  labelText:
                  "Email",

                  border:
                  OutlineInputBorder(),
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              ElevatedButton(

                onPressed:
                sendCode,

                child: const Text(
                  "Send Reset Code",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VerifyCodePage
    extends StatefulWidget {

  final String email;

  const VerifyCodePage({

    super.key,

    required this.email,
  });

  @override
  State<VerifyCodePage>
  createState() =>
      _VerifyCodePageState();
}

class _VerifyCodePageState
    extends State<VerifyCodePage> {

  final supabase =
      Supabase.instance.client;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;

  final codeController =
  TextEditingController();

  final passwordController =
  TextEditingController();

  final confirmController =
  TextEditingController();

  Future<void> resetPassword() async {

    try {

      final user =
      await supabase
          .from('users')
          .select()
          .eq(
        'email',
        widget.email,
      )
          .single();

      if (
      user['reset_code']
          != codeController.text.trim()
      ) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            content: Text(
              "Invalid code",
            ),
          ),
        );

        return;
      }

      final expiry =
      DateTime.parse(
        user['reset_code_expiry'],
      );

      if (
      DateTime.now()
          .isAfter(expiry)
      ) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            content: Text(
              "Code expired",
            ),
          ),
        );

        return;
      }

      if (
      passwordController.text
          .trim()
          !=
          confirmController.text
              .trim()
      ) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            content: Text(
              "Passwords do not match",
            ),
          ),
        );

        return;
      }

      await supabase
          .from('users')
          .update({

        'password':
        passwordController.text
            .trim(),

        'reset_code': null,

        'reset_code_expiry': null,
      })
          .eq(
        'email',
        widget.email,
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "Password updated",
          ),
        ),
      );

      Navigator.pushAndRemoveUntil(

        context,

        MaterialPageRoute(

          builder: (_) =>
          const LoginPage(),
        ),

            (route) => false,
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            "Error: $e",
          ),
        ),
      );
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(

      backgroundColor:
      const Color(0xFF24B65E),

      appBar: AppBar(

        title: const Text(
          "Verify Code",
        ),
      ),

      body: SingleChildScrollView(
      child: Center(

        child: Padding(

          padding:
          const EdgeInsets.all(30),

          child: Column(

            mainAxisSize:
            MainAxisSize.min,

            children: [

              Text(
                "A code was sent to\n${widget.email}",

                textAlign:
                TextAlign.center,

                style:
                const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              TextField(

                controller:
                codeController,

                decoration:
                const InputDecoration(

                  filled: true,

                  fillColor:
                  Colors.white,

                  labelText:
                  "Reset Code",

                  border:
                  OutlineInputBorder(),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              TextField(
                controller: passwordController,
                obscureText: _hideNewPassword,

                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: "New Password",
                  border: const OutlineInputBorder(),

                  suffixIcon: IconButton(
                    icon: Icon(
                      _hideNewPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),

                    onPressed: () {
                      setState(() {
                        _hideNewPassword =
                        !_hideNewPassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              TextField(
                controller: confirmController,
                obscureText: _hideConfirmPassword,

                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: "Confirm Password",
                  border: const OutlineInputBorder(),

                  suffixIcon: IconButton(
                    icon: Icon(
                      _hideConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),

                    onPressed: () {
                      setState(() {
                        _hideConfirmPassword =
                        !_hideConfirmPassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              ElevatedButton(

                onPressed:
                resetPassword,

                child: const Text(
                  "Reset Password",
                ),
              ),
            ],
          ),
        ),
      ),
      )
    );
  }
}

class UCLAPage extends StatefulWidget {

  const UCLAPage({
    super.key,
  });

  @override
  State<UCLAPage> createState() =>
      _UCLAPageState();
}

class _UCLAPageState extends State<UCLAPage> {

  late final WebViewController controller;

  final supabase = Supabase.instance.client;

  Future<void> saveScore(
      int score,
      ) async {

    try {

      await supabase
          .from(
          'loneliness_results')
          .insert({

        'username':
        Session.username,

        'score': score,

      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content: Text(
            'Score saved: $score',
          ),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            'Error: $e',
          ),
        ),
      );
    }
  }

  @override
  void initState() {

    super.initState();

    controller =
    WebViewController()

      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      )

      ..addJavaScriptChannel(

        'FlutterScore',

        onMessageReceived:
            (message) async {

          final score =
          int.parse(
            message.message,
          );

          await saveScore(
            score,
          );
        },
      )

      ..loadRequest(

        Uri.parse(

          'https://uclalonelinessscore.lovable.app',
        ),
      );
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "UCLA Test",
        ),
      ),

      body: WebViewWidget(

        controller: controller,
      ),
    );
  }
}


class DeviceService {

  static Future<String> getDeviceId() async {

    final prefs =
    await SharedPreferences.getInstance();

    String? id =
    prefs.getString("device_id");

    if (id == null) {

      id = const Uuid().v4();

      await prefs.setString(
        "device_id",
        id,
      );
    }

    return id;
  }

}
class PromptGate {
  static final _supabase = Supabase.instance.client;

  /// Pass the prompt's actual name/title — it's stored as-is,
  /// exactly like claimed_rewards stores the reward title as-is.
  static Future<bool> shouldShow(String prompt) async {
    final user = await _supabase
        .from('users')
        .select('shown_prompts')
        .eq('username', Session.username)
        .single();

    List shown = (user['shown_prompts'] ?? []) as List;
    if (shown.contains(prompt)) return false;

    shown = List.from(shown)..add(prompt);
    await _supabase.from('users').update({'shown_prompts': shown}).eq('username', Session.username);

    return true;
  }
}

class PickResult {
  final Map<String, String> item;
  final bool didReset;
  PickResult(this.item, this.didReset);
}

class RewardCycler {
  static final _supabase = Supabase.instance.client;

  static Future<PickResult> pickNext({
    required List<Map<String, String>> pool,
    required String column, // "claimed_rewards" or "shown_prompts"
  }) async {
    final user = await _supabase
        .from('users')
        .select(column)
        .eq('username', Session.username)
        .single();

    List used = (user[column] ?? []) as List;
    var available = pool.where((item) => !used.contains(item["title"])).toList();

    bool didReset = false;
    if (available.isEmpty) {
      used = [];
      available = pool;
      didReset = true;
    }

    final item = available[Random().nextInt(available.length)];
    used = List.from(used)..add(item["title"]);

    await _supabase.from('users').update({column: used}).eq('username', Session.username);

    return PickResult(item, didReset);
  }
}

class ChooseUsernamePage extends StatefulWidget {
  final String authUid;
  const ChooseUsernamePage({super.key, required this.authUid});

  @override
  State<ChooseUsernamePage> createState() => _ChooseUsernamePageState();
}

class _ChooseUsernamePageState extends State<ChooseUsernamePage> {
  final usernameController = TextEditingController();
	final promoCodeController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool _loading = false;
	bool _agreedToCommunications = false;

	@override
void dispose() {
  usernameController.dispose();
  promoCodeController.dispose();
  super.dispose();
}
	Future<void> checkPromoCode(String enteredPromo) async {
  try {
    final response = await supabase
        .from("users")
        .select()
        .eq("promo_code", enteredPromo);

    if (response.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid promo code.")),
      );
      return;
    }

    final owner = response.first;

    if (owner["username"] == Session.username) return;

    if (owner["device_id"] == Session.deviceId) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nice try 😊")),
      );
      return;
    }

    await supabase.from("users").update({
      "pending_rewards": owner["pending_rewards"] + 1,
    }).eq("username", owner["username"]);

    final currentUser = await supabase
        .from("users")
        .select("pending_rewards")
        .eq("username", Session.username)
        .single();

    await supabase.from("users").update({
      "pending_rewards": currentUser["pending_rewards"] + 1,
    }).eq("username", Session.username);
  } catch (e) {
    debugPrint(e.toString());
  }
}

  String generatePromoCode() {
    const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    final random = Random();
    String code = "LC";
    for (int i = 0; i < 6; i++) {
      code += chars[random.nextInt(chars.length)];
    }
    return code;
  }

  Future<void> _submit() async {
    final username = usernameController.text.trim();
    if (username.isEmpty) return;
	  if (!_agreedToCommunications) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Please agree to receive communications to continue"),
    ),
  );
  return;
}

    setState(() => _loading = true);

    try {
      final existingUser = await supabase
          .from('users')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (existingUser != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Username already exists")),
        );
        setState(() => _loading = false);
        return;
      }

      final email = supabase.auth.currentUser?.email ?? '';

      await supabase.from('users').insert({
        'username': username,
        'password': null,
        'auth_uid': widget.authUid,
        'email': email,
        'current_stage': 'smalltalk',
        'stage_progress': 0,
        'intro_completed': false,
        'bigtalk_intro_seen': false,
        'playdate_intro_seen': false,
        'hygge_intro_seen': false,
        'graduated': false,
        'graduation_seen': false,
        'lonely_yes': 0,
        'lonely_total': 0,
        'premium': false,
        'promo_code': generatePromoCode(),
        'pending_rewards': 0,
      });

      Session.username = username;
		final enteredPromo = promoCodeController.text.trim().toUpperCase();
if (enteredPromo.isNotEmpty) {
  await checkPromoCode(enteredPromo);
}
      Session.deviceId = await DeviceService.getDeviceId();

      await supabase.from("users").update({"device_id": Session.deviceId})
          .eq("username", username);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("loggedIn", true);
      await prefs.setString("username", username);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF24B65E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Choose a username",
                style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
							TextField(

                          controller: promoCodeController,

                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "Promo Code (Optional)",

                            suffixIcon: IconButton(

                              icon: const Icon(Icons.info_outline),

                              onPressed: () {

                                showDialog(

                                  context: context,

                                  builder: (_) => const AlertDialog(

                                    title: Text(
                                      "Promo Code",
                                    ),

                                    content: Text(

                                      "If you enter another user's promo code during registration, both of you will receive one Premium Reward at your registered email.",

                                    ),

                                  ),

                                );

                              },

                            ),

                          ),

                        ),
							const SizedBox(height: 30),
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Checkbox(
      value: _agreedToCommunications,
      fillColor: WidgetStateProperty.resolveWith((states) => Colors.white),
      checkColor: const Color(0xFF24B65E),
      onChanged: (value) {
        setState(() {
          _agreedToCommunications = value ?? false;
        });
      },
    ),
    Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _agreedToCommunications = !_agreedToCommunications;
          });
        },
        child: const Padding(
          padding: EdgeInsets.only(top: 14),
          child: Text(
            "I agree to receive occasional communications from Let's Connect",
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ),
    ),
  ],
),
const SizedBox(height: 30),
              _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : ElevatedButton(
                onPressed: _submit,
                child: const Text("Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF24B65E),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // Welcome Message
              const Text(
                "Welcome to Let's Connect",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              // Tagline
              Text(
                "Please choose an option below, so that we can help you better.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),

              const SizedBox(height: 60),

              // Option 1: Make friends
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TaskPage(),
                    ),
                  );
                },
                child: const Text(
                  'I want to make friends',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 16),

              // Option 2: I feel lonely
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LonelyPage(),
                    ),
                  );
                },
                child: const Text(
                  'I feel lonely',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class ReviewService {
  static const _kTaskCount = "review_task_count";
  static const _kRequested = "review_requested";
  static const _kPending   = "review_pending";

  /// How many comfortable task completions before we ask.
  static const _threshold = 3;

  /// Call this only when the user says the task felt OK.
  static Future<void> registerComfortableTask() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool(_kRequested) ?? false) return;

    final count = (prefs.getInt(_kTaskCount) ?? 0) + 1;
    await prefs.setInt(_kTaskCount, count);

    if (count >= _threshold) {
      await prefs.setBool(_kPending, true);
    }
  }

  /// Call this from a calm screen — never while a dialog is up.
  static Future<void> maybeRequestReview() async {
    final prefs = await SharedPreferences.getInstance();

    if (!(prefs.getBool(_kPending) ?? false)) return;
    if (prefs.getBool(_kRequested) ?? false) return;

    final inAppReview = InAppReview.instance;
    if (!await inAppReview.isAvailable()) return;

    // Burn the flags before asking — the OS may silently no-op,
    // and we never want to re-ask on every MainPage build.
    await prefs.setBool(_kPending, false);
    await prefs.setBool(_kRequested, true);

    await inAppReview.requestReview();
  }

  /// Manual "Rate us" — always opens the real store page.
  static Future<void> openStoreListing() async {
    await InAppReview.instance.openStoreListing(
      appStoreId: "6792295616",
    );
  }
}
