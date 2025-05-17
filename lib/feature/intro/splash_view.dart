import 'package:flutter/material.dart';
import 'package:se7ety/core/functions/navigation.dart';
import 'package:se7ety/core/services/local_storage.dart';
import 'package:se7ety/feature/doctor/nav_bar_widget.dart';
import 'package:se7ety/feature/intro/onboarding/onboarding_view.dart';
import 'package:se7ety/feature/intro/welcome_view.dart';
import 'package:se7ety/feature/patient/nav_bar.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  @override
  void initState() {
    super.initState();
  // AppLocalStorage.removeDta(key: AppLocalStorage.isPatients);
  //     AppLocalStorage.removeDta(key: AppLocalStorage.isDoctor);
  //     AppLocalStorage.removeDta(key: AppLocalStorage.isOnboardingShown);
    Future.delayed(const Duration(seconds: 3), () {
      String? isdoc =
          AppLocalStorage.getData(key: AppLocalStorage.isDoctor) ;
      String? ispa =
          AppLocalStorage.getData(key: AppLocalStorage.isPatients) ;
      bool isOnboardingShown =
          AppLocalStorage.getData(key: AppLocalStorage.isOnboardingShown) ??
              false;
          
      if (isdoc!=null) {
        pushReplacement(context, const DoctorNavBar());
      } else if (ispa!=null) {
        pushReplacement(context, const PatientNavBarWidget());
      } else if (isOnboardingShown) {
        pushReplacement(context, const WelcomeView());
      } else {
        pushReplacement(context, const OnboardingView());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 250,
            ),
          ],
        ),
      ),
    );
  }
}
