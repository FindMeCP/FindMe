#TODO
- Parse Server
  - Cloud functions
    - [] Friend Requests
    - [] Accepted Friend Requests

- FindMe Client App    
  - Login/SignupViewController
    - [] Improve UI
  - ContactsViewController
    - [] Optimize contact searching
  - RequestsViewController
    - [] Request to add friend
  - AddUserViewController
    - [] Add contact via username

# FindMe

## Description
Tired of trying to find your friends while they don't text you back? FindMe
helps you find your friends without any effort. The FindMe app is useful
for all ages, but we are specifically targeting college students.

## Info
FindMe is a geolocation app built on Google Maps API. Backend uses Parse Server with mongoDB, hosted on Heroku platform.

#Project Distribution
- William: Create users, access contacts, store and retrieve user data via Parse, allow tracking of other users, handle login and signup
- Jordi: Google maps functionality, customize screens (split, shared, solo) for viewing maps, manage location services

## User Stories

**Required** functionality: User can

- [X] Sign up, log in, and log out of the FindMe app.
- [X] Persisted across app restarts.
- [X] See the user's location on a Google Maps SDK map.
- [X] Share user locations with a friend.
- [X] Reset the map to user/friend locations.
- [X] Turn off all location sharing.
- [X] Select three map modes: split screen, shared screen, solo screen.
- [X] Find friends with app installed.
- [X] Friend's location pin updates every 5 seconds.

**Optional** features:

- [X] SMS Verification in Sign Up
- [X] Customize UI and logos
- [X] Invite friends without the app.
- [X] Enable maps to fix to users' locations.
- [] Track multiple friends at a time.
- [] Leave geonotes.
- [] Login with Facebook account.
- [] Ping other users.
- [] Set timer for user location sharing to end.

**APIs**
- Google Maps SDK API (link to endpoint)

**Model Classes**
- Users: username, password, phone number, latitude, longitude, friends, tracking

## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='http://i.imgur.com/2uEbYmn.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## License

    Copyright 2016 William Tong, Jordi E. Turner

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
