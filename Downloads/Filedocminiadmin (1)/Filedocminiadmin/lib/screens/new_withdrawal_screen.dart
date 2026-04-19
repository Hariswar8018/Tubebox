// import 'dart:io';
// import 'dart:math';
// import 'package:file_dock/constant/colors.dart';
// import 'package:file_dock/controllers/billing_controller.dart';
// import 'package:file_dock/widget/custom_app_bar.dart';
// import 'package:file_dock/model/withdrawal_model.dart';
// import 'package:file_dock/controllers/withdrawal_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';

// class WithdrawalScreen extends StatelessWidget {
//   WithdrawalScreen({super.key});

//   final WithdrawalProvider controller = Get.put(WithdrawalProvider());
//   final BillingController billingcontroller = Get.put(BillingController());
//   final ImagePicker picker = ImagePicker();

//   Future<void> _pickQr() async {
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       controller.setQr(File(picked.path));
//     }
//   }

//   Widget _inputField({
//     required TextEditingController controller,
//     required String hint,
//     TextInputType type = TextInputType.text,
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: type,
//       style: TextStyle(color: kwhite),
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: kbg2lightblack300,
//         hintText: hint,
//         hintStyle: TextStyle(color: ktext2white200),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide.none,
//         ),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       ),
//     );
//   }

//   Widget _sectionTitle(String text) {
//     return IntrinsicWidth(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             text,
//             style: TextStyle(
//               color: ktext1white100,
//               fontSize: 20,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           SizedBox(height: 7),
//           Container(
//             height: 3,
//             decoration: BoxDecoration(
//               color: kblueaccent,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: CustomAppBar(onRefresh: controller.onRefresh),
//         backgroundColor: kbg1black500,
//         body: Container(
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage("assets/images/register_bg.jpg"),
//               fit: BoxFit.cover,
//               opacity: 0.25,
//             ),
//           ),
//           child: SingleChildScrollView(
//             padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     IconButton(
//                       onPressed: () {
//                         Get.back();
//                       },
//                       icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
//                     ),
//                     Text(
//                       "New Withdrawal",
//                       style: TextStyle(
//                         color: kwhite,
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 20),

//                 Obx(() {
//                   final netAvailable = max(
//                     0,
//                     controller.approvedAmount.value -
//                         billingcontroller.paid.value,
//                   );

//                   return Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "Approved Amount Available",
//                         style: TextStyle(color: ktext2white200, fontSize: 16),
//                       ),
//                       Text(
//                         "₹ ${netAvailable.toStringAsFixed(2)}",
//                         style: TextStyle(
//                           color: kwhite,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   );
//                 }),

//                 SizedBox(height: 20),

//                 Text(
//                   "Amount to Withdraw",
//                   style: TextStyle(color: ktext1white100, fontSize: 16),
//                 ),
//                 SizedBox(height: 8),
//                 _inputField(
//                   controller: controller.amountController,
//                   hint: "Enter the amount",
//                   type: TextInputType.number,
//                 ),
//                 SizedBox(height: 16),

//                 Text(
//                   "Add UPI ID",
//                   style: TextStyle(color: ktext1white100, fontSize: 16),
//                 ),
//                 SizedBox(height: 8),
//                 _inputField(
//                   controller: controller.upiController,
//                   hint: "Enter UPI ID",
//                 ),
//                 SizedBox(height: 16),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Upload QR Code",
//                       style: TextStyle(color: ktext1white100, fontSize: 16),
//                     ),
//                     IconButton(
//                       onPressed: _pickQr,
//                       icon: Icon(Icons.upload, color: kwhite),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 8),
//                 Obx(
//                   () => controller.qrFile.value != null
//                       ? Text(
//                           "QR Selected",
//                           style: TextStyle(color: Colors.green),
//                         )
//                       : ElevatedButton(
//                           onPressed: _pickQr,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.transparent,
//                             side: BorderSide(color: kblueaccent),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(25),
//                             ),
//                           ),
//                           child: Text(
//                             "Upload",
//                             style: TextStyle(color: kblueaccent),
//                           ),
//                         ),
//                 ),
//                 SizedBox(height: 20),

//                 Center(
//                   child: SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: Obx(
//                       () => ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: kblueaccent,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(25),
//                           ),
//                         ),
//                         onPressed: controller.isLoading.value
//                             ? null
//                             : controller.submitRequest,
//                         child: controller.isLoading.value
//                             ? CircularProgressIndicator(color: Colors.white)
//                             : Text(
//                                 "Save",
//                                 style: TextStyle(
//                                   color: kblack,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 30),

//                 _sectionTitle("Approval Status"),
//                 SizedBox(height: 12),

//                 Obx(
//                   () => Column(
//                     children: controller.withdrawals.map((
//                       WithdrawalModel item,
//                     ) {
//                       Color statusColor = item.status == "pending"
//                           ? Colors.red
//                           : Colors.green;

