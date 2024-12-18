import 'dart:async';
import 'dart:io';
import 'package:ai_plant_app/presentation/pages/detail_page/article_detail.dart';
import 'package:ai_plant_app/presentation/widgets/homepage/buildArticleCard_widget.dart';
import 'package:ai_plant_app/presentation/widgets/homepage/buildCategory_widget.dart';
import 'package:ai_plant_app/presentation/widgets/homepage/buildScan_widget.dart';
import 'package:ai_plant_app/presentation/widgets/homepage/scanresult_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> articles;
  File? filePath;
  String label = "";
  double confidence = 0.0;
  bool showScanResult = false;
  String description = "";
  Map<String, int> plantDiseaseCounts = {
    'Apple': 0,
    'Grape': 0,
    'Corn': 0,
    'Orange': 0,
  };

  @override
  void initState() {
    super.initState();
    articles = fetchArticles();
    _tfLiteInit();
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  Future<void> _tfLiteInit() async {
    try {
      await Tflite.loadModel(
        model: "assets/models/model.tflite",
        labels: "assets/models/labels.txt",
      );
      print("Model loaded successfully!");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future<void> processImage(File imageFile) async {
    var recognition = await Tflite.runModelOnImage(
      path: imageFile.path,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 2,
      threshold: 0.2,
      asynch: true,
    );

    setState(() {
      filePath = imageFile;
      description = "Loading description..."; // Set loading state

      if (recognition != null && recognition.isNotEmpty) {
        confidence = (recognition[0]['confidence'] * 100);
        label = (recognition[0]['label'].toString());

        // Check if confidence is below the threshold
        if (confidence < 75) {
          label = "No Disease Found";
          confidence = 0.0;
        } else {
          updatePlantDiseaseCount(label);
        }

        showScanResult = true;
      } else {
        // Handle case when no results are returned
        label = "No Disease Found";
        confidence = 0.0;
        showScanResult = true;
      }
    });

    print('Recognized label: $label'); // Debug print

    if (label != "No Disease Found") {
      setState(() {
        description = "Loading description...";
      });

      await waitForModel(); // Wait for the model to be ready
      await fetchDescription(label);
    } else {
      setState(() {
        confidence = 0.0;
        description = "Could not identify the disease.";
      });
    }
  }

  Future<void> fetchDescription(String title) async {
    String apiUrl = dotenv.env['API_URL']!;
    String apiKey = dotenv.env['API_KEY_HUGGINGFACE']!;

    try {
      print('Fetching description for disease: $title');

      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'inputs':
                  '''Generate a comprehensive report about the plant disease "$title". 

Your report should include:
1. **Common Symptoms**: What visible signs appear on the plant?
2. **Causes**: What factors (e.g., fungi, bacteria, viruses, or environmental conditions) cause this disease?
3. **Prevention Methods**: What steps can farmers take to prevent this disease?
4. **Treatment Options**: How can this disease be treated effectively?

Format your response as a detailed and structured plain text explanation.''',
              'parameters': {
                'max_length': 800,
                'temperature': 0.6, // Slightly lower for more focused answers
                'top_k': 50,
              }
            }),
          )
          .timeout(const Duration(seconds: 15));

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        String generatedText = '';

        if (responseData is List && responseData.isNotEmpty) {
          generatedText = responseData[0]['generated_text'] ?? '';
        } else if (responseData is Map) {
          generatedText = responseData['generated_text'] ?? '';
        }

        generatedText = generatedText
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();

        setState(() {
          if (generatedText.isNotEmpty) {
            description = generatedText;
          } else {
            description =
                "The AI could not provide detailed information. Consider researching \"$title\" manually for more accurate data.";
          }
        });
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        setState(() {
          description =
              "Failed to fetch disease description. Please try again later.";
        });
      }
    } catch (e) {
      print('Error fetching description: $e');
      setState(() {
        description =
            e is TimeoutException ? "Request timed out." : "An error occurred.";
      });
    }
  }

