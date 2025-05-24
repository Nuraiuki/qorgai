import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme/app_colors.dart';
// import 'home_screen.dart'; 
import 'main_navigation_screen.dart'; 
import 'package:shared_preferences/shared_preferences.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool obscurePassword = true;
  bool isLoading = false;
  String? errorMessage;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Валидация email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email обязателен';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Введите корректный email';
    }
    return null;
  }

  // Валидация пароля
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пароль обязателен';
    }
    if (value.length < 6) {
      return 'Пароль должен быть не менее 6 символов';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Пароль должен содержать хотя бы одну заглавную букву';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Пароль должен содержать хотя бы одну цифру';
    }
    return null;
  }

  // Валидация имени
  String? validateName(String? value) {
    if (!isLogin && (value == null || value.isEmpty)) {
      return 'Имя обязательно';
    }
    if (!isLogin && value != null && value.length < 2) {
      return 'Имя должно быть не менее 2 символов';
    }
    return null;
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final url = Uri.parse(
        '${isLogin ? 'http://localhost:5001/api/login' : 'http://localhost:5001/api/register'}'
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text,
          if (!isLogin) ...{
            'name': nameController.text.trim(),
            'confirm_password': confirmPasswordController.text,
          },
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Сохраняем данные пользователя
        final userData = {
          'id': data['user_id'],
          'name': data['name'],
          'email': data['email'],
          'is_admin': data['is_admin'] ?? false,
        };

        // В реальном приложении здесь нужно сохранить токен
        // await storage.write(key: 'token', value: data['token']);
        final storage = await SharedPreferences.getInstance();
        await storage.setString('user', jsonEncode(userData));

        if (mounted) {
          if (!isLogin) {
            // Показываем диалог с соглашением только после регистрации
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Соглашение'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Данное приложение носит исключительно информационный характер и не является частью какого-либо движения или организации.',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Нажимая кнопку «Согласен», пользователь подтверждает, что осознаёт ответственность за распространение информации и принимает условия, согласно которым:',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text('– он не будет разглашать данные о третьих лицах без их согласия,'),
                        Text('– обязуется соблюдать положения Закона РК «О персональных данных»,'),
                        Text('– использует полученную информацию исключительно в личных целях,'),
                        Text('– и принимает условия использования контента в рамках закона.'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                        );
                      },
                      child: const Text('Согласен'),
                    ),
                  ],
                );
              },
            );
          } else {
            // Для входа просто показываем сообщение об успехе
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message']),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
            );
          }
        }
      } else {
        setState(() {
          errorMessage = data['message'] ?? 'Произошла ошибка';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Ошибка соединения с сервером';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
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
                              _textField(
                                "никнейм",
                                controller: nameController,
                                validator: validateName,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),

                        _textField(
                          "qorgai@email.com",
                          controller: emailController,
                          validator: validateEmail,
                        ),
                        const SizedBox(height: 16),
                        _textField(
                          "пароль",
                          controller: passwordController,
                          obscure: true,
                          validator: validatePassword,
                        ),
                        if (!isLogin) ...[
                          const SizedBox(height: 16),
                          _textField(
                            "подтверждение пароля",
                            controller: confirmPasswordController,
                            obscure: true,
                            validator: (value) {
                              if (value != passwordController.text) {
                                return 'Пароли не совпадают';
                              }
                              return null;
                            },
                          ),
                        ],

                        if (errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: isLoading ? null : submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6D9B6F),
                            padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
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
            onTap: () {
              setState(() {
                isLogin = true;
                errorMessage = null;
              });
            },
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
            onTap: () {
              setState(() {
                isLogin = false;
                errorMessage = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: !isLogin ? const Color(0xFF6D9B6F) : Colors.transparent,
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

  Widget _textField(
    String hint, {
    required TextEditingController controller,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFFDF8F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDBA7A7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDBA7A7)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
