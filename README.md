## UC San Diego Preview

The UC San Diego Preview app showcases what's in the works for the UC San Diego mobile app.

All new features and enhancements are prototyped and tested in collaboration with the UC San Diego student body.

If your feature or enhancement is selected as a possible release candidate, due to its sheer awesomeness or immediate need, it will go through an additional vetting process.

When successful, your feature or enhancement will be published to the UC San Diego mobile app for its 30,000 users to experience, and you will be added as a collaborator on https://mobile.ucsd.edu/.

We look forward to helping you become a published app developer!

For questions, please contact us at [mobile@ucsd.edu](mailto:mobile@ucsd.edu)


## How to Contribute

#### 1. Clone the `campus-mobile-flutter` project
```
git clone git@github.com:c3bryant/campus-mobile-flutter.git
cd campus-mobile-flutter
```


#### 2. Find a Task
Head over to the Campus Mobile Replatform ZenHub project board here:
https://app.zenhub.com/workspaces/campus-mobile-replatform-5d72857cf7e9c4000136b824/board?repos=206825554

Once you’ve arrived, look for the `Help Wanted` pipeline. Issues residing here are ready to be worked on, and can be self-assigned. To do this, simply drag the issue to the `In Progress` pipeline, and assign the issue to yourself.



#### 3. Commit & Push
After you’ve selected an issue to work on, but before you begin working, create a feature branch off of the default (`master`) branch:
```
git checkout master
git checkout -b feature/new-feature
```
As you work on your feature, commit and push your code:
```
git add lib/feature/newfeature.dart
git commit -m "Added new feature which does x, y, and z"
git push -u origin feature/my-feature
```
While most development work will be done locally on simulators in Debug mode, all `feature/` branches are hooked up to our CI/CD pipeline via Codemagic.io and built in Production mode. After you commit and push your code with the commands above, you’ll see a message from Codemagic indicating your build has begun, and another when it has completed (or failed).

_Tip: Keep an eye out for failed CI/CD builds containing your feature. This is an early indication that something is misconfigured, and should be addressed sooner than later._



#### 4. Wrap Up
When work on a feature has been completed, add a note to the issue indicating what work was completed and where.

Example for ‘Implement Events Card’:
```
Events card completed on branch `feature/events-card` and is ready for review.
```

Then, from the ZenHub board, drag the issue from the `In Progress` to the `In QA` pipeline.

Lastly, open the issue, and un-assign yourself from it.