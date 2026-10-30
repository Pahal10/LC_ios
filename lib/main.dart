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
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    checkLogin();
}

  Future<void> checkLogin() async {

    await Future.delayed(
      const Duration(seconds: 3),
    );

    final prefs =
    await SharedPreferences.getInstance();

    final loggedIn =
        prefs.getBool("loggedIn") ?? false;

    if (!mounted) return;

    if (loggedIn) {

      Session.username =
          prefs.getString("username") ?? "";

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainPage(),
        ),
      );

    } else {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFF24B65E),

      body: Center(

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            /// IMAGE
            Image.asset(
              "asset/splashimg.jpg",
              height: 250,
            ),

            const SizedBox(height: 40),

            /// LOADING CIRCLE
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
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

  Future<void> completeTask() async {

    showDialog(
      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Were you comfortable doing it?",
          ),

          actions: [

            /// NO
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await handleRewardFlow();
              },
              child: const Text("No"),
            ),

            /// SOMEWHAT
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await increaseProgress(1);
				await ReviewService.registerComfortableTask();
                await handleRewardFlow();
              },

              child: const Text("Somewhat"),
            ),

            /// YES
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await increaseProgress(2);
                await ReviewService.registerComfortableTask();
                await handleRewardFlow();

              },

              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
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

  final List<Map<String, dynamic>> pages = [
    {
      "title": "Next task",
      "button": "Let's connect",
      "icon": Icons.people_alt_rounded,
    },
    {
      "title": "UCLA loneliness\nscore test",
      "icon": Icons.psychology_rounded,
      "link": "https://uclalonelinessscore.lovable.app",
    },
  ];


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
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 28),
            const CircleAvatar(radius: 38, backgroundImage: AssetImage('asset/LCicon.png')),
            const SizedBox(height: 14),
            Text('Hello, ${Session.username}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 22),
              child: Text('Your account, preferences and support options are now grouped in Profile.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline_rounded, color: lcForest),
              title: const Text('Open Profile & Settings'),
              onTap: () {
                Navigator.pop(context);
                controller.animateToPage(3, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
              },
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(18),
              child: Text('LC • Let’s Connect', style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabTitles = ['Task Page', 'Friends', 'Exercises', 'Profile'];
    return Scaffold(
      key: _scaffoldKey,
      drawer: buildDrawer(),
      backgroundColor: const Color(0xFF0D482B),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF176B3A),
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 19,
              backgroundImage: AssetImage('asset/LCicon.png'),
            ),
            const SizedBox(width: 12),
            Text(
              tabTitles[currentPage],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Open menu',
            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PageView(
        controller: controller,
        onPageChanged: (index) => setState(() => currentPage = index),
        children: [
          _TaskHomeTab(
            onStart: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TaskPage()),
            ),
          ),
          _ConnectionsTab(
            onNewConnection: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TaskPage(forcedStage: 'smalltalk')),
            ),
            onExistingConnection: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StageSelectionPage()),
            ),
          ),
          const ExercisesPage(),
          _ProfileTab(
            username: Session.username,
            onLonelinessTest: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UCLAPage()),
            ),
            onAccountSettings: showAccountSettingsDialog,
            onReason: showReasonDialog,
            onPromoCode: () => showPromoCodeDialog(context),
            onContact: showContactDialog,
            onLocation: () async {
              try {
                await updateCurrentLocation();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location updated successfully.')));
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            onRate: () => ReviewService.openStoreListing(),
            onDelete: deleteAccount,
            onLogout: showLogoutDialog,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 4, 14, 12),
        child: _GlassBottomNavigation(
          currentIndex: currentPage,
          onSelected: (index) => controller.animateToPage(
            index,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );
  }
}


// -----------------------------------------------------------------------------
// LC HOME TABS + GLASS NAVIGATION
// -----------------------------------------------------------------------------
const Color lcGreen = Color(0xFF24B65E);
const Color lcDeepGreen = Color(0xFF0D482B);
const Color lcForest = Color(0xFF176B3A);
const Color lcPaleGreen = Color(0xFFE5F6EB);

class _GlassBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelected;
  const _GlassBottomNavigation({required this.currentIndex, required this.onSelected});

  static const items = [
    (Icons.task_alt_rounded, 'Task'),
    (Icons.people_alt_rounded, 'Friends'),
    (Icons.psychology_alt_rounded, 'Exercise'),
    (Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(36),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 76,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFF174D32).withOpacity(.82),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: Colors.white.withOpacity(.22), width: 1),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.24), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final selected = currentIndex == index;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Material(
                    color: selected ? Colors.white.withOpacity(.16) : Colors.transparent,
                    borderRadius: BorderRadius.circular(29),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(29),
                      onTap: () => onSelected(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(29),
                          border: selected ? Border.all(color: Colors.white.withOpacity(.13)) : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(items[index].$1, size: 23, color: selected ? const Color(0xFF75E5A0) : Colors.white),
                            const SizedBox(height: 3),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(items[index].$2, style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: selected ? FontWeight.w800 : FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _HomeBackground extends StatelessWidget {
  final Widget child;
  const _HomeBackground({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF176B3A), Color(0xFF0D482B), Color(0xFF092F20)])),
    child: SafeArea(child: child),
  );
}

