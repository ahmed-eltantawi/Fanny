import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/adaptive_layout.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../widgets/role_selector.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  UserRole _role = UserRole.customer;
  bool _otpSent = false;
  bool _isEmailAuth = true;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _login() {
    if (_isEmailAuth) {
      context.read<AuthCubit>().loginWithEmail(
            _emailCtrl.text.trim(),
            _passwordCtrl.text,
            _role,
          );
    } else {
      if (!_otpSent) {
        context
            .read<AuthCubit>()
            .sendPhoneOtp(_phoneCtrl.text.trim())
            .then((success) {
          if (success && mounted) setState(() => _otpSent = true);
        });
      } else {
        context.read<AuthCubit>().verifyPhoneOtp(_otpCtrl.text.trim(), _role);
      }
    }
  }

  void _loginWithGoogle() {
    context.read<AuthCubit>().loginWithGoogle(_role);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDesktop = AdaptiveLayout.isDesktop(context);
    final isWideWeb = MediaQuery.of(context).size.width >= 1100;

    return BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: isWideWeb
                ? Row(
                    children: [
                      const Expanded(child: _AuthPromoPanel()),
                      Expanded(
                        child: _buildFormContent(context, l, isDesktop),
                      ),
                    ],
                  )
                : _buildFormContent(context, l, isDesktop),
          ),
        ));
  }

  Widget _buildFormContent(
      BuildContext context, AppLocalizations l, bool isDesktop) {
    return Center(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: isDesktop ? 520 : double.infinity),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 52),

                // ── Logo ──────────────────────────────────────────
                FadeInDown(
                  duration: const Duration(milliseconds: 700),
                  child: Center(
                    child: Image.asset(AppImages.logo,
                        width: isDesktop ? 240 : 220,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                              Icons.home_repair_service_rounded,
                              size: 80,
                              color: AppColors.primary,
                            )),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Welcome text ──────────────────────────────────
                FadeInDown(
                  delay: const Duration(milliseconds: 150),
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        l.welcomeBack,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E),
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l.loginSubtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7B8FA1),
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Role selector ─────────────────────────────────
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 500),
                  child: RoleSelector(
                    selected: _role,
                    onChanged: (r) => setState(() => _role = r),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Auth Method Toggle ────────────────────────────
                FadeInUp(
                  delay: const Duration(milliseconds: 240),
                  duration: const Duration(milliseconds: 500),
                  child: _AuthMethodSelector(
                    isEmail: _isEmailAuth,
                    onChanged: (val) {
                      setState(() {
                        _isEmailAuth = val;
                        _otpSent = false;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // ── Input Fields ──────────────────────────────────
                AnimatedSize(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  child: _isEmailAuth
                      ? Column(
                          children: [
                            FadeInUp(
                              delay: const Duration(milliseconds: 280),
                              duration: const Duration(milliseconds: 500),
                              child: _TextFieldCard(
                                controller: _emailCtrl,
                                hint: 'البريد الإلكتروني',
                                icon: Icons.email_outlined,
                              ),
                            ),
                            const SizedBox(height: 14),
                            FadeInUp(
                              delay: const Duration(milliseconds: 320),
                              duration: const Duration(milliseconds: 500),
                              child: _TextFieldCard(
                                controller: _passwordCtrl,
                                hint: 'كلمة المرور',
                                icon: Icons.lock_outline_rounded,
                                obscureText: true,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            FadeInUp(
                              delay: const Duration(milliseconds: 280),
                              duration: const Duration(milliseconds: 500),
                              child: _PhoneField(controller: _phoneCtrl),
                            ),
                            if (_otpSent) ...[
                              const SizedBox(height: 14),
                              FadeInUp(
                                duration: const Duration(milliseconds: 400),
                                child: _OtpField(controller: _otpCtrl),
                              ),
                            ],
                          ],
                        ),
                ),

                const SizedBox(height: 28),

                // ── Login button ──────────────────────────────────
                FadeInUp(
                  delay: const Duration(milliseconds: 360),
                  duration: const Duration(milliseconds: 500),
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return _PrimaryButton(
                        label: _isEmailAuth
                            ? l.login
                            : (_otpSent ? l.login : l.sendOtp),
                        icon: Icons.arrow_back_rounded,
                        isLoading: isLoading,
                        onTap: _login,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // ── Register button ───────────────────────────────
                FadeInUp(
                  delay: const Duration(milliseconds: 420),
                  duration: const Duration(milliseconds: 500),
                  child: _SecondaryButton(
                    label: l.createNewAccount,
                    onTap: () => context.push('/register'),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Divider ───────────────────────────────────────
                FadeInUp(
                  delay: const Duration(milliseconds: 480),
                  duration: const Duration(milliseconds: 400),
                  child: _OrDivider(label: l.orLoginWith),
                ),

                const SizedBox(height: 20),

                // ── Social login ──────────────────────────────────
                FadeInUp(
                  delay: const Duration(milliseconds: 520),
                  duration: const Duration(milliseconds: 400),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialImageButton(
                        imagePath: AppImages.googleIcon,
                        label: 'Google',
                        onTap: _loginWithGoogle,
                      ),
                      const SizedBox(width: 16),
                      _SocialImageButton(
                        imagePath: AppImages.facebookIcon,
                        label: 'Facebook',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Terms ─────────────────────────────────────────
                FadeInUp(
                  delay: const Duration(milliseconds: 560),
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    l.termsNotice,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFAAADB7),
                      fontFamily: 'Cairo',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthPromoPanel extends StatelessWidget {
  const _AuthPromoPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF2FBF6), Color(0xFFE9F5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Image.asset(
            AppImages.logo,
            width: 300,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.home_repair_service_rounded,
              size: 110,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Phone input with +20 prefix ────────────────────────────────────────────────
class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  const _PhoneField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E9EF)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Color(0xFFE5E9EF))),
            ),
            child: const Text(
              '+20',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
                fontFamily: 'Cairo',
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Cairo',
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                hintText: l.phoneHint,
                hintStyle: const TextStyle(
                  color: Color(0xFFBEC3C9),
                  fontSize: 14,
                  letterSpacing: 0,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                suffixIcon: const Icon(Icons.phone_android_rounded,
                    color: Color(0xFFBEC3C9), size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── OTP 4-box input ──────────────────────────────────────────────────────────
class _OtpField extends StatelessWidget {
  final TextEditingController controller;
  const _OtpField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          l.otpLabel,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8FA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E9EF)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            maxLength: 4,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 18,
              fontFamily: 'Cairo',
            ),
            decoration: const InputDecoration(
              counterText: '',
              hintText: '• • • •',
              hintStyle: TextStyle(
                color: Color(0xFFBEC3C9),
                fontSize: 18,
                letterSpacing: 12,
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l.otpHint,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFFAAADB7),
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}

// ── Green primary button ───────────────────────────────────────────────────────
class _PrimaryButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onTap;
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.96,
        upperBound: 1.0,
        value: 1.0);
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white)),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.icon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        widget.label,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Dark secondary button ──────────────────────────────────────────────────────
class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SecondaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2D),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ),
    );
  }
}

// ── "Or" divider ───────────────────────────────────────────────────────────────
class _OrDivider extends StatelessWidget {
  final String label;
  const _OrDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE5E9EF))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFAAB0BC),
              fontFamily: 'Cairo',
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE5E9EF))),
      ],
    );
  }
}

