/*
  This file returns the encapsulating body widget for the Account page
*/
import 'dart:io';
import 'dart:typed_data';

import 'package:elevar_fitness_tracker/components/account_page_entry.dart';
import 'package:elevar_fitness_tracker/components/rounded_button.dart';
import 'package:elevar_fitness_tracker/login_signup_page/login_signup_page.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:elevar_fitness_tracker/materials/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:image_picker/image_picker.dart';

class AccountBody extends StatefulWidget {
  Function updatePage;
  Function stateCallBack;
  AccountBody(this.updatePage, this.stateCallBack, {super.key});

  @override
  State<AccountBody> createState() => _AccountBodyState();

  // Converts a date into a readable string for displaying to
  // the user, either in "January 1, 1970" if asText is true,
  // or as "1970/01/01" is asText is false.
  // Static since it also gets used in the signup process.
  static String formatTimestamp(DateTime date, {bool asText = false}) {
    const Map<int, String> months = {
      1: "January",
      2: "February",
      3: "March",
      4: "April",
      5: "May",
      6: "June",
      7: "July",
      8: "August",
      9: "September",
      10: "October",
      11: "November",
      12: "December"
    };

    return asText ?
      "${months[date.month]} ${date.day}, ${date.year}" :
      "${date.year.toString()}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}";
  }
}

class _AccountBodyState extends State<AccountBody> {
  SharedPreferences? prefs;
  String username = "";
  bool darkmode = false;

