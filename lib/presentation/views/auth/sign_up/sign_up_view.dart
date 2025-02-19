import 'package:flutter_video_feed/presentation/blocs/auth/auth_cubit.dart';
import 'package:flutter_video_feed/presentation/blocs/auth/auth_state.dart';
import 'package:flutter_video_feed/presentation/design_system/widgets/bare_bones_loading_indicator.dart';
import 'package:flutter_video_feed/presentation/design_system/widgets/bare_bones_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();

  final String _emailPattern = r'^[^@]+@[^@]+\.[^@]+$';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isButtonDisabled = true;

  void _validateForm() {
    final form = _formKey.currentState;

    if (form != null) {
      setState(() {
        _isButtonDisabled = !form.validate();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _validateForm();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (p, c) => p.isLoading != c.isLoading,
      listener: (context, state) {
        if (state.isLoading == true) {
          BareBonesLoadingIndicator.of(context).show();
        }
        if (state.isLoading == false) {
          BareBonesLoadingIndicator.of(context).hide();
        }
      },
      child: BareBonesScaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.signUp, style: const TextStyle(fontSize: 20))),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.email),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.enterYourEmail;
                    } else if (!RegExp(_emailPattern).hasMatch(value)) {
                      return AppLocalizations.of(context)!.enterValidEmail;
                    }
                    return null;
                  },
                  onChanged: (_) => _validateForm(),
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.password),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.passwordRequired;
                    }
                    if (value.length < 8) {
                      return AppLocalizations.of(context)!.passwordMustBeAtLeast8CharactersLong;
                    }
                    if (!value.contains(RegExp(r'[A-Z]'))) {
                      return AppLocalizations.of(context)!.passwordMustContainAtLeastOneUppercaseLetter;
                    }
                    if (!value.contains(RegExp(r'[a-z]'))) {
                      return AppLocalizations.of(context)!.passwordMustContainAtLeastOneLowercaseLetter;
                    }
                    if (!value.contains(RegExp(r'[0-9]'))) {
                      return AppLocalizations.of(context)!.passwordMustContainAtLeastOneNumbericCharacter;
                    }
                    if (!value.contains(RegExp(r'[!@#$%^&*()<>?/|}{~:]'))) {
                      return AppLocalizations.of(context)!.passwordMustContainAtLeastOneSpecialCharacter;
                    }
                    return null; // Password is valid.
                  },
                  onChanged: (_) => _validateForm(),
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.confirmPassword),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.reEnterPassword;
                    }
                    if (value != _passwordController.text) {
                      return AppLocalizations.of(context)!.passwordsDoNotMatch;
                    }
                    return null; // Passwords match.
                  },
                  onChanged: (_) => _validateForm(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed:
                      _isButtonDisabled
                          ? null
                          : () {
                            context.read<AuthCubit>().createUserWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                          },
                  child: Text(AppLocalizations.of(context)!.signUpExclamation),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
