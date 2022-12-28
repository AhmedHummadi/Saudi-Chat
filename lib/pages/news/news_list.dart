import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saudi_chat/models/news_form.dart';
import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/pages/chat/chat_page.dart';
import 'package:saudi_chat/pages/news/news_details_page.dart';
import 'package:saudi_chat/shared/widgets.dart';

class NewsList extends StatefulWidget {
  final dynamic streamedUser;
  const NewsList({Key? key, required this.streamedUser}) : super(key: key);

  @override
  _NewsListState createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  List<NewsForm> news = [];

  final _scrollController = ScrollController();

  bool isTop = false;

  int _kColumnChildrenViewLength = 60;

  late UserAuth streamedUser;

  @override
  void initState() {
    streamedUser = widget.streamedUser;

    findNews();

    // this makes it so that it shows 6 news at a time and
    // keep showing 6 the more you scroll
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        setState(() {
          isTop = _scrollController.position.pixels == 0;
          if (!isTop) {
            _kColumnChildrenViewLength +=
                news.length >= (_kColumnChildrenViewLength + 6)
                    ? 6
                    : news.length - _kColumnChildrenViewLength;
          }
        });
      } else {
        setState(() {
          isTop = false;
        });
      }
    });
    super.initState();
  }

  Future<void> findNews() async {
    /// this function will be the algorithm that will get all the news from the
    /// nadis that the user is subscribed to and put them in a list that will show
    /// them all in a news card from date added first

    List<NewsForm> _news = [];

    // all the nadis to then get the news from each one and put them in a list
    List<DocumentReference> nadis = streamedUser.groups!
        .map((e) => e["nadiReference"] as DocumentReference)
        .toList();

    // get the news from each nadi and then add them to the news list
    for (var nadi in nadis) {
      final QuerySnapshot newsCollection = await nadi.collection("News").get();

      final List<NewsForm> finalNews = newsCollection.docs
          .map((newsDoc) => NewsForm.parse(newsDoc.data() as Map))
          .toList();

      _news.addAll(finalNews);
    }

    if (news.length == _news.length) {
      return;
    }

    for (var _new in news) {
      _news.removeWhere((element) => element.description == _new.description);
    }

    if (mounted) {
      setState(() {
        news.addAll(_news);
        news.sort((a, b) => b.dateCreated!.compareTo(a.dateCreated!));
      });
      return;
    } else {
      news.addAll(_news);
      news.sort((a, b) => b.dateCreated!.compareTo(a.dateCreated!));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (news.isEmpty) {
      return FutureBuilder(
          future: findNews(), builder: (context, snapshot) => Container());
    } else {
      findNews();
      return ScrollConfiguration(
        behavior: NoGlowScrollBehaviour(),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Column(
                children: news
                    .map((e) => NewsCard(
                          news: e,
                        ))
                    .toList()
                    .getRange(
                        news.length > 8
                            ? news.length - _kColumnChildrenViewLength
                            : 0,
                        news.length)
                    .toList(),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      );
    }
  }
}

class NewsCard extends StatelessWidget {
  final NewsForm news;
  const NewsCard({required this.news, Key? key}) : super(key: key);

  static Size overallDimensions(BuildContext context) {
    final double width = MediaQuery.of(context).size.width -
        (MediaQuery.of(context).size.width / 20);
    final double height = MediaQuery.of(context).size.height / 2.2 + 14;
    return Size(width, height);
  }

  String dateCreated() {
    DateTime now = DateTime.now();
    DateTime postCreated = news.dateCreated!.toDate();
    Duration differenceDatetime = now.difference(postCreated);
    return (differenceDatetime.inHours >= 48)
        ?
        // more than 2 days
        (differenceDatetime.inDays > 30)
            ?
            // more than a month ago
            "${(differenceDatetime.inDays / 30).floor()} months ago"
            :
            // less than a month and more than a day
            "${differenceDatetime.inDays} Days ago"
        :
        // less than 2 day
        (differenceDatetime.inHours >= 24)
            ?
            // more than a day ago and less than 2 days ago
            "Yesterday"
            :
            // less than 24 hours
            (differenceDatetime.inHours > 1)
                ?
                // more than an hour ago
                "${differenceDatetime.inHours} hours ago"
                :
                // less than an hour ago
                "${differenceDatetime.inMinutes} minutes ago";
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(
        height: 10,
      ),
      Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width -
              (MediaQuery.of(context).size.width / 20),
          height: MediaQuery.of(context).size.height / 2.2 + 4,
          child: Card(
            elevation: 2,
            color: Theme.of(context).colorScheme.surfaceTint,
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return NewsDetailsPage(news: news);
                }));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
                          child: Text(
                              // this algorithm will see if the date created is more than 24 hours ago
                              // if yes it will show either "Yesterday" or "* Days ago"

                              dateCreated(),
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey[800]
                                    : Colors.white,
                              )),
                        ),
                        Row(
                          children: [
                            Text(news.nadi!.nadiName!),
                            const SizedBox(
                              width: 6,
                            ),
                            CircleAvatar(
                              radius:
                                  (MediaQuery.of(context).size.height / 2.2) /
                                      16,
                              backgroundImage: Image.asset(
                                "assets/new_nadi_profile_pic.jpg",
                              ).image,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    SizedBox(
                      width: Size.infinite.width,
                      child: Text(
                        news.title!,
                        textAlign: news.title!.characters.any((element) =>
                                arabicLetters.any(
                                    (arabicLetter) => arabicLetter == element))
                            ? TextAlign.right
                            : TextAlign.left,
                        textDirection: news.title!.toString().characters.any(
                                (element) => arabicLetters.any(
                                    (arabicLetter) => arabicLetter == element))
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        style: TextStyle(
                            fontSize: 22,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.grey[800]
                                    : Colors.white),
                      ),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height:
                            (MediaQuery.of(context).size.height / 2.2) - 126,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CachedNetworkImage(
                            width: MediaQuery.of(context).size.width - 40,
                            imageUrl: news.imageUrl!,
                            filterQuality: FilterQuality.low,
                            fit: BoxFit.cover,
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
                    const SizedBox(
                      height: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    ]);
  }
}

class NewsCardPreview extends StatelessWidget {
  final NewsForm news;
  const NewsCardPreview({required this.news, Key? key}) : super(key: key);

  String dateCreated() {
    DateTime now = DateTime.now();
    DateTime postCreated = news.dateCreated!.toDate();
    Duration differenceDatetime = now.difference(postCreated);
    return (differenceDatetime.inHours >= 48)
        ?
        // more than 2 days
        (differenceDatetime.inDays > 30)
            ?
            // more than a month ago
            "${(differenceDatetime.inDays / 30).floor()} months ago"
            :
            // less than a month and more than a day
            "${differenceDatetime.inDays} Days ago"
        :
        // less than 2 day
        (differenceDatetime.inHours >= 24)
            ?
            // more than a day ago and less than 2 days ago
            "Yesterday"
            :
            // less than 24 hours
            (differenceDatetime.inHours > 1)
                ?
                // more than an hour ago
                "${differenceDatetime.inHours} hours ago"
                :
                // less than an hour ago
                "${differenceDatetime.inMinutes} minutes ago";
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(
        height: 10,
      ),
      Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width -
              (MediaQuery.of(context).size.width / 20),
          height: MediaQuery.of(context).size.height / 2.2 + 4,
          child: Card(
            elevation: 2,
            color: Theme.of(context).brightness == Brightness.light
                ? const Color(0xffECF0F0)
                : Colors.grey[800],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
                        child: Text(
                            // this algorithm will see if the date created is more than 24 hours ago
                            // if yes it will show either "Yesterday" or "* Days ago"

                            dateCreated(),
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey[800]
                                  : Colors.white,
                            )),
                      ),
                      Row(
                        children: [
                          Text(news.nadi!.nadiName!),
                          const SizedBox(
                            width: 6,
                          ),
                          CircleAvatar(
                            radius:
                                (MediaQuery.of(context).size.height / 2.2) / 16,
                            backgroundImage: Image.asset(
                              "assets/new_nadi_profile_pic.jpg",
                            ).image,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  SizedBox(
                    width: Size.infinite.width,
                    child: Text(
                      news.title == null || news.title.toString().isEmpty
                          ? "Preview"
                          : news.title!,
                      textAlign: news.title!.characters.any((element) =>
                              arabicLetters.any(
                                  (arabicLetter) => arabicLetter == element))
                          ? TextAlign.right
                          : TextAlign.left,
                      textDirection: news.title!.toString().characters.any(
                              (element) => arabicLetters.any(
                                  (arabicLetter) => arabicLetter == element))
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: TextStyle(
                          fontSize: 22,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey[800]
                                  : Colors.white),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: (MediaQuery.of(context).size.height / 2.2) - 126,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: news.previewImageP == null
                              ? Container(
                                  color: Colors.grey.withOpacity(0.5),
                                  child: Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 45,
                                      color: Colors.grey[200],
                                    ),
                                  ),
                                )
                              : Image(image: news.previewImageP!)),
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    ]);
  }
}
