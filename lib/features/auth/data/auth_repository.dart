import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_dating_app/features/auth/domain/user_model.dart';
import 'package:student_dating_app/features/auth/domain/auth_state.dart'
    as app_auth;

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  Stream<app_auth.AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange.map((event) {
      final session = event.session;
      if (session != null) {
        // Simplified user mapping for now. In a real app we'd fetch the Profile.
        final user = UserModel(
          id: session.user.id,
          email: session.user.email ?? '',
          name: session.user.userMetadata?['name'] ?? '',
          isVerified: true,
          createdAt: DateTime.parse(session.user.createdAt),
        );
        return app_auth.AuthState.authenticated(user);
      } else {
        return const app_auth.AuthState.unauthenticated();
      }
    });
  }

  Future<void> signInWithEmail(String email) async {
    // Magic Link Sign In
    await _client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: 'studentdatingapp://login-callback',
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> deleteAccount() async {
    // Note: This requires a 'delete_user' RPC function in Supabase
    // because client SDK doesn't allow self-deletion from auth.users for security.
    await _client.rpc('delete_user');
    await signOut();
  }
}
