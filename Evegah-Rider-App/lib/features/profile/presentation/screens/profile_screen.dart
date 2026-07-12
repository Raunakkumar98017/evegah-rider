import 'package:flutter/material.dart';

import '../../data/services/profile_service.dart';
import 'basic_profile_screen.dart';

import '../../../offers/presentation/screens/offer_screen.dart';
import '../../../offers/presentation/screens/refer_earn_screen.dart';

import '../../../preferences/presentation/screens/preferences_screen.dart';

import '../../../support/presentation/screens/faq_screen.dart';
import '../../../support/presentation/screens/help_screen.dart';

import '../../../wallet/presentation/screens/wallet_screen.dart';

import '../../../rides/presentation/screen/ride_history_screen.dart';

import '../../../auth/presentation/screens/login_screen.dart';

import '../../../../core/services/session_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  // =================================================
  // EVEGAH COLORS
  // =================================================

  static const Color primaryPurple =
      Color(0xFF200F54);

  static const Color brandPurple =
      Color(0xFF4313B8);

  static const Color lightPurple =
      Color(0xFFF5F3FF);

  static const Color accentGreen =
      Color(0xFFD2FC00);

  static const Color backgroundColor =
      Color(0xFFFAFBFE);

  static const Color darkText =
      Color(0xFF0F172A);

  static const Color secondaryText =
      Color(0xFF94A3B8);

  static const Color borderColor =
      Color(0xFFE2E8F0);

  // =================================================
  // PROFILE SERVICE
  // =================================================

  final ProfileService _profileService =
      ProfileService();

  // =================================================
  // REFRESH PROFILE
  // =================================================

  void _refreshProfile() {
    setState(() {});
  }

  // =================================================
  // USER INITIALS
  // =================================================

  String _getInitials() {
    final String name =
        _profileService.userName.trim();

    if (name.isEmpty) {
      return "AO";
    }

    final List<String> words = name
        .split(" ")
        .where(
          (
            String word,
          ) =>
              word.isNotEmpty,
        )
        .toList();

    if (words.length == 1) {
      return words.first[0]
          .toUpperCase();
    }

    return "${words[0][0]}${words[1][0]}"
        .toUpperCase();
  }

  // =================================================
  // OPEN BASIC PROFILE
  // =================================================

  Future<void> _openProfileDetails() async {
    await Navigator.push(
      context,

      MaterialPageRoute(
        builder: (
          BuildContext context,
        ) =>
            const BasicProfileScreen(),
      ),
    );

    _refreshProfile();
  }

  // =================================================
  // LOGOUT
  // =================================================

  Future<void> _handleLogout() async {
    final bool? shouldLogout =
        await showDialog<bool>(
      context: context,

      builder: (
        BuildContext context,
      ) {
        return AlertDialog(
          backgroundColor: Colors.white,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              24,
            ),
          ),

          icon: Container(
            height: 58,
            width: 58,

            decoration:
                const BoxDecoration(
              color: Color(
                0xFFFFF1F2,
              ),

              shape:
                  BoxShape.circle,
            ),

            child:
                const Icon(
              Icons.logout_rounded,

              color:
                  Color(
                0xFFEF4444,
              ),

              size:
                  27,
            ),
          ),

          title:
              const Text(
            "Log out?",

            textAlign:
                TextAlign.center,

            style:
                TextStyle(
              color:
                  darkText,

              fontSize:
                  20,

              fontWeight:
                  FontWeight.w800,
            ),
          ),

          content:
              const Text(
            "Are you sure you want to log out of your Evegah account?",

            textAlign:
                TextAlign.center,

            style:
                TextStyle(
              color:
                  secondaryText,

              fontSize:
                  12,

              height:
                  1.5,
            ),
          ),

          actionsPadding:
              const EdgeInsets
                  .fromLTRB(
            20,
            0,
            20,
            20,
          ),

          actions: [

            Row(
              children: [

                Expanded(
                  child:
                      OutlinedButton(
                    onPressed:
                        () {
                      Navigator.pop(
                        context,
                        false,
                      );
                    },

                    style:
                        OutlinedButton
                            .styleFrom(
                      foregroundColor:
                          darkText,

                      side:
                          const BorderSide(
                        color:
                            borderColor,
                      ),

                      minimumSize:
                          const Size(
                        double.infinity,
                        48,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          14,
                        ),
                      ),
                    ),

                    child:
                        const Text(
                      "Cancel",

                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  width:
                      12,
                ),

                Expanded(
                  child:
                      ElevatedButton(
                    onPressed:
                        () {
                      Navigator.pop(
                        context,
                        true,
                      );
                    },

                    style:
                        ElevatedButton
                            .styleFrom(
                      elevation:
                          0,

                      backgroundColor:
                          const Color(
                        0xFFEF4444,
                      ),

                      foregroundColor:
                          Colors.white,

                      minimumSize:
                          const Size(
                        double.infinity,
                        48,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          14,
                        ),
                      ),
                    ),

                    child:
                        const Text(
                      "Log Out",

                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    await SessionService().logout();

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,

      MaterialPageRoute(
        builder: (
          BuildContext context,
        ) =>
            const LoginScreen(),
      ),

      (
        Route<dynamic> route,
      ) =>
          false,
    );
  }

  // =================================================
  // PROFILE SCREEN
  // =================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          backgroundColor,

      body:
          SafeArea(
        child:
            SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),

          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // =================================================
              // PROFILE HEADER
              // =================================================

              const Padding(
                padding:
                    EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  20,
                ),

                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    Text(
                      "Profile",

                      style:
                          TextStyle(
                        color:
                            darkText,

                        fontSize:
                            29,

                        fontWeight:
                            FontWeight
                                .w800,

                        letterSpacing:
                            -0.8,
                      ),
                    ),

                    SizedBox(
                      height:
                          5,
                    ),

                    Text(
                      "Manage your account and preferences",

                      style:
                          TextStyle(
                        color:
                            secondaryText,

                        fontSize:
                            13,

                        fontWeight:
                            FontWeight
                                .w500,
                      ),
                    ),
                  ],
                ),
              ),

              // =================================================
              // PREMIUM PROFILE CARD
              // =================================================

              Padding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal:
                      20,
                ),

                child:
                    Container(
                  width:
                      double.infinity,

                  decoration:
                      BoxDecoration(
                    gradient:
                        const LinearGradient(
                      colors: [

                        Color(
                          0xFF4313B8,
                        ),

                        Color(
                          0xFF200F54,
                        ),
                      ],

                      begin:
                          Alignment
                              .topLeft,

                      end:
                          Alignment
                              .bottomRight,
                    ),

                    borderRadius:
                        BorderRadius
                            .circular(
                      28,
                    ),

                    boxShadow: [

                      BoxShadow(
                        color:
                            brandPurple
                                .withValues(
                          alpha:
                              0.20,
                        ),

                        blurRadius:
                            24,

                        offset:
                            const Offset(
                          0,
                          12,
                        ),
                      ),
                    ],
                  ),

                  child:
                      Column(
                    children: [

                      // =========================================
                      // USER INFORMATION
                      // =========================================

                      Material(
                        color:
                            Colors.transparent,

                        child:
                            InkWell(
                          onTap:
                              _openProfileDetails,

                          borderRadius:
                              const BorderRadius
                                  .vertical(
                            top:
                                Radius.circular(
                              28,
                            ),
                          ),

                          child:
                              Padding(
                            padding:
                                const EdgeInsets
                                    .all(
                              20,
                            ),

                            child:
                                Row(
                              children: [

                                // =================================
                                // USER AVATAR
                                // =================================

                                Stack(
                                  clipBehavior:
                                      Clip.none,

                                  children: [

                                    Container(
                                      height:
                                          76,

                                      width:
                                          76,

                                      alignment:
                                          Alignment
                                              .center,

                                      decoration:
                                          BoxDecoration(
                                        color:
                                            Colors.white
                                                .withValues(
                                          alpha:
                                              0.13,
                                        ),

                                        shape:
                                            BoxShape
                                                .circle,

                                        border:
                                            Border.all(
                                          color:
                                              Colors.white
                                                  .withValues(
                                            alpha:
                                                0.20,
                                          ),

                                          width:
                                              2,
                                        ),
                                      ),

                                      child:
                                          Text(
                                        _getInitials(),

                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white,

                                          fontSize:
                                              25,

                                          fontWeight:
                                              FontWeight
                                                  .w900,
                                        ),
                                      ),
                                    ),

                                    Positioned(
                                      right:
                                          -1,

                                      bottom:
                                          -1,

                                      child:
                                          Container(
                                        height:
                                            27,

                                        width:
                                            27,

                                        decoration:
                                            BoxDecoration(
                                          color:
                                              accentGreen,

                                          shape:
                                              BoxShape
                                                  .circle,

                                          border:
                                              Border.all(
                                            color:
                                                primaryPurple,

                                            width:
                                                3,
                                          ),
                                        ),

                                        child:
                                            const Icon(
                                          Icons
                                              .edit_rounded,

                                          color:
                                              darkText,

                                          size:
                                              12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  width:
                                      15,
                                ),

                                // =================================
                                // USER DETAILS
                                // =================================

                                Expanded(
                                  child:
                                      Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [

                                      Text(
                                        _profileService
                                            .userName,

                                        maxLines:
                                            1,

                                        overflow:
                                            TextOverflow
                                                .ellipsis,

                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white,

                                          fontSize:
                                              18,

                                          fontWeight:
                                              FontWeight
                                                  .w800,

                                          letterSpacing:
                                              -0.3,
                                        ),
                                      ),

                                      const SizedBox(
                                        height:
                                            5,
                                      ),

                                      Text(
                                        _profileService
                                            .phoneNumber,

                                        maxLines:
                                            1,

                                        overflow:
                                            TextOverflow
                                                .ellipsis,

                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white70,

                                          fontSize:
                                              10,

                                          fontWeight:
                                              FontWeight
                                                  .w500,
                                        ),
                                      ),

                                      const SizedBox(
                                        height:
                                            3,
                                      ),

                                      Text(
                                        _profileService
                                            .email,

                                        maxLines:
                                            1,

                                        overflow:
                                            TextOverflow
                                                .ellipsis,

                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white70,

                                          fontSize:
                                              10,

                                          fontWeight:
                                              FontWeight
                                                  .w500,
                                        ),
                                      ),

                                      const SizedBox(
                                        height:
                                            8,
                                      ),

                                      // VERIFIED BADGE

                                      Container(
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                          horizontal:
                                              9,

                                          vertical:
                                              5,
                                        ),

                                        decoration:
                                            BoxDecoration(
                                          color:
                                              Colors.white
                                                  .withValues(
                                            alpha:
                                                0.12,
                                          ),

                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            30,
                                          ),
                                        ),

                                        child:
                                            const Row(
                                          mainAxisSize:
                                              MainAxisSize
                                                  .min,

                                          children: [

                                            Icon(
                                              Icons
                                                  .verified_rounded,

                                              color:
                                                  accentGreen,

                                              size:
                                                  12,
                                            ),

                                            SizedBox(
                                              width:
                                                  5,
                                            ),

                                            Text(
                                              "Verified Account",

                                              style:
                                                  TextStyle(
                                                color:
                                                    Colors.white,

                                                fontSize:
                                                    8,

                                                fontWeight:
                                                    FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(
                                  width:
                                      8,
                                ),

                                Container(
                                  height:
                                      34,

                                  width:
                                      34,

                                  decoration:
                                      BoxDecoration(
                                    color:
                                        Colors.white
                                            .withValues(
                                      alpha:
                                          0.10,
                                    ),

                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      10,
                                    ),
                                  ),

                                  child:
                                      const Icon(
                                    Icons
                                        .arrow_forward_ios_rounded,

                                    color:
                                        Colors.white70,

                                    size:
                                        13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // =========================================
                      // PROFILE STATISTICS
                      // =========================================

                      Container(
                        margin:
                            const EdgeInsets
                                .fromLTRB(
                          14,
                          0,
                          14,
                          14,
                        ),

                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal:
                              8,

                          vertical:
                              17,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white
                                  .withValues(
                            alpha:
                                0.10,
                          ),

                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),

                          border:
                              Border.all(
                            color:
                                Colors.white
                                    .withValues(
                              alpha:
                                  0.08,
                            ),
                          ),
                        ),

                        child:
                            Row(
                          children: [

                            Expanded(
                              child:
                                  _buildProfileStat(
                                icon:
                                    Icons
                                        .electric_scooter_rounded,

                                value:
                                    "32",

                                title:
                                    "Total Rides",
                              ),
                            ),

                            _buildStatDivider(),

                            Expanded(
                              child:
                                  _buildProfileStat(
                                icon:
                                    Icons
                                        .eco_rounded,

                                value:
                                    "18.4 kg",

                                title:
                                    "CO₂ Saved",
                              ),
                            ),

                            _buildStatDivider(),

                            Expanded(
                              child:
                                  _buildProfileStat(
                                icon:
                                    Icons
                                        .stars_rounded,

                                value:
                                    "420",

                                title:
                                    "EvePoints",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height:
                    24,
              ),

              // =================================================
              // QUICK ACCESS TITLE
              // =================================================

              const Padding(
                padding:
                    EdgeInsets
                        .symmetric(
                  horizontal:
                      20,
                ),

                child:
                    Text(
                  "Quick Access",

                  style:
                      TextStyle(
                    color:
                        darkText,

                    fontSize:
                        18,

                    fontWeight:
                        FontWeight
                            .w800,

                    letterSpacing:
                        -0.3,
                  ),
                ),
              ),

              const SizedBox(
                height:
                    14,
              ),

              // =================================================
              // QUICK ACCESS CARDS
              // =================================================

              Padding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal:
                      20,
                ),

                child:
                    Row(
                  children: [

                    _buildQuickAccess(
                      icon:
                          Icons
                              .history_rounded,

                      title:
                          "My Rides",

                      subtitle:
                          "Ride history",

                      iconColor:
                          const Color(
                        0xFF16A34A,
                      ),

                      background:
                          const Color(
                        0xFFECFDF3,
                      ),

                      onTap:
                          () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder:
                                (
                              BuildContext
                                  context,
                            ) =>
                                const RideHistoryScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(
                      width:
                          12,
                    ),

                    _buildQuickAccess(
                      icon:
                          Icons
                              .account_balance_wallet_rounded,

                      title:
                          "Wallet",

                      subtitle:
                          "Balance & payments",

                      iconColor:
                          brandPurple,

                      background:
                          lightPurple,

                      onTap:
                          () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder:
                                (
                              BuildContext
                                  context,
                            ) =>
                                const WalletScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height:
                    24,
              ),

              // =================================================
              // REFER AND EARN
              // =================================================

              Padding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal:
                      20,
                ),

                child:
                    Material(
                  color:
                      Colors.transparent,

                  child:
                      InkWell(
                    onTap:
                        () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder:
                              (
                            BuildContext
                                context,
                          ) =>
                              const ReferEarnScreen(),
                        ),
                      );
                    },

                    borderRadius:
                        BorderRadius
                            .circular(
                      22,
                    ),

                    child:
                        Container(
                      padding:
                          const EdgeInsets
                              .all(
                        17,
                      ),

                      decoration:
                          BoxDecoration(
                        gradient:
                            const LinearGradient(
                          colors: [

                            Color(
                              0xFFF7FEE7,
                            ),

                            Color(
                              0xFFF0FDF4,
                            ),
                          ],
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                          22,
                        ),

                        border:
                            Border.all(
                          color:
                              const Color(
                            0xFFD9F99D,
                          ),
                        ),
                      ),

                      child:
                          Row(
                        children: [

                          Container(
                            height:
                                58,

                            width:
                                58,

                            padding:
                                const EdgeInsets
                                    .all(
                              7,
                            ),

                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.white,

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                17,
                              ),
                            ),

                            child:
                                Image.asset(
                              "assets/gift_box_refer.png",

                              fit:
                                  BoxFit.contain,

                              errorBuilder:
                                  (
                                BuildContext
                                    context,

                                Object
                                    error,

                                StackTrace?
                                    stackTrace,
                              ) {
                                return const Icon(
                                  Icons
                                      .card_giftcard_rounded,

                                  color:
                                      Color(
                                    0xFF65A30D,
                                  ),

                                  size:
                                      28,
                                );
                              },
                            ),
                          ),

                          const SizedBox(
                            width:
                                13,
                          ),

                          const Expanded(
                            child:
                                Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Text(
                                  "Refer & Earn",

                                  style:
                                      TextStyle(
                                    color:
                                        darkText,

                                    fontSize:
                                        14,

                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),

                                SizedBox(
                                  height:
                                      4,
                                ),

                                Text(
                                  "Invite friends and earn EvePoints",

                                  style:
                                      TextStyle(
                                    color:
                                        Color(
                                      0xFF65A30D,
                                    ),

                                    fontSize:
                                        9,

                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            height:
                                36,

                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal:
                                  12,
                            ),

                            alignment:
                                Alignment.center,

                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.white,

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                11,
                              ),
                            ),

                            child:
                                const Text(
                              "Refer Now →",

                              style:
                                  TextStyle(
                                color:
                                    Color(
                                  0xFF65A30D,
                                ),

                                fontSize:
                                    9,

                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height:
                    16,
              ),

              // =================================================
              // EVECLUB MEMBERSHIP
              // =================================================

              Padding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal:
                      20,
                ),

                child:
                    Container(
                  padding:
                      const EdgeInsets
                          .all(
                    17,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        lightPurple,

                    borderRadius:
                        BorderRadius
                            .circular(
                      22,
                    ),

                    border:
                        Border.all(
                      color:
                          const Color(
                        0xFFDDD6FE,
                      ),
                    ),
                  ),

                  child:
                      Column(
                    children: [

                      Row(
                        children: [

                          Container(
                            height:
                                46,

                            width:
                                46,

                            decoration:
                                const BoxDecoration(
                              gradient:
                                  LinearGradient(
                                colors: [

                                  Color(
                                    0xFF6D28D9,
                                  ),

                                  Color(
                                    0xFF4313B8,
                                  ),
                                ],
                              ),

                              shape:
                                  BoxShape.circle,
                            ),

                            child:
                                const Icon(
                              Icons
                                  .workspace_premium_rounded,

                              color:
                                  Colors.white,

                              size:
                                  23,
                            ),
                          ),

                          const SizedBox(
                            width:
                                12,
                          ),

                          const Expanded(
                            child:
                                Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Row(
                                  children: [

                                    Flexible(
                                      child:
                                          Text(
                                        "EveClub Member",

                                        style:
                                            TextStyle(
                                          color:
                                              darkText,

                                          fontSize:
                                              13,

                                          fontWeight:
                                              FontWeight.w800,
                                        ),
                                      ),
                                    ),

                                    SizedBox(
                                      width:
                                          7,
                                    ),

                                    _MembershipBadge(),
                                  ],
                                ),

                                SizedBox(
                                  height:
                                      5,
                                ),

                                Text(
                                  "80 points away from Gold level",

                                  style:
                                      TextStyle(
                                    color:
                                        secondaryText,

                                    fontSize:
                                        9,

                                    fontWeight:
                                        FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .end,

                            children: [

                              Text(
                                "420",

                                style:
                                    TextStyle(
                                  color:
                                      brandPurple,

                                  fontSize:
                                      17,

                                  fontWeight:
                                      FontWeight.w900,
                                ),
                              ),

                              Text(
                                "of 500 pts",

                                style:
                                    TextStyle(
                                  color:
                                      secondaryText,

                                  fontSize:
                                      8,

                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(
                        height:
                            16,
                      ),

                      ClipRRect(
                        borderRadius:
                            BorderRadius
                                .circular(
                          10,
                        ),

                        child:
                            const LinearProgressIndicator(
                          value:
                              420 / 500,

                          minHeight:
                              7,

                          backgroundColor:
                              Color(
                            0xFFE2E8F0,
                          ),

                          valueColor:
                              AlwaysStoppedAnimation<
                                  Color>(
                            brandPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height:
                    27,
              ),

              // =================================================
              // ACCOUNT TITLE
              // =================================================

              const Padding(
                padding:
                    EdgeInsets
                        .symmetric(
                  horizontal:
                      20,
                ),

                child:
                    Text(
                  "Account",

                  style:
                      TextStyle(
                    color:
                        darkText,

                    fontSize:
                        18,

                    fontWeight:
                        FontWeight
                            .w800,

                    letterSpacing:
                        -0.3,
                  ),
                ),
              ),

              const SizedBox(
                height:
                    14,
              ),

              // =================================================
              // ACCOUNT MENU
              // =================================================

              Padding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal:
                      20,
                ),

                child:
                    Container(
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white,

                    borderRadius:
                        BorderRadius
                            .circular(
                      22,
                    ),

                    border:
                        Border.all(
                      color:
                          borderColor,
                    ),
                  ),

                  child:
                      Column(
                    children: [

                      _buildMenuItem(
                        icon:
                            Icons
                                .credit_card_rounded,

                        title:
                            "Payment Methods",

                        subtitle:
                            "Manage cards and payment options",

                        iconColor:
                            const Color(
                          0xFF0284C7,
                        ),

                        iconBackground:
                            const Color(
                          0xFFEFF6FF,
                        ),

                        onTap:
                            () {},
                      ),

                      _menuDivider(),

                      _buildMenuItem(
                        icon:
                            Icons
                                .local_offer_rounded,

                        title:
                            "Promotions & Offers",

                        subtitle:
                            "View your available offers",

                        iconColor:
                            const Color(
                          0xFF9333EA,
                        ),

                        iconBackground:
                            const Color(
                          0xFFFAE8FF,
                        ),

                        onTap:
                            () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder:
                                  (
                                BuildContext
                                    context,
                              ) =>
                                  const OfferScreen(),
                            ),
                          );
                        },
                      ),

                      _menuDivider(),

                      _buildMenuItem(
                        icon:
                            Icons
                                .shield_outlined,

                        title:
                            "Safety & Help",

                        subtitle:
                            "Get support and safety assistance",

                        iconColor:
                            const Color(
                          0xFF16A34A,
                        ),

                        iconBackground:
                            const Color(
                          0xFFECFDF3,
                        ),

                        onTap:
                            () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder:
                                  (
                                BuildContext
                                    context,
                              ) =>
                                  const HelpScreen(),
                            ),
                          );
                        },
                      ),

                      _menuDivider(),

                      _buildMenuItem(
                        icon:
                            Icons
                                .tune_rounded,

                        title:
                            "Preferences",

                        subtitle:
                            "Notifications, language and privacy",

                        iconColor:
                            const Color(
                          0xFFF59E0B,
                        ),

                        iconBackground:
                            const Color(
                          0xFFFFFBEB,
                        ),

                        onTap:
                            () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder:
                                  (
                                BuildContext
                                    context,
                              ) =>
                                  const PreferencesScreen(),
                            ),
                          );
                        },
                      ),

                      _menuDivider(),

                      _buildMenuItem(
                        icon:
                            Icons
                                .info_outline_rounded,

                        title:
                            "About Evegah",

                        subtitle:
                            "FAQs and app information",

                        iconColor:
                            brandPurple,

                        iconBackground:
                            lightPurple,

                        onTap:
                            () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder:
                                  (
                                BuildContext
                                    context,
                              ) =>
                                  const FaqScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height:
                    17,
              ),

              // =================================================
              // LOGOUT
              // =================================================

              Padding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal:
                      20,
                ),

                child:
                    Material(
                  color:
                      Colors.white,

                  borderRadius:
                      BorderRadius
                          .circular(
                    18,
                  ),

                  child:
                      InkWell(
                    onTap:
                        _handleLogout,

                    borderRadius:
                        BorderRadius
                            .circular(
                      18,
                    ),

                    child:
                        Container(
                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets
                              .all(
                        16,
                      ),

                      decoration:
                          BoxDecoration(
                        borderRadius:
                            BorderRadius
                                .circular(
                          18,
                        ),

                        border:
                            Border.all(
                          color:
                              const Color(
                            0xFFFECACA,
                          ),
                        ),
                      ),

                      child:
                          const Row(
                        children: [

                          Icon(
                            Icons
                                .logout_rounded,

                            color:
                                Color(
                              0xFFEF4444,
                            ),

                            size:
                                20,
                          ),

                          SizedBox(
                            width:
                                13,
                          ),

                          Expanded(
                            child:
                                Text(
                              "Log Out",

                              style:
                                  TextStyle(
                                color:
                                    Color(
                                  0xFFEF4444,
                                ),

                                fontSize:
                                    13,

                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ),

                          Icon(
                            Icons
                                .arrow_forward_ios_rounded,

                            color:
                                Color(
                              0xFFFCA5A5,
                            ),

                            size:
                                13,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height:
                    12,
              ),

              // =================================================
              // APP VERSION
              // =================================================

              const Center(
                child:
                    Text(
                  "Evegah Rider • Version 1.0.0",

                  style:
                      TextStyle(
                    color:
                        secondaryText,

                    fontSize:
                        9,

                    fontWeight:
                        FontWeight
                            .w500,
                  ),
                ),
              ),

              const SizedBox(
                height:
                    35,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =================================================
  // PROFILE STAT
  // =================================================

  Widget _buildProfileStat({
    required IconData icon,

    required String value,

    required String title,
  }) {
    return Column(
      children: [

        Icon(
          icon,

          color:
              accentGreen,

          size:
              20,
        ),

        const SizedBox(
          height:
              7,
        ),

        Text(
          value,

          maxLines:
              1,

          style:
              const TextStyle(
            color:
                Colors.white,

            fontSize:
                14,

            fontWeight:
                FontWeight.w900,
          ),
        ),

        const SizedBox(
          height:
              3,
        ),

        Text(
          title,

          maxLines:
              1,

          style:
              const TextStyle(
            color:
                Colors.white60,

            fontSize:
                8,

            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // =================================================
  // STAT DIVIDER
  // =================================================

  Widget _buildStatDivider() {
    return Container(
      height:
          42,

      width:
          1,

      color:
          Colors.white
              .withValues(
        alpha:
            0.12,
      ),
    );
  }

  // =================================================
  // QUICK ACCESS CARD
  // =================================================

  Widget _buildQuickAccess({
    required IconData icon,

    required String title,

    required String subtitle,

    required Color iconColor,

    required Color background,

    required VoidCallback onTap,
  }) {
    return Expanded(
      child:
          Material(
        color:
            Colors.white,

        borderRadius:
            BorderRadius
                .circular(
          19,
        ),

        child:
            InkWell(
          onTap:
              onTap,

          borderRadius:
              BorderRadius
                  .circular(
            19,
          ),

          child:
              Container(
            padding:
                const EdgeInsets
                    .all(
              15,
            ),

            decoration:
                BoxDecoration(
              borderRadius:
                  BorderRadius
                      .circular(
                19,
              ),

              border:
                  Border.all(
                color:
                    borderColor,
              ),
            ),

            child:
                Row(
              children: [

                Container(
                  height:
                      43,

                  width:
                      43,

                  decoration:
                      BoxDecoration(
                    color:
                        background,

                    borderRadius:
                        BorderRadius
                            .circular(
                      13,
                    ),
                  ),

                  child:
                      Icon(
                    icon,

                    color:
                        iconColor,

                    size:
                        21,
                  ),
                ),

                const SizedBox(
                  width:
                      11,
                ),

                Expanded(
                  child:
                      Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      Text(
                        title,

                        style:
                            const TextStyle(
                          color:
                              darkText,

                          fontSize:
                              12,

                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),

                      const SizedBox(
                        height:
                            3,
                      ),

                      Text(
                        subtitle,

                        maxLines:
                            1,

                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            const TextStyle(
                          color:
                              secondaryText,

                          fontSize:
                              8,

                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =================================================
  // MENU ITEM
  // =================================================

  Widget _buildMenuItem({
    required IconData icon,

    required String title,

    required String subtitle,

    required Color iconColor,

    required Color iconBackground,

    required VoidCallback onTap,
  }) {
    return Material(
      color:
          Colors.transparent,

      child:
          InkWell(
        onTap:
            onTap,

        child:
            Padding(
          padding:
              const EdgeInsets
                  .symmetric(
            horizontal:
                16,

            vertical:
                14,
          ),

          child:
              Row(
            children: [

              Container(
                height:
                    43,

                width:
                    43,

                decoration:
                    BoxDecoration(
                  color:
                      iconBackground,

                  borderRadius:
                      BorderRadius
                          .circular(
                    13,
                  ),
                ),

                child:
                    Icon(
                  icon,

                  color:
                      iconColor,

                  size:
                      21,
                ),
              ),

              const SizedBox(
                width:
                    13,
              ),

              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    Text(
                      title,

                      style:
                          const TextStyle(
                        color:
                            darkText,

                        fontSize:
                            12,

                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height:
                          4,
                    ),

                    Text(
                      subtitle,

                      maxLines:
                          1,

                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          const TextStyle(
                        color:
                            secondaryText,

                        fontSize:
                            8,

                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width:
                    8,
              ),

              const Icon(
                Icons
                    .arrow_forward_ios_rounded,

                color:
                    secondaryText,

                size:
                    13,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =================================================
  // MENU DIVIDER
  // =================================================

  Widget _menuDivider() {
    return const Padding(
      padding:
          EdgeInsets.only(
        left:
            72,
      ),

      child:
          Divider(
        color:
            Color(
          0xFFF1F5F9,
        ),

        height:
            1,
      ),
    );
  }
}

// =================================================
// MEMBERSHIP BADGE
// =================================================

class _MembershipBadge
    extends StatelessWidget {
  const _MembershipBadge();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets
              .symmetric(
        horizontal:
            7,

        vertical:
            3,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFE0E7FF,
        ),

        borderRadius:
            BorderRadius
                .circular(
          20,
        ),
      ),

      child:
          const Text(
        "SILVER",

        style:
            TextStyle(
          color: Color(0xFF4313B8),

          fontSize:
              7,

          fontWeight:
              FontWeight.w900,

          letterSpacing:
              0.3,
        ),
      ),
    );
  }
}