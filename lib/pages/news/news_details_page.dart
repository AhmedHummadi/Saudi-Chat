import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:saudi_chat/models/news_form.dart';
import 'package:saudi_chat/pages/chat/chat_page.dart';
import 'package:saudi_chat/shared/photo_viewer.dart';
import 'package:saudi_chat/shared/widgets.dart';

class NewsDetailsPage extends StatelessWidget {
  final NewsForm news;
  const NewsDetailsPage({required this.news, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat.yMMMd()
                                .format(news.dateCreated!.toDate())
                                .toString() +
                            ", ${DateFormat.jm().format(news.dateCreated!.toDate()).toString()}",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        "Created by: " + news.created_by!,
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        news.nadi!.nadiName!,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ProfileIconNadi(
                        nadiData: news.nadi!,
                        iconRadius: 80,
                        canEdit: false,
                        nadiDocument: news.nadiDoc!,
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: Size.infinite.width,
                child: Text(
                  news.title!,
                  textAlign: news.title!.characters.any((element) =>
                          arabicLetters
                              .any((arabicLetter) => arabicLetter == element))
                      ? TextAlign.right
                      : TextAlign.left,
                  textDirection: news.title!.toString().characters.any(
                          (element) => arabicLetters
                              .any((arabicLetter) => arabicLetter == element))
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: const TextStyle(color: Colors.black, fontSize: 26),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (d) => DetailScreen(
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
                            filterQuality: FilterQuality.low,
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
              Text(
                news.description!,
                textAlign: news.description!.characters.any((element) =>
                        arabicLetters
                            .any((arabicLetter) => arabicLetter == element))
                    ? TextAlign.right
                    : TextAlign.left,
                textDirection: news.description!.toString().characters.any(
                        (element) => arabicLetters
                            .any((arabicLetter) => arabicLetter == element))
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                style: TextStyle(color: Colors.grey[800], fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
