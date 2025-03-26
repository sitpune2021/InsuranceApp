import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:insurance/reset_password/reset_password.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.white,
  //     body: SingleChildScrollView(
  //       child: Column(
  //         children: <Widget>[
  //           Container(
  //             height: 400,
  //             decoration: const BoxDecoration(
  //               image: DecorationImage(
  //                 image: AssetImage('assets/images/background.png'),
  //                 fit: BoxFit.fill,
  //               ),
  //             ),
  //             child: Stack(
  //               children: <Widget>[
  //                 Positioned(
  //                   right: 20,
  //                   top: 20,
  //                   width: 80,
  //                   height: 150,
  //                   child: FadeInUp(
  //                     duration: const Duration(milliseconds: 1300),
  //                     child: Container(
  //                       decoration: const BoxDecoration(
  //                         image: DecorationImage(
  //                           image: AssetImage('assets/images/logo.png'),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 Positioned(
  //                   child: FadeInUp(
  //                     duration: const Duration(milliseconds: 1600),
  //                     child: Container(
  //                       margin: const EdgeInsets.only(top: 0),
  //                       child: const Center(
  //                         child: Text(
  //                           "Enter OTP",
  //                           style: TextStyle(
  //                             color: Colors.white,
  //                             fontSize: 35,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.all(30.0),
  //             child: Column(
  //               children: <Widget>[
  //                 FadeInUp(
  //                   duration: const Duration(milliseconds: 1800),
  //                   child: Container(
  //                     padding: const EdgeInsets.all(5),
  //                     // decoration: BoxDecoration(
  //                     //   color: Colors.white,
  //                     //   borderRadius: BorderRadius.circular(10),
  //                     //   border: Border.all(
  //                     //     color: const Color.fromRGBO(143, 148, 251, 1),
  //                     //   ),
  //                     //   boxShadow: const [
  //                     //     BoxShadow(
  //                     //       color: Color.fromRGBO(143, 148, 251, .2),
  //                     //       blurRadius: 20.0,
  //                     //       offset: Offset(0, 10),
  //                     //     ),
  //                     //   ],
  //                     // ),
  //                     child: TextField(
  //                       controller: _otpController,
  //                       maxLength: 6,
  //                       keyboardType: TextInputType.number,
  //                       decoration: InputDecoration(
  //                         border: OutlineInputBorder(
  //                             borderRadius:
  //                                 BorderRadius.all(Radius.circular(8))),
  //                         hintText: "Enter OTP",
  //                         hintStyle: TextStyle(color: Colors.grey[700]),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(
  //                   height: 30,
  //                 ),
  //                 FadeInUp(
  //                   duration: const Duration(milliseconds: 1900),
  //                   child: GestureDetector(
  //                     onTap: () async {
  //                       SharedPreferences pref =
  //                           await SharedPreferences.getInstance();
  //                       int? otp = pref.getInt("otp");
  //                       if (_otpController.text.isEmpty ||
  //                           _otpController.text.length < 5) {
  //                         ScaffoldMessenger.of(context).showSnackBar(
  //                           const SnackBar(
  //                             content: Text("enter opt"),
  //                             backgroundColor: Colors.green,
  //                           ),
  //                         );
  //                       } else {
  //                         if (otp.toString() ==
  //                             _otpController.text.toString()) {
  //                           ScaffoldMessenger.of(context).showSnackBar(
  //                             const SnackBar(
  //                               content: Text(
  //                                   "OTP Verified! Please enter new password."),
  //                               backgroundColor: Colors.green,
  //                             ),
  //                           );
  //                           Navigator.pushReplacement(
  //                               context,
  //                               MaterialPageRoute(
  //                                 builder: (context) => NewPasswordScreen(),
  //                               ));
  //                         } else {
  //                           ScaffoldMessenger.of(context).showSnackBar(
  //                             const SnackBar(
  //                               content: Text("Wrong otp please try again"),
  //                               backgroundColor: Colors.red,
  //                             ),
  //                           );
  //                         }
  //                       }
  //                     },
  //                     child: Container(
  //                       height: 50,
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(10),
  //                         gradient: const LinearGradient(
  //                           colors: [
  //                             Color.fromRGBO(143, 148, 251, 1),
  //                             Color.fromRGBO(143, 148, 251, .6),
  //                           ],
  //                         ),
  //                       ),
  //                       child: const Center(
  //                         child: Text(
  //                           "Verify OTP",
  //                           style: TextStyle(
  //                             color: Colors.white,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(
  //                   height: 70,
  //                 ),
  //                 // FadeInUp(
  //                 //   duration: const Duration(milliseconds: 2000),
  //                 //   child: GestureDetector(
  //                 //     onTap: () {
  //                 //       Navigator.pop(context);
  //                 //     },
  //                 //     child: const Text(
  //                 //       "Resend OTP",
  //                 //       style: TextStyle(
  //                 //         color: Color.fromRGBO(143, 148, 251, 1),
  //                 //       ),
  //                 //     ),
  //                 //   ),
  //                 // ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // resizeToAvoidBottomInset: false, // Prevents background image from moving
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Scrollable Content to avoid overflow
            Container(
              padding: const EdgeInsets.only(left: 16, right: 16),
              height:
                  MediaQuery.sizeOf(context).height, // Ensures proper height
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60), // Adjust spacing
                  // const Text(
                  //   "Forgot Password",
                  //   style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  // ),
                  // const Text(
                  //   "Welcome back",
                  //   style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  // ),
                  Align(
                    alignment: Alignment.center,
                    child: Image.asset("assets/images/otp.png", height: 350),
                  ),
                  const SizedBox(height: 30),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "We sent a otp to your Mobile Number",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 10),
                      Text(
                        " Enter the otp to continue",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),

                  // Mobile Number Input
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, right: 8.0, top: 5.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _otpController,
                            maxLength: 6,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              hintText: "Enter OTP",
                              hintStyle: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  GestureDetector(
                    onTap: () async {
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      int? otp = pref.getInt("otp");
                      if (_otpController.text.isEmpty ||
                          _otpController.text.length < 5) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("enter opt"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        if (otp.toString() == _otpController.text.toString()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "OTP Verified! Please enter new password."),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NewPasswordScreen(),
                              ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Wrong otp please try again"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xff546AE4)),
                      child: const Center(
                        child: Text(
                          "Verify OTP",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 40,
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     GestureDetector(
                  //       onTap: () {
                  //         Navigator.pop(context);
                  //       },
                  //       child: const Text(
                  //         "Back to Login",
                  //         style: TextStyle(
                  //           color: Color(0xff546AE4),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
