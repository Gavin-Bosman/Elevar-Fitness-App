# Hello!
This repository holds the flutter project for our CSCI 4100 Mobile Devices final project. We decided to make a fitness tracking app; I am passionate about exercise and physical activity so I wanted to develop an application I could see myself actually using. Development of this app will continue, I hope to eventually publish it on the google play store. 

## Project Requirements
We were given a list of requirements that our application needed to satisfy. These included:
- Basic functions such as multi-screen navigation and state management
  - Notifications, Snackbars, Dialogs and Pickers
- Use of persistent Sqlite storage
- Use of HTTP routing
- Use of cloud storage (FireBase)
- Optional requirements that are currently included:
  - Use of camera
  - Charts
 
## Sourcing of Data
In order to develop a method to track exercise progress, we needed a large amount of exercise data. I decided to use API Ninjas Exercises API. This JSON-based API includes thousands of exercises sorted into various categories that you can filter by; including name, type, muscle and difficulty. Using this API allowed us to fill some of our functional requirements as well, as I designed the HTTP routing model to interact with this API dynamically during the execution of the application. 

Check out the API here:
## https://api-ninjas.com/api/exercises

## Running the application
You must have either VsCode or Android studio installed, as well as the basic flutter/dart packages required to create a skeleton application. Upon opening this project in the IDE of your choice, you should first run 'flutter pub get' in the terminal (within the root project directory). This will ensure you have all the necessary packages installed for execution. You can then run 'flutter run' in the terminal and select any of the options to try running the app. NOTE: this app was designed for android mobile devices, as such it may not run optimally if you choose to run it on windows or ios. Your best choice of running the application would be on the android emulator, or on a physical android device (which you can run on by simply plugging your device into your computer, with 'usb-debugging' enabled in settings).

## Contributing Authors:

1. Gavin Bosman @gavinbos

2. Jonah Baayen @jonahbaayen-uoit

3. Moharaj Oritro @Moharaj12

4. Dane Rosedo @D-Rosedo

5. Eric D'Souza @sokorieh