class _TaskHomeTab extends StatelessWidget {
  final VoidCallback onStart;
  const _TaskHomeTab({required this.onStart});
  @override
  Widget build(BuildContext context) => _HomeBackground(
    child: ListView(padding: const EdgeInsets.fromLTRB(22, 28, 22, 30), children: [
      const Text('Small steps.\nReal connections.', style: TextStyle(color: Colors.white, fontSize: 32, height: 1.08, fontWeight: FontWeight.w900)),
      const SizedBox(height: 12),
      Text('Your next step towards building meaningful friendships.', style: TextStyle(color: Colors.white.withOpacity(.78), fontSize: 16, height: 1.4)),
      const SizedBox(height: 28),
      _FeaturePanel(icon: Icons.chat_bubble_outline_rounded, eyebrow: 'YOUR NEXT STEP', title: 'Ready to connect?', description: 'Get a practical social challenge and take it into the real world.', buttonText: 'View my task', onTap: onStart),
      const SizedBox(height: 18),
      const _TipCard(title: 'A little reminder', body: 'You do not need to be fascinating. Be curious, listen, and share a little about yourself too.'),
    ]),
  );
}

class _ConnectionsTab extends StatelessWidget {
  final VoidCallback onNewConnection;
  final VoidCallback onExistingConnection;
  const _ConnectionsTab({required this.onNewConnection, required this.onExistingConnection});
  @override
  Widget build(BuildContext context) => _HomeBackground(
    child: ListView(padding: const EdgeInsets.fromLTRB(22, 28, 22, 30), children: [
      const Text('Your connections', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      Text('Choose whether you are meeting someone new or growing a relationship you already have.', style: TextStyle(color: Colors.white.withOpacity(.78), fontSize: 15, height: 1.4)),
      const SizedBox(height: 25),
      _FeaturePanel(icon: Icons.person_add_alt_1_rounded, eyebrow: 'START SOMETHING NEW', title: 'A new connection', description: 'Get help starting a conversation and finding a natural way to keep it going.', buttonText: 'Meet someone new', onTap: onNewConnection),
      const SizedBox(height: 16),
      _FeaturePanel(icon: Icons.people_alt_rounded, eyebrow: 'KEEP BUILDING', title: 'An existing connection', description: 'Work on familiarity, shared interests, follow-ups and spending time together.', buttonText: 'Build a friendship', onTap: onExistingConnection),
      const SizedBox(height: 18),
      const _TipCard(title: 'A note about friendships', body: 'A connection grows through repeated, mutual interactions. You do not have to rush intimacy or force every conversation to become deep.'),
    ]),
  );
}

class _ProfileTab extends StatelessWidget {
  final String username;
  final VoidCallback onLonelinessTest, onAccountSettings, onReason, onPromoCode, onContact, onLocation, onRate, onDelete, onLogout;
  const _ProfileTab({required this.username, required this.onLonelinessTest, required this.onAccountSettings, required this.onReason, required this.onPromoCode, required this.onContact, required this.onLocation, required this.onRate, required this.onDelete, required this.onLogout});
  @override
  Widget build(BuildContext context) => _HomeBackground(
    child: ListView(padding: const EdgeInsets.fromLTRB(22, 28, 22, 30), children: [
      const Text('Your profile', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
      const SizedBox(height: 20),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(.16))), child: Row(children: [const CircleAvatar(radius: 30, backgroundColor: lcPaleGreen, child: Icon(Icons.person_rounded, color: lcForest, size: 32)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('SIGNED IN AS', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)), const SizedBox(height: 4), Text(username, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800))]))])),
      const SizedBox(height: 22),
      _ProfileAction(icon: Icons.insights_rounded, title: 'UCLA Loneliness Scale', subtitle: 'Reflect on how connected you feel', onTap: onLonelinessTest),
      _ProfileAction(icon: Icons.manage_accounts_rounded, title: 'Account settings', subtitle: 'Change your username or password', onTap: onAccountSettings),
      _ProfileAction(icon: Icons.tune_rounded, title: 'Change my reason', subtitle: 'Update what you would like help with', onTap: onReason),
      _ProfileAction(icon: Icons.card_giftcard_rounded, title: 'My promo code', subtitle: 'Share LC with someone', onTap: onPromoCode),
      _ProfileAction(icon: Icons.mail_outline_rounded, title: 'Contact LC', subtitle: 'Questions, feedback or support', onTap: onContact),
      _ProfileAction(icon: Icons.location_on_outlined, title: 'Update location', subtitle: 'Only needed for reward verification', onTap: onLocation),
      _ProfileAction(icon: Icons.star_rate_rounded, title: 'Rate LC', subtitle: 'Leave a review in the app store', onTap: onRate),
      const SizedBox(height: 8),
      TextButton.icon(onPressed: onDelete, icon: const Icon(Icons.delete_forever, color: Colors.redAccent), label: const Text('Delete account', style: TextStyle(color: Colors.redAccent))),
      const SizedBox(height: 4),
      TextButton.icon(onPressed: onLogout, icon: const Icon(Icons.logout_rounded, color: Colors.white70), label: const Text('Log out', style: TextStyle(color: Colors.white70))),
    ]),
  );
}

