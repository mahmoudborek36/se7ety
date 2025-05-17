import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:se7ety/core/constants/specialization_data.dart';
import 'package:se7ety/core/enum/user_type_enum.dart';
import 'package:se7ety/core/functions/dialogs.dart';
import 'package:se7ety/core/functions/navigation.dart';
import 'package:se7ety/core/services/local_storage.dart';
import 'package:se7ety/core/utils/colors.dart';
import 'package:se7ety/core/utils/text_style.dart';
import 'package:se7ety/feature/auth/data/models/doctor_model.dart';
import 'package:se7ety/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:se7ety/feature/auth/presentation/bloc/auth_event.dart';
import 'package:se7ety/feature/auth/presentation/bloc/auth_state.dart';
import 'package:se7ety/feature/doctor/nav_bar_widget.dart';

class DoctorRegistrationView extends StatefulWidget {
  const DoctorRegistrationView({super.key, required this.userType});
  final UserType userType;

  @override
  _DoctorRegistrationViewState createState() => _DoctorRegistrationViewState();
}

class _DoctorRegistrationViewState extends State<DoctorRegistrationView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _bio = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _phone1 = TextEditingController();
  final TextEditingController _phone2 = TextEditingController();
  String _specialization = specialization[0];

  late String _startTime =
      DateFormat('hh').format(DateTime(2023, 9, 7, 10, 00));
  late String _endTime = DateFormat('hh').format(DateTime(2023, 9, 7, 22, 00));

  String? _imagePath;
  String? userID;

  File? file;
  String? profileUrl;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    userID = FirebaseAuth.instance.currentUser!.uid;
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.color1,
        title: const Text('إكمال عملية التسجيل'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is UpdateDoctorSuccessState) {
            pushAndRemoveUntil(context, const DoctorNavBar());
          } else if (state is AuthErrorState) {
            Navigator.pop(context);
            showErrorDialog(context, state.error);
          } else if (state is UpdateDoctorLoadingState) {
            showLoadingDialog(context);
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
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
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              child: const Icon(Icons.camera_alt_rounded,
                                  size: 20),
                            ),
                          ),
                        ],
                      ),
                      const Gap(10),
                      Row(
                        children: [
                          Text('التخصص',
                              style: getbodyStyle(color: AppColors.black)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.accentColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: DropdownButton(
                          isExpanded: true,
                          iconEnabledColor: AppColors.color1,
                          icon: const Icon(Icons.expand_circle_down_outlined),
                          value: _specialization,
                          onChanged: (String? newValue) {
                            setState(() {
                              _specialization = newValue ?? specialization[0];
                            });
                          },
                          items: specialization.map((element) {
                            return DropdownMenuItem(
                              value: element,
                              child: Text(element),
                            );
                          }).toList(),
                        ),
                      ),
                      const Gap(10),
                      Row(
                        children: [
                          Text('نبذة تعريفية',
                              style: getbodyStyle(color: AppColors.black)),
                        ],
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        maxLines: 5,
                        controller: _bio,
                        style: const TextStyle(color: AppColors.black),
                        decoration: const InputDecoration(
                            hintText:
                                'سجل المعلومات الطبية العامة مثل تعليمك الأكاديمي وخبراتك السابقة...'),
                        validator: (value) => value!.isEmpty
                            ? 'من فضلك ادخل النبذة التعريفية'
                            : null,
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Text('عنوان العيادة',
                              style: getbodyStyle(color: AppColors.black)),
                        ],
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        controller: _address,
                        style: const TextStyle(color: AppColors.black),
                        decoration: const InputDecoration(
                            hintText: '5 شارع مصدق - الدقي - الجيزة'),
                        validator: (value) => value!.isEmpty
                            ? 'من فضلك ادخل عنوان العيادة'
                            : null,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ساعات العمل من',
                                    style:
                                        getbodyStyle(color: AppColors.black)),
                                TextFormField(
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      onPressed: () async =>
                                          await showStartTimePicker(),
                                      icon: const Icon(
                                          Icons.watch_later_outlined,
                                          color: AppColors.color1),
                                    ),
                                    hintText: _startTime,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('إلى',
                                    style:
                                        getbodyStyle(color: AppColors.black)),
                                TextFormField(
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      onPressed: () async =>
                                          await showEndTimePicker(),
                                      icon: const Icon(
                                          Icons.watch_later_outlined,
                                          color: AppColors.color1),
                                    ),
                                    hintText: _endTime,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Gap(10),
                      Row(
                        children: [
                          Text('رقم الهاتف 1',
                              style: getbodyStyle(color: AppColors.black)),
                        ],
                      ),
                      TextFormField(
                        controller: _phone1,
                        decoration:
                            const InputDecoration(hintText: '+20xxxxxxxxxx'),
                        validator: (value) =>
                            value!.isEmpty ? 'من فضلك ادخل الرقم' : null,
                      ),
                      const Gap(10),
                      Row(
                        children: [
                          Text('رقم الهاتف 2 (اختياري)',
                              style: getbodyStyle(color: AppColors.black)),
                        ],
                      ),
                      TextFormField(
                        controller: _phone2,
                        decoration:
                            const InputDecoration(hintText: '+20xxxxxxxxxx'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.only(top: 25.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (file != null) {
                  try {
                    profileUrl = await uploadImageToCloudinary(file!);
                  } catch (e) {
                    showErrorDialog(context, 'حدث خطأ أثناء رفع الصورة');
                    return;
                  }

                  context.read<AuthBloc>().add(UpdateDoctorRegistrationEvent(
                        model: DoctorModel(
                          uid: userID,
                          phone1: _phone1.text,
                          phone2: _phone2.text,
                          address: _address.text,
                          specialization: _specialization,
                          openHour: _startTime,
                          closeHour: _endTime,
                          bio: _bio.text,
                          image: profileUrl,
                        ),
                      ));

                  AppLocalStorage.cacheData(
                      key: AppLocalStorage.isDoctor, value: "true");
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('من فضلك قم بتحميل صورتك الشخصية')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.color1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('التسجيل',
                style: getTitleStyle(fontSize: 16, color: AppColors.white)),
          ),
        ),
      ),
    );
  }

  Future<void> showStartTimePicker() async {
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() => _startTime = picked.hour.toString());
    }
  }

  Future<void> showEndTimePicker() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
          DateTime.now().add(const Duration(minutes: 15))),
    );
    if (picked != null) {
      setState(() => _endTime = picked.hour.toString());
    }
  }
}
