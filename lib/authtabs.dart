import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'CustomInputField.dart'; // Импорт кастомного поля

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool obscurePassword = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void submit() {
    if (_formKey.currentState!.validate()) {
      debugPrint("✅ Email: ${emailController.text}");
      debugPrint("✅ Пароль: ${passwordController.text}");
      if (!isLogin) {
        debugPrint("✅ Подтверждение: ${confirmPasswordController.text}");
        debugPrint("✅ Никнейм: ${nameController.text}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 249, 249, 249),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTabs(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          isLogin ? "С возвращением!" : "Добро пожаловать!",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isLogin
                              ? "заполните ячейки ниже для входа"
                              : "заполните ячейки ниже для регистрации",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6C8A64),
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (!isLogin)
                          Column(
                            children: [
                              CustomInputField(
                                hintText: "никнейм",
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),

                        CustomInputField(
                          hintText: "qorgai@email.com",
                        ),
                        const SizedBox(height: 16),
                        CustomInputField(
                          hintText: "пароль",
                          obscureText: true,
                        ),

                        if (!isLogin) ...[
                          const SizedBox(height: 16),
                          CustomInputField(
                            hintText: "подтверждение пароля",
                            obscureText: true,
                          ),
                        ],

                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            isLogin ? "Войти" : "Зарегистрироваться",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          isLogin
                              ? "Забыли пароль?"
                              : "продолжить как гость",
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => isLogin = true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isLogin ? AppColors.primaryGreen : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                ),
                boxShadow: isLogin
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  "Вход",
                  style: TextStyle(
                    color: isLogin ? Colors.white : const Color(0xFF9E6B6B),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => isLogin = false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: !isLogin ? AppColors.primaryGreen : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                ),
                boxShadow: !isLogin
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  "Регистрация",
                  style: TextStyle(
                    color: !isLogin ? Colors.white : const Color(0xFF9E6B6B),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
