import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:insurance/otp_screen/otp_screen.dart';
import 'package:insurance/services/auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _mobilenoController = TextEditingController();
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
  //                 // Positioned(
  //                 //   left: 30,
  //                 //   width: 80,
  //                 //   height: 200,
  //                 //   child: FadeInUp(
  //                 //     duration: Duration(seconds: 1),
  //                 //     child: Container(
  //                 //       decoration: BoxDecoration(
  //                 //         image: DecorationImage(
  //                 //           image: AssetImage('assets/images/light-1.png'),
  //                 //         ),
  //                 //       ),
  //                 //     ),
  //                 //   ),
  //                 // ),
  //                 // Positioned(
  //                 //   left: 140,
  //                 //   width: 80,
  //                 //   height: 150,
  //                 //   child: FadeInUp(
  //                 //     duration: Duration(milliseconds: 1200),
  //                 //     child: Container(
  //                 //       decoration: BoxDecoration(
  //                 //         image: DecorationImage(
  //                 //           image: AssetImage('assets/images/light-2.png'),
  //                 //         ),
  //                 //       ),
  //                 //     ),
  //                 //   ),
  //                 // ),
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
  //                           "Forgot Password?",
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
  //                     // padding: const EdgeInsets.all(5),
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
  //                       keyboardType: TextInputType.number,
  //                       maxLength: 10,
  //                       controller: _mobilenoController,
  //                       decoration: InputDecoration(
  //                         border: OutlineInputBorder(
  //                             borderSide: BorderSide(
  //                           color: Color.fromRGBO(143, 148, 251, .2),
  //                         )),
  //                         hintText: "Enter your mobile no",
  //                         label: Text("Enter your mobile no"),
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
  //                       // Navigator.push(
  //                       //     context,
  //                       //     MaterialPageRoute(
  //                       //       builder: (context) => OtpScreen(),
  //                       //     ));
  //                       if (_mobilenoController.text.length < 10) {}

  //                       bool result = await Auth()
  //                           .sendOtp(_mobilenoController.text.toString());
  //                       if (result) {
  //                         ScaffoldMessenger.of(context).showSnackBar(
  //                           const SnackBar(
  //                             content: Text("OTP sent successfully"),
  //                             backgroundColor: Colors.green,
  //                           ),
  //                         );
  //                         Navigator.pushReplacement(
  //                             context,
  //                             MaterialPageRoute(
  //                               builder: (context) => OtpScreen(),
  //                             ));
  //                       } else {
  //                         ScaffoldMessenger.of(context).showSnackBar(
  //                           const SnackBar(
  //                             content:
  //                                 Text("Something went wrong! Check internet"),
  //                             backgroundColor: Colors.red,
  //                           ),
  //                         );
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
  //                           "Get Otp",
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
  //                 FadeInUp(
  //                   duration: const Duration(milliseconds: 2000),
  //                   child: GestureDetector(
  //                     onTap: () {
  //                       Navigator.pop(context);
  //                     },
  //                     child: const Text(
  //                       "Back to Login",
  //                       style: TextStyle(
  //                         color: Color.fromRGBO(143, 148, 251, 1),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60), // Adjust spacing
                  const Text(
                    "Forgot Password",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Welcome back",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Image.asset("assets/images/login.png", height: 300),
                  ),
                  // const SizedBox(height: 20),

                  // Mobile Number Label
                  const Text(
                    "Mobile Number",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Mobile Number Input
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, right: 8.0, top: 5.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            controller: _mobilenoController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              hintText: "Enter your mobile no",
                              label: Text("Enter your mobile no"),
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
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) => OtpScreen(),
                      //     ));
                      if (_mobilenoController.text.length < 10) {}

                      bool result = await Auth()
                          .sendOtp(_mobilenoController.text.toString());

                      if (result) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("OTP sent successfully"),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtpScreen(),
                            ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Something went wrong!"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xff546AE4),
                      ),
                      child: const Center(
                        child: Text(
                          "Get Otp",
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Back to Login",
                          style: TextStyle(
                            color: Color(0xff546AE4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
