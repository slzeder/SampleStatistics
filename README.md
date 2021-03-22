# SampleStatistics
Download and analyze a set data file containing packet data.


## Background

This app was written using the storyboard and UIKit. Networking was achieved using AlamoFire.


## Building

After cloning this repo, you must install all dependencies. This workspace includes the AlamoFire CocoaPod. After cloning, simply:

<project dir>$ pod install

Next, open the workspace and build. If AlamoFire does not automatically build, go into "manage schemes" and select AlamoFire for building.

Continue with workspace build.


## Running App

To download the data file, have the selector set to "Dropbox". Click "Retrieve and Process File" to kickoff the workflow.

To run the workflow with a small internal test file, move the selector to "Test".
