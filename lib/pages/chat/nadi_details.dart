import 'package:flutter/material.dart';

class NadiDetails extends StatefulWidget {
  final dynamic streamUser;
  final Map groupData;
  const NadiDetails({Key? key, this.streamUser, required this.groupData})
      : super(key: key);

  @override
  _NadiDetailsState createState() => _NadiDetailsState();
}

class _NadiDetailsState extends State<NadiDetails> {
  @override
  Widget build(BuildContext context) {
    final Map groupData = widget.groupData;
    final streamedUser = widget.streamUser;
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: screenSize.height / 20,
          ),
          Container(
            padding: EdgeInsets.symmetric(
                vertical: screenSize.height / 20,
                horizontal: screenSize.width / 5),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      Image.asset("assets/new_nadi_profile_pic.jpg").image,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  groupData["nadi_data"]["name"],
                  style: const TextStyle(fontSize: 30, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 30, 0, 30),
            height: screenSize.height / 1.9089,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade500,
                  blurRadius: 2.0,
                  spreadRadius: 1.0,
                  offset: Offset(0, -1),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 40, 0),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                          value: groupData["nadi_data"]["location"]),
                      SpecificDetail(
                          specification: "Phone Number",
                          value: groupData["nadi_data"]["phoneNum"]),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Members: ${groupData["members"].length.toString()}",
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      MembersList(
                        groupData: groupData,
                        streamedUser: streamedUser,
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$specification:",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          const SizedBox(
            height: 6,
          ),
          Text(value,
              style: TextStyle(
                  color: Theme.of(context).primaryColorDark, fontSize: 18)),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}

class MembersList extends StatelessWidget {
  final dynamic streamedUser;
  final Map groupData;
  const MembersList(
      {Key? key, required this.streamedUser, required this.groupData})
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
          children: (groupData["members"] as List).map((member) {
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
                        member["name"],
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
