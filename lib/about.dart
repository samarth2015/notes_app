import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    ///Input:BuildContext context
    ///Output:Widget
    ///This function returns a card which contains the details of team members
    ///This card has 3 icons of email, linkedin and github, wrapped with gesturedetector
    ///on tapping the icons _launchurl function will lead you to th gmail,
    ///linkedin account and github account of the respective member.
    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(255, 233, 208, 1),
        elevation: 0,
      ),
      backgroundColor: const Color.fromRGBO(255, 233, 208, 1),
      body: SafeArea(
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 1.5,
          ),
          children: [
            //Defining the details of each members to be shown by the _profileCard function
            _profileCard(
              "Samarth S.",
              "https://firebasestorage.googleapis.com/v0/b/notes-project-6d296.appspot.com/o/boy.jpg?alt=media&token=dc78dc51-ddc1-446b-8516-c79692a9e2ff",
              "mailto:23110317@iitgn.ac.in",
              "https://github.com/samarth2015",
              "https://www.linkedin.com/in/samarth-sonawane",
            ),
            _profileCard(
              "Praneel Joshi",
              "https://firebasestorage.googleapis.com/v0/b/notes-project-6d296.appspot.com/o/boy.jpg?alt=media&token=dc78dc51-ddc1-446b-8516-c79692a9e2ff",
              "mailto:23110254@iitgn.ac.in",
              "https://github.com/PraneelUJ",
              "https://www.linkedin.com/in/praneel-joshi-898954319",
            ),
            _profileCard(
              "Paras Shirvale",
              "https://firebasestorage.googleapis.com/v0/b/notes-project-6d296.appspot.com/o/boy.jpg?alt=media&token=dc78dc51-ddc1-446b-8516-c79692a9e2ff",
              "mailto:23110232@iitgn.ac.in",
              "https://github.com/Paras-Shirvale",
              "https://www.linkedin.com/in/paras-shirvale-6a53512a3",
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileCard(
      name, url_profile_pic, url_email, url_github, url_linkedin) {
    //Input: Details of users in string format as listed above
    //Output:Widget
    //This function contains the elements of the card containing the member details.
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        color: const Color.fromRGBO(255, 209, 157, 1),
        child: Container(
          padding: const EdgeInsets.all(16),
          // margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              //Defining the name and profile picture of the member
              Text(
                name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: "Nunito",
                    fontSize: 32),
              ),
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(url_profile_pic),
              ),
              const SizedBox(
                height: 16,
              ),
              SizedBox(
                width: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      //Defining the email, github and linkedin icons
                      //On tapping the icons, the respective account of the member will be opened
                      onTap: () {
                        _launchURL(url_email);
                      },
                      child: const Icon(
                        Icons.email,
                        size: 24,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _launchURL(url_github);
                      },
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage("https://firebasestorage.googleapis.com/v0/b/notes-project-6d296.appspot.com/o/github.png?alt=media&token=1d67183e-0b98-4efb-a77e-675c99974024"),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _launchURL(url_linkedin);
                      },
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage("https://firebasestorage.googleapis.com/v0/b/notes-project-6d296.appspot.com/o/linkedin.png?alt=media&token=0a02f960-8ada-437c-bf25-047d12a97ca9"),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    //Input:Url of the link.
    //Output:void
    //This is the function which redirects you to the corresponding location by tapping on the email, linkedin and github icon
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
