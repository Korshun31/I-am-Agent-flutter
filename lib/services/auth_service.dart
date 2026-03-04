import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class UserProfile {
  final String id;
  final String email;
  final String name;
  final String lastName;
  final String phone;
  final String telegram;
  final String whatsapp;
  final String documentNumber;
  final String? photoUri;
  final String? language;
  final Map<String, dynamic>? notificationSettings;
  final String? selectedCurrency;
  final List<dynamic>? locations;

  UserProfile({
    required this.id,
    required this.email,
    this.name = '',
    this.lastName = '',
    this.phone = '',
    this.telegram = '',
    this.whatsapp = '',
    this.documentNumber = '',
    this.photoUri,
    this.language,
    this.notificationSettings,
    this.selectedCurrency,
    this.locations,
  });
}

Future<UserProfile?> signIn({required String email, required String password}) async {
  final res = await supabase.auth.signInWithPassword(email: email, password: password);
  if (res.user == null) return null;
  return getUserProfile(res.user!.id);
}

Future<UserProfile> signUp({required String email, required String password, String? name}) async {
  final res = await supabase.auth.signUp(email: email, password: password);
  if (res.user == null) throw Exception('Registration failed');

  await supabase.from('agents').insert({
    'id': res.user!.id,
    'email': email,
    'name': name ?? '',
  });

  return (await getUserProfile(res.user!.id))!;
}

Future<void> signOut() async {
  await supabase.auth.signOut();
}

Future<UserProfile?> getCurrentUser() async {
  final session = await supabase.auth.getSession();
  if (session.session?.user == null) return null;
  return getUserProfile(session.session!.user.id);
}

Future<UserProfile?> getUserProfile(String userId) async {
  try {
    final res = await supabase.from('agents').select().eq('id', userId).single();
    final data = res;
    final settings = data['settings'] as Map<String, dynamic>? ?? {};
    return UserProfile(
      id: data['id'] ?? userId,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      lastName: data['last_name'] ?? '',
      phone: data['phone'] ?? '',
      telegram: data['telegram'] ?? '',
      whatsapp: data['whatsapp'] ?? '',
      documentNumber: data['document_number'] ?? '',
      photoUri: data['photo_url'],
      language: settings['language'],
      notificationSettings: settings['notificationSettings'] as Map<String, dynamic>?,
      selectedCurrency: settings['selectedCurrency'],
      locations: settings['locations'] as List<dynamic>?,
    );
  } catch (_) {
    return null;
  }
}
