import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saudi_chat/models/nadi.dart';
import 'package:saudi_chat/models/news_form.dart';
import 'package:saudi_chat/models/user.dart';
import 'package:saudi_chat/pages/news/news_list.dart';
import 'package:saudi_chat/services/controls.dart';
import 'package:saudi_chat/services/database.dart';
import 'package:saudi_chat/services/storage.dart';
import 'package:saudi_chat/shared/loadingWidget.dart';
import 'package:saudi_chat/shared/widgets.dart';

class AddNewsPage extends StatefulWidget {
  final dynamic streamedUser;
  const AddNewsPage({Key? key, required this.streamedUser}) : super(key: key);

  @override
  _AddNewsPageState createState() => _AddNewsPageState();
}

class _AddNewsPageState extends State<AddNewsPage> {
  String? postTitle = "";
  String? postDescription = "";
  Image? postImage;
  String? postImagePath;

  String? groupName;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Post"),
      ),
      body: Stack(alignment: Alignment.bottomCenter, children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Visibility(
                              visible: widget.streamedUser.groupAdmin != null,
                              child: Text(
                                "Group:",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey[200]),
                              ),
                            ),
                            Visibility(
                              visible: widget.streamedUser.userClass ==
                                  UserClass.moderator,
                              child: const SizedBox(
                                height: 10,
                              ),
                            ),
                            Visibility(
                              visible: widget.streamedUser.userClass ==
                                  UserClass.moderator,
                              child: FutureBuilder(
                                  future: getGroupsAdminNames(),
                                  builder: (context, snapshot) {
                                    return chooseGroupDropdown(
                                        snapshot.hasData
                                            ? snapshot.data as List<String>
                                            : [],
                                        widget.streamedUser);
                                  }),
                            ),
                            Visibility(
                              visible: widget.streamedUser.userClass ==
                                  UserClass.moderator,
                              child: const SizedBox(
                                height: 16,
                              ),
                            ),
                            Text(
                              "Title :",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[200]),
                            ),
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                width: MediaQuery.of(context).size.width / 1.1,
                                child: titleTextField()),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Description :",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[200]),
                            ),
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                width: MediaQuery.of(context).size.width / 1.1,
                                child: descriptionTextField()),
                            Text(
                              "Image :",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[200]),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            imageContainerField(),
                            const SizedBox(
                              height: 20,
                            ),
                          ]),
                    ),
                  ),
                  FutureBuilder<QuerySnapshot>(
                    future: DataBaseService()
                        .nadiCollection
                        .where("name", isEqualTo: groupName.toString())
                        .get(),
                    builder: (context, snapshot) => NewsCardPreview(
                        news: NewsForm(
                            dateCreated: Timestamp.fromDate(DateTime.now()),
                            title: postTitle,
                            description: postDescription,
                            nadiDoc: snapshot.hasData &&
                                    snapshot.data!.docs.isNotEmpty
                                ? snapshot.data!.docs.single.reference
                                : null,
                            nadi: snapshot.hasData &&
                                    snapshot.data!.docs.isNotEmpty
                                ? NadiData.parse(
                                    snapshot.data!.docs.single.data() as Map)
                                : NadiData(
                                    email: "gg@gmail.com",
                                    nadiName: "name",
                                    phoneNum: "+61423010463",
                                    location: "Sydney",
                                    id: "vLBRRym1i3MoZHa65FBm"),
                            previewImageP:
                                postImage != null ? postImage!.image : null)),
                  ),
                  SizedBox(
                    height: postTitle!.isNotEmpty &&
                            postImage != null &&
                            postDescription!.isNotEmpty
                        ? 90
                        : 15,
                  )
                ],
              ),
            ),
          ),
        ),
        Visibility(
            visible: postTitle!.isNotEmpty &&
                postImage != null &&
                postDescription!.isNotEmpty,
            child: Material(
              elevation: 5,
              color: Colors.transparent,
              child: Container(
                height: 70,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14))),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Material(
                        elevation: 1,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border:
                                  Border.all(color: Colors.black, width: 0.8)),
                          height: 40,
                          child: const Center(
                            child: Text(
                              "Cancel",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                            ),
                          ),
                          width: 80,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 70,
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          createLoadingOverlay(context);
                          await onPostTapped(widget.streamedUser);
                          removeOverlayEntry(context);
                          Navigator.of(context).pop();
                          Fluttertoast.showToast(msg: "Successfully Posted");
                        }
                      },
                      child: Material(
                        elevation: 1,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 40,
                          child: const Center(
                            child: Text(
                              "Post",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                          width: 80,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )),
      ]),
    );
  }

  Future<List<String>> getGroupsAdminNames() async {
    // ignore: avoid_single_cascade_in_expression_statements
    List<String> names = [];

    Future<String> getGroupName(DocumentSnapshot snapshot) async {
      return snapshot.get("name");
    }

    List<DocumentSnapshot> groups =
        (await DataBaseService().nadiCollection.get()).docs;

    for (var item in groups) {
      names.add(await getGroupName(item));
    }
    return names;
  }

  Future<void> onPostTapped(UserAuth streamedUser) async {
    try {
      // upload the image into firebase storage and get the url then
      // gather all the details into a map and add them
      // to the news list in the nadis document

      // if the user is a moderator then give him accesss to all the nadis
      // and post news to whichever nadi it wants
      if (streamedUser.userClass == UserClass.moderator) {
        DocumentReference groupDoc = DataBaseService().messagesCollection.doc(
            (await DataBaseService()
                    .nadiCollection
                    .where("name", isEqualTo: groupName)
                    .get())
                .docs
                .single
                .id);

        // upload the image first then get the url
        String url = await FireStorage()
            .uploadImageForNews(File(postImagePath!), groupDoc);

        // parse the nadi doc into a map for the details

        DocumentReference nadiDoc =
            DataBaseService().nadiCollection.doc(groupDoc.id);

        Map nadiData = (await nadiDoc.get()).data() as Map;

        // convert the details into a map then upload it to firestore
        Map details = {
          "dateCreated": Timestamp.now(),
          "imageUrl": url,
          "created_by": streamedUser.displayName,
          "nadi": nadiData,
          "nadiDoc": nadiDoc,
          "description": postDescription,
          "title": postTitle
        };

        await ControlsService().postNews(details);
        return;
      }

      // upload the image first then get the url
      String url = await FireStorage()
          .uploadImageForNews(File(postImagePath!), streamedUser.groupAdmin!);

      // parse the nadi doc into a map for the details

      DocumentReference nadiDoc =
          DataBaseService().nadiCollection.doc(streamedUser.groupAdmin!.id);

      Map nadiData = (await nadiDoc.get()).data() as Map;

      // convert the details into a map then upload it to firestore
      Map details = {
        "dateCreated": Timestamp.now(),
        "imageUrl": url,
        "nadi": nadiData,
        "created_by": streamedUser.displayName,
        "nadiDoc": nadiDoc,
        "description": postDescription,
        "title": postTitle
      };

      await ControlsService().postNews(details);
      return;
    } catch (e) {
      Fluttertoast.showToast(msg: "an unknown error has occured");
    }
  }

  Widget chooseGroupDropdown(List<String> itemList, UserAuth streamedUser) {
    return MyDropdownField(
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10)),
        itemsList: itemList,
        onChanged: (val) {
          setState(() {
            groupName = val.toString();
          });
        },
        validatorText: "Please choose a group",
        labelText: null);
  }

  Widget imageContainerField() {
    return Column(
      children: [
        Container(
          height: 220,
          width: MediaQuery.of(context).size.width / 1.1,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: postImage == null
                  ? Border.all(color: Colors.grey.shade600)
                  : null,
              color: postImage == null ? Colors.white.withOpacity(0.9) : null),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14), topRight: Radius.circular(14)),
            child: postImage ??
                Center(
                  child: TextButton.icon(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.surface)),
                      onPressed: () async {
                        await pickImage();
                      },
                      icon: const Icon(
                        Icons.image_outlined,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Upload an Image",
                        style: TextStyle(color: Colors.white),
                      )),
                ),
          ),
        ),
        Visibility(
          visible: postImage != null,
          child: InkWell(
            onTap: () => setState(() {
              postImage = null;
              postImagePath = null;
            }),
            child: Container(
                width: MediaQuery.of(context).size.width / 1.1,
                height: 38,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10))),
                child: const Center(
                  child: Text(
                    "Reset",
                    style: TextStyle(
                        letterSpacing: 1.2,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 22),
                  ),
                )),
          ),
        )
      ],
    );
  }

  Future pickImage() async {
    try {
      XFile? pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        final Uint8List imageBytes = await pickedImage.readAsBytes();
        // the user has picked an image, use the image to view it in preview
        // and imageContainerField, then when the user posts hte image we will
        // upload it to firebase storage and update news in the nadi document

        setState(() {
          postImage = Image.memory(
            imageBytes,
            fit: BoxFit.fitWidth,
          );
          postImagePath = pickedImage.path;
        });
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: "An error has occured, Please try again");
    }
  }

  MyTextField titleTextField() {
    return MyTextField(
        formKey: _formKey,
        maxLines: 2,
        cursorColor: Colors.grey[500],
        hintText: "Title...",
        hintTextStyle: const TextStyle(color: Colors.grey),
        backgroundColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey.shade500, width: 1.2)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey.shade500, width: 1.2)),
        labelStyle: const TextStyle(color: Colors.white),
        inputStyle: TextStyle(color: Colors.grey.shade600),
        validatorText: "Title must have at least 10 characters",
        onChangedVal: (val) {
          setState(() {
            postTitle = val;
          });
        },
        validateCondition: (val, errorText) =>
            val!.length < 10 ? errorText : null);
  }

  MyTextField descriptionTextField() {
    return MyTextField(
        formKey: _formKey,
        maxLines: 8,
        cursorColor: Colors.grey[500],
        hintText: "Description...",
        hintTextStyle: const TextStyle(color: Colors.grey),
        backgroundColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey.shade500, width: 1.2)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey.shade500, width: 1.2)),
        labelStyle: const TextStyle(color: Colors.white),
        inputStyle: TextStyle(color: Colors.grey.shade600),
        validatorText: "Description must have at least 50 characters",
        onChangedVal: (val) {
          setState(() {
            postDescription = val;
          });
        },
        validateCondition: (val, errorText) =>
            val!.length < 50 ? errorText : null);
  }
}
