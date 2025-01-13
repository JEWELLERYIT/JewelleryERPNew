// import 'package:digicat/Constants/Functions.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'dart:convert';

// import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';
import 'FilterScreen.dart';
import 'HomeDashBoard.dart';
import 'MaxWidthContainer.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  bool _isPasswordVisible = false;

  Constans constans = Constans();

  final FocusNode _userIdFocusNode = FocusNode(); // FocusNode for User ID field
  final FocusNode _passwordFocusNode =
      FocusNode(); // FocusNode for Password field

  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool loaderStatus = false;

//Authenticate using biometric
  void _showForgatePassword(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Digicat'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email to forgot password.'),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Enter Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity, // Makes the button occupy the full width
              child: ElevatedButton(
                onPressed: () {
                  final email = emailController.text;
                  if (email.isNotEmpty) {
                    // Handle sending email logic
                    print('Sending email to: $email');
                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Forgot password email has been sent to your email address.')),
                    );
                  } else {
                    // Show a message if email is empty
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter an email')),
                    );
                  }
                },
                child: const Text('Send Email'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _login() async {
    final String userId = _userIdController.text;
    final String password = _passwordController.text;

    if (userId.isEmpty) {
      constans.showToast("Please enter userId");
    } else if (password.isEmpty) {
      constans.showToast("Please enter Password");
    } else {
      try {
        setState(() {
          loaderStatus = true;
        });

        var formData = {
          'username': userId,
          'password': password,
          'isuser': "1",
        };

        constans.setData(StaticConstant.tagUserEmailIdForLogin, userId);
        constans.setData(StaticConstant.tagUserPasswordForLogin, password);

        // Make the POST request
        // var response = await http.post(
        //   url,
        //   body: formData,
        // );
        String response = await constans.callApi(formData, StaticUrl.loginUrl);

        setState(() {
          loaderStatus = false;
        });
        Map<String, dynamic> responseData = json.decode(response);

        Map<String, dynamic> jsonObject = {};

        if (responseData['response']) {
          //   // Add data to the JSON object

          // jsonObject['username'] = responseData['data']['username'];
          // jsonObject['password'] = responseData['data']['password'];
          // jsonObject['companyid'] = responseData['data']['companyid'];
          // jsonObject['autoid'] = responseData['data']['autoid'];
          // jsonObject['isAdmin'] = responseData['data']['isAdmin'];

          // print("responseData['data'] ${jsonEncode(responseData['data'])}");

          constans.setData(StaticConstant.userData, jsonEncode(responseData['data']));
          //
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MaxWidthContainer(
                    child: FilterScreen(),
                  ))
          );

        } else {
          constans.showToast(responseData['response']['message']);
        }
      } catch (e) {
        // Handle network errors or other exceptions
      }
    }
  }


  void setLoginData() async {
    String? email =
        await constans.getData(StaticConstant.tagUserEmailIdForLogin);
    String? password =
        await constans.getData(StaticConstant.tagUserPasswordForLogin);

    try {
      _userIdController.text = email!;
      _passwordController.text = password!;
    } catch (e) {}
  }

  final Uri _url = Uri.parse('https://digicat.in/users/register');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $_url';
    }
  }

  @override
  void initState() {
    super.initState();
    setLoginData();
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Image
                Image.asset(
                  'assets/login_logo.jpeg',
                  width: double.infinity,
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                // User Name Label
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "User Name",
                    style: TextStyle(
                      color: Color(0xFF23303B), // Theme color
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                // User Name TextField
                TextField(
                  focusNode: _userIdFocusNode,
                  controller: _userIdController,
                  decoration: InputDecoration(
                    hintText: 'Enter your username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(
                        color: Color(0xFF23303B),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(
                        color: Color(0xFF23303B),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 15.0,
                    ),
                  ),
                  onSubmitted: (value) {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                ),
                const SizedBox(height: 20),
                // Password Label
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Password",
                    style: TextStyle(
                      color: Color(0xFF23303B),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                // Password TextField with Show/Hide Icon
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF23303B),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          focusNode: _passwordFocusNode,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter your password',
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        child: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xFF23303B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF23303B),
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    onPressed: _login,
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (loaderStatus)
            // Loader overlay
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
