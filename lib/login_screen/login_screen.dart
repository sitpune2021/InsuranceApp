import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:insurance/dashboard_screen/dashboard_screen.dart';
import 'package:insurance/forget_password_screen/forget_password.dart';
import 'package:insurance/home_screen/home_screen.dart';
import 'package:insurance/services/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phonenumberController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                height: 400,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/background.png'),
                        fit: BoxFit.fill)),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 30,
                      width: 80,
                      height: 200,
                      child: FadeInUp(
                          duration: const Duration(seconds: 1),
                          child: Container(
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/light-1.png'))),
                          )),
                    ),
                    Positioned(
                      left: 140,
                      width: 80,
                      height: 150,
                      child: FadeInUp(
                          duration: const Duration(milliseconds: 1200),
                          child: Container(
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/light-2.png'))),
                          )),
                    ),
                    Positioned(
                      right: 40,
                      top: 40,
                      width: 80,
                      height: 150,
                      child: FadeInUp(
                          duration: const Duration(milliseconds: 1300),
                          child: Container(
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image:
                                        AssetImage('assets/images/logo.png'))),
                          )),
                    ),
                    // Positioned(
                    //   child: FadeInUp(
                    //       duration: Duration(milliseconds: 1600),
                    //       child: Container(
                    //         margin: EdgeInsets.only(top: 50),
                    //         child: Center(
                    //           child: SizedBox(
                    //             width: 100,
                    //             height: 100,
                    //             child: ClipRRect(
                    //               child: Image.asset("assets/images/logo.png"),
                    //             ),
                    //           ),
                    //           // child: Text(
                    //           //   "Login",
                    //           //   style: TextStyle(
                    //           //       color: Colors.white,
                    //           //       fontSize: 40,
                    //           //       fontWeight: FontWeight.bold),
                    //           // ),
                    //         ),
                    //       )),
                    // ),
                    Positioned(
                      child: FadeInUp(
                          duration: const Duration(milliseconds: 1600),
                          child: Container(
                            margin: const EdgeInsets.only(top: 50),
                            child: const Center(
                              child: Text(
                                "Login",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: <Widget>[
                    FadeInUp(
                        duration: const Duration(milliseconds: 1800),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color:
                                      const Color.fromRGBO(143, 148, 251, 1)),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color.fromRGBO(143, 148, 251, .2),
                                    blurRadius: 20.0,
                                    offset: Offset(0, 10))
                              ]),
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Color.fromRGBO(
                                                143, 148, 251, 1)))),
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  maxLength: 10,
                                  buildCounter: (BuildContext context,
                                      {int? currentLength,
                                      bool? isFocused,
                                      int? maxLength}) {
                                    return null; // Prevent the counter from displaying
                                  },
                                  controller: _phonenumberController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Enter Phone no",
                                      hintStyle:
                                          TextStyle(color: Colors.grey[700])),
                                ),
                              ),
                              // Container(
                              //   padding: const EdgeInsets.all(8.0),
                              //   child: TextFormField(
                              //     // controller: _passwordController,
                              //     // obscureText: _obscurePassword,
                              //     decoration: InputDecoration(
                              //       labelText: "Password",
                              //       suffixIcon: IconButton(
                              //         icon: Icon(
                              //           Icons.visibility_off,
                              //         ),
                              //         onPressed: () {
                              //           setState(() {
                              //             // _obscurePassword = !_obscurePassword;
                              //           });
                              //         },
                              //       ),
                              //     ),
                              //     validator: (value) {
                              //       if (value == null || value.isEmpty) {
                              //         return "Please enter your password";
                              //       }
                              //       return null;
                              //     },
                              //   ),
                              // )
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                      border: InputBorder.none,
                                      hintText: "Password",
                                      hintStyle:
                                          TextStyle(color: Colors.grey[700])),
                                ),
                              )
                            ],
                          ),
                        )),
                    const SizedBox(
                      height: 30,
                    ),
                    FadeInUp(
                        duration: const Duration(milliseconds: 1900),
                        child: GestureDetector(
                          onTap: () async {
                            showDialog(
                              context: context,
                              barrierDismissible:
                                  false, // Disable dismissing by tapping outside
                              builder: (context) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );

                            bool result = await Auth().loginAssistant(
                                _phonenumberController.text.toString(),
                                _passwordController.text.toString());

                            // Hide progress indicator
                            Navigator.of(context).pop();

                            if (result) {
// Show success toast
                              Fluttertoast.showToast(
                                msg: "Login successful",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                              );

                              // Delay navigation slightly to allow the toast to appear
                              Future.delayed(const Duration(milliseconds: 500),
                                  () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const DashboardScreen(),
                                  ),
                                );
                              });
                            } else {
                              // Show error dialog if login fails
                              showLoginFailedDialog();
                            }
                            // Navigator.pushReplacement(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => const HomeScreen(),
                            //     ));
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: const LinearGradient(colors: [
                                  Color.fromRGBO(143, 148, 251, 1),
                                  Color.fromRGBO(143, 148, 251, .6),
                                ])),
                            child: const Center(
                              child: Text(
                                "Login",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )),
                    const SizedBox(
                      height: 70,
                    ),
                    FadeInUp(
                        duration: const Duration(milliseconds: 2000),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordScreen(),
                                ));
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                                color: Color.fromRGBO(143, 148, 251, 1)),
                          ),
                        )),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showLoginFailedDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Failed'),
          content: const Text(
              'Unable to log in. Please check your credentials or try again later.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
