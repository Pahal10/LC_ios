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

      try {
        await updateCurrentLocation();
      } catch (e) {
        debugPrint("Location update failed: $e");
      }

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
      const Color(0xFF4CAF50),

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
        await updateCurrentLocation();

        final introCompleted =
            response.first["intro_completed"] ?? false;

        if (!introCompleted) {

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const LonelyPage(),
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
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),

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

                        color: const Color(0xFFFFD700),

                        fontSize: 14,

                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Container(
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
              ),

              const SizedBox(height: 20),

              /// LOGIN BUTTON
              ElevatedButton(
                onPressed: loginUser,

                child: const Text(
                  'Log in',
                  style: TextStyle(
                    color: Color(0xFF111A2D),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// OR
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: const Color(0xFFFFD700),
                      thickness: 2,
                      endIndent: 10,
                    ),
                  ),

                  const Text(
                    "or",
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Expanded(
                    child: Divider(
                      color: const Color(0xFFFFD700),
                      thickness: 2,
                      indent: 10,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// REGISTER BUTTON
              ElevatedButton(
                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const GetStartedPage(),
                    ),
                  );

                },

                child: const Text(
                  'Register',

                  style: TextStyle(
                    color: Color(0xFF111A2D),
                  ),
                ),
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

    /// PASSWORD MATCH CHECK
    if (password != confirmPassword) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
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
          builder: (context) => const LonelyPage(),
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
      backgroundColor: const Color(0xFF4CAF50),

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

                                      "If you enter another user's promo code during registration, both of you will receive one Premium Reward.\n\n"
                                          "Rewards can later be claimed from Access Pending Rewards.",

                                    ),

                                  ),

                                );

                              },

                            ),

                          ),

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
      const Color(0xFF4CAF50),

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
      backgroundColor: const Color(0xFF4CAF50),

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
      backgroundColor: const Color(0xFF4CAF50),

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
      backgroundColor: const Color(0xFF4CAF50),

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

        await Supabase.instance.client.functions.invoke(
          'premium-offer',
          body: {
            'email': user["email"],
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
                await handleRewardFlow();
              },

              child: const Text("Somewhat"),
            ),

            /// YES
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await increaseProgress(2);
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
      const Color(0xFF4CAF50),

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
        const Color(0xFF4CAF50),
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
    refreshLocation();


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

  Future<void> refreshLocation() async {

    try {

      await updateCurrentLocation();

    }

    catch (e) {

      debugPrint(
        "Location update failed: $e",
      );

    }

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

    final passwordController = TextEditingController();

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

    final password = await showCupertinoDialog<String>(
      context: context,
      builder: (_) => CupertinoAlertDialog(

        title: const Text("Enter Password"),

        content: Column(

          children: [

            const SizedBox(height: 10),

            CupertinoTextField(
              controller: passwordController,
              obscureText: true,
              placeholder: "Password",
            ),

          ],

        ),

        actions: [

          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () {
              Navigator.pop(
                context,
                passwordController.text.trim(),
              );
            },
          ),

        ],
      ),
    );

    if (password == null) return;

    try {

      final response = await supabase
          .from("users")
          .select()
          .eq("username", Session.username)
          .eq("password", password);

      if (response.isEmpty) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Incorrect password."),
          ),
        );

        return;
      }

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

                "If you get new users to download LC using your promo code, both of you will receive one Premium Reward.\n\n"
                    "You can later claim it from Access Pending Rewards.",

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
        child: SingleChildScrollView(
        child: Column(
          children: [

            const SizedBox(height: 20),

            CircleAvatar(
              radius: 40,
              backgroundColor:
              isPremium
                  ? Colors.amber
                  : Colors.white,
              backgroundImage:
              AssetImage("asset/LCicon.png"),
            ),

            const SizedBox(height: 20),

            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Text(
                "Welcome ${Session.username},\nWhat would you like to do today?",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 30),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(
                "Change Username",
              ),
              onTap: () {
                showChangeUsernameDialog();
              },
            ),

            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text(
                "Change Password",
              ),
              onTap: () {
                showChangePasswordDialog();
              },
            ),

            ListTile(
              leading:
              const Icon(Icons.psychology),
              title: const Text(
                "Choose Different Reason",
              ),
              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const LonelyPage(),
                  ),
                );
              },
            ),

            ListTile(
              leading:
              const Icon(Icons.email),
              title:
              const Text("Contact Us"),
              onTap: () {
                showContactDialog();
              },
            ),

            ListTile(
              leading:
              const Icon(Icons.email),
              title: const Text("My promo code"),
              onTap: () {
                Navigator.pop(context);

              showPromoCodeDialog(context);
              },
            ),
            ListTile(
              leading:
              const Icon(Icons.logout),
              title:
              const Text("Logout"),
              onTap: () {
                showLogoutDialog();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_forever,
                color: Colors.red,
              ),
              title: const Text(
                "Delete account",
                style: TextStyle(color: Colors.red),
              ),
              onTap: deleteAccount,
            ),
          ],
        ),
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: buildDrawer(),
      backgroundColor: currentPage == 1
          ? Colors.black
          : const Color(0xFF4CAF50),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF388E3C),
        elevation: 0,

        title: GestureDetector(
          onTap: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          child: CircleAvatar(
            radius: 20,
            backgroundImage:
            AssetImage("asset/LCicon.png"),
          ),
        ),

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
        child: Stack(
          children: [
            // UCLA FULL PAGE BACKGROUND
            if (currentPage == 1)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.35,
                  child: Image.asset(
                    "asset/ucla2.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // optional dark overlay
            if (currentPage == 1)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.15),
                ),
              ),

            /// PAGE VIEW
            PageView.builder(
              controller: controller,
              itemCount: pages.length,
              itemBuilder: (context, index) {
                final item = pages[index];

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GestureDetector(
                      onTap: () async {
                        if (index == 1) {
                          if (item["link"] != null) {
                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) =>
                                const UCLAPage(),
                              ),
                            );
                          }
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(42),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 25,
                            sigmaY: 25,
                          ),
                          child: Container(
                            width: double.infinity,
                            height: 280,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(42),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.20),
                                  Colors.white.withOpacity(0.07),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.18),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.10),
                                  blurRadius: 30,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),

                            child: Stack(
                              children: [
                                /// UCLA IMAGE BACKGROUND INSIDE GLASS
                                /*if (index == 1)
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(42),
                                      child: Opacity(
                                        opacity: 0.5, // increase visibility
                                        child: ColorFiltered(
                                          colorFilter: ColorFilter.mode(
                                            Colors.white.withOpacity(0.35),
                                            BlendMode.lighten,
                                          ),
                                          child: Image.asset(
                                            "asset/ucla2.png",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                /// DARK OVERLAY FOR READABILITY
                                if (index == 1)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(42),
                                        color: Colors.black.withOpacity(0.18),
                                      ),
                                    ),
                                  ),*/

                                /// LIGHT REFLECTION
                                Positioned(
                                  top: -30,
                                  left: -20,
                                  child: Container(
                                    width: 220,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(50),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.20),
                                          Colors.white.withOpacity(0.01),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                /// PRO FEATURE TAG
                                if (item["pro"] == true)
                                  Positioned(
                                    top: 20,
                                    right: 20,
                                    child: Container(
                                      padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.yellow,
                                        borderRadius:
                                        BorderRadius.circular(14),
                                      ),
                                      child: const Text(
                                        "PRO FEATURE",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ),

                                /// MAIN CONTENT
                                Center(
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [

                                        /// ICON
                                        Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                            Colors.white.withOpacity(
                                                0.10),
                                            border: Border.all(
                                              color: Colors.white
                                                  .withOpacity(0.15),
                                            ),
                                          ),
                                          child: Icon(
                                            item["icon"],
                                            size: 42,
                                            color: Colors.white,
                                          ),
                                        ),

                                        const SizedBox(height: 24),

                                        /// TITLE
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            item["title"],
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 30,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 24),

                                        /// BUTTON
                                        if (item["button"] != null)
                                          GestureDetector(
                                            onTap: () async {
                                              if (index == 0) {
                                                final data = await supabase
                                                    .from('users')
                                                    .select('graduated')
                                                    .eq(
                                                  'username',
                                                  Session.username,
                                                )
                                                    .single();

                                                bool graduated =
                                                    data['graduated'] ?? false;

                                                if (graduated) {

                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                      const StageSelectionPage(),
                                                    ),
                                                  );

                                                } else {

                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                      const TaskPage(),
                                                    ),
                                                  );

                                                }
                                              }
                                              else if (index == 2) {
                                                  showAccountSettingsDialog();
                                                }
                                              else if (index == 4) {
                                                showLogoutDialog();
                                              }



                                              else if (index == 3) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    bool isHovered = false;

                                                    return StatefulBuilder(
                                                      builder: (context, setState) {
                                                        return AlertDialog(
                                                          backgroundColor: const Color(0xFFFFFFFF),

                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(24),
                                                          ),

                                                          title: const Text(
                                                            "You are not alone.\nWe are here for you",
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 22,
                                                            ),
                                                          ),

                                                          content: const Text(
                                                            "Got a question for us?\n"
                                                                "Or craving for some social connection?\n\n"
                                                                "Email at:\n"
                                                                "pahal.bhatti11@gmail.com",
                                                            style: TextStyle(
                                                              color: Colors.white70,
                                                              fontSize: 16,
                                                              height: 1.5,
                                                            ),
                                                          ),

                                                          actions: [
                                                            MouseRegion(
                                                              onEnter: (_) {
                                                                setState(() {
                                                                  isHovered = true;
                                                                });
                                                              },
                                                              onExit: (_) {
                                                                setState(() {
                                                                  isHovered = false;
                                                                });
                                                              },
                                                              child: AnimatedContainer(
                                                                duration: const Duration(milliseconds: 200),

                                                                decoration: BoxDecoration(
                                                                  color: isHovered
                                                                      ? Colors.blue
                                                                      : Colors.white.withOpacity(0.12),

                                                                  borderRadius: BorderRadius.circular(14),
                                                                ),

                                                                child: TextButton(
                                                                  onPressed: () {
                                                                    Navigator.pop(context);
                                                                  },

                                                                  child: const Padding(
                                                                    padding: EdgeInsets.symmetric(
                                                                      horizontal: 14,
                                                                      vertical: 6,
                                                                    ),

                                                                    child: Text(
                                                                      "OK",
                                                                      style: TextStyle(
                                                                        color: Colors.white,
                                                                        fontWeight: FontWeight.w600,
                                                                      ),
                                                                    ),
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
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 28,
                                                vertical: 22,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(18),
                                                color: Colors.white.withOpacity(0.10),
                                                border: Border.all(
                                                  color: Colors.white.withOpacity(0.12),
                                                ),
                                              ),
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  item["button"],
                                                  textAlign: TextAlign.center,
                                                ),
                                              )
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            /// PAGE INDICATOR
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: controller,
                  count: pages.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 3,
                    spacing: 8,
                    activeDotColor: Colors.white,
                    dotColor: Colors.white.withOpacity(0.25),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StageSelectionPage extends StatelessWidget {

  const StageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFF4CAF50),

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
      const Color(0xFF4CAF50),

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
      const Color(0xFF4CAF50),

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