// ── Social login button with image ────────────────────────────────────────────
class _SocialImageButton extends StatefulWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;
  const _SocialImageButton({
    required this.imagePath,
    required this.label,
    required this.onTap,
  });

  @override
  State<_SocialImageButton> createState() => _SocialImageButtonState();
}

class _SocialImageButtonState extends State<_SocialImageButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.93 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: 130,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F8FA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E9EF)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  widget.imagePath,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

// ── Auth Method Selector ───────────────────────────────────────────────────────
class _AuthMethodSelector extends StatelessWidget {
  final bool isEmail;
  final ValueChanged<bool> onChanged;

  const _AuthMethodSelector({required this.isEmail, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTab('البريد الإلكتروني', true),
        const SizedBox(width: 12),
        _buildTab('رقم الهاتف', false),
      ],
    );
  }

  Widget _buildTab(String label, bool isThisEmail) {
    final selected = isEmail == isThisEmail;
    return GestureDetector(
      onTap: () => onChanged(isThisEmail),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE5E9EF)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primary : const Color(0xFF7B8FA1),
            fontWeight: selected ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}

// ── Text input card ───────────────────────────────────────────────────────────
class _TextFieldCard extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;

  const _TextFieldCard({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E9EF)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        textDirection: TextDirection.ltr,
        style: const TextStyle(
            fontSize: 15, fontFamily: 'Cairo', color: Color(0xFF1A1A2E)),
        decoration: InputDecoration(
          hintText: hint,
          hintTextDirection: TextDirection.rtl,
          hintStyle: const TextStyle(
              color: Color(0xFFBEC3C9), fontSize: 14, fontFamily: 'Cairo'),
          prefixIcon: Icon(icon, color: const Color(0xFFBEC3C9), size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}
