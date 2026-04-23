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
import '../../../../features/auth/domain/repositories/auth_repository.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../widgets/role_selector.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _specialtyCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  UserRole _role = UserRole.customer;
  bool _isEmailAuth = true;
  bool _otpSent = false;
  final _otpCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _specialtyCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;

    if (_isEmailAuth) {
      context.read<AuthCubit>().registerWithEmail(RegisterParams(
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            phone: '',
            password: _passwordCtrl.text,
            role: _role,
            specialty: _role == UserRole.technician
                ? _specialtyCtrl.text.trim()
                : null,
          ));
    } else {
      if (!_otpSent) {
        context
            .read<AuthCubit>()
            .sendPhoneOtp(_phoneCtrl.text.trim())
            .then((success) {
          if (success && mounted) setState(() => _otpSent = true);
        });
      } else {
        // Note: For a complete implementation, name and specialty should be updated after OTP.
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
          // Custom back button — no appbar title to keep design clean
          body: SafeArea(
            child: isWideWeb
                ? Row(
                    children: [
                      const Expanded(child: _RegisterPromoPanel()),
                      Expanded(
                        child: _buildRegisterForm(context, l, isDesktop),
                      ),
                    ],
                  )
                : _buildRegisterForm(context, l, isDesktop),
          ),
        ));
  }

  Widget _buildRegisterForm(
      BuildContext context, AppLocalizations l, bool isDesktop) {
    return Center(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: isDesktop ? 560 : double.infinity),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Back button ─────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 4),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F8FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E9EF)),
                          ),
                          child: const Icon(
                            Icons
                                .arrow_forward_ios_rounded, // RTL: left means "back"
                            size: 18,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Logo ──────────────────────────────────────────
                  FadeInDown(
                    duration: const Duration(milliseconds: 700),
                    child: Center(
                      child: Image.asset(
                        AppImages.logo,
                        width: isDesktop ? 240 : 220,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.home_repair_service_rounded,
                          size: 80,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── Header text ───────────────────────────────────
                  FadeInDown(
                    delay: const Duration(milliseconds: 150),
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      children: [
                        Text(
                          l.register,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l.registerSubtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7B8FA1),
                            fontFamily: 'Cairo',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Role selector ─────────────────────────────────
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 500),
                    child: RoleSelector(
                      selected: _role,
                      onChanged: (r) => setState(() => _role = r),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── Full name ─────────────────────────────────────
                  _AnimatedField(
                    delay: 260,
                    child: _InputCard(
                      label: l.fullName,
                      child: TextField(
                        controller: _nameCtrl,
                        style: _inputStyle,
                        decoration: _inputDecoration(
                            l.fullName, Icons.person_outline_rounded),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

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

                  const SizedBox(height: 18),

                  // ── Phone/Email fields ────────────────────────────
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
                              const SizedBox(height: 12),
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
                                child: _buildPhoneField(l),
                              ),
                              if (_otpSent) ...[
                                const SizedBox(height: 12),
                                FadeInUp(
                                  duration: const Duration(milliseconds: 400),
                                  child: _OtpField(
                                      controller: _otpCtrl,
                                      label: 'كود التحقق',
                                      hintText: '• • • •',
                                      hintMessage:
                                          'أدخل الكود المكون من 6 أرقام'),
                                ),
                              ],
                            ],
                          ),
                  ),

                  // ── Specialty (technician only) ───────────────────
                  AnimatedSize(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    child: _role == UserRole.technician
                        ? Column(
                            children: [
                              const SizedBox(height: 12),
                              _AnimatedField(
                                delay: 360,
                                child: _InputCard(
                                  label: l.specialty,
                                  child: TextField(
                                    controller: _specialtyCtrl,
                                    style: _inputStyle,
                                    decoration: _inputDecoration(l.specialty,
                                        Icons.engineering_outlined),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 28),

                  // ── Register button ───────────────────────────────
                  _AnimatedField(
                    delay: 420,
                    child: BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return _GreenButton(
                          label: _isEmailAuth
                              ? l.register
                              : (_otpSent ? l.register : 'إرسال كود التحقق'),
                          icon: Icons.person_add_rounded,
                          isLoading: isLoading,
                          onTap: _register,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Login link ────────────────────────────────────
                  _AnimatedField(
                    delay: 460,
                    child: _DarkButton(
                      label: l.login,
                      onTap: () => context.pop(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Divider ───────────────────────────────────────
                  _AnimatedField(
                    delay: 500,
                    child: _buildOrDivider(l.orRegisterWith),
                  ),

                  const SizedBox(height: 18),

                  // ── Social icons ──────────────────────────────────
                  _AnimatedField(
                    delay: 540,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialIcon(
                            icon: Icons.g_mobiledata_rounded,
                            color: const Color(0xFFDB4437),
                            onTap: _loginWithGoogle),
                        const SizedBox(width: 16),
                        _SocialIcon(
                            icon: Icons.apple_rounded,
                            color: Colors.black,
                            onTap: () {}),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Terms ─────────────────────────────────────────
                  _AnimatedField(
                    delay: 580,
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
      ),
    );
  }

  Widget _buildPhoneField(AppLocalizations l) {
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
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: const TextStyle(
                  fontSize: 16, fontFamily: 'Cairo', letterSpacing: 2),
              decoration: InputDecoration(
                hintText: l.phoneHint,
                hintStyle: const TextStyle(
                    color: Color(0xFFBEC3C9), fontSize: 14, letterSpacing: 0),
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

  Widget _buildOrDivider(String label) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE5E9EF))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFFAAB0BC), fontFamily: 'Cairo')),
        ),
        const Expanded(child: Divider(color: Color(0xFFE5E9EF))),
      ],
    );
  }

  static const TextStyle _inputStyle =
      TextStyle(fontSize: 15, fontFamily: 'Cairo', color: Color(0xFF1A1A2E));

  InputDecoration _inputDecoration(String label, IconData icon) =>
      InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(
            color: Color(0xFFBEC3C9), fontSize: 14, fontFamily: 'Cairo'),
        prefixIcon: Icon(icon, color: const Color(0xFFBEC3C9), size: 20),
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );
}

class _RegisterPromoPanel extends StatelessWidget {
  const _RegisterPromoPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEFFAF2), Color(0xFFF1F7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Image.asset(
            AppImages.logo,
            width: 320,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.person_add_alt_1_rounded,
              size: 110,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Input card wrapper ─────────────────────────────────────────────────────────
class _InputCard extends StatelessWidget {
  final String label;
  final Widget child;
  const _InputCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E9EF)),
      ),
      child: child,
    );
  }
}

// ── Animated field wrapper ─────────────────────────────────────────────────────
class _AnimatedField extends StatelessWidget {
  final int delay;
  final Widget child;
  const _AnimatedField({required this.delay, required this.child});

  @override
  Widget build(BuildContext context) => FadeInUp(
        delay: Duration(milliseconds: delay),
        duration: const Duration(milliseconds: 450),
        child: child,
      );
}

// ── Green CTA button ───────────────────────────────────────────────────────────
class _GreenButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onTap;
  const _GreenButton(
      {required this.label,
      required this.icon,
      required this.isLoading,
      required this.onTap});

  @override
  State<_GreenButton> createState() => _GreenButtonState();
}

class _GreenButtonState extends State<_GreenButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.96,
        upperBound: 1.0,
        value: 1.0);
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
        scale: _ctrl,
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
                      Text(widget.label,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Cairo')),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Dark secondary button ──────────────────────────────────────────────────────
class _DarkButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DarkButton({required this.label, required this.onTap});

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
                fontFamily: 'Cairo'),
          ),
        ),
      ),
    );
  }
}

// ── Social icon button ─────────────────────────────────────────────────────────
class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SocialIcon(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E9EF)),
        ),
        child: Center(
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
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

// ── OTP 4-box input ──────────────────────────────────────────────────────────
class _OtpField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final String hintMessage;

  const _OtpField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.hintMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
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
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 18,
              fontFamily: 'Cairo',
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFFBEC3C9),
                fontSize: 18,
                letterSpacing: 12,
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          hintMessage,
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
