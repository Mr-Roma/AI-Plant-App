import 'dart:io';

import 'package:ai_plant_app/data/repositories/plant_repository.dart';
import 'package:ai_plant_app/domain/usecases/image_picker.dart';
import 'package:ai_plant_app/domain/usecases/scan_provider.dart';
import 'package:ai_plant_app/presentation/pages/detail_page/article_detail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ImagePickerService _imagePickerService;
  late PlantRepository _plantRepository;
  late Future<List<dynamic>> articles;

  @override
  void initState() {
    super.initState();
    _imagePickerService = ImagePickerService();
    _plantRepository = PlantRepository();
    articles = fetchArticles(); // Fetch the articles when the page loads
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

  Future<void> _handleImageSelection(ImageSource source) async {
    final scanProvider = Provider.of<ScanProvider>(context, listen: false);

    try {
      final XFile? image = await _imagePickerService.pickImage(source);

      if (image != null) {
        scanProvider.setImage(File(image.path));
        scanProvider.setLoading(true);

        final result = await _plantRepository.identifyPlant(File(image.path));

        if (result['success']) {
          scanProvider.setScanResult(result['data']);
          // Navigate to result page
          Navigator.pushNamed(context, '/scan-result');
        } else {
          scanProvider.setError(result['error']);
        }
      }
    } catch (e) {
      scanProvider.setError('Failed to process image');
    } finally {
      scanProvider.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
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

                    // Scan Options
                    _buildScanOption(
                      icon: Icons.camera_alt,
                      color: Colors.green.shade700,
                      text: 'Scan and identify the plant',
                      onTap: () => _handleImageSelection(ImageSource.camera),
                    ),
                    const SizedBox(height: 12),
                    _buildScanOption(
                      icon: Icons.image,
                      color: Colors.green.shade700,
                      text: 'Browse the image file',
                      onTap: () => _handleImageSelection(ImageSource.gallery),
                    ),

                    // Categories Section
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
                            style: TextStyle(color: Colors.green.shade700),
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
                        _buildCategoryCard('Apple', '2 Plants',
                            'assets/images/apple_home.png'),
                        _buildCategoryCard(
                            'Grape', '1 Plant', 'assets/images/grape_home.png'),
                        _buildCategoryCard(
                            'Corn', '2 Plants', 'assets/images/corn_home.png'),
                        _buildCategoryCard('Orange', '5 Plants',
                            'assets/images/orange_home.png'),
                      ],
                    ),

                    // Article Disease Section
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
                            style: TextStyle(color: Colors.green.shade700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // FutureBuilder to load articles from the backend
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
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ArticleDetailPage(
                                                  article: article,
                                                )));
                                  },
                                  child: _buildArticleCard(
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
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanOption(
      {required IconData icon,
      required Color color,
      required String text,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, String subtitle, String imagePath) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(imagePath, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(String title, String subtitle, String imagePath) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imagePath,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}