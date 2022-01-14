import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saudi_chat/models/news_form.dart';
import 'package:saudi_chat/shared/photo_viewer.dart';

class NewsDetailsPage extends StatelessWidget {
  final NewsForm news;
  const NewsDetailsPage({required this.news, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat.yMMMd()
                    .format(news.dateCreated!.toDate())
                    .toString()),
                Row(
                  children: [
                    Text(news.nadi!.nadiName!),
                    const SizedBox(
                      width: 10,
                    ),
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: Image.asset(
                        "assets/new_nadi_profile_pic.jpg",
                      ).image,
                    ),
                  ],
                )
              ],
            ),
            Divider(
              color: Colors.grey[400],
              thickness: 1,
              height: 20,
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              news.title!,
              style: const TextStyle(color: Colors.black, fontSize: 24),
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailScreen(
                            isVideo: false,
                            imageUrl: news.imageUrl,
                            tag: news.imageUrl,
                          ))),
              child: Container(
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Center(
                  child: Hero(
                    tag: news.imageUrl!,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints.loose(const Size.fromHeight(300)),
                        child: CachedNetworkImage(
                          imageUrl: news.imageUrl!,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.fitWidth,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Description:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(
              height: 6,
            ),
            Text(
              news.description!,
              style: TextStyle(color: Colors.grey[800]),
            )
          ],
        ),
      ),
    );
  }
}
