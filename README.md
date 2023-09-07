# dropbox-client

### Credentials for testing
- email: anton.chuev.ukr+noname@gmail.com
- password: 111111

## Authorization
- launch the app
- tap "Sign In"
- if Dropbox app is installed, it will be launched to continue signing process
- otherwise web form for sign in will be opened
- enter credetials for testing to the corresponding fields and tap "Sign in"
- then tap "Continue", then "Allow"

## Architecture
Application was developed using MVVM pattern. It offers several advantages
that help in building more maintainable, scalable, and testable applications.
Key advantages of MVVM are:
- separation of concerns
- testability
- maintainability
- binding mechanism and other

MVC and MVP patterns fit this applications needs as well. 

## Features
- sign in by Dropbox API
- show root folder's content
- photo viewer
- "in memory" thumbnails and image caching
- video player
- "on disk" caching video
- photo and video details
- pagination
- delete file via "swipe to delete" action

## Missing requirements
- UI tests
- tests for models, image and video cache,  

## Missing optional tasks
- surfing through folder hierarchy
- move files
- delete multiple files
- Adjust SDK integration
- Pushwoosh SDK integration
- App Tracking Transparency
  
## Possible enhancements
- proper error handling with user-friendly error messages and UX
- file viewers for other file types
- offline mode
- handle dark/light mode color scheme
- extend test coverage for view models
- UI/UX
