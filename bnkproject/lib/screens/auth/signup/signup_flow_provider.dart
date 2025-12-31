// lib/screens/auth/signup/signup_flow_provider.dart
import 'package:flutter/foundation.dart';

enum SignupUserType { personal, company }
enum AuthChannel { phone, email, face }

class SignupFlowProvider extends ChangeNotifier {
  SignupUserType? userType;

  // Personal auth result
  AuthChannel? authChannel;
  String? verifiedTarget; // phone number or email
  bool personalVerified = false;

  // Face demo result
  String? faceCapturePath;
  bool faceTurnedLeft = false;
  bool faceTurnedRight = false;

  // Personal info form (MVP)
  String personalName = '';
  String personalPassword = '';

  // Company info form (MVP)
  String companyName = '';
  String bizNo = '';
  String managerName = '';
  String companyEmail = '';
  String companyPhone = '';
  String companyPassword = '';

  void selectUserType(SignupUserType type) {
    userType = type;

    // reset step states when user switches
    authChannel = null;
    verifiedTarget = null;
    personalVerified = false;
    faceCapturePath = null;
    faceTurnedLeft = false;
    faceTurnedRight = false;

    notifyListeners();
  }

  bool get canGoPersonalInfo {
    if (userType != SignupUserType.personal) return false;
    if (!personalVerified) return false;

    // ✅ face_legacy path 빈값 방지까지 포함
    if (authChannel == AuthChannel.face) {
      return (faceCapturePath != null) &&
          faceCapturePath!.isNotEmpty &&
          faceTurnedLeft &&
          faceTurnedRight;
    }

    return verifiedTarget != null && verifiedTarget!.isNotEmpty;
  }

  void setPersonalVerified({
    required AuthChannel channel,
    required String target,
  }) {
    authChannel = channel;
    verifiedTarget = target;
    personalVerified = true;
    notifyListeners();
  }

  void setFaceResult({
    required String path,
    required bool turnedLeft,
    required bool turnedRight,
  }) {
    authChannel = AuthChannel.face;
    personalVerified = true;
    faceCapturePath = path;
    faceTurnedLeft = turnedLeft;
    faceTurnedRight = turnedRight;
    notifyListeners();
  }

  // (선택) 외부에서 초기화하고 싶으면 사용
  void resetPersonalAuth() {
    authChannel = null;
    verifiedTarget = null;
    personalVerified = false;
    faceCapturePath = null;
    faceTurnedLeft = false;
    faceTurnedRight = false;
    notifyListeners();
  }
}
