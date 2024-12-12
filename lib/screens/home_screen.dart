import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flow_app/controller/image_controller.dart';
import 'package:flutter_flow_app/controller/search_history_controller.dart';
import 'package:flutter_flow_app/service/unsplash_api.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  final ImageController imageController =
      Get.put(ImageController(UnsplashApiService()));
  final SearchHistoryController searchHistoryController =
      Get.put(SearchHistoryController(FirebaseFirestore.instance));
  final CarouselController carouselController = CarouselController();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onSubmitted: (query) {
            imageController.resetAndSearch(query);
            searchHistoryController.saveSearchQuery(query);
          },
          decoration: const InputDecoration(hintText: 'Search Unsplash'),
        ),
      ),
      body: Obx(() {
        if (imageController.isLoading.value && imageController.images.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: CarouselSlider.builder(
            // carouselController: carouselController,
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height * 0.7,
              enlargeCenterPage: true,
              viewportFraction: 0.9,
              onPageChanged: (index, reason) {
                // Load next batch when reaching the last image
                if (index == imageController.images.length - 1 &&
                    imageController.hasMoreImages.value) {
                  imageController.loadNextBatch();
                }
              },
            ),
            itemCount: imageController.images.length,
            itemBuilder: (context, index, realIndex) {
              final image = imageController.images[index];
              return Image.network(image.imageUrl, fit: BoxFit.cover);
            },
          ),
        );
      }),
    );
  }
}