// Update the waitForModel function to use the new model
  Future<void> waitForModel() async {
    String apiUrl = dotenv.env['API_URL']!;
    String apiKey = dotenv.env['API_KEY_HUGGINGFACE']!;

    while (true) {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );

      if (response.statusCode != 503) break;
      await Future.delayed(const Duration(seconds: 20));
    }
  }

  Future<void> pickImageGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      await processImage(File(image.path));
    }
  }

  Future<void> pickImageCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      await processImage(File(image.path));
    }
  }

  Future<List<dynamic>> fetchArticles() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:5000/api/articles'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load articles');
    }
  }

  void updatePlantDiseaseCount(String diseaseLabel) {
    if (diseaseLabel.contains("Apple")) {
      plantDiseaseCounts['Apple'] = (plantDiseaseCounts['Apple'] ?? 0) + 1;
    } else if (diseaseLabel.contains("Grape")) {
      plantDiseaseCounts['Grape'] = (plantDiseaseCounts['Grape'] ?? 0) + 1;
    } else if (diseaseLabel.contains("Corn")) {
      plantDiseaseCounts['Corn'] = (plantDiseaseCounts['Corn'] ?? 0) + 1;
    } else if (diseaseLabel.contains("Orange")) {
      plantDiseaseCounts['Orange'] = (plantDiseaseCounts['Orange'] ?? 0) + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: showScanResult
            ? Column(
                children: [
                  AppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        setState(() {
                          showScanResult = false;
                          filePath = null;
                          label = "";
                          confidence = 0.0;
                        });
                      },
                    ),
                    title: const Text(
                      'Scan Result',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    backgroundColor: Colors.white,
                    elevation: 1,
                  ),
                  Expanded(
                    child: Expanded(
                      child: ScanResultPage(
                        confidence: confidence,
                        title: label,
                        subtitle:
                            "${confidence.toStringAsFixed(2)}% Confidence",
                        filePath: filePath,
                        description: description,
                      ),
                    ),
                  ),
                ],
              )
            : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    elevation: 1,
                    automaticallyImplyLeading: false,
                    title: const Text(
                      'Plant Disease App',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.black),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          const SizedBox(height: 20),
                          buildScanOption(
                              icon: Icons.camera_alt,
                              color: Colors.green.shade700,
                              text: 'Scan and identify the plant',
                              onTap: () {
                                pickImageCamera();
                              }),
                          const SizedBox(height: 12),
                          buildScanOption(
                              icon: Icons.image,
                              color: Colors.green.shade700,
                              text: 'Browse the image file',
                              onTap: () {
                                pickImageGallery();
                              }),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Categories',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  'View all',
                                  style:
                                      TextStyle(color: Colors.green.shade700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 2.5,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            children: [
                              buildCategoryCard(
                                  'Apple',
                                  '${plantDiseaseCounts['Apple']} Plants',
                                  'assets/images/apple_home.png'),
                              buildCategoryCard(
                                  'Grape',
                                  '${plantDiseaseCounts['Grape']} Plants',
                                  'assets/images/grape_home.png'),
                              buildCategoryCard(
                                  'Corn',
                                  '${plantDiseaseCounts['Corn']} Plants',
                                  'assets/images/corn_home.png'),
                              buildCategoryCard(
                                  'Orange',
                                  '${plantDiseaseCounts['Orange']} Plants',
                                  'assets/images/orange_home.png'),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Article Disease',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  'View all',
                                  style:
                                      TextStyle(color: Colors.green.shade700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          FutureBuilder<List<dynamic>>(
                            future: articles,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (snapshot.hasData) {
                                List<dynamic> articleData = snapshot.data!;
                                return Column(
                                  children: articleData.map((article) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ArticleDetailPage(
                                                article: article,
                                              ),
                                            ),
                                          );
                                        },
                                        child: buildArticleCard(
                                          article['title'],
                                          article['description'],
                                          article['imageUrl'],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              } else {
                                return const Text('No articles available');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
