import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:se7ety/core/utils/colors.dart';
import 'package:se7ety/core/utils/text_style.dart';
import 'package:se7ety/feature/doctor/profile/page/settings_view.dart';
import 'package:se7ety/feature/doctor/profile/widgets/appointments_list.dart';
import 'package:se7ety/feature/patient/search/widgets/item_tile.dart';

class DoctorProfileView extends StatefulWidget {
  const DoctorProfileView({super.key});

  @override
  _PatientProfileState createState() => _PatientProfileState();
}

class _PatientProfileState extends State<DoctorProfileView> {
  String? _imagePath;
  File? file;
  String? profileUrl;

  String? userId;

  Future<void> _getUser() async {
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  final cloudinary = CloudinaryPublic('dw3cchwk0', 'borekphotos', cache: false);

  Future<String?> uploadImageToCloudinary(File image) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl;
    } catch (e) {
      print('Upload Error: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    await _getUser();
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
        file = File(pickedFile.path);
      });

      profileUrl = await uploadImageToCloudinary(file!);
      if (profileUrl != null) {
        await FirebaseFirestore.instance.collection('doctors').doc(userId).set({
          'image': profileUrl,
        }, SetOptions(merge: true));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.color1,
        elevation: 0,
        title: const Text(
          'الحساب الشخصي',
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        actions: [
          IconButton(
            splashRadius: 20,
            icon: const Icon(
              Icons.settings,
              color: AppColors.white,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (contex) => const UserSettings()));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('doctors')
              .doc(userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            var userData = snapshot.data;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: AppColors.white,
                              child: CircleAvatar(
                                backgroundColor: AppColors.white,
                                radius: 60,
                                backgroundImage: (userData?['image'] != '')
                                    ? NetworkImage(userData?['image'])
                                    : (_imagePath != null)
                                        ? FileImage(File(_imagePath!)) as ImageProvider
                                        : const AssetImage('assets/doc.png'),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await _pickImage();
                              },
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 30),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${userData!['name']}",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: getTitleStyle(),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                userData['specialization'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: getbodyStyle(),
                              ),
                              const SizedBox(height: 15),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Text(
                      "نبذه تعريفيه",
                      style: getbodyStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userData['bio'] == '' ? 'لم تضاف' : userData['bio'],
                      style: getSmallStyle(),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    Text(
                      "معلومات التواصل",
                      style: getbodyStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(15),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.accentColor,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TileWidget(
                              text: userData['email'] ?? 'لم تضاف',
                              icon: Icons.email),
                          const SizedBox(height: 15),
                          TileWidget(text: userData['phone1'], icon: Icons.call),
                        ],
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(15),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.accentColor,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TileWidget(
                              text:
                                  '${userData['openHour']}:00 - ${userData['closeHour']}:00',
                              icon: Icons.email),
                          const SizedBox(height: 15),
                          TileWidget(text: userData['phone1'], icon: Icons.call),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "حجوزاتي",
                      style: getbodyStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 400, // تحديد ارتفاع ثابت لقائمة الحجوزات
                      child: const MyAppointmentsHistory(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
