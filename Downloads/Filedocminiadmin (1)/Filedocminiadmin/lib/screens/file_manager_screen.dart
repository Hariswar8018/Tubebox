// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import '../controllers/file_manager_controller.dart';
// import '../model/videoModel.dart';
// import '../constant/colors.dart';
// import '../widget/custom_app_bar.dart';

// class FileManagerScreen extends StatelessWidget {
//   const FileManagerScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(FileManagerController());

//     return Scaffold(
//       appBar: CustomAppBar(),
//       backgroundColor: kbg1black500,
//       body: Stack(
//         children: [
//           /// Background image
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage("assets/images/home_BG.jpg"),
//                 fit: BoxFit.cover,
//                 opacity: 0.15,
//               ),
//             ),
//           ),

//           /// Content
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _sectionTitle("File Manager"),
//                 const SizedBox(height: 14),

//                 /// File list
//                 Expanded(
//                   child: Obx(
//                     () => RefreshIndicator(
//                       onRefresh: () async {
//                         controller.onInit(); // reload stream
//                       },
//                       child: controller.files.isEmpty
//                           ? const Center(
//                               child: Text(
//                                 "No files uploaded",
//                                 style: TextStyle(
//                                   color: Colors.white70,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             )
//                           : ListView.builder(
//                               itemCount: controller.files.length,
//                               itemBuilder: (context, index) {
//                                 final video = controller.files[index];
//                                 return GestureDetector(
//                                   onTap: () {
//                                     // Get.to(() => VideoPlayerScreen(
//                                     //   videoUrl: video.storageUrl,
//                                     // ));
//                                   },
//                                   child: FileCard(
//                                     video: video,
//                                     onDelete: () =>
//                                         controller.deleteFile(index),
//                                     onCopy: () =>
//                                         controller.copyFileLink(video),
//                                   ),
//                                 );
//                               },
//                             ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
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
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 6),
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
// }

// /// -------------------- FILE CARD --------------------
// class FileCard extends StatelessWidget {
//   final VideoModel video;
//   final VoidCallback onDelete;
//   final VoidCallback onCopy;

//   const FileCard({
//     super.key,
//     required this.video,
//     required this.onDelete,
//     required this.onCopy,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 81,
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       padding: const EdgeInsets.symmetric(horizontal: 14),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1E1E1E),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           /// LEFT → File type icon
//           Container(
//             height: 61,
//             width: 61,
//             decoration: BoxDecoration(
//               color: ktext2white200,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Center(
//               child: SvgPicture.asset(
//                 "assets/svg icons/file manager svg/camera.svg",
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),

//           /// File details (title + size/views)
//           Expanded(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 /// File name (video title)
//                 Text(
//                   "https://filedock/${video.id}",
//                   style: TextStyle(
//                     color: kwhite,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),

//                 const SizedBox(height: 10),

//                 /// Size + Views
//                 Row(
//                   children: [
//                     Text(
//                       "${(video.size / (1024 * 1024)).toStringAsFixed(2)} MB",
//                       style: TextStyle(color: ktext3white300, fontSize: 16),
//                     ),
//                     const SizedBox(width: 32),
//                     Row(
//                       children: [
//                         Text(
//                           "${video.views}",
//                           style: TextStyle(color: ktext3white300, fontSize: 16),
//                         ),
//                         const SizedBox(width: 4),
//                         SvgPicture.asset(
//                           "assets/svg icons/file manager svg/eye.svg",
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           /// RIGHT SIDE → actions + date
//           Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               /// Copy & Delete row
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   GestureDetector(
//                     onTap: onCopy,
//                     child: SvgPicture.asset(
//                       "assets/svg icons/file manager svg/copy.svg",
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   GestureDetector(
//                     onTap: onDelete,
//                     child: SvgPicture.asset(
//                       "assets/svg icons/file manager svg/delete.svg",
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 6),

//               /// Date
//               Text(
//                 video.createdAt != null
//                     ? DateFormat("dd/MM/yyyy").format(
//                         video.createdAt is DateTime
//                             ? video.createdAt
//                             : (video.createdAt as Timestamp).toDate(),
//                       )
//                     : "",
//                 style: TextStyle(color: ktext3white300, fontSize: 16),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/file_manager_controller.dart';
import '../model/videoModel.dart';
import '../constant/colors.dart';
import '../widget/custom_app_bar.dart';

class FileManagerScreen extends StatelessWidget {
  const FileManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FileManagerController());

    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: kbg1black500,
      body: Stack(
        children: [
          /// Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/home_BG.jpg"),
                fit: BoxFit.cover,
                opacity: 0.15,
              ),
            ),
          ),

          /// Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle("File Manager"),
                const SizedBox(height: 14),

                /// File list
                Expanded(
                  child: Obx(
                    () => RefreshIndicator(
                      color: kblueaccent,
                      onRefresh: () async {
                        controller.onInit(); // reload stream
                      },
                      child: controller.files.isEmpty
                          ? const Center(
                              child: Text(
                                "No files uploaded",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: controller.files.length,
                              itemBuilder: (context, index) {
                                final video = controller.files[index];
                                return GestureDetector(
                                  onTap: () {
                                    // Get.to(() => VideoPlayerScreen(
                                    //   videoUrl: video.storageUrl,
                                    // ));
                                  },
                                  child: FileCard(
                                    video: video,
                                    onDelete: () =>
                                        controller.deleteFile(index),
                                    onCopy: () =>
                                        controller.copyFileLink(video),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
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
}

/// -------------------- FILE CARD --------------------
class FileCard extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onDelete;
  final VoidCallback onCopy;

  const FileCard({
    super.key,
    required this.video,
    required this.onDelete,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 81,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// LEFT → File type icon
          Container(
            height: 61,
            width: 61,
            decoration: BoxDecoration(
              color: ktext2white200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SvgPicture.asset(
                "assets/svg icons/file manager svg/camera.svg",
              ),
            ),
          ),
          const SizedBox(width: 12),

          /// File details (title + size/views)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// File name (video title)
                Text(
                  "${video.netlifyUrl}",
                  style: TextStyle(
                    color: kwhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                /// Size + Views
                Row(
                  children: [
                    Text(
                      "${(video.size / (1024 * 1024)).toStringAsFixed(2)} MB",
                      style: TextStyle(color: ktext3white300, fontSize: 16),
                    ),
                    // const SizedBox(width: 32),
                    // Row(
                    //   children: [
                    //     Text(
                    //       "${video.views}",
                    //       style: TextStyle(color: ktext3white300, fontSize: 16),
                    //     ),
                    //     const SizedBox(width: 4),
                    //     SvgPicture.asset(
                    //       "assets/svg icons/file manager svg/eye.svg",
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ],
            ),
          ),

          /// RIGHT SIDE → actions + date
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              /// Copy & Delete row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onCopy,
                    child: SvgPicture.asset(
                      "assets/svg icons/file manager svg/copy.svg",
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onDelete,
                    child: SvgPicture.asset(
                      "assets/svg icons/file manager svg/delete.svg",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              /// Date
              Text(
                video.createdAt != null
                    ? DateFormat("dd/MM/yyyy").format(
                        video.createdAt is DateTime
                            ? video.createdAt
                            : (video.createdAt as Timestamp).toDate(),
                      )
                    : "",
                style: TextStyle(color: ktext3white300, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
