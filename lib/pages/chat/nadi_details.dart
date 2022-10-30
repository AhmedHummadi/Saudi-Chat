import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NadiDetails extends StatefulWidget {
  final DocumentReference groupDocument;
  final dynamic streamUser;
  final Map groupData;
  final QuerySnapshot membersCollection;
  const NadiDetails(
      {Key? key,
      this.streamUser,
      required this.membersCollection,
      required this.groupData,
      required this.groupDocument})
      : super(key: key);

  @override
  _NadiDetailsState createState() => _NadiDetailsState();
}

class _NadiDetailsState extends State<NadiDetails> {
  @override
  Widget build(BuildContext context) {
    final Map groupData = widget.groupData;
    //?? The data of the nadis group document in the groups collection

    final streamedUser = widget.streamUser;
    final Size screenSize = MediaQuery.of(context).size;

    Future<QuerySnapshot> getMembersCollection(
        DocumentReference groupDocument) async {
      return await groupDocument.collection("members").get();
    }

    Future<QuerySnapshot> getAdminsCollection(
        DocumentReference groupDocument) async {
      return await groupDocument.collection("admins").get();
    }

    return Scaffold(
        appBar: AppBar(),
        body: FutureBuilder(
            future: Future.wait([
              getMembersCollection(widget.groupDocument),
              getAdminsCollection(widget.groupDocument)
            ]),
            builder: (context, snapshot) {
              late List<QuerySnapshot>? data;

              if (snapshot.hasData) {
                data = snapshot.data as List<QuerySnapshot>;
              } else {
                data = null;
              }

              return Container(
                height: screenSize.height,
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.2),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Material(
                        elevation: 1,
                        child: SizedBox(
                          width: screenSize.width,
                          height: screenSize.height / 3.2,
                          child: Stack(alignment: Alignment.center, children: [
                            CachedNetworkImage(
                                width: screenSize.width,
                                fit: BoxFit.cover,
                                imageUrl:
                                    "https://img.freepik.com/free-photo/black-monstera-leaves-background-wallpaper_53876-102420.jpg"),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey.shade500,
                                            spreadRadius: 0,
                                            blurRadius: 4)
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 48,
                                      backgroundImage: Image.asset(
                                        "assets/new_nadi_profile_pic.jpg",
                                      ).image,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    groupData["nadi_data"]["name"],
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500,
                                        shadows: [
                                          Shadow(
                                              offset: const Offset(0, 1.5),
                                              color: Colors.grey.shade500,
                                              blurRadius: 5)
                                        ]),
                                  )
                                ],
                              ),
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      //?? TODO: add a discription tab

                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SpecificDetail(
                                        specification: "Name",
                                        value: groupData["nadi_data"]["name"]),
                                    SpecificDetail(
                                        specification: "Email",
                                        value: groupData["nadi_data"]["email"]),
                                    SpecificDetail(
                                        specification: "Location",
                                        value: groupData["nadi_data"]
                                            ["location"])
                                  ],
                                )),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SpecificDetail(
                                        specification: "Phone Number",
                                        value: groupData["nadi_data"]
                                            ["phoneNum"]),
                                    SpecificDetail(
                                        specification: "Members",
                                        value: data != null
                                            ? data[0].docs.length.toString()
                                            : "..."),
                                    SpecificDetail(
                                        specification: "Admins",
                                        value: data != null
                                            ? data[1].docs.length.toString()
                                            : "...")
                                  ],
                                ))
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                            borderRadius: BorderRadius.circular(12)),
                        constraints: BoxConstraints.loose(
                            Size.fromHeight(screenSize.height / 3.5)),
                        width: screenSize.width,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Wrap(
                            direction: Axis.vertical,
                            children: data != null
                                ? data[0]
                                    .docs
                                    .map((memberDocument) => GroupMemberCard(
                                        memberDocumentData: memberDocument))
                                    .toList()
                                : [],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      )
                    ],
                  ),
                ),
              );
            }));
  }
}

class GroupMemberCard extends StatelessWidget {
  final DocumentSnapshot memberDocumentData;
  const GroupMemberCard({Key? key, required this.memberDocumentData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: ListTile(
        leading: CircleAvatar(
            radius: 24,
            backgroundImage: Image.asset(
              "assets/new_nadi_profile_pic.jpg",
            ).image),
        title: Text(
          memberDocumentData.get("name"),
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}

class SpecificDetail extends StatelessWidget {
  final String specification;
  final dynamic value;
  const SpecificDetail(
      {Key? key, required this.specification, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$specification:",
          style: TextStyle(
              color:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.75),
              fontSize: 14),
        ),
        const SizedBox(
          height: 2,
        ),
        Text(value,
            style: TextStyle(
                color: Theme.of(context).primaryColorDark, fontSize: 16)),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}

class MembersList extends StatelessWidget {
  final dynamic streamedUser;
  final Map groupData;
  final QuerySnapshot membersCollection;
  const MembersList(
      {Key? key,
      required this.streamedUser,
      required this.membersCollection,
      required this.groupData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        //border: Border.all(color: Colors.teal.shade900)
      ),
      height: screenSize.height / 2.8,
      width: screenSize.width / 2.2,
      child: SingleChildScrollView(
        child: Column(
          children: membersCollection.docs.map((member) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Divider(
                  color: Colors.grey[600],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.get("name"),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey[600],
                )
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
