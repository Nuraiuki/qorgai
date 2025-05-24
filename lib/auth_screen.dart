import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme/app_colors.dart';
// import 'home_screen.dart'; 
import 'main_navigation_screen.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'CustomInputField.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
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
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Пароль должен содержать хотя бы один специальный символ';
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
    if (!isLogin && value != null && !RegExp(r'^[а-яА-Яa-zA-Z\s-]+$').hasMatch(value)) {
      return 'Имя может содержать только буквы, пробелы и дефис';
    }
    return null;
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, исправьте ошибки в форме'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final url = Uri.parse(
        '${isLogin ? 'https://qorgai-backend-0odv.onrender.com/api/login' : 'https://qorgai-backend-0odv.onrender.com/api/register'}'
      );

      debugPrint('Отправка запроса на: $url'); // Логирование
      debugPrint('Метод: ${isLogin ? 'LOGIN' : 'REGISTER'}'); // Логирование

      final requestBody = {
        'email': emailController.text.trim(),
        'password': passwordController.text,
        if (!isLogin) ...{
          'name': nameController.text.trim(),
          'confirm_password': confirmPasswordController.text,
        },
      };

      debugPrint('Тело запроса: $requestBody'); // Логирование

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Origin': 'https://qorgai-frontend-0odv.onrender.com',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Превышено время ожидания ответа от сервера');
        },
      );

      debugPrint('Статус ответа: ${response.statusCode}'); // Логирование
      debugPrint('Заголовки ответа: ${response.headers}'); // Логирование
      debugPrint('Тело ответа: ${response.body}'); // Логирование

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          debugPrint('Успешный ответ: $data'); // Логирование

          // Сохраняем данные пользователя
          final userData = {
            'id': data['user_id'],
            'name': data['name'],
            'email': data['email'],
            'is_admin': data['is_admin'] ?? false,
          };

          debugPrint('Сохранение данных пользователя: $userData'); // Логирование

          final storage = await SharedPreferences.getInstance();
          await storage.setString('user', jsonEncode(userData));

          if (mounted) {
            if (!isLogin) {
              debugPrint('Показ диалога соглашения'); // Логирование
              // Показываем диалог с соглашением только после регистрации
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Text('Соглашение'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Пользователь:'),
                        SizedBox(height: 8),
                        Text('– согласен с условиями использования сервиса;'),
                        Text('– согласен с политикой конфиденциальности;'),
                        Text('– согласен с условиями обработки персональных данных;'),
                        Text('– и принимает условия использования контента в рамках закона.'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        debugPrint('Пользователь согласился с условиями'); // Логирование
                        Navigator.of(context).pop();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MainNavigationScreen(userId: data['user_id'])),
                        );
                      },
                      child: const Text('Согласен'),
                    ),
                  ],
                ),
              );
            } else {
              debugPrint('Успешный вход, переход на главный экран'); // Логирование
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(data['message']),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainNavigationScreen(userId: data['user_id'])),
              );
            }
          }
        } catch (e) {
          debugPrint('Ошибка при обработке ответа: $e'); // Логирование
          setState(() {
            errorMessage = 'Ошибка при обработке ответа сервера';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ошибка при обработке ответа сервера'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        String errorMessage;
        try {
          final data = jsonDecode(response.body);
          errorMessage = data['message'] ?? 'Произошла ошибка';
        } catch (e) {
          errorMessage = 'Ошибка сервера: ${response.statusCode}';
        }
        debugPrint('Ошибка: $errorMessage'); // Логирование
        setState(() {
          this.errorMessage = errorMessage;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Ошибка при отправке запроса: $e'); // Логирование
      setState(() {
        errorMessage = e is TimeoutException 
            ? 'Превышено время ожидания ответа от сервера'
            : 'Ошибка соединения с сервером';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
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
                              CustomInputField(
                                hintText: "никнейм",
                                controller: nameController,
                                validator: validateName,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),

                        CustomInputField(
                          hintText: "qorgai@email.com",
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: validateEmail,
                        ),
                        const SizedBox(height: 16),
                        CustomInputField(
                          hintText: "пароль",
                          controller: passwordController,
                          obscureText: true,
                          validator: validatePassword,
                        ),

                        if (!isLogin) ...[
                          const SizedBox(height: 16),
                          CustomInputField(
                            hintText: "подтверждение пароля",
                            controller: confirmPasswordController,
                            obscureText: true,
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
}
