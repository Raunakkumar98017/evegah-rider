import 'package:flutter/material.dart';
import '../../data/services/support_service.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  // =================================================
  // EVEGAH BRAND COLORS
  // =================================================

  static const Color primaryPurple = Color(0xFF200F54);
  static const Color brandPurple = Color(0xFF4313B8);
  static const Color accentGreen = Color(0xFF8CE600);

  static const Color backgroundColor = Color(0xFFFAFBFE);
  static const Color darkText = Color(0xFF0F172A);
  static const Color secondaryText = Color(0xFF94A3B8);
  static const Color borderColor = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final SupportService supportService = SupportService();

    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: Column(
          children: [

            // =================================================
            // MODERN HELP HEADER
            // =================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                18,
              ),

              child: Row(
                children: [

                  // Back button

                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),

                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },

                      borderRadius: BorderRadius.circular(14),

                      child: Container(
                        height: 46,
                        width: 46,

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(
                            14,
                          ),

                          border: Border.all(
                            color: borderColor,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: 0.04,
                              ),

                              blurRadius: 10,

                              offset: const Offset(
                                0,
                                4,
                              ),
                            ),
                          ],
                        ),

                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: primaryPurple,
                          size: 24,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  // Page title and subtitle

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          "Get Help",

                          style: TextStyle(
                            color: darkText,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          "How can we help you today?",

                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // =================================================
            // SCROLLABLE CONTENT
            // =================================================

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  4,
                  20,
                  30,
                ),

                children: [

                  // =================================================
                  // SUPPORT HERO CARD
                  // =================================================

                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.fromLTRB(
                      24,
                      28,
                      24,
                      28,
                    ),

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF200F54),
                          Color(0xFF4313B8),
                        ],

                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),

                      borderRadius: BorderRadius.circular(
                        28,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: primaryPurple.withValues(
                            alpha: 0.20,
                          ),

                          blurRadius: 24,

                          offset: const Offset(
                            0,
                            12,
                          ),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [

                        // Support icon

                        Container(
                          height: 76,
                          width: 76,

                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: 0.12,
                            ),

                            shape: BoxShape.circle,

                            border: Border.all(
                              color: Colors.white.withValues(
                                alpha: 0.15,
                              ),
                            ),
                          ),

                          child: const Icon(
                            Icons.support_agent_rounded,
                            color: accentGreen,
                            size: 42,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "We're here for you",

                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),

                        const SizedBox(height: 9),

                        const Text(
                          "Our support team is ready to help with your rides, payments, and account.",

                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.55,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Support availability

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: 0.11,
                            ),

                            borderRadius: BorderRadius.circular(
                              30,
                            ),
                          ),

                          child: const Row(
                            mainAxisSize: MainAxisSize.min,

                            children: [

                              // Online indicator

                              CircleAvatar(
                                radius: 4,
                                backgroundColor: accentGreen,
                              ),

                              SizedBox(width: 8),

                              Text(
                                "Support team is available",

                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =================================================
                  // CONTACT SECTION TITLE
                  // =================================================

                  const Text(
                    "Contact Support",

                    style: TextStyle(
                      color: darkText,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Choose how you would like to contact us",

                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 17),

                  // =================================================
                  // CALL SUPPORT CARD
                  // =================================================

                  _buildContactCard(
                    title: "Call Us",

                    subtitle: supportService.supportPhone,

                    info: supportService.operatingHours,

                    badge: "AVAILABLE",

                    icon: Icons.phone_rounded,

                    iconColor: const Color(
                      0xFF16A34A,
                    ),

                    iconBackground: const Color(
                      0xFFECFDF3,
                    ),

                    onTap: () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Launching phone dialer...",
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // =================================================
                  // EMAIL SUPPORT CARD
                  // =================================================

                  _buildContactCard(
                    title: "Email Support",

                    subtitle: supportService.supportEmail,

                    info: "Typical reply within 2 hours",

                    badge: "QUICK REPLY",

                    icon: Icons.mail_outline_rounded,

                    iconColor: const Color(
                      0xFF2563EB,
                    ),

                    iconBackground: const Color(
                      0xFFEFF6FF,
                    ),

                    onTap: () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Launching email app...",
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // =================================================
                  // HELP INFORMATION
                  // =================================================

                  Container(
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),

                      borderRadius: BorderRadius.circular(
                        18,
                      ),

                      border: Border.all(
                        color: const Color(
                          0xFFE9E3FF,
                        ),
                      ),
                    ),

                    child: const Row(
                      children: [

                        Icon(
                          Icons.info_outline_rounded,
                          color: brandPurple,
                          size: 21,
                        ),

                        SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            "For faster support, keep your ride or booking details ready.",

                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
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

  // =================================================
  // CONTACT SUPPORT CARD
  // =================================================

  Widget _buildContactCard({
    required String title,
    required String subtitle,
    required String info,
    required String badge,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,

      borderRadius: BorderRadius.circular(20),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(20),

        child: Container(
          padding: const EdgeInsets.all(17),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),

            border: Border.all(
              color: borderColor,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.025,
                ),

                blurRadius: 14,

                offset: const Offset(
                  0,
                  5,
                ),
              ),
            ],
          ),

          child: Row(
            children: [

              // Contact icon

              Container(
                height: 55,
                width: 55,

                decoration: BoxDecoration(
                  color: iconBackground,

                  borderRadius: BorderRadius.circular(
                    16,
                  ),
                ),

                child: Icon(
                  icon,
                  color: iconColor,
                  size: 26,
                ),
              ),

              const SizedBox(width: 15),

              // Contact details

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Row(
                      children: [

                        Flexible(
                          child: Text(
                            title,

                            style: const TextStyle(
                              color: darkText,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),

                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFF5F3FF,
                            ),

                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),

                          child: Text(
                            badge,

                            style: const TextStyle(
                              color: brandPurple,
                              fontSize: 7,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: darkText,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      info,

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: secondaryText,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Navigation arrow

              Container(
                height: 30,
                width: 30,

                decoration: BoxDecoration(
                  color: const Color(
                    0xFFF8FAFC,
                  ),

                  borderRadius: BorderRadius.circular(
                    9,
                  ),
                ),

                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: secondaryText,
                  size: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}