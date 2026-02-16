import 'package:app/core/theme/app_spacing.dart';
import 'package:app/features/auth/application/auth_controller.dart';
import 'package:app/shared/widgets/gradient_scaffold.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({required this.authController, super.key});

  final AuthController authController;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignup = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text;
    final password = _passwordController.text;

    if (_isSignup) {
      await widget.authController.signUp(email: email, password: password);
      return;
    }

    await widget.authController.signIn(email: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: widget.authController,
      builder: (context, _) {
        return GradientScaffold(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      if (MediaQuery.of(context).size.width > 760)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.xxl),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary.withAlpha(45),
                                  theme.colorScheme.surface.withAlpha(180),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('1Deen', style: theme.textTheme.headlineSmall),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'The app that protects your Salah.',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Lock distractions. Keep prayer first. Build better digital discipline.',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(_isSignup ? 'Create account' : 'Welcome back',
                                    style: theme.textTheme.headlineSmall),
                                const SizedBox(height: 6),
                                Text(
                                  _isSignup
                                      ? 'Set up your 1Deen account'
                                      : 'Login to continue your routine',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                SegmentedButton<bool>(
                                  segments: const [
                                    ButtonSegment<bool>(value: false, label: Text('Login')),
                                    ButtonSegment<bool>(value: true, label: Text('Sign Up')),
                                  ],
                                  selected: {_isSignup},
                                  onSelectionChanged: (value) => setState(() => _isSignup = value.first),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(labelText: 'Email'),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty || !value.contains('@')) {
                                      return 'Enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(labelText: 'Password'),
                                  validator: (value) {
                                    if (value == null || value.length < 6) {
                                      return 'Minimum 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                if (widget.authController.error != null) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    widget.authController.error!,
                                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.md),
                                FilledButton(
                                  onPressed: widget.authController.processing ? null : _submit,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 180),
                                    child: Text(
                                      key: ValueKey('${_isSignup}_${widget.authController.processing}'),
                                      widget.authController.processing
                                          ? 'Please wait...'
                                          : (_isSignup ? 'Create Account' : 'Login'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
