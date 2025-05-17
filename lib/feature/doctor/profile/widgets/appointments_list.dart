import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:se7ety/core/utils/colors.dart';
import 'package:se7ety/core/utils/text_style.dart';

class MyAppointmentsHistory extends StatefulWidget {
  const MyAppointmentsHistory({super.key});

  @override
  _MyAppointmentsHistoryState createState() => _MyAppointmentsHistoryState();
}

class _MyAppointmentsHistoryState extends State<MyAppointmentsHistory> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    final currentUser = _auth.currentUser;
    setState(() {
      user = currentUser;
    });
  }

  Future<void> deleteAppointment(String docID) {
    return FirebaseFirestore.instance
        .collection('appointments')
        .doc('appointments')
        .collection('pending')
        .doc(docID)
        .delete();
  }

  String _dateFormatter(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  String _timeFormatter(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  void showAlertDialog(BuildContext context, String docID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: const Text("حذف الحجز"),
          content: const Text("هل متأكد من حذف هذا الحجز؟"),
          actions: [
            TextButton(
              child: const Text("لا"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("نعم"),
              onPressed: () {
                deleteAppointment(docID);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _checkDiff(DateTime date) {
    return DateTime.now().difference(date).inHours > 2;
  }

  bool _compareDate(DateTime date) {
    return _dateFormatter(DateTime.now()) == _dateFormatter(date);
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .doc('appointments')
                  .collection('pending')
                  .where('doctorID', isEqualTo: user!.email)
                  .orderBy('date')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/images/no_scheduled.svg',
                            width: 250),
                        Text('لا يوجد حجوزات قادمة', style: getbodyStyle()),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                // حذف الحجوزات التي مرت عليها أكثر من ساعتين (اختياري)
                for (var doc in docs) {
                  final Timestamp timestamp = doc['date'];
                  final dateTime = timestamp.toDate();

                  if (_checkDiff(dateTime)) {
                    deleteAppointment(doc.id);
                  }
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final document = docs[index];
                    final Timestamp timestamp = document['date'];
                    final dateTime = timestamp.toDate();

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.accentColor,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(-3, 0),
                              blurRadius: 15,
                              color: Colors.grey.withOpacity(.1),
                            )
                          ],
                        ),
                        child: ExpansionTile(
                          childrenPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                          expandedCrossAxisAlignment: CrossAxisAlignment.end,
                          backgroundColor: AppColors.accentColor,
                          collapsedBackgroundColor: AppColors.accentColor,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(
                                  'د. ${document['doctor']}',
                                  style: getTitleStyle(),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 5, left: 5),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_month_rounded,
                                        color: AppColors.color1, size: 16),
                                    const SizedBox(width: 10),
                                    Text(
                                      _dateFormatter(dateTime),
                                      style: getbodyStyle(),
                                    ),
                                    const SizedBox(width: 30),
                                    Text(
                                      _compareDate(dateTime) ? "اليوم" : "",
                                      style: getbodyStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.watch_later_outlined,
                                        color: AppColors.color1, size: 16),
                                    const SizedBox(width: 10),
                                    Text(
                                      _timeFormatter(dateTime),
                                      style: getbodyStyle(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 5, right: 10, left: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('اسم المريض: ${document['name']}'),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_rounded,
                                          color: AppColors.color1, size: 16),
                                      const SizedBox(width: 10),
                                      Text(document['location']),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          foregroundColor: AppColors.white,
                                          backgroundColor: AppColors.redColor),
                                      onPressed: () =>
                                          showAlertDialog(context, document.id),
                                      child: const Text('حذف الحجز'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
