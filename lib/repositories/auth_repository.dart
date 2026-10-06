import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  final _supabase = supa.Supabase.instance.client;

  Future<User> login(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Login failed');
    }

    return await _fetchUserProfile(response.user!.id);
  }

  Future<User> signUp(String email, String password, String name) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );

    if (response.user == null) {
      throw Exception('Sign up failed');
    }

    return await _fetchUserProfile(response.user!.id, name: name);
  }

  Future<User> googleLogin(String idToken) async {
    final response = await _supabase.auth.signInWithIdToken(
      provider: supa.OAuthProvider.google,
      idToken: idToken,
    );

    if (response.user == null) {
      throw Exception('Google login failed');
    }

    return await _fetchUserProfile(response.user!.id);
  }

  Future<User> me() async {
    final session = _supabase.auth.currentSession;
    if (session == null) {
      throw Exception('Not authenticated');
    }
    
    return await _fetchUserProfile(session.user.id);
  }

  Future<User> _fetchUserProfile(String userId, {String? name}) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('user_id', userId)
          .single();
          
      return User.fromJson(data);
    } catch (e) {
      // If user profile doesn't exist by user_id, check if it exists by email
      try {
        final email = _supabase.auth.currentUser?.email ?? 'unknown@example.com';
        
        // Try to find an existing user by email (e.g. if auth user was deleted but public user remained)
        final existing = await _supabase
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();

        if (existing != null) {
          // Update the user_id of the existing profile to match the new auth user
          final updated = await _supabase
            .from('users')
            .update({'user_id': userId})
            .eq('email', email)
            .select()
            .single();
          return User.fromJson(updated);
        }

        // Otherwise create a fresh profile
        final data = await _supabase.from('users').insert({
          'user_id': userId,
          'email': email,
          'name': name ?? 'Citizen',
          'role': 'citizen',
          'password_hash': 'supabase-auth',
        }).select().single();
        return User.fromJson(data);
      } catch (insertError) {
        throw Exception('Failed to create user profile: $insertError');
      }
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Future<String?> getToken() async {
    return _supabase.auth.currentSession?.accessToken;
  }
}
