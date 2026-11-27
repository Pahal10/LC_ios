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

/// 1.0 on a ~390pt-wide phone (iPhone 14/15). Smaller phones shrink a bit, bigger ones grow a bit.
double lcScale(BuildContext context) =>
    (MediaQuery.of(context).size.width / 390).clamp(0.85, 1.15).toDouble();
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
	  builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.1),
          ),
          child: child!,
        );
      },
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
  @override
void dispose() {
  usernameController.dispose();
  passwordController.dispose();
  super.dispose();
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


  

// Replace BOTH of these inside _LoginPageState (build + _buildLoginField).
// Everything above them (loginUser, signInWithGoogle, etc.) stays untouched.

@override
Widget build(BuildContext context) {
  final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
  return Scaffold(
    backgroundColor: const Color(0xFF003F32),
    body: Stack(
      children: [
        // BACKGROUND
        // Swap to the image once you export the swirl as asset/login_bg.png
        // (and list it in pubspec.yaml):
        // Positioned.fill(child: Image.asset('asset/login_bg.png', fit: BoxFit.cover)),
        Positioned.fill(
          child: Image.asset('asset/emerald.png', fit: BoxFit.cover),
        ),

        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final h = constraints.maxHeight;

              // FIXED SIZES (no more stretching)
              final logoHeight = (h * 0.15).clamp(80.0, 120.0);
              const fieldHeight = 50.0;
              const loginHeight = 52.0;
              const socialHeight = 42.0;

              final content = Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: 16, // needs Flutter 3.27+
                  children: [
                    // LOGO
                    Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 28),
                      child: Image.asset(
                        'asset/LCLogo2.png',
                        height: logoHeight,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // USERNAME
                    SizedBox(
                      height: fieldHeight,
                      child: _buildLoginField(
                        controller: usernameController,
                        hint: "Username",
                      ),
                    ),

                    // PASSWORD
                    SizedBox(
                      height: fieldHeight,
                      child: _buildLoginField(
                        controller: passwordController,
                        hint: "Password",
                        obscure: _hidePassword,
                        suffix: IconButton(
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF444444),
                          ),
                          onPressed: () {
                            setState(() => _hidePassword = !_hidePassword);
                          },
                        ),
                      ),
                    ),

                    // FORGOT PASSWORD
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: loginHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF007AFF), Color(0xFF00C6FF)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.35),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00C6FF).withOpacity(0.45),
                              blurRadius: 18,
                              spreadRadius: 0,
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
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Log in",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // OR DIVIDER
                    const Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.white, thickness: 1.2),
                        ),
                        SizedBox(width: 14),
                        Text(
                          "or",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Divider(color: Colors.white, thickness: 1.2),
                        ),
                      ],
                    ),

                    // GOOGLE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: socialHeight,
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(21),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(21),
                          onTap: signInWithGoogle,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'asset/Glogo.png',
                                height: 22,
                                width: 22,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Continue with Google",
                                style: TextStyle(
                                  color: Color(0xFF202124),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // APPLE BUTTON
                    if (isIOS)
                      SizedBox(
                        width: double.infinity,
                        height: socialHeight,
                        child: SignInWithAppleButton(
                          onPressed: signInWithApple,
                          style: SignInWithAppleButtonStyle.black,
                          height: socialHeight,
                          borderRadius: BorderRadius.circular(21),
                        ),
                      ),

                    // REGISTER
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "New here?",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            SizedBox(width: 9),
                            Text(
                              "Register",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );

              // Scroll only when the keyboard is open.
			  return SingleChildScrollView(
                 child: ConstrainedBox(
    			 constraints: BoxConstraints(minHeight: constraints.maxHeight),
    			 child: content,
  				),
			  );
            },
          ),
        ),
      ],
    ),
  );
}

