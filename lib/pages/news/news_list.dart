import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saudi_chat/models/news_form.dart';
import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/pages/news/news_details_page.dart';
import 'package:saudi_chat/shared/widgets.dart';

class NewsList extends StatefulWidget {
  final dynamic streamedUser;
  bool? isHomeStyle = false;
  NewsList({Key? key, required this.streamedUser, this.isHomeStyle})
      : super(key: key);

  @override
  _NewsListState createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  List<NewsForm> news = [];

  @override
  void initState() {
    findNews();
    super.initState();
  }

  Future<void> findNews() async {
    /// this function will be the algorithm that will get all the news from the
    /// nadis that the user is subscribed to and put them in a list that will show
    /// them all in a news card from date added first

    UserAuth streamedUser = widget.streamedUser;
    List<NewsForm> _news = [];
    // all the nadis to then get the news from each one and put them in a list
    List<DocumentReference> nadis = streamedUser.groups!
        .map((e) => e["nadiReference"] as DocumentReference)
        .toList();

    // get the news from each nadi and then add them to the news list
    for (var nadi in nadis) {
      final Map data = await nadi.get().then((value) => value.data() as Map);
      final List nadiNews = data["news"];

      final List<NewsForm> finalNews =
          nadiNews.map((nadiNew) => NewsForm.parse(nadiNew)).toList();

      _news.addAll(finalNews);
    }

    for (var _new in news) {
      _news.removeWhere((element) => element.description == _new.description);
    }

    setState(() {
      news.addAll(_news);
      news.sort((a, b) => b.dateCreated!.compareTo(a.dateCreated!));
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      displacement: 30,
      onRefresh: () async => await findNews(),
      child: ScrollConfiguration(
        behavior: widget.isHomeStyle == true
            ? NoGlowScrollBehaviour()
            : const ScrollBehavior(),
        child: SingleChildScrollView(
          scrollDirection:
              widget.isHomeStyle == true ? Axis.horizontal : Axis.vertical,
          child: widget.isHomeStyle == true
              ? Row(
                  children: news.isEmpty
                      ? []
                      : news
                          .sublist(0, 4)
                          .map((e) => NewsCard(
                                news: e,
                                isHomeStyle: widget.isHomeStyle,
                              ))
                          .toList(),
                )
              : Column(
                  children: news
                      .map((e) => NewsCard(
                            news: e,
                            isHomeStyle: widget.isHomeStyle,
                          ))
                      .toList(),
                ),
        ),
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final NewsForm news;
  final bool? isHomeStyle;
  const NewsCard({required this.news, this.isHomeStyle, Key? key})
      : super(key: key);

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
    List<Widget> children = [
      SizedBox(
        height: isHomeStyle == true ? 0 : 14,
        width: isHomeStyle == true ? 6 : 0,
      ),
      Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width -
              (isHomeStyle == true ? 30 : 16),
          height: 330,
          child: Card(
            elevation: 2,
            color: isHomeStyle == true
                ? (Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[200]
                    : Colors.grey[800])
                : Theme.of(context).colorScheme.surface,
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return NewsDetailsPage(news: news);
                }));
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 32,
                                child: Text(
                                  news.title!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 22,
                                      color: isHomeStyle == true
                                          ? Colors.grey[900]
                                          : Colors.white),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(news.description!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: isHomeStyle == true
                                          ? Colors.grey[600]
                                          : Colors.white)),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: Image.asset(
                            "assets/new_nadi_profile_pic.jpg",
                          ).image,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            return const LinearGradient(
                              begin: Alignment.center,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black, Colors.transparent],
                            ).createShader(Rect.fromLTRB(
                                0, 0, rect.width, rect.height + 10));
                          },
                          blendMode: BlendMode.dstIn,
                          child: CachedNetworkImage(
                            width: MediaQuery.of(context).size.width - 40,
                            imageUrl: news.imageUrl!,
                            filterQuality: FilterQuality.low,
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
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            // this algorithm will see if the date created is more than 24 hours ago
                            // if yes it will show either "Yesterday" or "* Days ago"
                            dateCreated(),
                            style: TextStyle(
                              color: isHomeStyle == true
                                  ? Colors.grey[800]
                                  : Colors.white,
                            )),
                        Text(
                          "Show Details",
                          style: TextStyle(
                              color: isHomeStyle == true
                                  ? Colors.grey[800]
                                  : Colors.white,
                              decoration: TextDecoration.underline),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ];

    return isHomeStyle == true
        ? Row(
            children: children,
          )
        : Column(children: children);
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
                : differenceDatetime.inMinutes == 0
                    ? "now"
                    :
                    // less than an hour ago
                    "${differenceDatetime.inMinutes} minutes ago";
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 2,
        color: Theme.of(context).colorScheme.surface,
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 20,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            news.title!.isEmpty ? "Preview" : news.title!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 22),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            news.description!.isEmpty
                                ? "This is what your post should look like"
                                : news.description!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                color: Colors.grey[300], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: Image.asset(
                        "assets/new_nadi_profile_pic.jpg",
                      ).image,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: ShaderMask(
                      shaderCallback: (rect) {
                        return const LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black, Colors.transparent],
                        ).createShader(
                            Rect.fromLTRB(0, 0, rect.width, rect.height + 10));
                      },
                      blendMode: BlendMode.dstIn,
                      child: news.previewImageP == null
                          ? Container(
                              color: Colors.white.withOpacity(0.8),
                              child: const Center(
                                child: Icon(
                                  Icons.image,
                                  size: 30,
                                ),
                              ),
                            )
                          : Image(
                              image: news.previewImageP!,
                              width: MediaQuery.of(context).size.width - 40,
                              fit: BoxFit.fitWidth,
                            ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        // this algorithm will see if the date created is more than 24 hours ago
                        // if yes it will show either "Yesterday" or "* Days ago"
                        dateCreated(),
                        style: const TextStyle(
                          color: Colors.white,
                        )),
                    const Text(
                      "Show Details",
                      style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
