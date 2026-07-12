import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  // Focus nodes to manage input highlight states
  late FocusNode phoneFocusNode;
  late FocusNode passwordFocusNode;

  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    phoneFocusNode = FocusNode();
    passwordFocusNode = FocusNode();

    // Add listeners so the UI automatically updates when you tap in OR tap out
    phoneFocusNode.addListener(() {
      setState(() {});
    });
    passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    mobileController.dispose();
    passwordController.dispose();
    phoneFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  void _onContinuePressed() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard on submit
    debugPrint('===== LOGIN BUTTON CLICKED =====');

    final mobile = mobileController.text.trim();
    final password = passwordController.text.trim();

    debugPrint('Mobile Number: $mobile, Password length: ${password.length}');

    if (mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter mobile number')),
      );
      return;
    }

    if (mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mobile number must be exactly 10 digits'),
        ),
      );
      return;
    }

    try {
      debugPrint('Going to dashboard...');
      context.go(AppRoutes.dashboard);
      debugPrint('Navigation command executed');
    } catch (e) {
      debugPrint('ERROR: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Navigation Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if phone field is currently focused
    final isPhoneFocused = phoneFocusNode.hasFocus;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // Soft premium backdrop
      body: SafeArea(
        child: SingleChildScrollView(
          // Ensures smooth scrolling when keyboard pops up
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 28),
              
              // App Logo / Icon Header
              Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'evegah',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E1C9F),
                        letterSpacing: -0.5,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Hero Welcome section with subtle card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E1C9F), Color(0xFF160E58)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E1C9F).withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -15,
                        bottom: -15,
                        child: Opacity(
                          opacity: 0.1,
                          child: const Icon(Icons.flash_on_rounded, size: 85, color: Colors.white),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Welcome Rider! 👋',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Sign in to continue your journey and monitor battery diagnostics.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFFC0BDF2),
                              fontWeight: FontWeight.w400,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Rider Illustration Card
              Center(
                child: Image.asset(
                  'assets/images/rider_illustration.png',
                  height: 190,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 140,
                      height: 140,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFFFCA),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.electric_scooter_rounded,
                        size: 64,
                        color: Color(0xFF8CE300),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // White Form Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03), // Softer shadow
                      blurRadius: 15,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Phone number Label
                    const Text(
                      'Phone Number',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF151833),
                      ),
                    ),
                    const SizedBox(height: 8),
// Phone custom input container (with focus highlighting)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2), // Adjusted vertical padding
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // This is the OUTER box border. We keep this one!
                        border: Border.all(
                          color: isPhoneFocused ? const Color(0xFF2E1C9F) : const Color(0xFFF1F5F9), 
                          width: 1.5
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '🇮🇳',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '+91',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF151833),
                            ),
                          ),
                          
                          Container(
                            height: 18,
                            width: 1.5,
                            color: const Color(0xFFF1F5F9),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          Expanded(
                            child: TextField(
                              controller: mobileController,
                              focusNode: phoneFocusNode,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              onEditingComplete: () => FocusScope.of(context).requestFocus(passwordFocusNode),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF151833),
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                                hintText: 'Enter phone number',
                                hintStyle: TextStyle(
                                  color: Color(0xFF8C93A8),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w400,
                                ),
                                counterText: '',
                                // THIS REMOVES THE INNER BOX COMPLETELY
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Label Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF151833),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // Forgot Password logic
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E1C9F), // Royal Purple link
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Password input field
                    TextField(
                      controller: passwordController,
                      focusNode: passwordFocusNode,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF151833),
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: Color(0xFF8C93A8)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            size: 20,
                            color: const Color(0xFF8C93A8),
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        hintText: 'Enter password',
                        hintStyle: const TextStyle(
                          color: Color(0xFF8C93A8),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF2E1C9F), width: 1.5),
                        ),
                      ),
                    ),
                    
                    // Increased spacing here to replace the removed checkbox
                    const SizedBox(height: 32),

                    // Login Button (Indigo Gradient)
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2E1C9F), Color(0xFF160E58)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E1C9F).withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _onContinuePressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Divider: "or continue with"
                    Row(
                      children: const [
                        Expanded(child: Divider(color: Color(0xFFF1F5F9), thickness: 1.5)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'or continue with',
                            style: TextStyle(
                              color: Color(0xFF8C93A8),
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Color(0xFFF1F5F9), thickness: 1.5)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Social login Row
                    Row(
                      children: [
                        _buildSocialBtn(
                          logo: const Icon(
                            Icons.g_mobiledata_rounded,
                            color: Colors.blue,
                            size: 28,
                          ),
                          label: 'Google',
                          onTap: () {},
                        ),
                        const SizedBox(width: 8),
                        _buildSocialBtn(
                          logo: const Icon(
                            Icons.apple_rounded,
                            color: Colors.black,
                            size: 20,
                          ),
                          label: 'Apple',
                          onTap: () {},
                        ),
                        const SizedBox(width: 8),
                        _buildSocialBtn(
                          logo: const Icon(
                            Icons.phonelink_ring_rounded,
                            color: Color(0xFF2E1C9F),
                            size: 16,
                          ),
                          label: 'Phone OTP',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Footer: Don't have an account? Sign Up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: Color(0xFF8C93A8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // Go to sign up
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color(0xFF2E1C9F),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Refactored Social Button to include beautiful touch ripples
  Widget _buildSocialBtn({
    required Widget logo,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                logo,
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF151833),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}