<h1 align="center"> YASM Media!!🌟 (Beta) </h1> <br>
<p align="center">
    <img alt="YASM" title="YASM" src="https://firebasestorage.googleapis.com/v0/b/yasm-react.appspot.com/o/assets%2Fpng%2Fg1003.png?alt=media" width="250">

</p>

<p align="center">
  Coolest and hippest place to join! Built with React, Flutter and NodeJS
</p>

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Introduction](#introduction)
- [Features](#features)
- [Feedback](#feedback)
- [Contributors](#contributors)
- [Build Process](#build-process)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Introduction

A pretty fast and reliable social media app where you can meet new people, share memories or just go crazy and follow people lives as they happen!

<p align="center">
  <img src = "https://i.ibb.co/S63NztP/shotsnapp-1624101503-127.png" width=450>
  <img src = "https://firebasestorage.googleapis.com/v0/b/yasm-react.appspot.com/o/assets%2FScreenshot_20220330-090443.jpg?alt=media&token=8131df6f-fbd0-4725-a971-4069ffbf0a72" width=200>
</p>

## Features

A few of the things you can do on YASM:

- View user posts
- Like and comment on images you like
- Follow other people
- Chat with other people
- Posts stories
- And many more!

## Feedback

Feel free to [file an issue](https://github.com/YASM-Media/yasm_mobile/issues/new/choose). Feature requests are always welcome. If you wish to contribute, please take a quick look at the [guidelines](./CONTRIBUTING.md)!

## Contributors

Please refer the [contribution guidelines](./CONTRIBUTING.md) for exact details on how to contribute to this project.

## Build Process

Here are the instructions on how to build and run this project on your respective systems.

- Clone the project on your system via GitHub.
- Clone the [full stack app](https://github.com/YASM-Media/yasm) as well on your system since YASM Mobile works on both NodeJS as well as Firebase.
- Make sure you have [docker](https://www.docker.com/products/docker-desktop) installed on your system.
- Create a [firebase project](https://console.firebase.google.com/) and fetch the `google-services.json` and save it in the `android/app/src/dev` folder.
- Run `docker compose -f docker-compose.yml up --build` in the server root folder to build and run a development version of the server.
- Open up a console and an emulator and run `flutter run --flavor dev -t .\lib\main.dev.dart` to run the development version of the app.

