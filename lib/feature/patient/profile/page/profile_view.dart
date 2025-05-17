import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:se7ety/core/functions/navigation.dart';
import 'package:se7ety/core/utils/colors.dart';
import 'package:se7ety/core/utils/text_style.dart';
import 'package:se7ety/core/widgets/custom_button.dart';
import 'package:se7ety/feature/patient/profile/page/settings_view.dart';
import 'package:se7ety/feature/patient/profile/widgets/appointments_list.dart';
import 'package:se7ety/feature/patient/search/widgets/item_tile.dart';

class PatientProfile extends StatefulWidget {
  const PatientProfile({super.key});

  @override
  _PatientProfileState createState() => _PatientProfileState();
}

class _PatientProfileState extends State<PatientProfile> {
   String? _imagePath;
   String? userID;
   
  File? file;
  String? profileUrl;

  @override
  void initState() {
    super.initState();
    
    userID = FirebaseAuth.instance.currentUser?.uid;
  }
  Future<String> uploadImageToCloudinary(File image) async {
    final cloudinary =
        CloudinaryPublic('dw3cchwk0', 'borekphotos', cache: true);

    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path,
            resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('فشل رفع الصورة: $e');
    }
  }
   Future<void> _getUser() async {
    userID = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<void> _pickImage() async {
    _getUser();
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
        file = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
  
    if (userID == null) {
      return const Center(child: CircularProgressIndicator());
    }

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
              push(context, const UserSettings());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('patients')
                .doc(userID)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              var userData = snapshot.data;

              if (userData == null || !userData.exists) {
                return const Center(
                  child: Text('لم يتم العثور على البيانات.'),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: AppColors.white,
                                  child: CircleAvatar(
                              radius: 60,
                              backgroundImage: (_imagePath != null)
                                  ? FileImage(File(_imagePath!))
                                  : const AssetImage('assets/images/doc.png')
                                      as ImageProvider,
                            ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                     await _pickImage();
                                  },
                                  child: CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 20,
                                      
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${userData['name']}",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: getTitleStyle(),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  (userData['city'] == '')
                                      ? CustomButton(
                                          text: 'تعديل الحساب',
                                          height: 40,
                                          onPressed: () {},
                                        )
                                      : Text(
                                          userData['city'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: getbodyStyle(),
                                        ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Text(
                          "نبذه تعريفيه",
                          style: getbodyStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          userData['bio'] == '' ? 'لم تضاف' : userData['bio'],
                          style: getSmallStyle(),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Divider(),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          "معلومات التواصل",
                          style: getbodyStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
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
                              const SizedBox(
                                height: 15,
                              ),
                              TileWidget(
                                  text: userData['phone'] == ''
                                      ? 'لم تضاف'
                                      : userData['phone'],
                                  icon: Icons.call),
                            ],
                          ),
                        ),
                        const Divider(),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          "حجوزاتي",
                          style: getbodyStyle(fontWeight: FontWeight.w600),
                        ),
                        const MyAppointmentsHistory()
                      ],
                    )),
              );
            }),
      ),
    );
  }
}
