## UC San Diego

### Installation & Setup

#### Campus Mobile MacOS Installer: 
https://github.com/UCSD/campus-mobile/pull/2087

#### Campus Mobile Flutter Version:
3.24.5


### Clone the Campus Mobile repo
```shell
git clone https://github.com/UCSD/campus-mobile.git
```

### Keeping Your Repo Up to Date
You'll want to make sure you keep your repo up to date by tracking the original "upstream" repo that you cloned. To do this, you'll need to add a remote:

```shell
# Add 'upstream' repo to list of remotes
git remote add upstream https://github.com/UCSD/campus-mobile.git
```

Whenever you want to update your repo with the latest upstream changes, you'll need to first fetch the upstream Campus Mobile repo's branches and latest commits to bring them into your repository:
```shell
# Fetch from upstream remote
git fetch upstream
```

Now you are ready to checkout your local `campus-activation-redesign` branch and merge in any changes from the upstream repo's `campus-activation-redesign` branch:
```shell
# Checkout your master branch and merge upstream
git checkout campus-activation-redesign
git merge upstream/campus-activation-redesign
```

Your local `campus-activation-redesign` branch is now up-to-date with any changes upstream.

### Doing Your Work (Campus Activation Redesign)

```shell
# Add 'upstream' repo to list of remotes
git remote add upstream https://github.com/UCSD/campus-mobile.git
```

```shell
# Fetch from upstream remote
git fetch upstream
```

#### Create a Feature Branch
When you begin working on a new feature or bugfix, it is important that you create a new branch. Not only is it proper git workflow, but it also keeps your changes organized and separated from the `campus-activation-redesign` branch so that you can easily submit and manage multiple pull requests for every task you complete.

To create a new branch and start working on it:

```shell
# Checkout the campus-activation-redesign branch
git checkout campus-activation-redesign

# Create and checkout a branch named newfeature
git checkout -b campus-activation-redesign
```

You are now ready to begin developing your new feature. Commit your code often, using present-tense and concise verbiage explaining the work completed.

Example: Add, commit, and push your new feature:
```shell
# Show the state of staged and unstaged files you created or updated
git status

# Add files to include in your newfeature
git add lib/core/push_notifications_in_app.dart

# Commit your code
git commit -m "Add in-app push notifications"

# Push your code
git push -u upstream newfeature

```


### Submitting a Pull Request

#### Update your feature branch
From the time you created your new feature branch `newfeature`, to submitting a pull request, it is likely that your branch 

Branch `upstream/campus-activation-redesign` is updated often. Prior to submitting a pull request, update your `newfeature` branch from `upstream/campus-activation-redesign` so that merging it will be a simple process which won't require any conflict resolution work.
```shell
# Fetch upstream campus-activation-redesign and merge with your local campus-activation-redesign branch
git fetch upstream
git checkout campus-activation-redesign
git merge upstream/campus-activation-redesign

# If there were any new commits, merge them to your `newfeature` branch from the `campus-activation-redesign` branch
git checkout newfeature
git merge campus-activation-redesign
git push upstream newfeature
```


#### Submitting
Once you've committed and pushed your feature branch `newfeature` to GitHub, go to the page for your fork on GitHub, select branch 'newfeature' and click the 'New pull request' button.

If you need to make future updates to your pull request, push the new commit or commits to your feature branch `newfeature` on GitHub. Your pull request will automatically track the changes on your feature branch.

## Platform
The goal of this platform is to provide responsive and intuitive mobile interactions for a personalized campus experience.

[UC San Diego](https://mobile.ucsd.edu/) uses this platform for its campus mobile app on iOS and Android.

## License
	MIT
