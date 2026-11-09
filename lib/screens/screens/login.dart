import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/auth_helper.dart';
import '../../services/biometric_service.dart';
import '../../theme/design_system.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snackbar.dart';
import '../../navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final supabase = Supabase.instance.client;
  final BiometricService _biometricService = BiometricService();
  bool loading = true;
  bool loggingIn = false;
  List<Map<String, dynamic>> committees = [];
  List<Map<String, dynamic>> members = [];
  Map<String, dynamic>? selectedCommittee;
  Map<String, dynamic>? selectedMember;
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCommittees();
  }

  String getImageUrl(Map<String, dynamic> member) {
    final role = (member['role'] ?? '').toString().toLowerCase();
    final usn = (member['usn'] ?? '').toString();
    if (role == 'faculty') {
      return supabase.storage.from('profile-images').getPublicUrl('$usn.JPG');
    }
    return supabase.storage.from('profile-images').getPublicUrl('$usn.jpg');
  }

  Future<void> loadCommittees() async {
    try {
      final data = await supabase
          .from('login_committees')
          .select()
          .order('display_order', ascending: true);
      committees = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint(e.toString());
    }
    if (!mounted) return;
    setState(() => loading = false);
  }

  Future<void> loadMembers(int committeeId) async {
    HapticFeedback.selectionClick();
    setState(() {
      loading = true;
      selectedMember = null;
      members = [];
    });
    try {
      final data = await supabase
          .from('login_members_directory')
          .select()
          .eq('committee_id', committeeId)
          .order('id', ascending: true);
      members = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint(e.toString());
    }
    if (!mounted) return;
    setState(() => loading = false);
  }

  Future<void> login() async {
    if (selectedMember == null) {
      showSnack("SELECT MEMBER", AppColors.error);
      return;
    }
    final rawPassword = passwordController.text;
    final submittedPassword = rawPassword.trim();
    if (submittedPassword.isEmpty) {
      showSnack("ENTER PASSWORD", AppColors.warning);
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => loggingIn = true);

    final selectedId = selectedMember!['id'];
    final selectedUsn = selectedMember!['usn']?.toString();
    final syntheticEmail = AuthHelper.deriveSyntheticEmail(
      selectedId,
      selectedUsn,
    );

    User? authUser;
    try {
      final authResponse = await supabase.auth.signInWithPassword(
        email: syntheticEmail,
        password: submittedPassword,
      );
      authUser = authResponse.user ?? supabase.auth.currentUser;
    } on AuthException catch (_) {
      if (!mounted) return;
      showSnack("INVALID PASSWORD", AppColors.error);
      if (mounted) setState(() => loggingIn = false);
      return;
    } catch (e) {
      if (!mounted) return;
      showSnack("AUTH ERROR: $e", AppColors.error);
      if (mounted) setState(() => loggingIn = false);
      return;
    }

    if (authUser == null) {
      if (!mounted) return;
      showSnack("AUTH ERROR: Session creation failed", AppColors.error);
      if (mounted) setState(() => loggingIn = false);
      return;
    }

    // STAGE 2: POST-AUTH PROFILE QUERY
    Map<String, dynamic>? userProfile;
    try {
      final profileData = await supabase.rpc('get_current_user_profile');

      if (profileData == null) {
        throw Exception("Profile resolution returned null");
      }

      userProfile = Map<String, dynamic>.from(profileData as Map);

      if (userProfile['id'].toString() != selectedId.toString()) {
        await supabase.auth.signOut();
        if (!mounted) return;
        showSnack("PROFILE MISMATCH ERROR", AppColors.error);
        if (mounted) setState(() => loggingIn = false);
        return;
      }
    } catch (e) {
      if (!mounted) return;
      showSnack("PROFILE RESOLUTION ERROR: $e", AppColors.error);
      if (mounted) setState(() => loggingIn = false);
      return;
    }

    // STAGE 3: CACHE & BIOMETRICS
    try {
      final box = Hive.box('robo_cache');
      box.put('logged_in_user', userProfile);
      await _biometricService.setBiometricEnabled(true);
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 300));

    final bool isSupported = await _biometricService.isBiometricsSupported();
    if (isSupported) {
      try {
        await _biometricService.authenticate(
          localizedReason: 'Enable fingerprint for quick login',
        );
      } catch (e) {
        debugPrint('Biometric authentication after login error: $e');
      }
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: MainNavigation(user: userProfile!),
          );
        },
      ),
    );
    if (mounted) setState(() => loggingIn = false);
  }

  Future<void> _quickBiometricLogin() async {
    final session = supabase.auth.currentSession;
    final box = Hive.box('robo_cache');
    final cachedUser = box.get('logged_in_user');
    if (session == null || cachedUser == null) {
      showSnack("Session expired. Please log in first.", AppColors.warning);
      return;
    }

    final bool authenticated = await _biometricService.authenticate(
      localizedReason: 'Scan fingerprint to unlock Robo Cell',
    );

    if (authenticated && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              MainNavigation(user: Map<String, dynamic>.from(cachedUser)),
        ),
      );
    }
  }

  void loginAsGuest() {
    HapticFeedback.lightImpact();
    final guestUser = {
      'id': 'guest_user',
      'name': 'Guest Visitor',
      'usn': 'GUEST',
      'email': 'guest@robocell.org',
      'role': 'GUEST',
      'committee_id': null,
      'committees': {'name': 'Public Visitor'},
    };

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MainNavigation(user: guestUser)),
    );
  }

  void showSnack(String text, Color color) {
    AppSnackBar.show(
      context,
      message: text,
      type: color == AppColors.error
          ? SnackBarType.error
          : (color == AppColors.warning
                ? SnackBarType.warning
                : SnackBarType.info),
    );
  }

  Widget buildCommitteeDropdown() {
    return DropdownButtonFormField<Map<String, dynamic>>(
      isExpanded: true,
      initialValue: selectedCommittee,
      dropdownColor: AppColors.surfaceElevated,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      iconEnabledColor: AppColors.primaryEmerald,
      decoration: const InputDecoration(
        labelText: "COMMITTEE",
        hintText: "SELECT COMMITTEE",
      ),
      items: committees.map((c) {
        return DropdownMenuItem(
          value: c,
          child: Text(c['name'].toString().toUpperCase()),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() => selectedCommittee = value);
        loadMembers(value['id']);
      },
    );
  }

  Widget buildMemberDropdown() {
    return AnimatedSwitcher(
      duration: AppDurations.normal,
      child: loading && selectedCommittee != null
          ? Container(
              key: const ValueKey("loading"),
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.input),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.primaryEmerald,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          : DropdownButtonFormField<Map<String, dynamic>>(
              key: const ValueKey("loaded"),
              isExpanded: true,
              initialValue: selectedMember,
              dropdownColor: AppColors.surfaceElevated,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              iconEnabledColor: AppColors.primaryEmerald,
              decoration: const InputDecoration(
                labelText: "MEMBER",
                hintText: "SELECT MEMBER",
              ),
              items: members.map((m) {
                final imageUrl = getImageUrl(m);
                return DropdownMenuItem(
                  value: m,
                  child: Row(
                    children: [
                      ClipOval(
                        child: Container(
                          width: 32,
                          height: 32,
                          color: AppColors.primaryEmerald,
                          child: imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Image.asset(
                                    'assets/rcell.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                        Icons.person_rounded,
                                        color: Colors.black,
                                        size: 18,
                                      ),
                                )
                              : const Icon(
                                  Icons.person_rounded,
                                  color: Colors.black,
                                  size: 18,
                                ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          m['name'].toString().toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                HapticFeedback.selectionClick();
                setState(() => selectedMember = value);
              },
            ),
    );
  }

  Widget buildHeroProfile() {
    final imageUrl = selectedMember != null ? getImageUrl(selectedMember!) : '';
    return Hero(
      tag: "rcell_logo",
      child: AnimatedSwitcher(
        duration: AppDurations.normal,
        child: selectedMember == null
            ? Container(
                key: const ValueKey("logo"),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryEmerald, width: 2),
                ),
                child: const CircleAvatar(
                  radius: 56,
                  backgroundColor: AppColors.surface,
                  backgroundImage: AssetImage('assets/rcell.jpg'),
                ),
              )
            : Container(
                key: ValueKey(selectedMember!['id']),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryEmerald, width: 2),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.surface,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Image.asset('assets/rcell.jpg', fit: BoxFit.cover),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person_rounded,
                        color: AppColors.primaryEmerald,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryEmerald,
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    buildHeroProfile(),
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      "WELCOME BACK",
                      style: TextStyle(
                        color: AppColors.headingGold,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "ROBO CELL PORTAL",
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppCard(
                      isGlass: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "SIGN IN",
                            style: TextStyle(
                              color: AppColors.headingGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          buildCommitteeDropdown(),
                          if (members.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.md),
                            buildMemberDropdown(),
                          ],
                          if (selectedMember != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                labelText: "PASSWORD",
                                hintText: "ENTER PASSWORD",
                                prefixIcon: Icon(
                                  Icons.lock_rounded,
                                  color: AppColors.primaryEmerald,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Row(
                              children: [
                                Expanded(
                                  child: AppButton(
                                    text: "SIGN IN",
                                    isLoading: loggingIn,
                                    onPressed: loggingIn ? null : login,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Container(
                                  height: AppSpacing.buttonHeight,
                                  width: AppSpacing.buttonHeight,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.button,
                                    ),
                                    border: Border.all(
                                      color: AppColors.borderSubtle,
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.fingerprint_rounded,
                                      color: AppColors.primaryEmerald,
                                      size: 24,
                                    ),
                                    onPressed: _quickBiometricLogin,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  showSnack(
                                    "Please contact your Committee Head or President to reset password.",
                                    AppColors.warning,
                                  );
                                },
                                child: const Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      text: "CONTINUE AS GUEST",
                      variant: AppButtonVariant.outlined,
                      icon: Icons.person_outline_rounded,
                      width: double.infinity,
                      onPressed: loginAsGuest,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
      ),
    );
  }
}
