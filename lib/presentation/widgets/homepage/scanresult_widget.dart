import 'dart:io';

import 'package:flutter/material.dart';

class ScanResultPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final File? filePath;
  final String description;
  final double confidence;

  ScanResultPage({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.filePath,
    required this.description,
    required this.confidence,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Card(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
                child: filePath == null
                    ? Image.asset(
                        'assets/images/upload.png',
                        fit: BoxFit.cover,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          filePath!,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Success message
                    Row(
                      children: [
                        Icon(
                          title == "No Disease Found"
                              ? Icons.error
                              : Icons.check_circle,
                          color: title == "No Disease Found"
                              ? Colors.red
                              : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title == "No Disease Found"
                              ? "Sorry, we could not identify the disease!"
                              : "Hurray, we identified the disease!",
                          style: TextStyle(
                            fontSize: 16,
                            color: title == "No Disease Found"
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Description
                    Text(
                      "Confidence $confidence",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(
                          title == "No Disease Found"
                              ? Icons.error
                              : Icons.check_circle,
                          color: title == "No Disease Found"
                              ? Colors.red
                              : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Accuracy is ${confidence.toStringAsFixed(2)}%",
                          style: TextStyle(
                            color: title == "No Disease Found"
                                ? Colors.red
                                : Colors.green,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),

                    Text(
                      description.isEmpty
                          ? "Loading description..."
                          : "Description: ",
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: () {
                          // Implement save functionality
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.bookmark_border,
                                  color: Colors.white),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "Save this plant",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
