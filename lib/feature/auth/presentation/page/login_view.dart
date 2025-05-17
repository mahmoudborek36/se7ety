import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se7ety/core/enum/user_type_enum.dart';
import 'package:se7ety/core/functions/dialogs.dart';
import 'package:se7ety/core/functions/email_validate.dart';
import 'package:se7ety/core/functions/navigation.dart';
import 'package:se7ety/core/services/local_storage.dart';
import 'package:se7ety/core/utils/colors.dart';
import 'package:se7ety/core/utils/text_style.dart';
import 'package:se7ety/core/widgets/custom_button.dart';
import 'package:se7ety/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:se7ety/feature/auth/presentation/bloc/auth_event.dart';
import 'package:se7ety/feature/auth/presentation/bloc/auth_state.dart';
import 'package:se7ety/feature/auth/presentation/page/register_view.dart';
import 'package:se7ety/feature/doctor/nav_bar_widget.dart';
import 'package:se7ety/feature/patient/nav_bar.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key, required this.userType});
  final UserType userType;

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isVisible = true;

  String handleUserType() {
    return widget.userType == UserType.doctor ? 'دكتور' : 'مريض';
  }

  void handleUserTypeCache() {
    if (widget.userType == UserType.doctor) {
      AppLocalStorage.cacheData(key: AppLocalStorage.isDoctor, value: "true");
    } else {
      AppLocalStorage.cacheData(key: AppLocalStorage.isPatients, value: "true");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LoginLoadingState) {
          showLoadingDialog(context);
        } else {
          Navigator.pop(context); // يقفل ديالوج التحميل بعد أي حالة
        }

        if (state is LoginSuccessState) {
          handleUserTypeCache();
          if (widget.userType == UserType.patient) {
            pushAndRemoveUntil(context, const PatientNavBarWidget());
          } else {
            pushAndRemoveUntil(context, const DoctorNavBar());
          }
        } else if (state is AuthErrorState) {
          showErrorDialog(context, state.error);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          leading: const BackButton(),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 200,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'سجل دخول الان كـ "${handleUserType()}"',
                      style: getTitleStyle(),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.end,
                      decoration: const InputDecoration(
                        hintText: 'Borek@example.com',
                        prefixIcon: Icon(Icons.email_rounded),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'من فضلك ادخل الايميل';
                        } else if (!emailValidate(value)) {
                          return 'من فضلك ادخل الايميل صحيحا';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                    TextFormField(
                      controller: _passwordController,
                      textAlign: TextAlign.end,
                      obscureText: isVisible,
                      decoration: InputDecoration(
                        hintText: '********',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(isVisible
                              ? Icons.visibility_off
                              : Icons.remove_red_eye),
                          onPressed: () {
                            setState(() {
                              isVisible = !isVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'من فضلك ادخل كلمة السر';
                        }
                        return null;
                      },
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(top: 5, right: 10),
                      child: Text(
                        'نسيت كلمة السر ؟',
                        style: getSmallStyle(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: "تسجيل الدخول",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                                LoginEvent(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                  userType: widget.userType,
                                ),
                              );
                          handleUserTypeCache();
                        }
                      },
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ليس لدي حساب ؟',
                          style: getbodyStyle(color: AppColors.black),
                        ),
                        TextButton(
                          onPressed: () {
                            pushReplacement(
                              context,
                              RegisterView(userType: widget.userType),
                            );
                          },
                          child: Text(
                            'سجل الان',
                            style: getbodyStyle(color: AppColors.color1),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