class _FeaturePanel extends StatelessWidget {
  final IconData icon; final String eyebrow, title, description, buttonText; final VoidCallback onTap;
  const _FeaturePanel({required this.icon, required this.eyebrow, required this.title, required this.description, required this.buttonText, required this.onTap});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2C9858), Color(0xFF176B3A)]), borderRadius: BorderRadius.circular(26), border: Border.all(color: Colors.white.withOpacity(.2)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.15), blurRadius: 20, offset: const Offset(0, 9))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: const Color(0xFFB8F4CE), size: 32), const SizedBox(height: 20), Text(eyebrow, style: const TextStyle(color: Color(0xFFB8F4CE), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)), const SizedBox(height: 6), Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text(description, style: TextStyle(color: Colors.white.withOpacity(.84), fontSize: 14, height: 1.4)), const SizedBox(height: 20), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: lcForest, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.w800))))]),
  );
}

class _TipCard extends StatelessWidget {
  final String title, body;
  const _TipCard({required this.title, required this.body});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white.withOpacity(.09), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(.12))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)), const SizedBox(height: 7), Text(body, style: TextStyle(color: Colors.white.withOpacity(.76), height: 1.45))]));
}

class _ProfileAction extends StatelessWidget {
  final IconData icon; final String title, subtitle; final VoidCallback onTap;
  const _ProfileAction({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: Colors.white.withOpacity(.10), borderRadius: BorderRadius.circular(17), border: Border.all(color: Colors.white.withOpacity(.12))), child: ListTile(onTap: onTap, leading: Icon(icon, color: const Color(0xFFB8F4CE), size: 25), title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)), subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(.67), fontSize: 12)), trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white70)));
}

// -----------------------------------------------------------------------------
// 50 CONVERSATION EXERCISES
// -----------------------------------------------------------------------------
class LCExercise {
  final int id; final String category, title, scenario, question;
  final List<String> options; final int bestAnswer; final String explanation;
  const LCExercise({required this.id, required this.category, required this.title, required this.scenario, required this.question, required this.options, required this.bestAnswer, required this.explanation});
}

