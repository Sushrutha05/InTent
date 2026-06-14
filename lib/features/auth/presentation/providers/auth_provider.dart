import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:student_dating_app/features/auth/domain/auth_state.dart';
import 'package:student_dating_app/features/auth/domain/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  AuthState build() {
    // Trigger immediate auth check
    Future.microtask(() => checkAuth());
    return const AuthState.initial();
  }

  Future<void> checkAuth() async {
    state = const AuthState.loading();
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;

    if (session != null) {
      final user = session.user;
      final userModel = UserModel(
        id: user.id,
        email: user.email ?? '',
        name: '',
        isVerified: user.emailConfirmedAt != null,
        createdAt: DateTime.parse(user.createdAt),
      );
      state = AuthState.authenticated(userModel);
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AuthState.loading();
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user != null) {
        final userModel = UserModel(
          id: user.id,
          email: user.email ?? '',
          name: '',
          isVerified: user.emailConfirmedAt != null,
          createdAt: DateTime.parse(user.createdAt),
        );
        state = AuthState.authenticated(userModel);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = const AuthState.unauthenticated();
      rethrow;
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = const AuthState.loading();
    try {
      final supabase = Supabase.instance.client;
      final domain = email.trim().split('@').last.toLowerCase();

      // Validate domain against college_domain table
      final domainCheck =
          await supabase
              .from('college_domain')
              .select('college_id')
              .eq('domain', domain)
              .eq('verified', true)
              .maybeSingle();

      String collegeName;
      if (domainCheck == null) {
        // Developer bypass for testing without database setup
        if (domain == 'test.edu' || domain == 'test.com') {
          collegeName = 'Test University';
        } else {
          throw Exception(
            'Your email domain ($domain) is not recognized as a registered, verified college. Please use a valid university email or a test domain (test.edu).',
          );
        }
      } else {
        final collegeId = domainCheck['college_id'];
        try {
          // Attempt to get the beautiful name from the colleges table
          final college = await supabase.from('colleges').select('name').eq('id', collegeId).maybeSingle();
          collegeName = college != null ? college['name'] as String : domain.toUpperCase();
        } catch (_) {
          // Fallback to domain name if colleges table has different column names
          collegeName = domain.toUpperCase();
        }
      }

      // Proceed with signup, injecting collegeName into user metadata
      final response = await supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'college_name': collegeName},
      );

      final user = response.user;
      if (user != null) {
        final userModel = UserModel(
          id: user.id,
          email: user.email ?? '',
          name: '',
          isVerified: user.emailConfirmedAt != null,
          createdAt: DateTime.parse(user.createdAt),
        );
        state = AuthState.authenticated(userModel);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = const AuthState.unauthenticated();
      rethrow;
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    state = const AuthState.unauthenticated();
  }

  Future<void> deleteAccount() async {
    state = const AuthState.loading();
    try {
      // We use RPC because Supabase doesn't allow self-deletion from client SDK
      await Supabase.instance.client.rpc('delete_user');
      await logout();
    } catch (e) {
      // Revert loading state if it fails
      await checkAuth();
      rethrow;
    }
  }
}
