import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_dock/controllers/billing_controller.dart';
import 'package:file_dock/controllers/profile_controller.dart';
import 'package:file_dock/controllers/withdrawal_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart' show DateFormat;

import 'package:percent_indicator/circular_percent_indicator.dart';
import '../constant/colors.dart';
import '../widget/custom_app_bar.dart';
import 'new_withdrawal_screen.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  int selectedTab = 0; // 0 = New Withdrawal, 1 = Old Withdrawal
  final PageController _pageController = PageController();
  //final BillingController controller = Get.put(BillingController());
  final ProfileController controller = Get.put(ProfileController());
  final BillingController billingcontroller = Get.put(BillingController());
  final WithdrawalProvider wcontroller = Get.put(WithdrawalProvider());
  // Mock data for Old Withdrawals

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: SafeArea(
        child: Scaffold(
          appBar: CustomAppBar(),

          backgroundColor: kbg1black500,
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/register_bg.jpg"),
                fit: BoxFit.cover,
                opacity: 0.25,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),

                /// Header
                Center(
                  child: Text(
                    "Revenue Details",
                    style: TextStyle(
                      color: kwhite,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// Revenue Cards (row 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Obx(
                      () => _revenueCard(
                        "Total",
                        //"${controller.earnings.toStringAsFixed(0)} ₹",
                        "${wcontroller.approvedAmount.value.toStringAsFixed(2)} ₹",
                        svg: "assets/svg icons/billing svg/total.svg",
                      ),
                    ),
                    Obx(
                      () => _revenueCard(
                        "Paid",
                        "${billingcontroller.paid.value.toStringAsFixed(2)} ₹", // show 2 decimals
                        svg: "assets/svg icons/billing svg/paid.svg",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// Revenue Cards (row 2 changes by tab)
                if (selectedTab == 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(
                        () => _revenueCard(
                          "Pending",
                          "${billingcontroller.pending.value.toStringAsFixed(2)} ₹",
                          svg: "assets/svg icons/billing svg/pending.svg",
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _revenueCard(
                        "Available",
                        "${(wcontroller.approvedAmount.value - billingcontroller.paid.value).toStringAsFixed(2)} ₹",

                        svg: "assets/svg icons/billing svg/available.svg",
                      ),
                      Obx(
                        () => _revenueCard(
                          "Approved",
                          "${billingcontroller.paid.value.toStringAsFixed(2)} ₹",
                          svg: "assets/svg icons/billing svg/approved.svg",
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 30),

                /// Tabs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _tab("New Withdrawal", 0),
                    _tab("Old Withdrawal", 1),
                  ],
                ),

                const SizedBox(height: 20),

                /// Swipeable content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => selectedTab = index);
                    },
                    children: [_newWithdrawalCard(), _oldWithdrawalList()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Tab widget with underline (dynamic width)
  Widget _tab(String label, int index) {
    final bool isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() => selectedTab = index);
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? kwhite : Colors.grey,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 6),
          if (isSelected)
            Container(
              height: 2,
              margin: const EdgeInsets.only(top: 2),
              color: kblueaccent,
              width: _textWidth(label, 16, isSelected),
            ),
        ],
      ),
    );
  }

  double _textWidth(String text, double fontSize, bool isBold) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width;
  }

  /// New Withdrawal card with SVG
  Widget _newWithdrawalCard() {
    return Container(
      height: 157,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: kbg2lightblack300.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/svg icons/billing svg/new_withdrawal.svg",
            width: 50,
            height: 50,
            color: kwhite,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kblueaccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: () {
              // TODO: Navigator.pushNamed(context, '/new_withdrawal');
              Get.to(WithdrawalScreen());
            },
            child: Text(
              "New Withdrawal Request",
              style: TextStyle(
                color: kblack,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _oldWithdrawalList() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(
        child: Text("User not logged in", style: TextStyle(color: Colors.grey)),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('withdrawals')
          .where('userId', isEqualTo: uid)
          .orderBy('requestedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading withdrawals"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No withdrawals yet.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        final withdrawals = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: withdrawals.length,
          itemBuilder: (context, index) {
            final data = withdrawals[index].data() as Map<String, dynamic>;
            final bool approved =
                (data["status"] ?? "").toLowerCase() == "approved";
            final amount = (data["amount"] ?? 0).toString();
            final requestedAt = data["requestedAt"] as Timestamp?;
            final date = requestedAt != null
                ? DateFormat('MMM d, yyyy').format(requestedAt.toDate())
                : "N/A";
            final qrUrl = data["screenshotUrl"] as String?;

            return Container(
              height: 80,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kbg2lightblack300.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: (qrUrl != null && qrUrl.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: qrUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.qr_code,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "₹$amount",
                          style: TextStyle(
                            color: kwhite,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          date,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    data["status"] ?? "-",
                    style: TextStyle(
                      color: approved ? Colors.greenAccent : Colors.redAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Reusable revenue card widget with CircularPercentIndicator + SVG
  ///
  Widget _revenueCard(
    String title,
    String value, {
    String? svg,
    IconData? icon,
    double percent = 0.7,
  }) {
    double cardWidth = (value.length * 15).toDouble().clamp(150, 300);

    return Container(
      width: cardWidth,
      height: 100,
      padding: const EdgeInsets.fromLTRB(4, 5, 0, 5),
      decoration: BoxDecoration(
        color: kbg2lightblack300.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularPercentIndicator(
            radius: 28,
            lineWidth: 4,
            percent: percent,
            progressColor: kblueaccent,
            backgroundColor: Colors.grey.shade800,
            circularStrokeCap: CircularStrokeCap.round,
            center: svg != null
                ? SvgPicture.asset(svg, color: kblueaccent, width: 20)
                : Icon(icon, color: kblueaccent, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: kblueaccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              AutoSizeText(
                value,
                style: TextStyle(color: kwhite, fontWeight: FontWeight.w700),
                maxLines: 1,
                minFontSize: 15,
                maxFontSize: 22,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _revenueCard(
  //   String title,
  //   String value, {
  //   String? svg,
  //   IconData? icon,
  //   double percent = 0.7,
  // }) {
  //   return Container(
  //     width: 150,
  //     height: 100,
  //     padding: const EdgeInsets.all(6),
  //     decoration: BoxDecoration(
  //       color: kbg2lightblack300.withOpacity(0.85),
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.25),
  //           blurRadius: 6,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         CircularPercentIndicator(
  //           radius: 28,
  //           lineWidth: 4,
  //           percent: percent,
  //           progressColor: kblueaccent,
  //           backgroundColor: Colors.grey.shade800,
  //           circularStrokeCap: CircularStrokeCap.round,
  //           center: svg != null
  //               ? SvgPicture.asset(svg, color: kblueaccent, width: 20)
  //               : Icon(icon, color: kblueaccent, size: 20),
  //         ),
  //         const SizedBox(width: 10),
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Text(
  //               title,
  //               style: TextStyle(
  //                 color: kblueaccent,
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //             const SizedBox(height: 8),
  //             Text(
  //               value,
  //               style: TextStyle(
  //                 color: kwhite,
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w700,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