  Uint8List? userImage;
  File? selectedImage;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((sharedPrefs) {
      setState(() {
        prefs = sharedPrefs;
        // We get the username stored in local storage so we can grab it's
        // relevent information from the cloud later on.
        username = prefs?.getString('username') ?? "";
      });
    });
  }

  // Display a dialog for editing the name fields (first and last)
  void editNameDialog(BuildContext context, String username, Map<String, dynamic> data, TextEditingController firstNameController, TextEditingController lastNameController) {
    firstNameController.text = data['first_name'];
    lastNameController.text = data['last_name'];
  
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('Edit Name', style: AppStyles.getSubHeadingStyle(darkmode)),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(label: Text("First Name")),
                  controller: firstNameController
                ),
                TextFormField(
                  decoration: const InputDecoration(label: Text("Last Name")),
                  controller: lastNameController
                )
              ],
            )
          ),
          actions: <Widget>[
            MaterialButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(ctx);              
              }
            ),
            MaterialButton(
              color: AppStyles.highlightColor(darkmode),
              child: const Text("Confirm"),
              onPressed: () {
                FirebaseFirestore.instance.collection('users').doc(username).update({
                  'first_name': firstNameController.text,
                  'last_name': lastNameController.text
                });

                setState(() { });
                Navigator.pop(ctx);   
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Updated name to \"${firstNameController.text} ${lastNameController.text}\"")
                  )
                );      
              }
            )
          ],
        );
      }
    );
  }

  // Display a dialog for editing the birthdate field
  void editBirthdateDialog(BuildContext context, String username, Map<String, dynamic> data) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: (data['birthdate'] as Timestamp).toDate(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      cancelText: "Cancel",
      confirmText: "Confirm",
      helpText: "Edit Birthdate",
    );

    if (picked != null) {
      FirebaseFirestore.instance.collection('users').doc(username).update({
        'birthdate': Timestamp.fromDate(picked),
      });

      setState(() { });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Updated birthdate to \"${AccountBody.formatTimestamp(Timestamp.fromDate(picked).toDate())}\"")
        )
      );      
    } 
  }

  // Display a dialog for editing the email field.
  // Makes the user enter the new e-mail twice to confirm,
  // as well as starting with the first text field auto-
  // filled in case they only need to make a minor change.
  void editEmailDialog(BuildContext context, String username, Map<String, dynamic> data, TextEditingController emailController, TextEditingController confirmController) async {
    emailController.text = data['email'];
    final editEmailFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('Edit Email', style: AppStyles.getSubHeadingStyle(darkmode)),
          content: Form(
            key: editEmailFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(label: Text("New e-mail")),
                  controller: emailController
                ),
                TextFormField(
                  decoration: const InputDecoration(label: Text("Confirm new e-mail")),
                  controller: confirmController,
                  validator: (String? value) {
                    return (emailController.text != confirmController.text) ? 'E-mails must match' : null;
                  },
                  autovalidateMode: AutovalidateMode.always,
                )
              ],
            )
          ),
          actions: <Widget>[
            MaterialButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(ctx);
              }
            ),
            MaterialButton(
              color: AppStyles.highlightColor(darkmode),
              child: const Text("Confirm"),
              onPressed: () {
                if (editEmailFormKey.currentState!.validate()) {
                  FirebaseFirestore.instance.collection('users').doc(username).update({
                    'email': emailController.text
                  });

                  setState(() { });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Updated e-mail to \"${emailController.text}\"")
                    )
                  );
                }
              }
            )
          ]
        );
      }
    );
  }

  // Display a dialog for editing the password field.
  // Makes the user enter the current password, and the
  // new password twice for confirmation purposes.
  void editPasswordDialog(BuildContext context, String username, Map<String, dynamic> data, TextEditingController currentPassword, TextEditingController newPassword, TextEditingController confirmNewPassword) async {
    final editPasswordFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('Edit Password', style: AppStyles.getSubHeadingStyle(darkmode)),
          content: Form(
            key: editPasswordFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(label: Text("Current password")),
                  controller: currentPassword,
                  validator: (String? value) {
                    return (currentPassword.text != data['password']) ? "Incorrect password" : null;
                  }
                ),
                TextFormField(
                  decoration: const InputDecoration(label: Text("New password")),
                  controller: newPassword,
                  validator: (String? value) {
                    if (newPassword.text.isEmpty) {
                      return "Password cannot be empty";
                    } else if (newPassword.text == currentPassword.text) {
                      return "New password cannot match old password";
                    }

                    return null;
                  }
                ),
                TextFormField(
                  decoration: const InputDecoration(label: Text("Confirm new password")),
                  controller: confirmNewPassword,
                  validator: (String? value) {
                    return (newPassword.text != confirmNewPassword.text) ? "Passwords must match" : null;
                  }
                )
              ],
            )
          ),
          actions: <Widget>[
            MaterialButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(ctx);
              }
            ),
            MaterialButton(
              color: AppStyles.highlightColor(darkmode),
              child: const Text("Confirm"),
              onPressed: () {
                if (editPasswordFormKey.currentState!.validate()) {
                  FirebaseFirestore.instance.collection('users').doc(username).update({
                    'password': newPassword.text
                  });

                  setState(() { });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Updated password")
                    )
                  );
                }
              }
            )
          ]
        );
      }
    );
  }

  // For refreshing page when user toggles dark mode
  void refresh() {
    setState(() {});
    //widget.stateCallBack(darkmode);
  }

  //Dialog for users to pick image source
  void pickProfilePic() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                pickImageFromAlbum();
              },
              child: const ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Photo Album'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                pickImageFromCamera();
              },
              child: const ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
              ),
            ),
            const Divider(),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                FirebaseFirestore.instance.collection('users').doc(username).update({
                  'picture_url': FieldValue.delete()
                });
                setState(() {});
              },
              child: const ListTile(
                leading: Icon(Icons.delete),
                title: Text('Remove'),
              ),
            )
          ],
        );
      },
    );
  }

  //Take picture using camera
  Future<void> pickImageFromCamera() async {
    try {
      ImagePicker picker = ImagePicker();
      final returnImage = await picker.pickImage(source: ImageSource.camera);

      if (returnImage == null) {
        return;
      }

      final File imageFile = File(returnImage.path);

      if (imageFile.existsSync()) {
        // Push image to firebase
        DateTime now = DateTime.now().toLocal();
        var filename = '${now.year}-${now.month}-${now.day}.${now.hour}-${now.minute}-${now.second}';
        final storageRef = FirebaseStorage.instance.ref().child('files').child(username);
        // Delete existing profile pictures if any
        await storageRef.listAll().then((value) {
          for (var element in value.items) {
            FirebaseStorage.instance.ref(element.fullPath).delete();
          }
        });
        final fileRef = storageRef.child('$filename.${imageFile.path.split('.').last}');
        final TaskSnapshot snapshot = await fileRef.putFile(imageFile);
        var downloadUrl = await snapshot.ref.getDownloadURL();
        FirebaseFirestore.instance.collection('users').doc(username).update({
          'picture_url': downloadUrl
        });

        setState(() {
          selectedImage = imageFile;
          userImage = imageFile.readAsBytesSync();
        });

        // Pop route only if it exists
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      } else {
        print('Error: Image file does not exist.');
      }
    } on FileSystemException catch (e) {
      print('Error picking image: $e');
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  //Open album to pick a picture
  Future<void> pickImageFromAlbum() async {
    try {
      ImagePicker picker = ImagePicker();
      final returnImage = await picker.pickImage(source: ImageSource.gallery);

      if (returnImage == null) {
        return;
      }
      final File imageFile = File(returnImage.path);

      if (imageFile.existsSync()) {
        // Push image to firebase
        DateTime now = DateTime.now().toLocal();
        var filename = '${now.year}-${now.month}-${now.day}.${now.hour}-${now.minute}-${now.second}';
        final storageRef = FirebaseStorage.instance.ref().child('files').child(username);
        // Delete existing profile pictures if any
        await storageRef.listAll().then((value) {
          for (var element in value.items) {
            FirebaseStorage.instance.ref(element.fullPath).delete();
          }
        });
        final fileRef = storageRef.child('$filename.${imageFile.path.split('.').last}');
        final TaskSnapshot snapshot = await fileRef.putFile(imageFile);
        var downloadUrl = await snapshot.ref.getDownloadURL();
        FirebaseFirestore.instance.collection('users').doc(username).update({
          'picture_url': downloadUrl
        });

        setState(() {
          selectedImage = imageFile;
          userImage = imageFile.readAsBytesSync();
        });

        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      } else {
        print('Error: Image file does not exist.');
      }
    } on FileSystemException catch (e) {
      print('Error picking image: $e');
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final emailConfirmController = TextEditingController();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool isDarkMode = prefs?.getBool('darkmode') ?? false;

    return Scaffold(
      backgroundColor: AppStyles.backgroundColor(isDarkMode),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              CupertinoIcons.person_solid,
              color: AppStyles.textColor(isDarkMode)
            ),
            const SizedBox(width: 10),
            Text(
              "Account",
              style: TextStyle(
                fontFamily: 'Geologica',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppStyles.textColor(isDarkMode),
              )
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: AppStyles.textColor(isDarkMode),
            ),
            onPressed: () {
              prefs?.setString('username', '');
              prefs?.setString('password', '');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginSignupPage()),
              );
            },
          )
        ],
        backgroundColor: AppStyles.primaryColor(isDarkMode).withOpacity(isDarkMode ? 0.5 : 1.0)
      ),
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.delta.distance > 5) {
            if (details.delta.dx > 0) {
              widget.updatePage(1);
            }
          }
        },
        child: Stack(
          children: [
            Container(
              // When in light mode, we want the background to be slightly darker than foreground
              // elements, so we overlay a bit of the primary color over the white background.
              // However, applying the same logic in dark mode would result in a slightly tinted
              // background with black foreground elements, which is the opposite of what we want.
              // Therefore, we flip the colouring logic of this background and of the foreground
              // elements based on if we're in dark mode or not. You'll see this throughout this
              // doc, the next comment block down is an example of foreground elements.
              color: isDarkMode ? Colors.transparent : AppStyles.primaryColor(isDarkMode).withOpacity(0.2)
            ),
            username.isEmpty
            ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Want to track account info?",
                    style: TextStyle(
                      fontFamily: 'Geologica',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppStyles.textColor(isDarkMode)
                    )
                  ),
                  const SizedBox(height: 60),
                  RoundedButton("Login", () {
                    prefs?.setString('username', '');
                    prefs?.setString('password', '');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginSignupPage()),
                    );
                  }, prefs),
                  Text(
                    "or",
                    style: TextStyle(
                      fontFamily: 'Geologica',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppStyles.textColor(isDarkMode).withOpacity(0.5)
                    )
                  ),
                  RoundedButton("Signup", () {
                    prefs?.setString('username', '');
                    prefs?.setString('password', '');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginSignupPage(showSignup: true)),
                    );
                  }, prefs),
                ],
              ),
            )
            : FutureBuilder(
              future: SharedPreferences.getInstance(),
              builder: (BuildContext context0, AsyncSnapshot<SharedPreferences> snapshot0) {
                if (snapshot0.connectionState == ConnectionState.done) {
                  return FutureBuilder(
                    future: users.doc(username).get(),
                    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text("Something went wrong!",
                          style: AppStyles.getSubHeadingStyle(darkmode))
                        );
                      }
        
                      if (snapshot.hasData && !snapshot.data!.exists) {
                        return Center(
                          child: Text(
                            "Could not fetch data for '$username'!",
                            style: AppStyles.getSubHeadingStyle(darkmode)
                          )
                        );
                      }
        
                      if (snapshot.connectionState == ConnectionState.done) {
                        Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                        Reference? httpsRef;
                        if (data.containsKey('picture_url')) {
                          httpsRef = FirebaseStorage.instance.refFromURL(data['picture_url']);
                        }
        
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                                  // Here! Is where we handle the colouring of foreground elements
                                  // depending on if we're in light or dark mode. See comment above
                                  // for context.
                                  // This happens a few more times throughout this doc (for every
                                  // user information container we have), so I will not comment on it
                                  // past this point, but keep it in mind.
                                  color: isDarkMode ? AppStyles.primaryColor(isDarkMode).withOpacity(0.2) : AppStyles.backgroundColor(isDarkMode),
                                  boxShadow: [
                                    // One softer, blurrier shadow combined with a sharper
                                    // shadow to create a sense of layering. Idea shamelessly
                                    // taken from Microsoft's Fluent 2 design docs.
                                    BoxShadow(
                                      spreadRadius: 2,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3),
                                      color: Colors.black.withOpacity(0.1)
                                    ),
                                    BoxShadow(
                                      blurRadius: 1,
                                      offset: const Offset(0, 1),
                                      color: Colors.black.withOpacity(0.1)
                                    )
                                  ]
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          margin: AppStyles.getDefaultInsets(),
                                          child: httpsRef == null
                                          ? Stack(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: AppStyles.secondaryColor(isDarkMode),
                                                minRadius: 60,
                                                child: Text(
                                                  "${data['first_name'][0]}${data['last_name'][0]}",
                                                  style: TextStyle(
                                                    fontFamily: 'Geologica',
                                                    fontSize: 48,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppStyles.textColor(isDarkMode).withOpacity(0.5),
                                                  )
                                                )
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                right: -25,
                                                child: RawMaterialButton(
                                                  onPressed: () {
                                                    pickProfilePic();
                                                  },
                                                  fillColor: AppStyles.primaryColor(isDarkMode),
                                                  shape: const CircleBorder(),
                                                  elevation: 4,
                                                  child: Icon(
                                                    Icons.camera_alt,
                                                    color: AppStyles.textColor(!isDarkMode),
                                                  )
                                                )
                                              )
                                            ],
                                          )
                                          : FutureBuilder(
                                            future: httpsRef.getData(),
                                            builder: (BuildContext imgContext, AsyncSnapshot<Uint8List?> imgSnapshot) {
                                              if (imgSnapshot.connectionState == ConnectionState.done && imgSnapshot.hasData) {
                                                return Stack(
                                                  children: [
                                                    CircleAvatar(
                                                      minRadius: 60,
                                                      backgroundImage: MemoryImage(imgSnapshot.data!),
                                                    ),
                                                    Positioned(
                                                      bottom: 0,
                                                      right: -25,
                                                      child: RawMaterialButton(
                                                        onPressed: () {
                                                          pickProfilePic();
                                                        },
                                                        fillColor: AppStyles.primaryColor(isDarkMode),
                                                        shape: const CircleBorder(),
                                                        elevation: 4,
                                                        child: Icon(
                                                          Icons.camera_alt,
                                                          color: AppStyles.textColor(!isDarkMode),
                                                        )
                                                      )
                                                    )
                                                  ],
                                                );
                                              }

                                              return Stack(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor: AppStyles.secondaryColor(isDarkMode),
                                                    minRadius: 60,
                                                    child: Text(
                                                      "${data['first_name'][0]}${data['last_name'][0]}",
                                                      style: TextStyle(
                                                        fontFamily: 'Geologica',
                                                        fontSize: 48,
                                                        fontWeight: FontWeight.w800,
                                                        color: AppStyles.textColor(isDarkMode).withOpacity(0.5),
                                                      )
                                                    )
                                                  ),
                                                  Positioned(
                                                    bottom: 0,
                                                    right: -25,
                                                    child: RawMaterialButton(
                                                      onPressed: () {
                                                        pickProfilePic();
                                                      },
                                                      fillColor: AppStyles.primaryColor(isDarkMode),
                                                      shape: const CircleBorder(),
                                                      elevation: 4,
                                                      child: Icon(
                                                        Icons.camera_alt,
                                                        color: AppStyles.textColor(!isDarkMode),
                                                      )
                                                    )
                                                  )
                                                ],
                                              );
                                            }
                                          )
                                        ),
                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.all(5),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${data['first_name']} ${data['last_name']}",
                                                  style: TextStyle(
                                                    fontFamily: 'Geologica',
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppStyles.textColor(isDarkMode),
                                                  )
                                                ),
                                                Text(
                                                  "@$username",
                                                  style: TextStyle(
                                                    fontFamily: 'Geologica',
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppStyles.accentColor(isDarkMode),
                                                  )
                                                )
                                              ],
                                            )
                                          )
                                        )
                                      ]
                                    ),
                                    Divider(
                                      indent: 20,
                                      endIndent: 20,
                                      color: AppStyles.textColor(isDarkMode).withOpacity(0.25)
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20.0, top: 10.0),
                                      child: Text(
                                        "User Info",
                                        style: TextStyle(
                                          fontFamily: 'Geologica',
                                          fontWeight: FontWeight.w800,
                                          color: AppStyles.accentColor(isDarkMode).withOpacity(0.5),
                                        )
                                      )
                                    ),
                                    ListView(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      children: [
                                        AccountPageEntry(
                                          prefs: prefs,
                                          entryName: "Name",
                                          icon: CupertinoIcons.person_solid,
                                          text: "${data['first_name']} ${data['last_name']}",
                                          onPress: () {
                                            editNameDialog(context, username, data, firstNameController, lastNameController);
                                          }
                                        ),
                                        AccountPageEntry(
                                          prefs: prefs,
                                          entryName: "Birthdate",
                                          icon: CupertinoIcons.calendar,
                                          text: AccountBody.formatTimestamp((data['birthdate'] as Timestamp).toDate(), asText: true),
                                          onPress: () {
                                            editBirthdateDialog(context, username, data);
                                          }
                                        ),
                                      ]
                                    )
                                  ]
                                )
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                                  color: isDarkMode ? AppStyles.primaryColor(isDarkMode).withOpacity(0.2) : AppStyles.backgroundColor(isDarkMode),
                                  boxShadow: [
                                    BoxShadow(
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 3),
                                      color: Colors.black.withOpacity(0.05)
                                    ),
                                    BoxShadow(
                                      blurRadius: 1,
                                      offset: const Offset(0, 1),
                                      color: Colors.black.withOpacity(0.1)
                                    )
                                  ]
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20.0, top: 10.0),
                                      child: Text(
                                        "Account Info",
                                        style: TextStyle(
                                          fontFamily: 'Geologica',
                                          fontWeight: FontWeight.w800,
                                          color: AppStyles.accentColor(isDarkMode).withOpacity(0.5),
                                        )
                                      )
                                    ),
                                    ListView(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      children: [
                                        AccountPageEntry(
                                          prefs: prefs,
                                          entryName: "E-mail",
                                          icon: CupertinoIcons.mail_solid,
                                          text: "${data['email']}",
                                          onPress: () {
                                            editEmailDialog(context, username, data, emailController, emailConfirmController);
                                          }
                                        ),
                                        AccountPageEntry(
                                          prefs: prefs,
                                          entryName: "Password",
                                          icon: CupertinoIcons.lock_fill,
                                          text: "${data['password']}",
                                          onPress: () {
                                            editPasswordDialog(context, username, data, currentPasswordController, newPasswordController, confirmPasswordController);
                                          },
                                          hideText: true
                                        )
                                      ],
                                    ),
                                  ],
                                )
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                                  color: isDarkMode ? AppStyles.primaryColor(isDarkMode).withOpacity(0.2) : AppStyles.backgroundColor(isDarkMode),
                                  boxShadow: [
                                    BoxShadow(
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 3),
                                      color: Colors.black.withOpacity(0.05)
                                    ),
                                    BoxShadow(
                                      blurRadius: 1,
                                      offset: const Offset(0, 1),
                                      color: Colors.black.withOpacity(0.1)
                                    )
                                  ]
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20.0, top: 10.0),
                                      child: Text(
                                        "Settings",
                                        style: TextStyle(
                                          fontFamily: 'Geologica',
                                          fontWeight: FontWeight.w800,
                                          color: AppStyles.accentColor(isDarkMode).withOpacity(0.5),
                                        )
                                      )
                                    ),
                                    ListView(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      children: [
                                        DarkModeToggleEntry(prefs: prefs, refreshParent: refresh, stateCallBack: widget.stateCallBack),
                                      ],
                                    ),
                                  ],
                                )
                              )
                            ]
                          ),
                        );
                      }
        
                      // While we haven't finished loading the user information from
                      // the cloud, display a simple loading screen.
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Loading @$username's Info",
                              style: TextStyle(
                                fontFamily: 'Geologica',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppStyles.accentColor(isDarkMode)
                              )
                            ),
                            const SizedBox(height: 10),
                            LoadingAnimationWidget.threeArchedCircle(
                              color: AppStyles.accentColor(isDarkMode),
                              size: 50,
                            )
                          ],
                        )
                      );
                    }
                  );
                }
        
                // While we aren't sure of the current status from the cloud,
                // display a simple loading screen.
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Connecting...",
                        style: TextStyle(
                          fontFamily: 'Geologica',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppStyles.accentColor(isDarkMode)
                        )
                      ),
                      const SizedBox(height: 10),
                      LoadingAnimationWidget.threeArchedCircle(
                        color: AppStyles.accentColor(isDarkMode),
                        size: 50,
                      )
                    ],
                  )
                );
              }
            ),
          ],
        ),
      )
    );
  }
}