const List<LCExercise> lcExercises = [
  LCExercise(id:1,category:'Starting',title:'The seat beside you',scenario:'Someone sits next to you before a lecture. You have never spoken before.',question:'What is a natural way to begin?',options:['“Why are you sitting here?”', '“Have you had this professor before?”', 'Immediately ask where they live.', 'Stay silent because they should speak first.'],bestAnswer:1,explanation:'A shared, low-pressure situation is an easy opening. It gives the other person room to respond without demanding personal information.'),
  LCExercise(id:2,category:'Starting',title:'Waiting in line',scenario:'You are waiting for coffee and the person beside you comments that the line is long.',question:'How could you respond?',options:['“Yeah, it moves slowly around this time. Have you tried the coffee here before?”', '“I hate this place.”', 'Ignore them and look at your phone.', 'Ask for their phone number.'],bestAnswer:0,explanation:'Acknowledge their comment, then add a related, easy question. You are building on what they offered.'),
  LCExercise(id:3,category:'Starting',title:'A familiar face',scenario:'You recognize someone from class but have never introduced yourself.',question:'What is a comfortable opener?',options:['“I know everything about you from class.”', '“We should be friends.”', 'Ask a very personal question.', '“Hey, I think we have the same lecture. I’m ___. What’s your name?”'],bestAnswer:3,explanation:'Introduce yourself and use the shared context. Keep the first interaction light.'),
  LCExercise(id:4,category:'Starting',title:'Joining a study table',scenario:'A few classmates are studying in a common area. There is an open seat.',question:'What is a respectful way to join?',options:['Sit down and take someone’s materials.', 'Interrupt with an unrelated story.', '“Hey, is anyone using this seat? I’m working on the same assignment.”', 'Assume they do not want company.'],bestAnswer:2,explanation:'Ask permission and establish common ground. Watch whether the group seems open to conversation.'),
  LCExercise(id:5,category:'Starting',title:'At a club meeting',scenario:'You arrive at a club meeting and do not know anyone.',question:'What could you ask another attendee?',options:['“Who here is the most popular?”', '“Is this your first meeting too, or have you been coming for a while?”', '“Can you introduce me to everyone?”', '“This club looks boring.”'],bestAnswer:1,explanation:'A question about the shared event makes it easy for someone to include you in the conversation.'),
  LCExercise(id:6,category:'Starting',title:'A genuine compliment',scenario:'Someone has a book you have read and enjoyed.',question:'Which opener is most natural?',options:['“I read that recently and really liked it. What do you think of it so far?”', '“You look intelligent because of that book.”', '“Give me the book.”', '“That is my favourite book, so we must be alike.”'],bestAnswer:0,explanation:'A specific, genuine observation plus an open invitation works better than a judgment about the person.'),
  LCExercise(id:7,category:'Starting',title:'The elevator moment',scenario:'You are in an elevator with a neighbour you have seen several times.',question:'What is a reasonable first step?',options:['Ask why they never talk to you.', 'Start a long personal conversation immediately.', 'Pretend you do not recognize them.', 'Smile, say hello, and perhaps ask how their day is going.'],bestAnswer:3,explanation:'Repeated brief greetings build familiarity. You do not need to turn every encounter into a long conversation.'),
  LCExercise(id:8,category:'Starting',title:'Before a group activity',scenario:'You are paired with someone for a short class activity.',question:'How do you start collaboratively?',options:['“I’ll do everything myself.”', '“You seem like you don’t understand this.”', '“Want to quickly compare how we’re approaching this?”', 'Wait for the activity to end.'],bestAnswer:2,explanation:'A shared task gives you a natural reason to speak and creates an easy starting point.'),
  LCExercise(id:9,category:'Starting',title:'A new roommate',scenario:'You and your roommate have exchanged only basic greetings.',question:'What is a friendly invitation?',options:['“We need to become best friends.”', '“I’m heading to grab food. Want to come along?”', '“Why are you always in your room?”', 'Demand that they share their schedule.'],bestAnswer:1,explanation:'A low-pressure invitation creates an opportunity to spend time together while making it easy to decline.'),
  LCExercise(id:10,category:'Starting',title:'The event introduction',scenario:'You attend a campus event and stand near someone looking at the same display.',question:'What could you say?',options:['“What brought you to this event?”', '“Tell me your biggest secret.”', '“Do you know everyone here?”', '“You should talk to me.”'],bestAnswer:0,explanation:'Ask about their reason for attending. It is relevant, open-ended and not overly personal.'),
  LCExercise(id:11,category:'Keeping it going',title:'The difficult assignment',scenario:'You ask how someone is finding class. They say, “The assignments are pretty difficult.”',question:'What is a helpful follow-up?',options:['“Yeah.”', '“You should study harder.”', 'Immediately change to an unrelated topic.', '“Which part has been the most challenging?”'],bestAnswer:3,explanation:'Follow the thread they introduced. A relevant follow-up shows you listened and gives them room to elaborate.'),
  LCExercise(id:12,category:'Keeping it going',title:'One-word answer',scenario:'You ask, “How was your weekend?” They answer, “Good.”',question:'What is a reasonable next move?',options:['Ask the exact same question again.', 'Fire five questions at them.', 'Offer a small detail about your weekend and see if they engage.', 'Tell them they are boring.'],bestAnswer:2,explanation:'A brief answer may mean many things. Share something small, then see whether they reciprocate instead of interrogating them.'),
  LCExercise(id:13,category:'Keeping it going',title:'The unexpected hobby',scenario:'They mention they have started learning guitar.',question:'What follow-up could keep the topic alive?',options:['“I don’t like guitar.”', '“What made you want to learn guitar?”', '“Can you play a full concert now?”', 'Switch topics immediately.'],bestAnswer:1,explanation:'Ask about the story or motivation behind their interest, rather than testing their skill.'),
  LCExercise(id:14,category:'Keeping it going',title:'They mention travel',scenario:'They say they visited Japan over the summer.',question:'Which response invites a story?',options:['“What was one moment from the trip that really stuck with you?”', '“Japan is far away.”', '“I have been to more countries.”', '“How much did everything cost?”'],bestAnswer:0,explanation:'Inviting a memorable moment encourages a personal story and can reveal what they enjoyed.'),
  LCExercise(id:15,category:'Keeping it going',title:'Avoiding an interview',scenario:'You have asked three questions in a row and they have answered each one.',question:'What should you try next?',options:['Ask ten more questions.', 'Stop listening.', 'Ask whether they like being interviewed.', 'Share a related experience or opinion of your own.'],bestAnswer:3,explanation:'Good conversations involve both curiosity and self-disclosure. Offer something about yourself so the exchange feels balanced.'),
  LCExercise(id:16,category:'Keeping it going',title:'A shared complaint',scenario:'You both mention that the campus shuttle is often late.',question:'How can you extend the moment?',options:['“Everything here is terrible.”', '“You should complain to the dean.”', '“It always seems busiest after class. Do you usually take this route?”', 'Say nothing else.'],bestAnswer:2,explanation:'Build from the shared observation into a relevant question. Keep the tone light rather than escalating negativity.'),
  LCExercise(id:17,category:'Keeping it going',title:'They seem excited',scenario:'They tell you they got accepted into a research program.',question:'What response shows interest?',options:['“Lucky you.”', '“That’s exciting! What will you be working on?”', '“I got something better.”', 'Change the topic to your grades.'],bestAnswer:1,explanation:'Celebrate their news and invite them to share more. Avoid turning their moment into a comparison.'),
  LCExercise(id:18,category:'Keeping it going',title:'A pause in conversation',scenario:'You finish discussing an assignment and there is a short silence.',question:'What is a healthy interpretation?',options:['A pause is normal; you can let it breathe or introduce a related topic.', 'The conversation has failed.', 'You must say something immediately.', 'The other person dislikes you.'],bestAnswer:0,explanation:'Silence is not automatically awkward. Comfortable conversations have pauses; do not treat every gap as an emergency.'),
  LCExercise(id:19,category:'Keeping it going',title:'Remembering a detail',scenario:'Last time, they mentioned an upcoming presentation. You meet again.',question:'What is a thoughtful opener?',options:['“I forgot everything you told me.”', '“Did you get the highest grade?”', 'Ask a completely unrelated personal question.', '“How did your presentation go?”'],bestAnswer:3,explanation:'Remembering a detail communicates attention and creates continuity between interactions.'),
  LCExercise(id:20,category:'Keeping it going',title:'They ask you back',scenario:'They answer your question and ask, “What about you?”',question:'What should you do?',options:['Say “nothing” every time.', 'Give a 20-minute monologue.', 'Answer with a little detail, then leave room for them to respond.', 'Ignore their question.'],bestAnswer:2,explanation:'Reciprocity matters. Give a real answer at a comfortable level of detail, then let the conversation flow.'),
  LCExercise(id:21,category:'Common ground',title:'Different interests',scenario:'They love football, while you are more interested in films.',question:'How can you find a bridge?',options:['Pretend to know every player.', 'Ask what they enjoy about following a team or sport.', 'Tell them their interest is pointless.', 'End the conversation.'],bestAnswer:1,explanation:'You do not need identical hobbies. Curiosity about why something matters to them can create connection.'),
  LCExercise(id:22,category:'Common ground',title:'Same hometown',scenario:'You discover you grew up in the same city.',question:'What could you explore together?',options:['“What part of the city did you spend most of your time in?”', '“You must know all my friends.”', '“My neighbourhood is better.”', 'Ask for their home address.'],bestAnswer:0,explanation:'A shared place can open up memories and experiences without assuming your lives were identical.'),
  LCExercise(id:23,category:'Common ground',title:'A shared class',scenario:'You both find a particular course challenging.',question:'What is a natural next step?',options:['Demand that they tutor you.', 'Complain about the professor for the whole conversation.', 'Assume you are now close friends.', 'Suggest comparing notes or studying together sometime.'],bestAnswer:3,explanation:'A shared challenge can become a low-pressure activity. Make an invitation, not an obligation.'),
  LCExercise(id:24,category:'Common ground',title:'Discovering a shared interest',scenario:'They mention enjoying photography, something you also like.',question:'What could you say?',options:['“I am probably better than you.”', '“We have exactly the same personality.”', '“I enjoy taking photos too. What do you usually like photographing?”', 'Ask them to send you all their photos.'],bestAnswer:2,explanation:'Name the overlap, then invite them to share their version of the interest.'),
  LCExercise(id:25,category:'Common ground',title:'Different opinions',scenario:'You disagree about a movie they loved.',question:'How can you stay connected?',options:['“Your opinion is wrong.”', '“Interesting, what did you like most about it? I think I reacted differently to the ending.”', 'Pretend to agree with everything.', 'Make fun of their taste.'],bestAnswer:1,explanation:'You can disagree while staying curious and respectful. Connection does not require identical opinions.'),
  LCExercise(id:26,category:'Common ground',title:'A shared routine',scenario:'You learn that you both study in the same library most afternoons.',question:'What might create a recurring connection?',options:['“Maybe we can study near each other sometime.”', '“I will track when you are here.”', '“We should spend every day together.”', 'Say you will never study there again.'],bestAnswer:0,explanation:'A small recurring routine can create familiarity without forcing a commitment.'),
  LCExercise(id:27,category:'Common ground',title:'The food conversation',scenario:'They mention a restaurant you have wanted to try.',question:'What could you do?',options:['Ask them to pay for your meal.', 'Say their taste is bad.', 'Immediately invite yourself to their home.', 'Ask what they recommend and whether they would go again.'],bestAnswer:3,explanation:'Recommendations are an easy way to exchange preferences and may naturally lead to a shared outing.'),
  LCExercise(id:28,category:'Common ground',title:'Finding a shared goal',scenario:'They mention wanting to get better at running. You are also trying to exercise more.',question:'What response opens a possibility?',options:['“You need to run every day.”', '“I am much fitter than you.”', '“I’m trying to build that habit too. Have you found a route you like?”', 'Tell them goals are pointless.'],bestAnswer:2,explanation:'Shared goals can create encouragement and shared activities. Keep the invitation collaborative.'),
  LCExercise(id:29,category:'Common ground',title:'A surprising overlap',scenario:'They mention volunteering at a local organization, which you have considered.',question:'What should you ask?',options:['“Can you guarantee I will like it?”', '“What has the experience been like for you?”', '“How prestigious is it?”', 'Change the subject because you are inexperienced.'],bestAnswer:1,explanation:'Ask about their lived experience. You can learn while showing genuine interest.'),
  LCExercise(id:30,category:'Common ground',title:'Turning overlap into a plan',scenario:'You both enjoy board games and have talked about it a few times.',question:'What is a natural invitation?',options:['“A few of us are playing this weekend. Would you like to join?”', '“You have to come to my house tonight.”', '“If you do not come, I will be upset.”', 'Wait for them to guess you want to meet.'],bestAnswer:0,explanation:'Make a specific, low-pressure invitation and give them room to say no.'),
  LCExercise(id:31,category:'Deeper connection',title:'A meaningful turning point',scenario:'You have been chatting comfortably and they mention changing majors.',question:'What could you ask?',options:['“Was that a stupid decision?”', '“How much money will you earn?”', 'Ask for their most painful memory.', '“What led you to make that change?”'],bestAnswer:3,explanation:'Ask about the meaning behind a choice, while allowing them to decide how much to share.'),
  LCExercise(id:32,category:'Deeper connection',title:'A personal win',scenario:'They mention being proud of something they accomplished.',question:'How can you invite more?',options:['“That is not a big deal.”', '“I have done more.”', '“What made that achievement especially meaningful to you?”', 'Ask whether they got an award.'],bestAnswer:2,explanation:'A question about meaning often leads to a richer conversation than asking only about the result.'),
  LCExercise(id:33,category:'Deeper connection',title:'A difficult week',scenario:'A friend says they have had a stressful week.',question:'What is a supportive response?',options:['“Other people have it worse.”', '“That sounds like a lot. Do you want to talk about what happened?”', '“Just stop being stressed.”', 'Immediately tell them what they must do.'],bestAnswer:1,explanation:'Acknowledge the feeling and ask permission before going deeper. They may want support, advice, or simply a change of topic.'),
  LCExercise(id:34,category:'Deeper connection',title:'Sharing your own story',scenario:'They share that they were nervous on their first day at university.',question:'How can you relate without taking over?',options:['“I felt something similar on my first day. I remember…” then return the focus to them.', 'Tell a much longer story and never return to theirs.', 'Say they should not have been nervous.', 'Compare who had the worse first day.'],bestAnswer:0,explanation:'Brief self-disclosure can create closeness when it connects to their experience rather than replacing it.'),
  LCExercise(id:35,category:'Deeper connection',title:'Respecting a boundary',scenario:'You ask about their family and they say they would rather not discuss it.',question:'What is the best response?',options:['Ask why they are hiding it.', 'Keep asking in different ways.', 'Tell them they are being rude.', '“Of course, no worries. We can talk about something else.”'],bestAnswer:3,explanation:'Respecting boundaries is essential to trust. Let the person choose what they want to share.'),
  LCExercise(id:36,category:'Deeper connection',title:'A values question',scenario:'You have known each other for a while and are discussing future plans.',question:'Which question invites reflection without pressure?',options:['“What is your deepest secret?”', '“Why have you not achieved more?”', '“What is something you would really like to make time for in the next few years?”', '“What is your exact five-year plan?”'],bestAnswer:2,explanation:'Open, nonjudgmental questions can invite reflection while leaving the other person control over the depth.'),
  LCExercise(id:37,category:'Deeper connection',title:'Responding to vulnerability',scenario:'They tell you they sometimes feel out of place at university.',question:'What response is most helpful?',options:['“Everyone feels that, get over it.”', '“I’m glad you told me. What has been making it feel that way?”', 'Immediately tell them they need more friends.', 'Change the topic without acknowledging it.'],bestAnswer:1,explanation:'Acknowledge the trust they showed and invite them to say more, without minimizing or trying to fix everything.'),
  LCExercise(id:38,category:'Deeper connection',title:'A moment of disagreement',scenario:'A friend shares a belief you do not agree with.',question:'How can you explore it respectfully?',options:['“I see it differently, but I’m interested in how you arrived at that view.”', '“Only an idiot thinks that.”', 'Pretend to agree to avoid discomfort.', 'Make the conversation a competition.'],bestAnswer:0,explanation:'Respectful curiosity allows disagreement without attacking the person.'),
  LCExercise(id:39,category:'Deeper connection',title:'Checking in',scenario:'A friend mentioned an important interview happening today.',question:'What follow-up message feels thoughtful?',options:['“Did you get the job? Answer now.”', '“You probably failed.”', 'Send repeated messages until they reply.', '“Hey, how did the interview go? I remembered you had it today.”'],bestAnswer:3,explanation:'A simple, specific check-in shows that you remembered. Give them time to respond.'),
  LCExercise(id:40,category:'Deeper connection',title:'Ending a deep conversation',scenario:'You have had a meaningful conversation but need to leave.',question:'How can you close warmly?',options:['Walk away mid-sentence.', 'Promise to meet tomorrow even if you cannot.', '“I really appreciated talking about that. I need to head out, but I’d like to continue another time.”', 'Apologize repeatedly for having to leave.'],bestAnswer:2,explanation:'A clear, warm ending respects both people and signals that the conversation mattered.'),
  LCExercise(id:41,category:'Friendship',title:'Following up after meeting',scenario:'You had a good conversation at a club event and exchanged contact details.',question:'What is a good follow-up?',options:['Send ten messages in a row.', '“Hey, it was nice talking with you at the meeting. Hope the rest of your week goes well!”', 'Wait for them to message first as a test.', 'Immediately ask for a major favour.'],bestAnswer:1,explanation:'A short message that refers to where you met makes the follow-up recognizable and low-pressure.'),
  LCExercise(id:42,category:'Friendship',title:'Making a specific plan',scenario:'You have both said you should hang out sometime.',question:'What makes the invitation actionable?',options:['“Would you like to grab lunch after class on Thursday?”', '“We should do something one day.”', '“You owe me a hangout.”', '“Tell me your entire schedule.”'],bestAnswer:0,explanation:'A concrete suggestion makes it easier to accept, decline or offer another time.'),
  LCExercise(id:43,category:'Friendship',title:'They decline an invitation',scenario:'You invite someone for coffee and they say they are busy.',question:'How should you respond?',options:['“You clearly do not like me.”', 'Keep pressuring them to explain.', 'Stop speaking to them forever.', '“No worries. Maybe another time!”'],bestAnswer:3,explanation:'A decline may simply mean they are unavailable. Respect it and look for mutual interest over time.'),
  LCExercise(id:44,category:'Friendship',title:'Maintaining a friendship',scenario:'You have not spoken to a friend in a few weeks.',question:'What is a simple way to reconnect?',options:['Accuse them of abandoning you.', 'Wait until you need something.', 'Send a genuine message referencing something you both discussed.', 'Pretend nothing happened and demand a reply.'],bestAnswer:2,explanation:'A specific, warm check-in is often easier to respond to than guilt or pressure.'),
  LCExercise(id:45,category:'Friendship',title:'Including someone',scenario:'You are planning a small group lunch and know someone who may enjoy joining.',question:'How can you invite them?',options:['Tell them they must come.', '“A few of us are getting lunch after class. You’re welcome to join if you’re free.”', 'Invite everyone except them and mention it later.', 'Say they probably would not fit in.'],bestAnswer:1,explanation:'An inclusive invitation communicates that they are welcome while preserving their choice.'),
  LCExercise(id:46,category:'Friendship',title:'Entering a group conversation',scenario:'Three classmates are discussing a show you have watched.',question:'How can you join naturally?',options:['Listen for a moment, then add a relevant thought or ask what episode they are discussing.', 'Interrupt and change the topic.', 'Stand silently and assume they will notice.', 'Talk louder than everyone else.'],bestAnswer:0,explanation:'Listen for context before contributing. A relevant comment helps you enter without taking over.'),
  LCExercise(id:47,category:'Friendship',title:'Reading the room',scenario:'Someone gives short replies, keeps looking away and says they need to finish something.',question:'What should you do?',options:['Keep asking questions until they engage.', 'Assume they secretly want you to persist.', 'Tell them they are unfriendly.', 'Respect the cue and wrap up politely.'],bestAnswer:3,explanation:'Several cues together may indicate they are unavailable. Give them space rather than treating persistence as a social skill.'),
  LCExercise(id:48,category:'Friendship',title:'Repairing a small misunderstanding',scenario:'You made a joke that seemed to upset a friend.',question:'What is a constructive response?',options:['Tell them they are too sensitive.', 'Pretend it did not happen.', '“I think that came across badly. I’m sorry. What I meant was…”', 'Make another joke about it.'],bestAnswer:2,explanation:'Acknowledge the impact, apologize sincerely and listen. You do not need to defend your intention first.'),
  LCExercise(id:49,category:'Friendship',title:'Balancing effort',scenario:'You have initiated the last several conversations and the other person rarely responds.',question:'What is a healthy next step?',options:['Keep messaging until they answer.', 'Give them space and see whether they reciprocate; invest in other connections too.', 'Conclude that you are unlikeable.', 'Use guilt to get a response.'],bestAnswer:1,explanation:'Friendship needs mutual effort. One-sided effort is not proof that something is wrong with you.'),
  LCExercise(id:50,category:'Friendship',title:'A friendship milestone',scenario:'You have studied together several times and feel comfortable around each other.',question:'What is a natural way to deepen the connection?',options:['Suggest doing something enjoyable outside the shared class or routine.', 'Demand that they call you their best friend.', 'Ask them to share every personal detail.', 'Stop making plans so they have to chase you.'],bestAnswer:0,explanation:'Shared experiences beyond the original context can help a friendship grow. Let closeness develop mutually and at its own pace.'),
];

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});
  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  String selectedCategory = 'All';
  final Set<int> completed = {};
  final Map<int, int> attempts = {};
  final Map<int, bool> mastered = {};
  static const categories = ['All', 'Starting', 'Keeping it going', 'Common ground', 'Deeper connection', 'Friendship'];

  @override
  Widget build(BuildContext context) {
    final filtered = lcExercises.where((e) => selectedCategory == 'All' || e.category == selectedCategory).toList();
    return _HomeBackground(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 22, 20, 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('The Conversation Gym', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text('Practice the skills that make conversations feel more natural.', style: TextStyle(color: Colors.white.withOpacity(.78), fontSize: 14, height: 1.35)),
        const SizedBox(height: 14),
        Row(children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: completed.length / lcExercises.length, minHeight: 8, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Color(0xFF75E5A0))))), const SizedBox(width: 10), Text('${completed.length}/50', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))]),
      ])),
      SizedBox(height: 48, child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 18), itemCount: categories.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (context, i) { final c = categories[i]; final active = selectedCategory == c; return ChoiceChip(label: Text(c), selected: active, onSelected: (_) => setState(() => selectedCategory = c), selectedColor: const Color(0xFFB8F4CE), backgroundColor: Colors.white.withOpacity(.12), labelStyle: TextStyle(color: active ? lcForest : Colors.white, fontWeight: FontWeight.w700), side: BorderSide(color: Colors.white.withOpacity(.18))); })),
      const SizedBox(height: 8),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final e = filtered[index];
            final done = completed.contains(e.id);
            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.11),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: done ? const Color(0xFF75E5A0) : Colors.white.withOpacity(.13)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                leading: CircleAvatar(
                  backgroundColor: done ? const Color(0xFFB8F4CE) : Colors.white.withOpacity(.16),
                  child: done ? const Icon(Icons.check_rounded, color: lcForest) : Text('${e.id}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: Text(e.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text(e.category, style: TextStyle(color: Colors.white.withOpacity(.68), fontSize: 12))),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white70),
                onTap: () => _openExercise(e),
              ),
            );
          },
        ),
      ),
    ]));
  }

  Future<void> _openExercise(LCExercise exercise) async {
    int? selected;
    bool checked = false;
    final result = await showModalBottomSheet<bool>(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (sheetContext) => StatefulBuilder(builder: (context, modalSetState) => DraggableScrollableSheet(initialChildSize: .84, minChildSize: .65, maxChildSize: .95, expand: false, builder: (_, scrollController) => Container(decoration: const BoxDecoration(color: Color(0xFFF6FBF7), borderRadius: BorderRadius.vertical(top: Radius.circular(28))), child: ListView(controller: scrollController, padding: const EdgeInsets.fromLTRB(22, 16, 22, 30), children: [Center(child: Container(width: 42, height: 5, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(5)))), const SizedBox(height: 22), Text('EXERCISE ${exercise.id} OF 50  •  ${exercise.category.toUpperCase()}', style: const TextStyle(color: lcForest, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: .7)), const SizedBox(height: 10), Text(exercise.title, style: const TextStyle(color: Color(0xFF17251D), fontSize: 27, fontWeight: FontWeight.w900)), const SizedBox(height: 16), Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: lcPaleGreen, borderRadius: BorderRadius.circular(18)), child: Text(exercise.scenario, style: const TextStyle(color: Color(0xFF244A32), fontSize: 15, height: 1.45))), const SizedBox(height: 22), Text(exercise.question, style: const TextStyle(color: Color(0xFF17251D), fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 12), ...List.generate(exercise.options.length, (i) { final chosen = selected == i; final correct = i == exercise.bestAnswer; return Padding(padding: const EdgeInsets.only(bottom: 9), child: InkWell(borderRadius: BorderRadius.circular(15), onTap: checked ? null : () => modalSetState(() => selected = i), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: checked && correct ? const Color(0xFFE0F5E7) : chosen ? const Color(0xFFEAF0EB) : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: checked && correct ? lcGreen : chosen ? lcForest : const Color(0xFFDCE5DE), width: chosen || (checked && correct) ? 1.7 : 1)), child: Row(children: [Expanded(child: Text('${String.fromCharCode(65+i)}.  ${exercise.options[i]}', style: const TextStyle(color: Color(0xFF25352B), height: 1.35, fontWeight: chosen ? FontWeight.w700 : FontWeight.w500))), if (checked && correct) const Icon(Icons.check_circle, color: lcForest), if (!checked && chosen) const Icon(Icons.radio_button_checked, color: lcForest)])))); }),
      if (checked) Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFFE5F6EB), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(selected == exercise.bestAnswer ? 'Good instinct' : 'A more useful approach', style: const TextStyle(color: lcForest, fontWeight: FontWeight.w900, fontSize: 16)), const SizedBox(height: 6), Text(exercise.explanation, style: const TextStyle(color: Color(0xFF35513D), height: 1.4))])),
      const SizedBox(height: 18),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: selected == null ? null : () { if (!checked) { modalSetState(() => checked = true); } else { Navigator.pop(sheetContext, selected == exercise.bestAnswer); } }, style: ElevatedButton.styleFrom(backgroundColor: lcForest, foregroundColor: Colors.white, disabledBackgroundColor: Colors.black12, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: Text(checked ? 'Finish exercise' : 'Check my answer', style: const TextStyle(fontWeight: FontWeight.w800)))),
    ])))));
    if (result == true || result == false) {
      setState(() { attempts[exercise.id] = (attempts[exercise.id] ?? 0) + 1; if (result == true) { completed.add(exercise.id); mastered[exercise.id] = true; } });
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
