import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:se7ety/core/utils/colors.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;

  final List<String> labelName = [
    'الاسم',
    'البريد الإلكتروني',
    'التخصص',
    'العنوان',
    'نبذة',
    'رقم الهاتف 1',
    'رقم الهاتف 2',
    'ساعة الفتح',
    'ساعة الإغلاق',
  ];

  final List<String> value = [
    'name',
    'email',
    'specialization',
    'address',
    'bio',
    'phone1',
    'phone2',
    'openHour',
    'closeHour',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppColors.color1,
          title: const Text("بيانات الدكتور")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .doc(user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("لا توجد بيانات."));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: List.generate(
              labelName.length,
              (index) => InkWell(
                onTap: () {
                  var con = TextEditingController(
                    text: userData[value[index]] == '' ||
                            userData[value[index]] == null
                        ? 'لم تضاف'
                        : userData[value[index]],
                  );
                  var form = GlobalKey<FormState>();

                  showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        alignment: Alignment.center,
                        contentPadding: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        children: [
                          Form(
                            key: form,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'ادخل ${labelName[index]}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: con,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'من فضلك ادخل ${labelName[index]}.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    if (form.currentState!.validate()) {
                                      updateData(value[index], con.text);
                                    }
                                  },
                                  child: const Text("حفظ التعديل"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade200,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        labelName[index],
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Flexible(
                        child: Text(
                          userData[value[index]] == '' ||
                                  userData[value[index]] == null
                              ? 'لم تضاف'
                              : userData[value[index]].toString(),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> updateData(String key, value) async {
    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(user!.uid)
        .update({key: value});

    if (key == "name") {
      await user?.updateDisplayName(value);
    }

    Navigator.pop(context);
  }
}
