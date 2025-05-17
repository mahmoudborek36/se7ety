class AuthState {}

class AuthInitial extends AuthState {}



class LoginLoadingState extends AuthState {}

class LoginSuccessState extends AuthState {}



class RegisterLoadingState extends AuthState {}

class RegisterSuccessState extends AuthState {}



class UpdateDoctorLoadingState extends AuthState {}

class UpdateDoctorSuccessState extends AuthState {}



class AuthErrorState extends AuthState {
  final String error;
  AuthErrorState(this.error);
}
