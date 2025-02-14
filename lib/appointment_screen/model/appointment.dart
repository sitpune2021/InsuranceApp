class Appointment {
  final int appointment_id;
  final String appointment_no;
  final String clientName;
  final String medicalTests;
  final String time;
  final String date;
  final String mobileno;

  // Constructor
  Appointment({
    required this.appointment_id,
    required this.appointment_no,
    required this.clientName,
    required this.medicalTests,
    required this.time,
    required this.date,
    required this.mobileno,
  });

  // Method to convert all fields to lowercase and return a new instance
  Appointment toLowerCase() {
    return Appointment(
      appointment_id: appointment_id,
      appointment_no: appointment_no.toLowerCase(),
      clientName: clientName.toLowerCase(),
      medicalTests: medicalTests.toLowerCase(),
      time: time.toLowerCase(),
      date: date.toLowerCase(),
      mobileno: mobileno.toLowerCase(),
    );
  }

  // Method to return a JSON representation of the object
  Map<String, dynamic> toJson() {
    return {
      'appointment_id': appointment_id,
      'appointment_no': appointment_no,
      'clientName': clientName,
      'medicalTests': medicalTests,
      'time': time,
      'date': date,
      'mobileno': mobileno,
    };
  }

  // Factory method to create an Appointment from JSON
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointment_id: json['appointment_id'],
      appointment_no: json['appointment_no'] ?? '',
      clientName:
          json['name'] ?? 'Unknown Client', // Fallback to a default value
      medicalTests: json['treatment'] ?? 'Not Specified',
      time: json['time'] ?? '00:00', // Use a default time format
      date: json['time'] ?? 'date not available', // Use a default date format
      mobileno: json['mobileno'] ?? 'not found',
    );
  }

  // Override toString for better debugging and logging
  @override
  String toString() {
    return 'Appointment(clientName: $clientName, medicalTests: $medicalTests, time: $time, date: $date)';
  }
}
