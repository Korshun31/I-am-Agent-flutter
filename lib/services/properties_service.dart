import 'supabase_service.dart';
import '../models/property.dart';

Future<List<Property>> getProperties() async {
  final session = await supabase.auth.getSession();
  if (session.session?.user == null) return [];

  try {
    final res = await supabase
        .from('properties')
        .select()
        .eq('agent_id', session.session!.user.id)
        .order('name');

    final list = res as List<dynamic>? ?? [];
    return list.map((e) => Property.fromJson(e as Map<String, dynamic>)).toList();
  } catch (_) {
    return [];
  }
}

Future<Property> createProperty({
  required String name,
  required String code,
  String type = 'house',
  String? locationId,
  String? ownerId,
}) async {
  final session = await supabase.auth.getSession();
  if (session.session?.user == null) {
    throw Exception('Not authenticated');
  }

  final res = await supabase.from('properties').insert({
    'agent_id': session.session!.user.id,
    'name': name,
    'code': code,
    'type': type,
    'location_id': locationId,
    'owner_id': ownerId,
  }).select().single();

  return Property.fromJson(res as Map<String, dynamic>);
}

Future<Property> createPropertyFull(Map<String, dynamic> updates) async {
  final session = await supabase.auth.getSession();
  if (session.session?.user == null) {
    throw Exception('Not authenticated');
  }

  final row = {
    'agent_id': session.session!.user.id,
    ...updates,
  };

  final res = await supabase.from('properties').insert(row).select().single();
  return Property.fromJson(res as Map<String, dynamic>);
}

Future<Property> updateProperty(String id, Map<String, dynamic> updates) async {
  final session = await supabase.auth.getSession();
  if (session.session?.user == null) {
    throw Exception('Not authenticated');
  }

  final res = await supabase
      .from('properties')
      .update(updates)
      .eq('id', id)
      .eq('agent_id', session.session!.user.id)
      .select()
      .single();

  return Property.fromJson(res as Map<String, dynamic>);
}

Future<void> deleteProperty(String id) async {
  final session = await supabase.auth.getSession();
  if (session.session?.user == null) {
    throw Exception('Not authenticated');
  }

  await supabase
      .from('properties')
      .delete()
      .eq('id', id)
      .eq('agent_id', session.session!.user.id);
}