//                       // ✅ FIXED Timestamp → DateTime conversion
//                       String dateText = "";
//                       if (item.requestedAt != null) {
//                         final dt = item.requestedAt!.toDate().toLocal();
//                         dateText = "${dt.day}-${dt.month}-${dt.year}";
//                       }

//                       return Container(
//                         margin: EdgeInsets.only(bottom: 10),
//                         padding: EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: kbg2lightblack300,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   "Amount : Rs ${item.amount}",
//                                   style: TextStyle(color: kwhite, fontSize: 14),
//                                 ),
//                                 Text(
//                                   "Date : $dateText",
//                                   style: TextStyle(
//                                     color: ktext2white200,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Text(
//                               "Status : ${item.status}",
//                               style: TextStyle(
//                                 color: statusColor,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:io';
import 'dart:math';
import 'package:file_dock/constant/colors.dart';
import 'package:file_dock/controllers/billing_controller.dart';
import 'package:file_dock/widget/custom_app_bar.dart';
import 'package:file_dock/model/withdrawal_model.dart';
import 'package:file_dock/controllers/withdrawal_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class WithdrawalScreen extends StatelessWidget {
  WithdrawalScreen({super.key});

  final WithdrawalProvider controller = Get.put(WithdrawalProvider());
  final BillingController billingcontroller = Get.put(BillingController());
  final ImagePicker picker = ImagePicker();

  // 🔑 GlobalKey for form
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickQr() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      controller.setQr(File(picked.path));
    }
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      style: TextStyle(color: kwhite),
      validator: validator, // ✅ validator added
      decoration: InputDecoration(
        filled: true,
        fillColor: kbg2lightblack300,
        hintText: hint,
        hintStyle: TextStyle(color: ktext2white200),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

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
          SizedBox(height: 7),
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(onRefresh: controller.onRefresh),
        backgroundColor: kbg1black500,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/register_bg.jpg"),
              fit: BoxFit.cover,
              opacity: 0.25,
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Form(
              key: _formKey, // ✅ form wrap
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "New Withdrawal",
                        style: TextStyle(
                          color: kwhite,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  Obx(() {
                    final netAvailable = max(
                      0,
                      controller.approvedAmount.value -
                          billingcontroller.paid.value,
                    );

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Approved Amount Available",
                          style: TextStyle(color: ktext2white200, fontSize: 16),
                        ),
                        Text(
                          "₹ ${netAvailable.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: kwhite,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }),

                  SizedBox(height: 20),

                  Text(
                    "Amount to Withdraw",
                    style: TextStyle(color: ktext1white100, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  _inputField(
                    controller: controller.amountController,
                    hint: "Enter the amount",
                    type: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter an amount";
                      }
                      final num? parsed = num.tryParse(value);
                      if (parsed == null) {
                        return "Invalid number";
                      }
                      if (parsed % 1 != 0) {
                        return "Amount must be a whole number";
                      }
                      if (parsed <= 0) {
                        return "Amount must be greater than 0";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  Text(
                    "Add UPI ID",
                    style: TextStyle(color: ktext1white100, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  _inputField(
                    controller: controller.upiController,
                    hint: "Enter UPI ID",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a UPI ID";
                      }
                      if (!value.contains("@")) {
                        return "Invalid UPI ID format";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Upload QR Code",
                        style: TextStyle(color: ktext1white100, fontSize: 16),
                      ),
                      IconButton(
                        onPressed: _pickQr,
                        icon: Icon(Icons.upload, color: kwhite),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Obx(
                    () => controller.qrFile.value != null
                        ? Text(
                            "QR Selected",
                            style: TextStyle(color: Colors.green),
                          )
                        : ElevatedButton(
                            onPressed: _pickQr,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              side: BorderSide(color: kblueaccent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              "Upload",
                              style: TextStyle(color: kblueaccent),
                            ),
                          ),
                  ),
                  SizedBox(height: 20),

                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Obx(
                        () => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kblueaccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: controller.isLoading.value
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    controller.submitRequest();
                                  }
                                },
                          child: controller.isLoading.value
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Save",
                                  style: TextStyle(
                                    color: kblack,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  _sectionTitle("Approval Status"),
                  SizedBox(height: 12),

                  Obx(
                    () => Column(
                      children: controller.withdrawals.map((
                        WithdrawalModel item,
                      ) {
                        Color statusColor = item.status == "pending"
                            ? Colors.red
                            : Colors.green;

                        String dateText = "";
                        if (item.requestedAt != null) {
                          final dt = item.requestedAt!.toDate().toLocal();
                          dateText = "${dt.day}-${dt.month}-${dt.year}";
                        }

                        return Container(
                          margin: EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kbg2lightblack300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Amount : Rs ${item.amount}",
                                    style: TextStyle(
                                      color: kwhite,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    "Date : $dateText",
                                    style: TextStyle(
                                      color: ktext2white200,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "Status : ${item.status}",
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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
