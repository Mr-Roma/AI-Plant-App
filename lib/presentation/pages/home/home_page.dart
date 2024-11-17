import 'dart:io';
import 'package:ai_plant_app/presentation/pages/detail_page/article_detail.dart';
import 'package:ai_plant_app/presentation/widgets/homepage/buildArticleCard_widget.dart';
import 'package:ai_plant_app/presentation/widgets/homepage/buildCategory_widget.dart';
import 'package:ai_plant_app/presentation/widgets/homepage/buildScan_widget.dart';
import 'package:flutter/material.dart';
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
        showScanResult = true;
      } else {
        label = "No result";
        confidence = 0.0;
        showScanResult = true;
      }
    });

    print('Recognized label: $label'); // Debug print

    if (label != "No result") {
      await fetchDescription(label);
    } else {
      setState(() {
        description = "Could not identify the disease.";
      });
    }
  }

  Future<void> fetchDescription(String title) async {
    const String apiUrl =
        'https://api-inference.huggingface.co/models/OpenAssistant/oasst-sft-4-pythia-12b-epoch-3.5';
    const String apiKey = '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';

    try {
      print('Fetching description for disease: $title'); // Debug print

      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'inputs':
                  'Describe the plant disease: $title. Include symptoms, causes, and basic treatment recommendations.',
              'parameters': {
                'max_length': 500,
                'temperature': 0.7,
              }
            }),
          )
          .timeout(
              const Duration(seconds: 15)); // Set a timeout for the request

      print('Response status code: ${response.statusCode}'); // Debug print
      print('Response body: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        // Parse the response
        final List<dynamic> responseData = json.decode(response.body);
        if (responseData.isNotEmpty &&
            responseData[0]['generated_text'] != null) {
          setState(() {
            description = responseData[0]['generated_text'];
          });
        } else {
          setState(() {
            description = 'No description available.';
          });
        }
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
            "An error occurred while fetching the disease description.";
      });
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
                    child: _scanResultPage(label, confidence.toString(), ''),
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
                              buildCategoryCard('Apple', '2 Plants',
                                  'assets/images/apple_home.png'),
                              buildCategoryCard('Grape', '1 Plant',
                                  'assets/images/grape_home.png'),
                              buildCategoryCard('Corn', '2 Plants',
                                  'assets/images/corn_home.png'),
                              buildCategoryCard('Orange', '5 Plants',
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

  Widget _scanResultPage(String title, String subtitle, String imagePath) {
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
                      children: const [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          "Hurray, we identified the disease!",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green,
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
                      "Confidence $subtitle",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          "Accuracy is ${confidence.toStringAsFixed(2)}%",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
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
                          : description,
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
