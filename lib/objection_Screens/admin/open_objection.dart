import 'dart:convert';

import 'package:flutter/material.dart';

<<<<<<< HEAD
import 'package:log_in/Constants.dart';
=======
import 'package:university_services/Constants.dart';
import 'package:university_services/bottom_navigation_bar.dart';
>>>>>>> 4b6224479fd278443d8a0122472ba76d9606474e
import 'package:http/http.dart' as http;
import 'package:university_services/login_Screen/AuthService.dart';

class OpenOb extends StatefulWidget {
  const OpenOb({super.key});

  @override
  State<OpenOb> createState() => _OpenObState();
}

class _OpenObState extends State<OpenOb> {
  String? year;
  String? term;
  bool isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> openObjection() async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse("${Constants.baseUrl}/admin/objections");
    final name = _nameController.text;
    final startDate = _startDateController.text;
    final endDate = _endDateController.text;
    final token = await AuthService.getToken();
    try {
      final response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'subject_name': name,
            'subject_year': year,
            'subject_term': term,
            'start_at': startDate,
            'end_at': endDate
          }));
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        Constants.showMessage(context, data['message'], Colors.green);
      } else if (data.containsKey('errors')) {
        final errors = data['errors'] as Map<String, dynamic>;
        final error_message = errors.values.first[0];
        Constants.showMessage(context, error_message, Colors.red);
      } else if (data.containsKey('message')) {
        Constants.showMessage(context, data['message'], Colors.red);
      } else {
        Constants.showMessage(context, "Unknown Error", Colors.red);
      }
    } catch (e) {
      Constants.showMessage(
          context, "Failed to connect server: $e", Colors.red);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Open Objection",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Constants.primaryColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, size: 30, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Enter subject name and date for the new objection:",
                  style: TextStyle(
                      fontSize: 16, color: Color.fromARGB(160, 0, 0, 0)),
                  // textAlign: TextAlign.start,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.only(
                  right: 10,
                  left: 10,
                ),
                decoration: BoxDecoration(
                    color: const Color.fromARGB(232, 255, 255, 255),
                    borderRadius: BorderRadius.circular(15)),
                child: DropdownButton<String>(
                  value: year,
                  hint: const Text("Select year"),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem<String>(
                        value: "first", child: Text("First year")),
                    DropdownMenuItem<String>(
                        value: "second", child: Text("Second year")),
                    DropdownMenuItem<String>(
                        value: "third", child: Text("Third year")),
                    DropdownMenuItem<String>(
                        value: "fourth", child: Text("Fourth year")),
                    DropdownMenuItem<String>(
                        value: "fifth", child: Text("Fifth year")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      year = value;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.only(
                  right: 10,
                  left: 10,
                ),
                decoration: BoxDecoration(
                    color: const Color.fromARGB(232, 255, 255, 255),
                    borderRadius: BorderRadius.circular(15)),
                child: DropdownButton<String>(
                  value: term,
                  hint: const Text("Select term"),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem<String>(
                        value: "first", child: Text("First term")),
                    DropdownMenuItem<String>(
                        value: "second", child: Text("Second term")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      term = value;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                // width: 100,
                // height: 20,
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Object name",
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xff000000))),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Constants.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                // width: 170,
                height: 50,
                child: TextFormField(
                  controller: _startDateController,
                  onTap: () => _selectDate(context, _startDateController),
                  decoration: InputDecoration(
                    labelText: "Start Date",
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xff000000))),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Constants.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                // width: 170,
                height: 50,
                child: TextFormField(
                  controller: _endDateController,
                  onTap: () => _selectDate(context, _endDateController),
                  decoration: InputDecoration(
                    labelText: "End Date",
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xff000000))),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Constants.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              isLoading
                  ? const CircularProgressIndicator()
                  : Container(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          openObjection();
                        },
                        child: const Text(
                          "Create Objection",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Constants.primaryColor,
                            elevation: 5),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