// REUSABLE LOGIN INPUT FIELD
Widget _buildLoginField({
  required TextEditingController controller,
  required String hint,
  bool obscure = false,
  Widget? suffix,
}) {
  return Container(
    height: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(
        color: Color(0xFF353535),
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF555555),
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF00C6A0), width: 2),
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
  backgroundColor: const Color(0xFF003F32),

  extendBodyBehindAppBar: true,

  appBar: AppBar(
    centerTitle: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,

    iconTheme: const IconThemeData(
      color: Colors.white,
    ),

    title: const Text(
      'Sign Up',
      style: TextStyle(
        color: Colors.amber,
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
    ),
  ),

  body: Stack(
    children: [

      // GREEN BACKGROUND IMAGE
      Positioned.fill(
        child: Image.asset(
          'asset/emerald.png',
          fit: BoxFit.cover,
        ),
      ),

      SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
          ),
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
                       }, // closes builder
          ),   // closes LayoutBuilder
        ),     // closes Padding
      ),       // closes SafeArea
    ],         // closes Stack children
  ),           // closes Stack
);             // closes Scaffold
  }            // closes build()
}              // closes RegisterPage State class

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
  final int? friendId;

  const TaskPage({
    super.key,
    this.forcedStage,
	this.friendId,
  });
  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {

  final supabase = Supabase.instance.client;
  static const Map<String, int> friendStageThresholds = {
  'smalltalk': 2,
  'mediumtalk': 4,
  'bigtalk': 6,
  'voicecall': 6,
  'playdate': 6,
  'hygge': 6,
};

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
	  if (widget.friendId != null) {
  final friend = await supabase
      .from('friends')
      .select('current_stage, stage_progress')
      .eq('id', widget.friendId!)
      .eq('username', Session.username)
      .single();

  currentStage = friend['current_stage'] ?? 'smalltalk';

  progress = friend['stage_progress'] ?? 0;
} else {
  currentStage =
      widget.forcedStage ?? (data['current_stage'] ?? 'smalltalk');

  progress = data['stage_progress'] ?? 0;
}
      bool bigTalkSeen = data['bigtalk_intro_seen'] ?? false;
      bool playDateSeen = data['playdate_intro_seen'] ?? false;
      bool hyggeSeen = data['hygge_intro_seen'] ?? false;
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

      if (widget.friendId == null && !introCompleted) {
  Future.delayed(
    const Duration(milliseconds: 500),
    	() 		{
      		if (mounted) showIntroDialog();
    		},
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
  
Future<bool> showFriendInteractionDialog(
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

  if (widget.friendId != null) {
    // Continuing an existing friendship:
    // lock the interaction to this exact friend.
    selectedFriendId = widget.friendId;
    addNewFriend = false;
  } else if (friends.isEmpty) {
    addNewFriend = true;
  }
  } catch (e) {
    debugPrint('Could not load friends: $e');
    loadingFriends = false;
    addNewFriend = true;
  }

  if (!mounted) return false;

  final saved = await showDialog<bool>(
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
onChanged: (double value) {
  onChanged(value.round());
},                ),
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
			  dynamic friendId = widget.friendId ?? selectedFriendId;
              if (addNewFriend) {
                final newFriend = await supabase
                    .from('friends')
                    .insert({
                      'username': username,
                      'display_name': name,
                      'comfort_rating': comfort,
                      'happiness_rating': happiness,
                      'highest_stage': completedStage,
					  'current_stage': 'smalltalk',
					  'stage_progress': 0,
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

              Navigator.pop(dialogContext, true);
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
                    
if (widget.friendId == null) ...[
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
  return saved ?? false;
}

Future<void> maybeShowInAppRating() async {
  try {
    // Check whether this user has already submitted a rating.
    final user = await supabase
        .from('users')
        .select('rating_prompt_completed')
        .eq('username', Session.username)
        .maybeSingle();

    if (!mounted || user == null) return;

    if (user['rating_prompt_completed'] == true) return;

    final feedbackController = TextEditingController();
    int selectedRating = 0;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, updateDialog) {
              return AlertDialog(
                backgroundColor: const Color(0xFFF8FCF8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: const Text(
                  'How has LC been helping you connect?',
                  style: TextStyle(
                    color: Color(0xFF176B3A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'You have taken another step towards building meaningful friendships. We would love to hear how it is going.',
                        style: TextStyle(
                          color: Color(0xFF34483A),
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'How would you rate your experience?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF263C2C),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (index) {
                          final rating = index + 1;

                          return IconButton(
                            onPressed: () {
                              updateDialog(() {
                                selectedRating = rating;
                              });
                            },
                            icon: Icon(
                              rating <= selectedRating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: const Color(0xFFFFB52E),
                              size: 34,
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Anything we could improve? (Optional)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF263C2C),
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        controller: feedbackController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Tell us about your experience...',
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

                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text(
                      'Maybe later',
                      style: TextStyle(
                        color: Color(0xFF52715B),
                      ),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: selectedRating == 0
                        ? null
                        : () async {
                            try {
                              await supabase
                                  .from('users')
                                  .update({
                                'rating_prompt_completed': true,
                                'app_rating': selectedRating,
                                'rating_feedback':
                                    feedbackController.text.trim().isEmpty
                                        ? null
                                        : feedbackController.text.trim(),
                              }).eq(
                                'username',
                                Session.username,
                              );

                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                              }
                            } catch (e) {
                              if (dialogContext.mounted) {
                                ScaffoldMessenger.of(dialogContext)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Could not save your rating: $e',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF176B3A),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Submit rating'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      feedbackController.dispose();
    }
  } catch (e) {
    debugPrint('Could not show rating dialog: $e');
  }
}

Future<void> completeTask() async {
  try {
    final interactionSaved = await showFriendInteractionDialog(
      context,
      currentStage,
    );

    if (!interactionSaved || !mounted) return;

    // Increment progression only after successful interaction saving.
    await increaseProgress(1);

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


  Future<void> increaseProgress(int amount) async {
  final previousStage = currentStage;
  // Keep this user-level flag, regardless of whether the task is
  // associated with a particular friend.
  await supabase
      .from('users')
      .update({
        'intro_completed': true,
      })
      .eq('username', Session.username);

  progress += amount;

  // Each existing friend progresses independently.
if (widget.friendId != null) {
  final threshold = friendStageThresholds[currentStage] ?? 6;

  progress += amount;

  if (progress >= threshold) {
    final currentIndex = stages.indexOf(currentStage);

    if (currentIndex < stages.length - 1) {
      currentStage = stages[currentIndex + 1];
      progress = 0;
    } else {
      // Keep the final stage completed.
      progress = threshold;
    }
  }

  // Save the current stage and progress for this friend.
  final update = <String, dynamic>{
    'current_stage': currentStage,
    'stage_progress': progress,
  };

  // Update the highest stage reached, without moving it backwards.
  final stageOrder = {
    'smalltalk': 1,
    'mediumtalk': 2,
    'bigtalk': 3,
    'voicecall': 4,
    'playdate': 5,
    'hygge': 6,
  };

  final friendData = await supabase
      .from('friends')
      .select('highest_stage')
      .eq('id', widget.friendId!)
      .eq('username', Session.username)
      .single();

  final highestStage =
      friendData['highest_stage'] ?? 'smalltalk';

  if ((stageOrder[currentStage] ?? 1) >
      (stageOrder[highestStage] ?? 1)) {
    update['highest_stage'] = currentStage;
  }

  await supabase
      .from('friends')
      .update(update)
      .eq('id', widget.friendId!)
      .eq('username', Session.username);

  if (!mounted) return;

  setState(() {});
  if (currentStage != previousStage) {
    await maybeShowInAppRating();
  }
  return;
}

  // Original user-wide progression for tasks not associated with a friend.
  if (progress >= 6) {
    if (currentStage == 'hygge') {
      await supabase
          .from('users')
          .update({
            'graduated': true,
            'graduation_seen': true,
          })
          .eq('username', Session.username);

      await showGraduationDialog();
    }

    if (currentStage == 'mediumtalk') {
      final user = await supabase
          .from('users')
          .select('email')
          .eq('username', Session.username)
          .single();

      final email = user['email'];

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

    final answeredYes = await askConnectionQuestion();

    await updateLonelinessStats(answeredYes);

    final currentIndex = stages.indexOf(currentStage);

    if (currentIndex < stages.length - 1) {
      currentStage = stages[currentIndex + 1];
      progress = 0;
    }
  }

  // Save the original user-wide progress.
    await supabase
      .from('users')
      .update({
        'current_stage': currentStage,
        'stage_progress': progress,
        'verifyshow': true,
      })
      .eq('username', Session.username);

  // Also support the original user-wide progression.
  if (!mounted) return;

  if (currentStage != previousStage) {
    await maybeShowInAppRating();
  }
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
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  
Future<void> openTask() async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _ConnectChoiceSheet(
        onNew: () {
          Navigator.pop(sheetContext);
          _startNewConnection();
        },
        onExisting: () {
          Navigator.pop(sheetContext);
          _openFriendsPage();
        },
      );
    },
  );
}


Future<void> _startNewConnection() async {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const TaskPage(forcedStage: 'smalltalk'),
    ),
  );
}

void _openFriendsPage() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const FriendsPage(),
    ),
  );
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
                5,
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
                3,
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
FriendsPage(
  embedded: true,
  onSelectFriend: (friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FriendDetailPage(friend: friend),
      ),
    );
  },
),
	  // 2 - QUICK HELP
	  const QuickHelpPage(),
      // 3 — EXERCISES
      const ExercisesPage(),

      // 4 — REWARDS
      const RewardsPage(),

      // 5 — PROFILE
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

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});
  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  bool _loading = true;
  String? _error;
  int _verifiedTasks = 0;
  int _totalTasks = 0;

  @override
  void initState() {
    super.initState();
    _loadTaskCounts();
  }

  Future<void> _loadTaskCounts() async {
    if (Session.username.trim().isEmpty) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Please sign in again to view your progress.';
      });
      return;
    }
    try {
      final username = Session.username.trim();
      final supabase = Supabase.instance.client;
      final verifiedResponse = await supabase
          .from('verification_pairs')
          .select('user1')
          .or('user1.eq.$username,user2.eq.$username');
      final totalResponse = await supabase
          .from('friend_interactions')
          .select('id')
          .eq('username', username);
      if (!mounted) return;
      setState(() {
        _verifiedTasks = (verifiedResponse as List).length;
        _totalTasks = (totalResponse as List).length;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      debugPrint('Could not load Rewards progress: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'We couldn’t load your progress right now.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = lcScale(context);
    final progressInCycle = _verifiedTasks % 3;
    return _LCPageBackground(
      child: RefreshIndicator(
        color: const Color(0xFF9AF0C0),
        backgroundColor: const Color(0xFF104B35),
        onRefresh: _loadTaskCounts,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20, 18 * scale, 20, 34),
          children: [
            const Text(
              'YOUR REWARDS',
              style: TextStyle(
                color: Color(0xFFB8F4CE),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
              ),
            ),
            SizedBox(height: 20 * scale),
            // Aurora-glass membership card
            ClipRRect(
              borderRadius: BorderRadius.circular(27),
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF0D8060),
                            Color(0xFF176D72),
                            Color(0xFF234C72),
                            Color(0xFF102F43),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -65,
                    right: -25,
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF7DFFD0).withOpacity(.23),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -100,
                    left: -40,
                    child: Container(
                      width: 230,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF60BFFF).withOpacity(.20),
                      ),
                    ),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      padding: EdgeInsets.all(22 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.075),
                        border: Border.all(color: Colors.white.withOpacity(.24)),
                        borderRadius: BorderRadius.circular(27),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 43,
                                height: 43,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.16),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white.withOpacity(.25)),
                                ),
                                child: const Icon(
                                  Icons.workspace_premium_rounded,
                                  color: Color(0xFFB9FFE0),
                                  size: 24,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'LC  /  MEMBERSHIP',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.78),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 27 * scale),
                          const Text(
                            'CONNECTION BUILDER',
                            style: TextStyle(
                              color: Color(0xFFD2FFEB),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.1,
                            ),
                          ),
                          SizedBox(height: 7 * scale),
                          Text(
                            Session.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 27 * scale,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 17 * scale),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFB8F4CE)),
                ),
              )
            else if (_error != null)
              _RewardsGlassPanel(
                child: Column(
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        color: Color(0xFFB8F4CE), size: 28),
                    const SizedBox(height: 10),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _loadTaskCounts,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try again'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFB8F4CE),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: _RewardsMetricCard(
                      icon: Icons.verified_rounded,
                      label: 'VERIFIED TASKS',
                      value: _verifiedTasks,
                      accent: const Color(0xFF9CFFD6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RewardsMetricCard(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'TOTAL TASKS',
                      value: _totalTasks,
                      accent: const Color(0xFF9BD9FF),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15 * scale),
              _RewardsGlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Your next reward',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '$progressInCycle out of 3',
                          style: const TextStyle(
                            color: Color(0xFFB8F4CE),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Complete 3 verified tasks to reach your next milestone.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.68),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progressInCycle / 3,
                        minHeight: 9,
                        backgroundColor: Colors.white.withOpacity(.12),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF9AF0C0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(3, (index) {
                        return Row(
                          children: [
                            Icon(
                              index < progressInCycle
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              size: 13,
                              color: index < progressInCycle
                                  ? const Color(0xFF9AF0C0)
                                  : Colors.white38,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Task ${index + 1}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(.58),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 18 * scale),
            _RewardsGlassPanel(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9AF0C0).withOpacity(.13),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFB8F4CE),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      'Your effort to build meaningful connections is valued by us.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.9),
                        fontSize: 14 * scale,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardsMetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color accent;

  const _RewardsMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return _RewardsGlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 21),
          const SizedBox(height: 15),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(.62),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: .8,
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardsGlassPanel extends StatelessWidget {
  final Widget child;
  const _RewardsGlassPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.085),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(.15)),
          ),
          child: child,
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
	(Icons.lightbulb_outline_rounded, 'Help'),
    (Icons.psychology_alt_rounded, 'Exercise'),
    (Icons.workspace_premium_rounded, 'Rewards'),
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
			  final itemWidth = constraints.maxWidth / items.length;
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
					children: List.generate(items.length, (index) {
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
          .select('current_stage')
          .eq('username', Session.username)
          .single();
      if (!mounted) return;
      setState(() => stage = d['current_stage'] ?? 'smalltalk');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final s = lcScale(context);

    return LayoutBuilder(builder: (context, c) {
      // card never wider than 420, never touches the screen edges
      final cardW = (c.maxWidth - 44).clamp(0.0, 420.0).toDouble();

      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
          child: SizedBox(
            width: cardW,
            child: _LCGlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 8 * s),
                  CircleAvatar(
                    radius: cardW * 0.16,
                    backgroundColor: const Color(0xFF3FA55F),
                    backgroundImage: const AssetImage('asset/LCicon.png'),
                  ),
                  SizedBox(height: 26 * s),
                  Text(
                    'continue your journey of becoming close friends with people around you!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFFB8F4CE),
                      fontSize: 17 * s,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 22 * s),
                  SizedBox(
                    width: double.infinity,
                    height: 52 * s,
                    child: ElevatedButton(
                      onPressed: widget.onStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA8EBC1),
                        foregroundColor: const Color(0xFF104D2C),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      child: FittedBox(          // shrinks text instead of cutting it
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Continue your journey',
                                style: TextStyle(
                                    fontSize: 17 * s,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20 * s),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 18 * s),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white.withOpacity(.25))),
                      const SizedBox(width: 10),
                      Flexible(
                        flex: 4,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${labels[stage] ?? stage}  •  Your current stage',
                            style: TextStyle(
                              color: const Color(0xFFB8F4CE),
                              fontSize: 12.5 * s,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Divider(color: Colors.white.withOpacity(.25))),
                    ],
                  ),
                  SizedBox(height: 6 * s),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
class _ConnectChoiceSheet extends StatelessWidget {
  final VoidCallback onNew;
  final VoidCallback onExisting;

  const _ConnectChoiceSheet({
    required this.onNew,
    required this.onExisting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F8F1),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Who would you like to connect with?',
              style: TextStyle(
                color: Color(0xFF183D2B),
                fontSize: 25,
                height: 1.15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Every connection starts somewhere.',
              style: TextStyle(color: Color(0xFF718074), fontSize: 14),
            ),
            const SizedBox(height: 24),
            _ChoiceTile(
              icon: Icons.person_add_alt_1_rounded,
              title: 'Someone new',
              subtitle: 'Start with a simple Small Talk prompt.',
              onTap: onNew,
            ),
            const SizedBox(height: 13),
            _ChoiceTile(
              icon: Icons.people_alt_rounded,
              title: 'Someone I know',
              subtitle: 'Choose a friend and continue where you left off.',
              onTap: onExisting,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F1E5),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF287347),
                  size: 27,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF203C2A),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF718074),
                        height: 1.35,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF64806B),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FriendsPage extends StatefulWidget {
  final bool embedded;
  final ValueChanged<Map<String, dynamic>>? onSelectFriend;

  const FriendsPage({
    super.key,
    this.embedded = false,
    this.onSelectFriend,
  });

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> friends = [];
  bool loading = true;
  String? error;

  static const Map<String, String> stageLabels = {
    'smalltalk': 'Small Talk',
    'mediumtalk': 'Medium Talk',
    'bigtalk': 'Big Talk',
    'playdate': 'Play Time',
    'hygge': 'Hygge',
  };

  @override
  void initState() {
    super.initState();
    loadFriends();
  }

  Future<void> loadFriends() async {
    try {
      final response = await supabase
          .from('friends')
          .select(
            'id, display_name, comfort_rating, happiness_rating, '
            'highest_stage, last_interaction_at',
          )
          .eq('username', Session.username);

      final loaded = List<Map<String, dynamic>>.from(response);

      // Recommend the person with the strongest recent connection signals.
      loaded.sort((a, b) {
        final aScore =
            ((a['comfort_rating'] ?? 3) as num).toDouble() +
            ((a['happiness_rating'] ?? 3) as num).toDouble();
        final bScore =
            ((b['comfort_rating'] ?? 3) as num).toDouble() +
            ((b['happiness_rating'] ?? 3) as num).toDouble();
        return bScore.compareTo(aScore);
      });

      if (!mounted) return;
      setState(() {
        friends = loaded;
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  String _lastSeen(dynamic value) {
    if (value == null) return 'Not yet recorded';

    try {
      final date = DateTime.parse(value.toString()).toLocal();
      final days = DateTime.now().difference(date).inDays;

      if (days <= 0) return 'Connected today';
      if (days == 1) return 'Connected yesterday';
      if (days < 7) return 'Connected $days days ago';
      if (days < 30) return 'Connected ${days ~/ 7} weeks ago';
      return 'Last connected ${days ~/ 30} months ago';
    } catch (_) {
      return 'Connection saved';
    }
  }

  void _openFriend(Map<String, dynamic> friend) {
    if (widget.onSelectFriend != null) {
      widget.onSelectFriend!(friend);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FriendDetailPage(friend: friend),
      ),
    ).then((_) => loadFriends());
  }

  Widget _recommendationCard() {
    if (friends.isEmpty) return const SizedBox.shrink();

    final friend = friends.first;
    final name = (friend['display_name'] ?? 'Your friend').toString();
    final stage = (friend['highest_stage'] ?? 'smalltalk').toString();
    final comfort = (friend['comfort_rating'] ?? 3) as num;
    final happiness = (friend['happiness_rating'] ?? 3) as num;

    final suggestion = comfort >= 4 && happiness >= 4
        ? 'You seem to enjoy your conversations. Maybe try taking things a little deeper.'
        : 'A small check-in could be a lovely way to keep this connection going.';

    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDFF0DF), Color(0xFFBFDDBF)],
        ),
        borderRadius: BorderRadius.circular(27),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  color: Color(0xFF39754B), size: 18),
              SizedBox(width: 7),
              Text(
                'A SUGGESTION FOR TODAY',
                style: TextStyle(
                  color: Color(0xFF39754B),
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white.withOpacity(.8),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Color(0xFF286B42),
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Color(0xFF1D432B),
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      stageLabels[stage] ?? stage,
                      style: const TextStyle(
                        color: Color(0xFF54735A),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            suggestion,
            style: const TextStyle(
              color: Color(0xFF34583D),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 17),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _openFriend(friend),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF286B42),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text('Connect with $name'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _friendCard(Map<String, dynamic> friend) {
    final name = (friend['display_name'] ?? 'Friend').toString();
    final stage = (friend['highest_stage'] ?? 'smalltalk').toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        child: InkWell(
          onTap: () => _openFriend(friend),
          borderRadius: BorderRadius.circular(21),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFFE5F0E4),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Color(0xFF286B42),
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Color(0xFF203B29),
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${stageLabels[stage] ?? stage}  ·  '
                        '${_lastSeen(friend['last_interaction_at'])}',
                        style: const TextStyle(
                          color: Color(0xFF718074),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: Color(0xFF809184),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _content() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B8A4C),
            Color(0xFF115C34),
            Color(0xFF082A1B),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: loadFriends,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 35),
            children: [
              const Text(
                'Your people.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Good connections grow a little at a time.',
                style: TextStyle(
                  color: Colors.white.withOpacity(.72),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 27),
              if (loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(35),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              else if (error != null)
                _LCGlassCard(
                  child: Column(
                    children: [
                      const Icon(Icons.cloud_off_rounded,
                          color: Colors.white, size: 30),
                      const SizedBox(height: 10),
                      const Text(
                        'Could not load your connections.',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        error!,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11),
                      ),
                      TextButton(
                        onPressed: loadFriends,
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                )
              else if (friends.isEmpty)
                _LCGlassCard(
                  child: Column(
                    children: [
                      const Icon(Icons.spa_rounded,
                          color: Color(0xFFB8F4CE), size: 38),
                      const SizedBox(height: 12),
                      const Text(
                        'Your connections will find a home here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Start with one person. We’ll help you take it from there.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                _recommendationCard(),
                const SizedBox(height: 27),
                const Text(
                  'YOUR CONNECTIONS',
                  style: TextStyle(
                    color: Color(0xFFB8F4CE),
                    fontSize: 11,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 13),
                ...friends.map(_friendCard),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _content();

    return Scaffold(
      backgroundColor: const Color(0xFF115C34),
      appBar: AppBar(
        backgroundColor: const Color(0xFF115C34),
        foregroundColor: Colors.white,
        title: const Text('Your connections'),
      ),
      body: _content(),
    );
  }
}


class FriendDetailPage extends StatefulWidget {
  final Map<String, dynamic> friend;

  const FriendDetailPage({
    super.key,
    required this.friend,
  });

  @override
  State<FriendDetailPage> createState() => _FriendDetailPageState();
}

class _FriendDetailPageState extends State<FriendDetailPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> interactions = [];
  bool loading = true;
  String? error;

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
    loadInteractions();
  }

  Future<void> loadInteractions() async {
    try {
      final response = await supabase
          .from('friend_interactions')
          .select()
          .eq('username', Session.username)
          .eq('friend_id', widget.friend['id'])
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        interactions = List<Map<String, dynamic>>.from(response);
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  String formatDate(dynamic value) {
    if (value == null) return 'Date not recorded';

    try {
      final date = DateTime.parse(value.toString()).toLocal();
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return 'Date not recorded';
    }
  }

  Widget ratingPill(IconData icon, String label, dynamic value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF2E8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF39764D), size: 19),
            const SizedBox(height: 5),
            Text(
              '${value ?? '—'}/5',
              style: const TextStyle(
                color: Color(0xFF24452E),
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF718074),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget interactionCard(Map<String, dynamic> item) {
    final stage = (item['stage'] ?? 'smalltalk').toString();
    final notes = (item['notes'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7EDE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Color(0xFF39764D),
                size: 19,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  labels[stage] ?? stage,
                  style: const TextStyle(
                    color: Color(0xFF24452E),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                formatDate(item['created_at']),
                style: const TextStyle(
                  color: Color(0xFF879287),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              ratingPill(
                Icons.favorite_outline_rounded,
                'Comfort',
                item['comfort_rating'],
              ),
              const SizedBox(width: 10),
              ratingPill(
                Icons.sentiment_satisfied_alt_rounded,
                'Happiness',
                item['happiness_rating'],
              ),
            ],
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              notes,
              style: const TextStyle(
                color: Color(0xFF58685B),
                height: 1.45,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name =
        (widget.friend['display_name'] ?? 'Friend').toString();

    final stage =
        (widget.friend['current_stage'] ??
         widget.friend['highest_stage'] ??
         'smalltalk').toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7F0),
        foregroundColor: const Color(0xFF1D432B),
        elevation: 0,
        title: const Text('Your connection'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFDFF0DF),
                  Color(0xFFBFDDBF),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 39,
                  backgroundColor: Colors.white,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Color(0xFF286B42),
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF1D432B),
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  labels[stage] ?? stage,
                  style: const TextStyle(
                    color: Color(0xFF54735A),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskPage(
                    forcedStage: stage,
                    friendId: widget.friend['id'] as int,
                  ),
                ),
              ).then((_) {
                loadInteractions();
              });
            },
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: const Text('Continue this connection'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF286B42),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          const SizedBox(height: 29),

          const Text(
            'Your story so far',
            style: TextStyle(
              color: Color(0xFF203B29),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Little moments that helped this connection grow.',
            style: TextStyle(
              color: Color(0xFF718074),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 18),

          if (loading)
            const Center(child: CircularProgressIndicator())
          else if (error != null)
            Text(
              'Could not load interaction history: $error',
              style: const TextStyle(color: Colors.red),
            )
          else if (interactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Your first interaction with this person will appear here.',
                style: TextStyle(
                  color: Color(0xFF718074),
                  height: 1.4,
                ),
              ),
            )
          else
            ...interactions.map(interactionCard),
        ],
      ),
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
                    ],
                  ),
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
class ExerciseResponse {
  final String response;
  final String feedback;

  const ExerciseResponse({
    required this.response,
    required this.feedback,
  });
}

class LCExercise {
  final int id;
  final String category;
  final String title;
  final String scenario;
  final String question;
  final List<ExerciseResponse> options;

  const LCExercise({
    required this.id,
    required this.category,
    required this.title,
    required this.scenario,
    required this.question,
    required this.options,
  });
}

const List<LCExercise> lcExercises = [

  // =====================================================
  // CATEGORY 1: STARTING
  // Small talk, opening conversations, reading situations
  // =====================================================

  LCExercise(
    id: 1,
    category: 'Starting',
    title: 'The First Hello',
    scenario: 'You are sitting next to someone before class begins. Neither of you knows each other.',
    question: 'How would you open the conversation?',
    options: [
      ExerciseResponse(response: 'Hey, have you had this professor before?', feedback: 'This feels natural because it gives the other person an easy topic to respond to. You are using something you both share.'),
      ExerciseResponse(response: 'I was going to sit somewhere else, but this seat looked less intimidating.', feedback: 'This adds a little personality and humour. It can work especially well if you deliver it with a relaxed smile.'),
      ExerciseResponse(response: 'Hey, I’m [your name]. What’s yours?', feedback: 'Direct and friendly. It communicates confidence, although it may feel slightly formal depending on the atmosphere.'),
      ExerciseResponse(response: 'This class looks like it might be interesting. What made you take it?', feedback: 'You are inviting the other person to share an opinion rather than just exchange basic information.'),
    ],
  ),

  LCExercise(
    id: 2,
    category: 'Starting',
    title: 'The Campus Event',
    scenario: 'You arrive at a campus event where you do not recognize anyone. Someone is standing near the refreshments.',
    question: 'How might you start talking to them?',
    options: [
      ExerciseResponse(response: 'Have you been to one of these events before?', feedback: 'A low-pressure opener. It lets them talk about their experience without demanding much personal information.'),
      ExerciseResponse(response: 'I’m trying to figure out whether everyone here already knows each other.', feedback: 'A little self-aware humour can make the situation feel less awkward and give them a chance to relate.'),
      ExerciseResponse(response: 'What brought you here today?', feedback: 'This is open-ended and gives them room to talk about their interests or reasons for attending.'),
      ExerciseResponse(response: 'I came here hoping to meet some new people. How’s your evening going?', feedback: 'Honest and approachable. It makes your intention clear without putting pressure on them.'),
    ],
  ),

  LCExercise(
    id: 3,
    category: 'Starting',
    title: 'The Book Compliment',
    scenario: 'Someone nearby is reading a book you have been meaning to read.',
    question: 'What could you say?',
    options: [
      ExerciseResponse(response: 'I’ve heard so much about that book. Are you enjoying it?', feedback: 'The compliment is specific and the question gives them an easy way to continue.'),
      ExerciseResponse(response: 'That book has been sitting on my reading list for about six months.', feedback: 'A relatable observation with a little humour. It gives them something to react to.'),
      ExerciseResponse(response: 'Would you recommend it so far?', feedback: 'Simple and useful. It invites an opinion, which usually creates a more interesting exchange than a yes-or-no question.'),
      ExerciseResponse(response: 'I was actually thinking of reading that next. What made you pick it?', feedback: 'You show genuine interest in their choice, not just the book itself.'),
    ],
  ),

  LCExercise(
    id: 4,
    category: 'Starting',
    title: 'The Familiar Face',
    scenario: 'You keep seeing the same person around campus, but you have never spoken.',
    question: 'How do you turn familiarity into a conversation?',
    options: [
      ExerciseResponse(response: 'I feel like we keep ending up in the same places. I’m [name], by the way.', feedback: 'You acknowledge the shared pattern and introduce yourself naturally.'),
      ExerciseResponse(response: 'I think I’ve seen you around the library a few times. Are you usually there?', feedback: 'A specific observation makes the opening feel less random. Keep the tone casual so it does not feel like you have been tracking them.'),
      ExerciseResponse(response: 'We should probably stop being strangers at this point.', feedback: 'Playful and confident. It can be charming when the repeated encounters have already created some familiarity.'),
      ExerciseResponse(response: 'Hey! How has your week been?', feedback: 'A warm, uncomplicated greeting. It works particularly well if you have exchanged smiles or greetings before.'),
    ],
  ),

  LCExercise(
    id: 5,
    category: 'Starting',
    title: 'Joining a Conversation',
    scenario: 'Two people are discussing a restaurant you have visited. You are standing nearby and know one of them slightly.',
    question: 'How could you join without interrupting awkwardly?',
    options: [
      ExerciseResponse(response: 'Wait for a natural pause, then say, “Are you talking about the place near campus?”', feedback: 'You listen first and connect your contribution to the existing topic. That makes joining feel natural.'),
      ExerciseResponse(response: 'Oh, I love that place. Their desserts are dangerously good.', feedback: 'You add an opinion and a detail that gives the group something new to respond to.'),
      ExerciseResponse(response: 'I’ve been meaning to try that place. Is it actually worth the hype?', feedback: 'You invite both people to contribute and make it easy for the conversation to include you.'),
      ExerciseResponse(response: 'Sorry to jump in, but I have a very strong opinion about that restaurant.', feedback: 'This signals enthusiasm and acknowledges the interruption. It works best when your tone is friendly rather than demanding.'),
    ],
  ),

  LCExercise(
    id: 6,
    category: 'Starting',
    title: 'The Shared Queue',
    scenario: 'You are waiting in a long coffee queue with someone who looks relaxed and is not using their phone.',
    question: 'What might make a natural opening?',
    options: [
      ExerciseResponse(response: 'Is it always this busy around this time?', feedback: 'A situational question is easy to answer and does not demand personal disclosure.'),
      ExerciseResponse(response: 'I think we might be here long enough to become regular customers.', feedback: 'Light humour turns a shared inconvenience into a small moment of connection.'),
      ExerciseResponse(response: 'Have you tried anything here that you would recommend?', feedback: 'You give them a chance to share a preference and perhaps discover a common interest.'),
      ExerciseResponse(response: 'I always underestimate how long coffee queues take.', feedback: 'A small personal observation makes you sound approachable and gives them room to agree or add their own experience.'),
    ],
  ),

  LCExercise(
    id: 7,
    category: 'Starting',
    title: 'The Group Project',
    scenario: 'You have just been assigned to a group project with three students you have never met.',
    question: 'How do you help the group get comfortable?',
    options: [
      ExerciseResponse(response: 'Should we quickly introduce ourselves before we divide the work?', feedback: 'You create a simple structure that helps everyone participate without forcing instant closeness.'),
	  ExerciseResponse(response: "What are everyone's strengths? I want to know who I should be asking for help.", feedback: 'This is practical and positive, though adding your own strengths can make it feel more mutual.'),      ExerciseResponse(response: 'I’m hoping we can make this one of those group projects that actually works.', feedback: 'A shared aspiration can create a friendly team atmosphere and a little optimism.'),
      ExerciseResponse(response: 'Has anyone worked on something like this before?', feedback: 'A relevant question invites people to share experience and helps the group find a starting point.'),
    ],
  ),

  LCExercise(
    id: 8,
    category: 'Starting',
    title: 'The Compliment That Continues',
    scenario: 'Someone in your class gives a thoughtful answer during a discussion.',
    question: 'How could you approach them afterwards?',
    options: [
      ExerciseResponse(response: 'I liked the point you made about that topic. How did you arrive at it?', feedback: 'Specific appreciation feels more genuine than a generic compliment, and the follow-up opens a conversation.'),
      ExerciseResponse(response: 'You explained that much better than I could have.', feedback: 'This is warm and complimentary, but adding what you found interesting makes it easier to continue.'),
      ExerciseResponse(response: 'I had a similar thought, but you explained it in a way I had not considered.', feedback: 'You create a connection through shared thinking while showing that you listened carefully.'),
      ExerciseResponse(response: 'I’m curious what you think about the other side of that argument.', feedback: 'This can lead to an interesting exchange, especially if you first acknowledge what you appreciated about their point.'),
    ],
  ),

  LCExercise(
    id: 9,
    category: 'Starting',
    title: 'The Weekend Opener',
    scenario: 'You meet someone on Friday afternoon and want to start a casual conversation.',
    question: 'What would you ask?',
    options: [
      ExerciseResponse(response: 'Anything interesting planned for the weekend?', feedback: 'A familiar, low-pressure question. It gives them an opportunity to share as much or as little as they want.'),
      ExerciseResponse(response: 'Are you more of a productive-weekend person or a do-absolutely-nothing person?', feedback: 'The contrast makes the question more playful and gives them a chance to reveal personality.'),
      ExerciseResponse(response: 'I need a good weekend recommendation. What do you usually get up to?', feedback: 'You invite them to share something they enjoy and make the question feel conversational.'),
      ExerciseResponse(response: 'My weekend plans are currently just a collection of possibilities. How about yours?', feedback: 'Sharing a little about yourself first makes the exchange feel less like an interview.'),
    ],
  ),

  LCExercise(
    id: 10,
    category: 'Starting',
    title: 'The Quiet Moment',
    scenario: 'You are sitting beside someone at a social gathering. There is a pause and neither of you has spoken yet.',
    question: 'How might you break the ice?',
    options: [
      ExerciseResponse(response: 'How do you know the people hosting this?', feedback: 'It uses the shared setting to create an easy conversation without being overly personal.'),
      ExerciseResponse(response: 'I’m still figuring out the social geography of this room. Who do you know here?', feedback: 'A playful observation can make the awkwardness feel shared rather than uncomfortable.'),
      ExerciseResponse(response: 'Have you tried the food? I’m deciding whether to investigate.', feedback: 'A small shared decision is an easy way to start talking.'),
      ExerciseResponse(response: 'I don’t think we have met yet. I’m [name].', feedback: 'Direct introductions are often underrated. They communicate openness and make the next interaction easier.'),
    ],
  ),

  // =====================================================
  // CATEGORY 2: KEEPING IT GOING
  // Follow-ups, listening, storytelling, conversational flow
  // =====================================================

  LCExercise(
    id: 11,
    category: 'Keeping it going',
    title: 'The Short Answer',
    scenario: 'You ask someone how their day was. They reply, “Pretty good, just busy.”',
    question: 'How could you keep the conversation moving?',
    options: [
      ExerciseResponse(response: 'Busy in a good way or the exhausting kind?', feedback: 'A useful follow-up that gives them two easy directions to take the conversation.'),
      ExerciseResponse(response: 'What has been keeping you occupied?', feedback: 'Shows interest and invites more detail without assuming what their day involved.'),
      ExerciseResponse(response: 'I know that feeling. Mine has been all over the place too.', feedback: 'Sharing your own experience can make the exchange mutual, especially if you add a specific detail.'),
      ExerciseResponse(response: 'Hopefully you get some time to relax tonight. Anything planned?', feedback: 'You acknowledge their busy day and gently offer a new direction for the conversation.'),
    ],
  ),

  LCExercise(
    id: 12,
    category: 'Keeping it going',
    title: 'The Follow-up',
    scenario: 'Someone tells you they recently started learning guitar.',
    question: 'What response shows genuine curiosity?',
    options: [
      ExerciseResponse(response: 'What made you want to learn guitar?', feedback: 'You ask about the motivation behind the hobby, which often leads to a more personal answer.'),
      ExerciseResponse(response: 'What kind of music are you hoping to play?', feedback: 'This helps them imagine their goal and gives you a natural topic to explore.'),
      ExerciseResponse(response: 'How is it going so far? I imagine the beginning is a little painful.', feedback: 'You show interest while adding a relatable observation that can make them smile.'),
      ExerciseResponse(response: 'I tried learning an instrument once and discovered I have very little patience. How are you finding it?', feedback: 'Sharing a small personal story makes the question feel less like an interview.'),
    ],
  ),

  LCExercise(
    id: 13,
    category: 'Keeping it going',
    title: 'The Story Behind It',
    scenario: 'Someone mentions that they recently went on a spontaneous road trip.',
    question: 'How could you encourage a story?',
    options: [
      ExerciseResponse(response: 'What was the moment when you decided to just go?', feedback: 'You ask about the turning point, which is often where an interesting story begins.'),
      ExerciseResponse(response: 'Was it planned at all, or did you just wake up and leave?', feedback: 'A playful contrast helps them describe the experience in their own way.'),
      ExerciseResponse(response: 'What was the best part of the whole trip?', feedback: 'This directs attention towards a memorable moment rather than a list of destinations.'),
      ExerciseResponse(response: 'I love trips that happen without too much planning. Did anything unexpected happen?', feedback: 'You share your enthusiasm and give them an opening to tell a story.'),
    ],
  ),

  LCExercise(
    id: 14,
    category: 'Keeping it going',
    title: 'When They Mention Work',
    scenario: 'Someone tells you they have been working part-time alongside college.',
    question: 'What could you say next?',
    options: [
      ExerciseResponse(response: 'How are you balancing everything?', feedback: 'Shows interest in their experience rather than just asking what job they have.'),
      ExerciseResponse(response: 'Has it been worth it so far?', feedback: 'Invites them to reflect on what they are getting out of the experience.'),
      ExerciseResponse(response: 'What is the most unexpected thing you have learned from it?', feedback: 'An interesting question that can lead to a story or a personal insight.'),
      ExerciseResponse(response: 'I feel like college already takes up enough hours. What made you decide to work too?', feedback: 'You share a relatable perspective and invite them to explain their motivation.'),
    ],
  ),

  LCExercise(
    id: 15,
    category: 'Keeping it going',
    title: 'The Conversation Pivot',
    scenario: 'You have been talking about classes for a while, and the conversation is starting to run out of energy.',
    question: 'How could you introduce a new topic?',
    options: [
      ExerciseResponse(response: 'Outside of classes, what have you been enjoying lately?', feedback: 'A smooth transition from a shared responsibility to personal interests.'),
      ExerciseResponse(response: 'Important question: what is your current favourite way to waste time?', feedback: 'A playful question can create a lighter atmosphere and reveal personality.'),
      ExerciseResponse(response: 'Have you discovered any good places around campus?', feedback: 'A practical topic can lead to recommendations, shared experiences, or future plans.'),
      ExerciseResponse(response: 'I feel like we have discussed enough academics for one day. What do you do when you are not studying?', feedback: 'You acknowledge the topic shift and invite a more relaxed conversation.'),
    ],
  ),

  LCExercise(
    id: 16,
    category: 'Keeping it going',
    title: 'The Different Opinion',
    scenario: 'Someone says they dislike a movie that you absolutely loved.',
    question: 'How could you respond without shutting down the conversation?',
    options: [
      ExerciseResponse(response: 'Really? What did you dislike about it?', feedback: 'Curiosity keeps the exchange open and helps you understand their perspective.'),
      ExerciseResponse(response: 'I loved it, so I feel like we need to investigate this disagreement.', feedback: 'Playful disagreement creates energy without making the other person feel attacked.'),
      ExerciseResponse(response: 'I can see why it might not work for everyone. Which part lost you?', feedback: 'You acknowledge their opinion while inviting a more specific explanation.'),
      ExerciseResponse(response: 'That is interesting. I think the thing I liked most was actually the part people criticize.', feedback: 'You offer a genuine contrast that can lead to a lively discussion.'),
    ],
  ),

  LCExercise(
    id: 17,
    category: 'Keeping it going',
    title: 'The Story Exchange',
    scenario: 'Someone tells you an embarrassing but funny story from their school days.',
    question: 'How can you make the conversation feel mutual?',
    options: [
      ExerciseResponse(response: 'That reminds me of something equally embarrassing that happened to me.', feedback: 'Reciprocating with your own story shows that you are comfortable being a little vulnerable too.'),
      ExerciseResponse(response: 'I need to know what happened immediately after that.', feedback: 'You show that you are listening and encourage them to continue the story.'),
      ExerciseResponse(response: 'I would like to pretend I would have handled that better, but I probably would not.', feedback: 'Self-deprecating humour can make the exchange feel warm and non-judgmental.'),
      ExerciseResponse(response: 'Was everyone laughing, or were you the only one who found it funny?', feedback: 'A specific follow-up shows interest in the details and emotional context of the story.'),
    ],
  ),

  LCExercise(
    id: 18,
    category: 'Keeping it going',
    title: 'The Unexpected Detail',
    scenario: 'Someone says they enjoy travelling. You want to avoid the conversation becoming a list of countries.',
    question: 'What could you ask?',
    options: [
      ExerciseResponse(response: 'What is one place you would go back to tomorrow?', feedback: 'A personal favourite often leads to a story about what made the place special.'),
      ExerciseResponse(response: 'Have you ever had a trip go completely differently from what you expected?', feedback: 'This invites a memorable story rather than a factual answer.'),
      ExerciseResponse(response: 'Are you someone who plans every detail or figures it out as you go?', feedback: 'A personality-based question reveals how they approach experiences.'),
      ExerciseResponse(response: 'What is something you always do when you visit somewhere new?', feedback: 'You move from destinations to habits and preferences, creating a more personal exchange.'),
    ],
  ),

  LCExercise(
    id: 19,
    category: 'Keeping it going',
    title: 'The Phone Distraction',
    scenario: 'You are talking with someone, but they keep glancing at their phone.',
    question: 'How could you handle the moment?',
    options: [
      ExerciseResponse(response: 'Everything okay? You seem like you might be waiting for something.', feedback: 'A considerate check-in avoids assuming they are being rude.'),
      ExerciseResponse(response: 'I can pause if you need to take care of something.', feedback: 'You give them space without making them feel guilty.'),
      ExerciseResponse(response: 'I was just getting to the interesting part of my story.', feedback: 'Light teasing can work if you already have rapport, but it may feel passive-aggressive with someone new.'),
      ExerciseResponse(response: 'Anyway, I was saying...', feedback: 'Continuing calmly can be appropriate if the distraction is brief. If it persists, consider changing the subject or ending the interaction.'),
    ],
  ),

  LCExercise(
    id: 20,
    category: 'Keeping it going',
    title: 'The Conversation Pause',
    scenario: 'You have been talking for a few minutes. Suddenly, neither person has anything to say.',
    question: 'What is a natural way to handle the silence?',
    options: [
      ExerciseResponse(response: 'I just remembered something I wanted to ask you...', feedback: 'A genuine question can restart the conversation, provided you are actually curious.'),
      ExerciseResponse(response: 'I think we have officially reached the thinking portion of the conversation.', feedback: 'A little humour can make silence feel less threatening.'),
      ExerciseResponse(response: 'By the way, have you tried that new place nearby?', feedback: 'Introducing a new shared topic can help the conversation regain momentum.'),
      ExerciseResponse(response: 'I actually like that we do not have to fill every second with talking.', feedback: 'This communicates comfort and can make a quiet moment feel perfectly acceptable.'),
    ],
  ),

  // =====================================================
  // CATEGORY 3: COMMON GROUND
  // Similarities, shared interests, playful exchanges
  // =====================================================

  LCExercise(
    id: 21,
    category: 'Common ground',
    title: 'The Shared Interest',
    scenario: 'Someone mentions that they enjoy photography. You have recently started taking photos too.',
    question: 'How could you build on the shared interest?',
    options: [
      ExerciseResponse(response: 'What do you usually like taking pictures of?', feedback: 'You begin with their interests rather than immediately making the conversation about yourself.'),
      ExerciseResponse(response: 'I have been trying photography too. I am still figuring out how to make everything look less accidental.', feedback: 'Sharing your beginner experience creates common ground and a little humour.'),
      ExerciseResponse(response: 'Do you prefer taking photos of people or places?', feedback: 'A specific question makes it easier to discover what you both enjoy.'),
      ExerciseResponse(response: 'We should compare our favourite photos sometime.', feedback: 'You suggest a natural next interaction based on something you both enjoy.'),
    ],
  ),

  LCExercise(
    id: 22,
    category: 'Common ground',
    title: 'The Music Connection',
    scenario: 'Someone says they listen to the same artist you love.',
    question: 'How could you turn that into a more interesting exchange?',
    options: [
      ExerciseResponse(response: 'What is your favourite song by them?', feedback: 'A simple question that can reveal whether you connect over the same music.'),
      ExerciseResponse(response: 'Okay, important question: which album are you defending forever?', feedback: 'A playful prompt invites a stronger opinion and gives the conversation personality.'),
      ExerciseResponse(response: 'I saw them live once. Have you ever been to one of their concerts?', feedback: 'Sharing an experience gives them an easy way to exchange stories.'),
      ExerciseResponse(response: 'I feel like music taste tells you a surprising amount about someone.', feedback: 'This introduces a slightly more personal angle and invites them to explain their taste.'),
    ],
  ),

  LCExercise(
    id: 23,
    category: 'Common ground',
    title: 'The Food Debate',
    scenario: 'A friend of a friend says they believe pineapple belongs on pizza. You disagree, but not seriously.',
    question: 'How could you respond playfully?',
    options: [
      ExerciseResponse(response: 'I respect your right to be wrong.', feedback: 'A familiar teasing line can be funny when delivered warmly and when the disagreement is clearly lighthearted.'),
      ExerciseResponse(response: 'I think we need to establish what other controversial food opinions you have.', feedback: 'You turn a small disagreement into a playful conversation about preferences.'),
      ExerciseResponse(response: 'I disagree, but I am willing to hear your defence.', feedback: 'You invite them to make their case and create a fun back-and-forth.'),
      ExerciseResponse(response: 'Honestly, I used to hate it. Maybe you can convince me.', feedback: 'You leave room for a shared joke and show openness rather than treating the disagreement as serious.'),
    ],
  ),

  LCExercise(
    id: 24,
    category: 'Common ground',
    title: 'The Favourite Place',
    scenario: 'Someone mentions a café they visit regularly. You have never been there.',
    question: 'How could you discover whether you have similar tastes?',
    options: [
      ExerciseResponse(response: 'What do you usually order there?', feedback: 'A concrete question can lead to shared food preferences and recommendations.'),
      ExerciseResponse(response: 'What makes it your regular place?', feedback: 'You invite them to explain what they value about the atmosphere or experience.'),
      ExerciseResponse(response: 'I am always looking for a new place to become unnecessarily attached to.', feedback: 'A little personality makes the question feel less transactional.'),
      ExerciseResponse(response: 'Would you say it is more of a study café or a sit-and-talk-for-three-hours café?', feedback: 'A playful contrast helps uncover what kind of environment they enjoy.'),
    ],
  ),

  LCExercise(
    id: 25,
    category: 'Common ground',
    title: 'The Friendly Rivalry',
    scenario: 'You discover that someone supports a rival sports team.',
    question: 'How could you make the difference fun rather than awkward?',
    options: [
      ExerciseResponse(response: 'I suppose we can still be friends despite this.', feedback: 'Light teasing communicates that the rivalry is not serious.'),
      ExerciseResponse(response: 'What made you support them in the first place?', feedback: 'You turn the difference into a chance to learn about their history and interests.'),
      ExerciseResponse(response: 'We should watch a match together sometime. Winner gets bragging rights.', feedback: 'A shared activity turns the rivalry into a potential connection.'),
      ExerciseResponse(response: 'I will admit they have had a few good moments. A few.', feedback: 'Playful concession makes the banter feel reciprocal instead of hostile.'),
    ],
  ),

  LCExercise(
    id: 26,
    category: 'Common ground',
    title: 'The Unexpected Similarity',
    scenario: 'Someone mentions that they also moved to the city recently.',
    question: 'How could you use that shared experience?',
    options: [
      ExerciseResponse(response: 'What has been the biggest adjustment so far?', feedback: 'You connect through a shared transition and invite them to reflect on their experience.'),
      ExerciseResponse(response: 'I am still pretending I know where everything is. How are you doing?', feedback: 'A relatable admission creates room for humour and mutual understanding.'),
      ExerciseResponse(response: 'Have you found any places that already feel familiar?', feedback: 'This can lead to recommendations and shared exploration.'),
      ExerciseResponse(response: 'We should compare our discoveries. I am sure we have both found some hidden gems.', feedback: 'You turn a similarity into an opportunity for a future interaction.'),
    ],
  ),

  LCExercise(
    id: 27,
    category: 'Common ground',
    title: 'The Unpopular Opinion',
    scenario: 'Someone shares an unusual opinion about a popular TV show.',
    question: 'How can you make the exchange engaging?',
    options: [
      ExerciseResponse(response: 'That is a bold take. I need to hear the reasoning.', feedback: 'You show curiosity and encourage them to explain rather than immediately judging.'),
      ExerciseResponse(response: 'I might disagree, but I appreciate the confidence.', feedback: 'This adds playful energy while leaving room for a friendly debate.'),
      ExerciseResponse(response: 'What would you change about the show?', feedback: 'A specific question gives them a chance to elaborate on their taste.'),
      ExerciseResponse(response: 'I have a feeling you and I would have very different rankings.', feedback: 'You create a playful shared activity out of the difference in opinion.'),
    ],
  ),

  LCExercise(
    id: 28,
    category: 'Common ground',
    title: 'The Callback',
    scenario: 'Earlier, someone joked that they are terrible at cooking. Later, you see them ordering instant noodles.',
    question: 'How could you refer back to the earlier conversation?',
    options: [
      ExerciseResponse(response: 'Is this part of your advanced cooking curriculum?', feedback: 'A callback makes the conversation feel connected and shows that you remembered what they said.'),
      ExerciseResponse(response: 'I see the culinary journey is progressing.', feedback: 'Gentle exaggeration creates humour without making their ability the target of a harsh joke.'),
      ExerciseResponse(response: 'You know, instant noodles are a legitimate life skill.', feedback: 'You join the joke rather than positioning yourself above them.'),
      ExerciseResponse(response: 'Have you actually tried cooking anything since we spoke?', feedback: 'You refer back to the earlier topic and give them a chance to share an update.'),
    ],
  ),

  LCExercise(
    id: 29,
    category: 'Common ground',
    title: 'The Shared Complaint',
    scenario: 'You and someone else both complain about how confusing the campus timetable is.',
    question: 'How could you turn the complaint into connection?',
    options: [
      ExerciseResponse(response: 'I think the timetable was designed as a puzzle.', feedback: 'Shared humour can make a frustrating experience feel like a small team effort.'),
      ExerciseResponse(response: 'Have you found any tricks for making it easier?', feedback: 'You turn the shared frustration into a practical exchange.'),
      ExerciseResponse(response: 'At least we are confused together.', feedback: 'A warm, simple comment creates a sense of solidarity.'),
      ExerciseResponse(response: 'We should start a support group for people who cannot read this thing.', feedback: 'An exaggerated suggestion can be funny and create a playful shared identity.'),
    ],
  ),

  LCExercise(
    id: 30,
    category: 'Common ground',
    title: 'The Mini Challenge',
    scenario: 'You discover that someone enjoys trying new restaurants just like you.',
    question: 'How could you build on the shared interest?',
    options: [
      ExerciseResponse(response: 'What is the best new place you have tried recently?', feedback: 'You invite them to share a recommendation and potentially discover overlapping tastes.'),
      ExerciseResponse(response: 'We should each pick a place the other has never tried.', feedback: 'A small shared challenge gives the connection a reason to continue.'),
      ExerciseResponse(response: 'Are you adventurous with food, or do you usually order the same thing?', feedback: 'A personality-based question makes the topic more interesting than simply listing restaurants.'),
      ExerciseResponse(response: 'I think finding a good restaurant is one of the more underrated skills in life.', feedback: 'You share an opinion that can lead to playful agreement or disagreement.'),
    ],
  ),

  // =====================================================
  // CATEGORY 4: DEEPER CONNECTION
  // Opinions, personal stories, empathy, self-expression
  // =====================================================

  LCExercise(
    id: 31,
    category: 'Deeper connection',
    title: 'Beyond the Surface',
    scenario: 'You have spoken to someone several times. They mention that they have been enjoying college more than they expected.',
    question: 'How could you invite a more meaningful conversation?',
    options: [
      ExerciseResponse(response: 'What has made the biggest difference for you?', feedback: 'You invite reflection on a meaningful experience rather than asking for a generic summary.'),
      ExerciseResponse(response: 'Was there a moment when it started feeling like home?', feedback: 'This asks about a specific emotional turning point and can encourage a personal story.'),
      ExerciseResponse(response: 'What has surprised you most about yourself since starting?', feedback: 'You move towards self-discovery while allowing them to choose how much they want to share.'),
      ExerciseResponse(response: 'I think it takes a while to find your people. Have you started finding yours?', feedback: 'You share a thoughtful observation and open the door to discussing belonging.'),
    ],
  ),

  LCExercise(
    id: 32,
    category: 'Deeper connection',
    title: 'The Personal Goal',
    scenario: 'Someone tells you they are working towards a goal that is important to them.',
    question: 'What response could make them feel heard?',
    options: [
      ExerciseResponse(response: 'What made this goal important to you?', feedback: 'You focus on the personal meaning behind the goal rather than only the outcome.'),
      ExerciseResponse(response: 'What has been the hardest part so far?', feedback: 'You acknowledge that meaningful goals often involve challenges and invite them to share.'),
      ExerciseResponse(response: 'What would achieving it change for you?', feedback: 'This helps them describe the impact they hope to create in their life.'),
      ExerciseResponse(response: 'I like that you are taking it seriously. How are you keeping yourself motivated?', feedback: 'You recognize their effort and invite them to reflect on their process.'),
    ],
  ),

  LCExercise(
    id: 33,
    category: 'Deeper connection',
    title: 'The Difficult Week',
    scenario: 'A friend says they have had a difficult week and seem quieter than usual.',
    question: 'How could you respond supportively?',
    options: [
      ExerciseResponse(response: 'That sounds like a lot. Do you want to talk about it?', feedback: 'You acknowledge their experience and let them decide whether they want to open up.'),
      ExerciseResponse(response: 'I am here if you need someone to listen, even if you do not know where to start.', feedback: 'This offers support without demanding that they explain everything immediately.'),
      ExerciseResponse(response: 'Would you rather talk about it or get your mind off things for a while?', feedback: 'You offer two forms of support and give them control over what would help.'),
      ExerciseResponse(response: 'I am sorry it has been a rough week. What has been weighing on you most?', feedback: 'A direct but caring question invites them to identify what is bothering them.'),
    ],
  ),

  LCExercise(
    id: 34,
    category: 'Deeper connection',
    title: 'The Different Perspective',
    scenario: 'Someone tells you they are considering changing their major. You think it is a risky decision.',
    question: 'How could you discuss it without taking over?',
    options: [
      ExerciseResponse(response: 'What is making you consider the change?', feedback: 'You start by understanding their reasons instead of imposing your own judgment.'),
      ExerciseResponse(response: 'What would you be excited about, and what would you be giving up?', feedback: 'You help them explore both sides without telling them what decision to make.'),
      ExerciseResponse(response: 'Have you had a chance to speak with someone who has made a similar change?', feedback: 'You offer a practical perspective while respecting that the decision is theirs.'),
      ExerciseResponse(response: 'I can see why it feels like a big decision. What is your instinct telling you?', feedback: 'You acknowledge the emotional weight and invite them to think through their own priorities.'),
    ],
  ),

  LCExercise(
    id: 35,
    category: 'Deeper connection',
    title: 'The Meaningful Memory',
    scenario: 'Someone mentions that they miss their hometown.',
    question: 'How could you understand what they miss?',
    options: [
      ExerciseResponse(response: 'What is the first thing you think of when you picture home?', feedback: 'This invites a vivid memory and allows them to choose what matters most.'),
      ExerciseResponse(response: 'Is it the people, the place, or just the feeling of being familiar with everything?', feedback: 'You offer possible angles without assuming which one is true.'),
      ExerciseResponse(response: 'What is one thing from home you wish you could bring here?', feedback: 'A concrete question can lead to a personal story or a meaningful detail.'),
      ExerciseResponse(response: 'I think sometimes you miss the little routines more than the big things. Is that true for you?', feedback: 'You share a thoughtful perspective while leaving room for their own experience.'),
    ],
  ),

  LCExercise(
    id: 36,
    category: 'Deeper connection',
    title: 'The Honest Opinion',
    scenario: 'Someone asks what you genuinely think about a decision they made. You have a different opinion.',
    question: 'How can you be honest without being dismissive?',
    options: [
      ExerciseResponse(response: 'I see why you chose that. I think I would have approached it differently because...', feedback: 'You validate their reasoning before sharing your own perspective.'),
      ExerciseResponse(response: 'Do you want my honest opinion or the supportive-friend version?', feedback: 'This can be playful, but it also checks what kind of response they are looking for.'),
      ExerciseResponse(response: 'There is one part I am not completely convinced by. Can I explain?', feedback: 'You ask permission before offering criticism, which can make honesty easier to receive.'),
      ExerciseResponse(response: 'I might be looking at it differently, but here is what I would consider...', feedback: 'You frame your opinion as a perspective rather than an absolute judgment.'),
    ],
  ),

  LCExercise(
    id: 37,
    category: 'Deeper connection',
    title: 'The Unexpected Vulnerability',
    scenario: 'Someone admits that they sometimes feel out of place in social situations.',
    question: 'How could you respond in a way that builds trust?',
    options: [
      ExerciseResponse(response: 'I think more people feel that way than they let on.', feedback: 'You normalize the experience without dismissing what they are feeling.'),
      ExerciseResponse(response: 'I have felt that too, especially when I do not know anyone.', feedback: 'Sharing a relatable experience can make the other person feel less alone.'),
      ExerciseResponse(response: 'What kinds of situations make you feel that way?', feedback: 'You show curiosity about their specific experience rather than assuming you understand it.'),
      ExerciseResponse(response: 'You do not have to pretend to be comfortable around me.', feedback: 'This communicates acceptance and can help create a safer atmosphere.'),
    ],
  ),

  LCExercise(
    id: 38,
    category: 'Deeper connection',
    title: 'The Personal Story',
    scenario: 'Someone asks you what experience has changed the way you see things.',
    question: 'How could you answer in a way that invites a real conversation?',
    options: [
      ExerciseResponse(response: 'There was a time when something did not go as planned, and it changed what I value.', feedback: 'You offer a meaningful opening without feeling pressured to reveal every detail.'),
      ExerciseResponse(response: 'I think meeting certain people has changed me more than any single event.', feedback: 'This expresses a personal belief and gives the other person something thoughtful to respond to.'),
      ExerciseResponse(response: 'I am still figuring that out. I think my perspective changes as I experience more.', feedback: 'You show self-awareness and make room for an evolving answer.'),
      ExerciseResponse(response: 'Probably the moment I realized I had been wrong about something important.', feedback: 'A story about changing your mind can reveal humility and encourage the other person to share too.'),
    ],
  ),

  LCExercise(
    id: 39,
    category: 'Deeper connection',
    title: 'The Good News',
    scenario: 'Someone tells you they received an opportunity they had been hoping for.',
    question: 'How can you make your response feel genuinely enthusiastic?',
    options: [
      ExerciseResponse(response: 'That is amazing! How did you find out?', feedback: 'You celebrate the news and invite them to relive the moment.'),
      ExerciseResponse(response: 'I know you were hoping for this. You must be so relieved.', feedback: 'Remembering their earlier hopes makes your excitement feel personal and attentive.'),
      ExerciseResponse(response: 'What are you most excited about now?', feedback: 'You move beyond the announcement and invite them to imagine what comes next.'),
      ExerciseResponse(response: 'We might need to celebrate this properly.', feedback: 'You turn their good news into a shared moment and potentially a future plan.'),
    ],
  ),

  LCExercise(
    id: 40,
    category: 'Deeper connection',
    title: 'The Curious Question',
    scenario: 'You have become comfortable talking with someone and want to understand them beyond their usual interests.',
    question: 'Which question could open a more personal conversation?',
    options: [
      ExerciseResponse(response: 'What is something you wish more people understood about you?', feedback: 'This invites self-expression, but it is best used when there is already some trust.'),
      ExerciseResponse(response: 'What is something you have changed your mind about recently?', feedback: 'This reveals how they think and whether they are comfortable reflecting on their own beliefs.'),
      ExerciseResponse(response: 'What kind of day makes you feel like yourself?', feedback: 'A gentle question about personal fulfilment can reveal values without feeling intrusive.'),
      ExerciseResponse(response: 'What is something you are looking forward to that you have not told many people about?', feedback: 'This invites a personal answer while allowing them to choose how much to reveal.'),
    ],
  ),

  // =====================================================
  // CATEGORY 5: FRIENDSHIP
  // Humour, charisma, playfulness, group dynamics, follow-up
  // =====================================================

  LCExercise(
    id: 41,
    category: 'Friendship',
    title: 'The Playful Tease',
    scenario: 'A friend arrives ten minutes late and jokingly says they are always perfectly on time.',
    question: 'How could you respond with friendly banter?',
    options: [
      ExerciseResponse(response: 'I admire your commitment to redefining time.', feedback: 'Exaggeration makes the joke about the situation rather than attacking the person.'),
      ExerciseResponse(response: 'We were just about to send a search party.', feedback: 'A familiar playful exaggeration can make the arrival feel like part of the fun.'),
      ExerciseResponse(response: 'I knew you would arrive exactly when you felt like it.', feedback: 'This is teasing with a warm tone, especially if lateness is already an established joke between you.'),
      ExerciseResponse(response: 'Good timing. We have just reached the part where we start talking about you.', feedback: 'A playful line that makes them feel included rather than unwelcome.'),
    ],
  ),

  LCExercise(
    id: 42,
    category: 'Friendship',
    title: 'The Funny Observation',
    scenario: 'Your group is trying to decide where to eat. Everyone keeps saying they are fine with anything.',
    question: 'How could you add some energy to the discussion?',
    options: [
	  ExerciseResponse(response: 'I see we have assembled a committee that is afraid of making decisions.', feedback: "A humorous observation captures the group's shared indecision without targeting one person."),      ExerciseResponse(response: 'I will give everyone three options, and we are legally required to choose one.', feedback: 'You introduce a playful structure that also helps the group move forward.'),
      ExerciseResponse(response: 'Let us each nominate one place and defend it like a courtroom case.', feedback: 'Turning a mundane decision into a game can make the group more engaged.'),
      ExerciseResponse(response: 'I am happy with anything, but I reserve the right to judge the final decision.', feedback: 'This is light banter, though pairing it with a real suggestion keeps you involved.'),
    ],
  ),

  LCExercise(
    id: 43,
    category: 'Friendship',
    title: 'The Group Conversation',
    scenario: 'You are in a group conversation. Two people are talking enthusiastically while another person has barely spoken.',
    question: 'How could you help everyone feel included?',
    options: [
      ExerciseResponse(response: 'What do you think about this? You might have a different perspective.', feedback: 'You create an opening for the quieter person without putting them on the spot too aggressively.'),
      ExerciseResponse(response: 'We have heard two strong opinions. I am curious what everyone else thinks.', feedback: 'You broaden participation and make the conversation feel more balanced.'),
      ExerciseResponse(response: 'I think we need another perspective before this debate gets out of hand.', feedback: 'A little humour can invite others in while keeping the group atmosphere relaxed.'),
	  ExerciseResponse(response: 'That reminds me of something you mentioned earlier...', feedback: "Connecting the quieter person's earlier contribution to the current topic shows that you were listening."),    ],
  ),

  LCExercise(
    id: 44,
    category: 'Friendship',
    title: 'The Callback Joke',
    scenario: 'A friend once joked that they have terrible luck with technology. Their laptop freezes during a group study session.',
    question: 'What could you say?',
    options: [
      ExerciseResponse(response: 'The technology has chosen its next victim.', feedback: 'You build on an established joke and make the situation feel less frustrating.'),
      ExerciseResponse(response: 'I think your laptop is trying to communicate something.', feedback: 'A playful personification adds humour without blaming your friend.'),
      ExerciseResponse(response: 'Should we give it a moment to reconsider its life choices?', feedback: 'This exaggerates the situation and creates a shared funny moment.'),
      ExerciseResponse(response: 'At this point, I think you need to introduce your devices to me before buying them.', feedback: 'A callback makes the joke feel personal and shows you remember details from previous conversations.'),
    ],
  ),

  LCExercise(
    id: 45,
    category: 'Friendship',
    title: 'The Spontaneous Plan',
    scenario: 'You and someone have been talking about a new activity you both want to try.',
    question: 'How could you turn the conversation into an actual plan?',
    options: [
      ExerciseResponse(response: 'We keep talking about this. Should we actually go this weekend?', feedback: 'Direct and friendly. You turn shared enthusiasm into a concrete invitation.'),
      ExerciseResponse(response: 'I think this is the part where we stop discussing and start doing.', feedback: 'A playful push can create momentum without making the invitation feel demanding.'),
      ExerciseResponse(response: 'Would you be interested in going together sometime?', feedback: 'Clear and considerate. It gives them room to say yes or suggest another time.'),
      ExerciseResponse(response: 'I am going to need someone to make sure I actually follow through. Interested?', feedback: 'You make the invitation feel collaborative and give the other person a role in the plan.'),
    ],
  ),

  LCExercise(
    id: 46,
    category: 'Friendship',
    title: 'The Friendly Challenge',
    scenario: 'A friend claims they are much better than you at a game you both enjoy.',
    question: 'How could you keep the competitive energy fun?',
    options: [
      ExerciseResponse(response: 'That is a very confident statement. I suppose we should test it.', feedback: 'You accept the challenge and create playful anticipation.'),
      ExerciseResponse(response: 'I will let you enjoy this confidence while it lasts.', feedback: 'A teasing response can be funny when both people enjoy competitive banter.'),
      ExerciseResponse(response: 'Loser buys the next coffee?', feedback: 'You turn the competition into a shared activity with a lighthearted consequence.'),
      ExerciseResponse(response: 'I respect the confidence. I am not sure the evidence supports it.', feedback: 'This combines mock seriousness with humour and invites a friendly back-and-forth.'),
    ],
  ),

  LCExercise(
    id: 47,
    category: 'Friendship',
    title: 'The Friend Check-in',
    scenario: 'You have not spoken to a friend in a few weeks. You want to reconnect without making it awkward.',
    question: 'What could you send?',
    options: [
      ExerciseResponse(response: 'Hey, I realized it has been a while. How have you been?', feedback: 'Warm and straightforward. It acknowledges the gap without making it a big issue.'),
      ExerciseResponse(response: 'I just saw something that reminded me of you. How is everything going?', feedback: 'A personal reference makes the message feel thoughtful and gives the conversation a natural starting point.'),
      ExerciseResponse(response: 'We should catch up soon. What has been happening in your world?', feedback: 'You express an intention to reconnect and invite them to share an update.'),
      ExerciseResponse(response: 'I feel like we have both been busy disappearing from the planet. How are you?', feedback: 'Shared humour can make restarting contact feel relaxed, especially if that tone fits your friendship.'),
    ],
  ),

  LCExercise(
    id: 48,
    category: 'Friendship',
    title: 'The Inside Joke',
    scenario: 'Your friend makes a reference to a funny moment you both experienced months ago.',
    question: 'How could you build on the shared memory?',
    options: [
	  ExerciseResponse(response: 'I cannot believe we are still living with the consequences of that day.', feedback: "You revive the shared memory and make it feel like part of your friendship's history."),      ExerciseResponse(response: 'That moment deserves its own documentary.', feedback: 'Exaggeration adds humour and invites the other person to add their version.'),
      ExerciseResponse(response: 'I still maintain that my decision made sense at the time.', feedback: 'You playfully defend your role in the memory and create room for friendly disagreement.'),
      ExerciseResponse(response: 'We really should recreate that sometime, preferably with fewer consequences.', feedback: 'You turn a shared memory into the possibility of another experience together.'),
    ],
  ),

  LCExercise(
    id: 49,
    category: 'Friendship',
    title: 'The Genuine Appreciation',
    scenario: 'A friend has helped you through a difficult period. You want them to know that it mattered.',
    question: 'How could you express appreciation naturally?',
    options: [
      ExerciseResponse(response: 'I do not think I said it properly at the time, but I really appreciated you being there.', feedback: 'Specific and sincere. You acknowledge their effort without making the moment overly formal.'),
      ExerciseResponse(response: 'You made a bigger difference than you probably realize.', feedback: 'This communicates emotional impact and helps the person understand that their support mattered.'),
      ExerciseResponse(response: 'I owe you one. Seriously, thank you.', feedback: 'Casual but meaningful. It works well when that is already the tone of your friendship.'),
      ExerciseResponse(response: 'I am glad I have someone like you around.', feedback: 'A simple statement of affection can strengthen a friendship because it makes appreciation explicit.'),
    ],
  ),

  LCExercise(
    id: 50,
    category: 'Friendship',
    title: 'Making the Friendship Last',
    scenario: 'You have become friends with someone, but you both have busy schedules and do not meet as often as you would like.',
    question: 'How could you keep the connection alive?',
    options: [
      ExerciseResponse(response: 'Want to make one day a week our unofficial catch-up day?', feedback: 'A recurring ritual can make staying connected easier without relying entirely on spontaneous plans.'),
      ExerciseResponse(response: 'I saw something today that reminded me of our conversation and had to send it to you.', feedback: 'Small, thoughtful interactions help maintain closeness even when you are not meeting regularly.'),
      ExerciseResponse(response: 'We should plan something now before another month disappears.', feedback: 'A little humour and a concrete suggestion can help turn good intentions into plans.'),
      ExerciseResponse(response: 'No pressure to meet constantly, but I would like us to keep making time for each other.', feedback: 'You communicate that the friendship matters while respecting that both people have other responsibilities.'),
    ],
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
          final selectedResponse = selectedAnswer == null
              ? null
              : exercise.options[selectedAnswer!];

          return DraggableScrollableSheet(
            initialChildSize: 0.88,
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

                    // SITUATION
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2F3E7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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

                    const SizedBox(height: 8),

                    const Text(
                      'There is no perfect answer. Choose the response that feels most natural to you.',
                      style: TextStyle(
                        color: Color(0xFF66806D),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // RESPONSE OPTIONS
                    ...List.generate(
                      exercise.options.length,
                      (index) {
                        final option = exercise.options[index];
                        final isSelected = selectedAnswer == index;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 11),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(17),
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
                                color: isSelected
                                    ? const Color(0xFFE2F3E7)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(17),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF176B3A)
                                      : const Color(0xFFDCE8DF),
                                  width: isSelected ? 1.7 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF176B3A)
                                          : const Color(0xFFEAF1EB),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        String.fromCharCode(65 + index),
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF42634B),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Text(
                                      option.response,
                                      style: const TextStyle(
                                        color: Color(0xFF263C2C),
                                        fontSize: 14,
                                        height: 1.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFF176B3A),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // PERSONALIZED FEEDBACK
                    if (checked && selectedResponse != null) ...[
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(19),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5F2E8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFC8E2CF),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: Color(0xFF176B3A),
                                  size: 19,
                                ),
                                const SizedBox(width: 9),
                                const Text(
                                  'HOW THIS MIGHT LAND',
                                  style: TextStyle(
                                    color: Color(0xFF176B3A),
                                    fontSize: 10,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 13),

                            Text(
                              selectedResponse.feedback,
                              style: const TextStyle(
                                color: Color(0xFF294B34),
                                fontSize: 14,
                                height: 1.65,
                              ),
                            ),

                            const SizedBox(height: 17),

                            const Divider(
                              color: Color(0xFFC8E2CF),
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              'REMEMBER',
                              style: TextStyle(
                                color: Color(0xFF176B3A),
                                fontSize: 10,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              'The way you say something matters as much as the words themselves. Your tone, timing, body language, and the other person’s comfort all shape how a response is received.',
                              style: TextStyle(
                                color: Color(0xFF496452),
                                fontSize: 13,
                                height: 1.6,
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
                          backgroundColor: const Color(0xFF176B3A),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.black12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        child: Text(
                          checked
                              ? 'Finish exercise'
                              : 'See how it comes across',
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

const Color _mint = Color(0xFFB8F4CE);

class QuickHelpGuide {
  final String title, subtitle, situation, tip;
  final IconData icon;
  final List<String> say, avoid;
  const QuickHelpGuide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.situation,
    required this.say,
    required this.avoid,
    required this.tip,
  });
}

const List<QuickHelpGuide> quickHelpGuides = [
  QuickHelpGuide(
    title: 'Keep a conversation going',
    subtitle: "When you don't know what to say next.",
    icon: Icons.forum_rounded,
    situation: "They answered you, and now your mind is blank. Example: they say, “I went hiking this weekend.”",
    say: [
      "“Oh nice! Where did you go? Was it your first time there?”",
      "“That reminds me of a time I… Have you had something like that?”",
      "“What do you enjoy most about it?”",
      "“I've been wanting to try that. Any tips?”",
    ],
    avoid: [
      "One-word replies like “cool” and then silence.",
      "Firing question after question.",
      "Changing the topic while they're mid-story.",
    ],
    tip: "A conversation is a two-way exchange, not an interview. Follow what they just said, then add something of your own.",
  ),
  QuickHelpGuide(
    title: 'Exit gracefully',
    subtitle: 'Leave without making it awkward.',
    icon: Icons.waving_hand_rounded,
    situation: "You need to go, and you want to leave on a warm note.",
    say: [
      "“It was really nice talking to you! I'll catch you later.”",
      "“I should get going, but hopefully we'll talk again soon.”",
      "“I'm going to grab something to eat. See you around!”",
      "In a group: “I'm going to catch up with someone else. Enjoy!”",
      "In a group: “I'm going to head out, but it was great meeting you all.”",
    ],
    avoid: [
      "Disappearing mid-sentence.",
      "Elaborate fake excuses.",
      "Apologizing over and over.",
    ],
    tip: "You don't need an elaborate excuse. Being warm, clear and respectful is enough.",
  ),
  QuickHelpGuide(
    title: 'Handle awkward silence',
    subtitle: 'When neither person knows what to say.',
    icon: Icons.pause_circle_outline_rounded,
    situation: "The conversation stalled and you can feel the quiet.",
    say: [
      "“Random question: what's the best thing you've watched lately?”",
      "“So what's been the highlight of your week?”",
      "“I realized I don't know how you ended up here. What's the story?”",
      "Make a small comment about where you are: the food, the music, the view.",
    ],
    avoid: [
      "Panicking or saying “this is awkward”.",
      "Apologizing for the silence.",
      "Talking nonstop just to fill the gap.",
    ],
    tip: "Pauses are normal. A short silence feels much longer to you than it does to them.",
  ),
  QuickHelpGuide(
    title: 'Join a group',
    subtitle: 'When everyone seems to know each other.',
    icon: Icons.groups_rounded,
    situation: "A group is already talking and you want to step in.",
    say: [
      "Listen for 20–30 seconds to find the topic, then:",
      "“Sorry to jump in, are you talking about ___? I loved that.”",
      "“Hey, I'm ___. What are you all up to?”",
      "“Mind if I join? What did I miss?”",
    ],
    avoid: [
      "Interrupting to change the subject.",
      "Hovering silently for minutes.",
      "Trying to impress everyone at once.",
    ],
    tip: "You don't need a big entrance. One relevant comment is enough to be part of the group.",
  ),
  QuickHelpGuide(
    title: 'Start talking to someone',
    subtitle: 'Easy openers for different situations.',
    icon: Icons.chat_bubble_outline_rounded,
    situation: "You'd like to talk to someone but don't have a first line.",
    say: [
      "In class: “Have you had this professor before?”",
      "At an event: “Is this your first time at one of these?”",
      "Anywhere: “That's a cool ___. Where did you get it?”",
      "Or simply: “Hey, I'm ___.”",
    ],
    avoid: [
      "Opening with a heavy personal question.",
      "“Why are you alone?”",
      "Waiting for the perfect line.",
    ],
    tip: "Comment on something you both can see. An opener only needs to be easy to answer, not clever.",
  ),
  QuickHelpGuide(
    title: 'Avoid sounding like an interviewer',
    subtitle: 'Balance questions with sharing.',
    icon: Icons.balance_rounded,
    situation: "You've asked several questions in a row and it feels one-sided.",
    say: [
      "“Same here, I…” and then add a short detail about yourself.",
      "Answer your own question first: “I've been getting into cooking lately. What about you?”",
      "“That makes sense. I felt similar when…”",
    ],
    avoid: [
      "Rapid-fire questions.",
      "Never sharing anything about yourself.",
      "A “next question” tone.",
    ],
    tip: "Ask one, share one. Pass the conversation back and forth.",
  ),
  QuickHelpGuide(
    title: 'Show interest without overdoing it',
    subtitle: 'Listen, remember, respond naturally.',
    icon: Icons.hearing_rounded,
    situation: "You want the other person to feel heard without it feeling forced.",
    say: [
      "“Wait, how did that turn out?”",
      "“How did your presentation go? You mentioned it last week.”",
      "“That sounds like it meant a lot to you.”",
    ],
    avoid: [
      "Over-the-top reactions.",
      "Interrupting to relate everything to yourself.",
      "Checking your phone while they talk.",
    ],
    tip: "Listen for one detail and ask about it later. Remembering small things beats big reactions.",
  ),
  QuickHelpGuide(
    title: 'Recover from an awkward moment',
    subtitle: 'After saying something strange or going blank.',
    icon: Icons.refresh_rounded,
    situation: "You said something odd, or you lost your train of thought.",
    say: [
      "“That came out wrong! What I meant was…”",
      "“Okay, let me start over.”",
      "“Ha, that was random. Anyway, how's your week going?”",
      "“Sorry, I lost my train of thought.”",
    ],
    avoid: [
      "Long apologies.",
      "Replaying the moment in your head mid-conversation.",
      "Leaving the conversation out of embarrassment.",
    ],
    tip: "People forget awkward moments much faster than you do. A light laugh and moving on works.",
  ),
];

class QuickHelpPage extends StatelessWidget {
  const QuickHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = (MediaQuery.of(context).size.width / 390).clamp(0.85, 1.15).toDouble();

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
      children: [
        const Text('QUICK HELP',
            style: TextStyle(color: _mint, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Text('Not sure what to\nsay next?',
            style: TextStyle(color: Colors.white, fontSize: 32 * s, height: 1.1, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        Text('A little help for the moments when conversations get awkward, quiet or difficult.',
            style: TextStyle(color: Colors.white.withOpacity(.75), fontSize: 14.5 * s, height: 1.4)),
        const SizedBox(height: 22),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quickHelpGuides.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 172,
          ),
          itemBuilder: (context, i) {
            final g = quickHelpGuides[i];
            return _GuideCard(
              guide: g,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => QuickHelpGuidePage(guide: g)),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _GuideCard extends StatelessWidget {
  final QuickHelpGuide guide;
  final VoidCallback onTap;
  const _GuideCard({required this.guide, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.10),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(.16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _mint.withOpacity(.14),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(guide.icon, color: _mint, size: 23),
              ),
              const Spacer(),
              Text(guide.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w800, height: 1.2)),
              const SizedBox(height: 4),
              Text(guide.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withOpacity(.65), fontSize: 11.5, height: 1.3)),
            ],
          ),
        ),
      ),
    );
  }
}

class QuickHelpGuidePage extends StatelessWidget {
  final QuickHelpGuide guide;
  const QuickHelpGuidePage({super.key, required this.guide});

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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: Colors.white,
          title: const Text('Quick Help', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _mint.withOpacity(.14),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(guide.icon, color: _mint, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(guide.title,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.15)),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              _label('THE SITUATION'),
              _panel(Text(guide.situation,
                  style: TextStyle(color: Colors.white.withOpacity(.88), fontSize: 15, height: 1.45))),

              const SizedBox(height: 20),
              _label('WHAT YOU CAN SAY  (tap to copy)'),
              ...guide.say.map((line) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: line));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied'), duration: Duration(seconds: 1)),
                          );
                        },
                        child: Ink(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _mint.withOpacity(.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _mint.withOpacity(.25)),
                          ),
                          child: Text(line,
                              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  )),

              const SizedBox(height: 10),
              _label('WHAT TO AVOID'),
              _panel(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: guide.avoid
                    .map((a) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.close_rounded, color: Color(0xFFFF9A8B), size: 19),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(a,
                                    style: TextStyle(color: Colors.white.withOpacity(.85), fontSize: 14.5, height: 1.4)),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              )),

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('LC TIP',
                        style: TextStyle(color: _mint, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    const SizedBox(height: 8),
                    Text(guide.tip,
                        style: const TextStyle(color: Colors.white, fontSize: 15.5, height: 1.45, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(t,
            style: const TextStyle(color: _mint, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
      );

  Widget _panel(Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.09),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(.12)),
        ),
        child: child,
      );
}

class EmeraldBackgroundPainter extends CustomPainter {
  const EmeraldBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {

    final rect = Offset.zero & size;

    // BASE EMERALD GRADIENT
    final backgroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF004B3B),
          Color(0xFF006747),
          Color(0xFF003F35),
          Color(0xFF002F2A),
        ],
        stops: [0.0, 0.35, 0.72, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, backgroundPaint);

    // TOP GREEN LIGHT GLOW
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.9, -0.5),
        radius: 1.0,
        colors: [
          const Color(0xFF00D878).withOpacity(0.35),
          const Color(0xFF00B76A).withOpacity(0.12),
          Colors.transparent,
        ],
      ).createShader(rect);

    canvas.drawRect(rect, glowPaint);

    // DRAW FLOWING RIBBONS
    _drawRibbon(
      canvas,
      size,
      [
        Offset(size.width * 0.65, -size.height * 0.05),
        Offset(size.width * 0.05, size.height * 0.15),
        Offset(size.width * 0.05, size.height * 0.40),
        Offset(-size.width * 0.2, size.height * 0.55),
      ],
      [
        Offset(size.width * 1.2, size.height * 0.02),
        Offset(size.width * 0.8, size.height * 0.35),
        Offset(size.width * 0.65, size.height * 0.50),
        Offset(size.width * 1.1, size.height * 0.62),
      ],
      const Color(0xFF00E878).withOpacity(0.18),
      const Color(0xFF00A95E).withOpacity(0.02),
    );

    _drawRibbon(
      canvas,
      size,
      [
        Offset(-size.width * 0.2, size.height * 0.38),
        Offset(size.width * 0.3, size.height * 0.25),
        Offset(size.width * 0.65, size.height * 0.65),
        Offset(size.width * 1.2, size.height * 0.42),
      ],
      [
        Offset(size.width * 1.2, size.height * 0.55),
        Offset(size.width * 0.8, size.height * 0.78),
        Offset(size.width * 0.35, size.height * 0.75),
        Offset(-size.width * 0.2, size.height * 0.90),
      ],
      const Color(0xFF00E87B).withOpacity(0.20),
      const Color(0xFF008D57).withOpacity(0.015),
    );

    _drawRibbon(
      canvas,
      size,
      [
        Offset(size.width * 1.15, size.height * 0.58),
        Offset(size.width * 0.7, size.height * 0.75),
        Offset(size.width * 0.55, size.height * 0.88),
        Offset(size.width * 0.05, size.height * 1.05),
      ],
      [
        Offset(size.width * 1.15, size.height * 0.82),
        Offset(size.width * 0.7, size.height * 1.0),
        Offset(size.width * 0.3, size.height * 1.0),
        Offset(-size.width * 0.1, size.height * 1.05),
      ],
      const Color(0xFF00F18A).withOpacity(0.17),
      const Color(0xFF006A4A).withOpacity(0.02),
    );

    // ADD DARK TRANSLUCENT GLASS WAVES
    final darkWave = Path()
      ..moveTo(0, size.height * 0.82)
      ..cubicTo(
        size.width * 0.30,
        size.height * 0.90,
        size.width * 0.55,
        size.height * 0.72,
        size.width,
        size.height * 0.80,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      darkWave,
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF001F27).withOpacity(0.10),
            const Color(0xFF001D27).withOpacity(0.55),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect),
    );

    // NEON LIGHT STREAKS
    _drawLightStreak(
      canvas,
      size,
      [
        Offset(-size.width * 0.1, size.height * 0.30),
        Offset(size.width * 0.25, size.height * 0.18),
        Offset(size.width * 0.65, size.height * 0.05),
        Offset(size.width * 1.05, -size.height * 0.05),
      ],
    );

    _drawLightStreak(
      canvas,
      size,
      [
        Offset(-size.width * 0.05, size.height * 1.0),
        Offset(size.width * 0.45, size.height * 0.92),
        Offset(size.width * 0.65, size.height * 0.82),
        Offset(size.width * 1.05, size.height * 0.73),
      ],
    );

    _drawLightStreak(
      canvas,
      size,
      [
        Offset(size.width * 0.15, size.height * 0.55),
        Offset(size.width * 0.5, size.height * 0.52),
        Offset(size.width * 0.75, size.height * 0.48),
        Offset(size.width * 1.05, size.height * 0.34),
      ],
    );

    // GLOWING PARTICLES
    final particles = <Offset>[
      Offset(size.width * 0.08, size.height * 0.18),
      Offset(size.width * 0.92, size.height * 0.23),
      Offset(size.width * 0.12, size.height * 0.43),
      Offset(size.width * 0.82, size.height * 0.52),
      Offset(size.width * 0.25, size.height * 0.72),
      Offset(size.width * 0.92, size.height * 0.79),
      Offset(size.width * 0.16, size.height * 0.91),
      Offset(size.width * 0.70, size.height * 0.94),
      Offset(size.width * 0.55, size.height * 0.35),
      Offset(size.width * 0.40, size.height * 0.57),
    ];

    for (final particle in particles) {
      canvas.drawCircle(
        particle,
        7,
        Paint()
          ..color = const Color(0xFF00FF8C).withOpacity(0.15)
          ..maskFilter = const MaskFilter.blur(
            BlurStyle.normal,
            9,
          ),
      );

      canvas.drawCircle(
        particle,
        2,
        Paint()
          ..color = const Color(0xFF42FFA1).withOpacity(0.9),
      );
    }
  }

  void _drawRibbon(
    Canvas canvas,
    Size size,
    List<Offset> top,
    List<Offset> bottom,
    Color startColor,
    Color endColor,
  ) {
    final path = Path()
      ..moveTo(top[0].dx, top[0].dy)
      ..cubicTo(
        top[1].dx, top[1].dy,
        top[2].dx, top[2].dy,
        top[3].dx, top[3].dy,
      )
      ..lineTo(bottom[0].dx, bottom[0].dy)
      ..cubicTo(
        bottom[1].dx, bottom[1].dy,
        bottom[2].dx, bottom[2].dy,
        bottom[3].dx, bottom[3].dy,
      )
      ..close();

    final rect = Offset.zero & size;

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ).createShader(rect),
    );
  }

  void _drawLightStreak(
    Canvas canvas,
    Size size,
    List<Offset> points,
  ) {
    final path = Path()
      ..moveTo(points[0].dx, points[0].dy)
      ..cubicTo(
        points[1].dx, points[1].dy,
        points[2].dx, points[2].dy,
        points[3].dx, points[3].dy,
      );

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF00FF91).withOpacity(0.20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          12,
        ),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF4DFFAE).withOpacity(0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}


