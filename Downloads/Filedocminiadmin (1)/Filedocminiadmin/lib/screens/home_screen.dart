import 'package:file_dock/controllers/home_controller.dart';
import 'package:file_dock/controllers/withdrawal_controller.dart';
import 'package:file_dock/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import '../constant/colors.dart';

import 'package:file_dock/controllers/home_controller.dart';
import 'package:file_dock/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../constant/colors.dart';
import '../controllers/billing_controller.dart';
import '../controllers/profile_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeScreenController controller = Get.put(HomeScreenController());

    final BillingController billingcontroller = Get.put(BillingController());
    final WithdrawalProvider wcontroller = Get.put(WithdrawalProvider());

    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: kbg1black500,
      body: Stack(
        children: [
          /// Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/svg icons/home svgs/home_background.jpg",
                ),
                fit: BoxFit.cover,
                opacity: 0.25,
              ),
            ),
          ),

          /// Main content with RefreshIndicator
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: RefreshIndicator(
              color: kblueaccent,
              onRefresh: () async {
                /// call your controller refresh logic
                await controller.refreshData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(), // 👈 important
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Revenue Analytics
                    _sectionTitle("Revenue Analytics"),
                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: "Total",
                            value: Obx(
                              () => Text(
                                "Rs ${wcontroller.approvedAmount.value.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: kwhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            title: "Paid",
                            value: Obx(
                              () => Text(
                                "Rs ${billingcontroller.paid.value.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: kwhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    StatCard(
                      title: "Pending",
                      value: Obx(
                        () => Text(
                          "Rs ${billingcontroller.pending.value.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: kwhite,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// Daily Analytics
                    _sectionTitle("Daily Analytics"),
                    const SizedBox(height: 15),
                    InkWell(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: kblueaccent,
                                  // selected day / header
                                  onPrimary: kblack,
                                  // text on selected day
                                  surface: kbg2lightblack300,
                                  // picker background
                                  onSurface: kwhite, // default text color
                                ),
                                dialogBackgroundColor: kbg1black500,
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          await controller.fetchAnalyticsForPickedDate(picked);
                        }
                      },
                      child: Obx(
                        () => StatCardTitleIcon(
                          title: controller.todayDate.value,
                          icon: SvgPicture.asset(
                            "assets/svg icons/home svgs/date.svg",
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    Obx(
                      () => StatCardWithIcon(
                        title: "Files Uploaded",
                        value: controller.dailyFilesUploaded.value.toString(),
                        icon: SvgPicture.asset(
                          "assets/svg icons/home svgs/upload.svg",
                          width: 70,
                          height: 70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      () => StatCardWithIcon(
                        title: "Clicks",
                        value: controller.dailyClicks.value.toString(),
                        icon: SvgPicture.asset(
                          "assets/svg icons/home svgs/clicks.svg",
                          width: 70,
                          height: 70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      () => StatCardWithIcon(
                        title: "Earned",
                        value:
                            "Rs ${controller.dailyEarned.value.toStringAsFixed(2)}",
                        icon: SvgPicture.asset(
                          "assets/svg icons/home svgs/earned.svg",
                          width: 70,
                          height: 70,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// Monthly Analytics
                    _sectionTitle("Monthly Analytics"),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        DateTime? picked = await showMonthPicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2023, 1),
                          lastDate: DateTime.now(),
                          monthPickerDialogSettings: MonthPickerDialogSettings(
                            actionBarSettings: PickerActionBarSettings(
                              cancelWidget: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: kblueaccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              confirmWidget: Text(
                                'Ok',
                                style: TextStyle(
                                  color: kblueaccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            dialogSettings: PickerDialogSettings(
                              dialogBackgroundColor: kbg2lightblack300,
                            ),
                            dateButtonsSettings: PickerDateButtonsSettings(
                              currentMonthTextColor: kblueaccent,
                              monthTextStyle: TextStyle(color: kblack),
                              selectedMonthBackgroundColor: kblueaccent,
                              unselectedMonthsTextColor: kwhite,
                              unselectedYearsTextColor: kwhite,
                              selectedMonthTextColor: kblack,
                            ),
                            headerSettings: PickerHeaderSettings(
                              headerBackgroundColor: kblueaccent,
                              headerIconsColor: kblack,
                              headerCurrentPageTextStyle: TextStyle(
                                color: kblack,
                              ),
                              headerSelectedIntervalTextStyle: TextStyle(
                                color: kblack,
                              ),
                            ),
                          ),
                        );
                        if (picked != null) {
                          await controller.fetchAnalyticsForPickedMonth(picked);
                        }
                      },
                      child: Obx(
                        () => StatCardTitleIcon(
                          title: controller.currentMonth.value,
                          icon: SvgPicture.asset(
                            "assets/svg icons/home svgs/date.svg",
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    Obx(
                      () => StatCardWithIcon(
                        title: "Files Uploaded",
                        value: controller.monthlyFilesUploaded.value.toString(),
                        icon: SvgPicture.asset(
                          "assets/svg icons/home svgs/upload.svg",
                          width: 70,
                          height: 70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      () => StatCardWithIcon(
                        title: "Clicks",
                        value: controller.monthlyClicks.value.toString(),
                        icon: SvgPicture.asset(
                          "assets/svg icons/home svgs/clicks.svg",
                          width: 70,
                          height: 70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      () => StatCardWithIcon(
                        title: "Earned",
                        value:
                            "Rs ${controller.monthlyEarned.value.toStringAsFixed(2)}",
                        icon: SvgPicture.asset(
                          "assets/svg icons/home svgs/earned.svg",
                          width: 70,
                          height: 70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- Widgets ----------------

Widget _sectionTitle(String text) {
  return IntrinsicWidth(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            color: ktext1white100,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          height: 3,
          decoration: BoxDecoration(
            color: kblueaccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    ),
  );
}

/// Simple card (accepts any widget as value)
class StatCard extends StatelessWidget {
  final String title;
  final Widget value;

  const StatCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: kbg2lightblack300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: ktext2white200, fontSize: 14)),
          value,
        ],
      ),
    );
  }
}

/// Card with icon
class StatCardWithIcon extends StatelessWidget {
  final String title;
  final String value;
  final Widget icon;

  const StatCardWithIcon({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: kbg2lightblack300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// Texts
          Padding(
            padding: const EdgeInsets.only(left: 15), // small breathing space
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              // 👈 left-align text
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: kwhite,
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: TextStyle(color: ktext2white200, fontSize: 20),
                ),
              ],
            ),
          ),

          /// Icon
          icon,
        ],
      ),
    );
  }
}

/// Card with only title and icon
class StatCardTitleIcon extends StatelessWidget {
  final String title;
  final Widget icon;
  final Color? iconColor;
  final Color? bgColor;

  const StatCardTitleIcon({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: bgColor ?? kbg2lightblack300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// Title
          Text(
            title,
            style: TextStyle(
              color: ktext2white200,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),

          /// Icon
          icon,
        ],
      ),
    );
  }
}
