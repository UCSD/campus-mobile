## UC San Diego

### Installation & Setup

#### Campus Mobile MacOS Installer: 
https://github.com/UCSD/campus-mobile/pull/2087

#### Campus Mobile Flutter Version:
3.44.6 (stable), including Dart 3.12.2. Use this SDK locally to match the pinned GitHub Actions workflow.

#### Set Up Your IDE to use our `.editorconfig` Settings
- If using VS Code, install the [EditorConfig for VS Code](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig) extension.
- If using Android Studio, EditorConfig support is built-in.
    - Simply go to File > Settings > Editor > Code Style > Enable EditorConfig Support.


### Clone the Campus Mobile Repository
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

Now you are ready to checkout your local `experimental` branch and merge in any changes from the upstream repo's `experimental` branch:
```shell
# Checkout your master branch and merge upstream
git checkout experimental
git merge upstream/experimental
```

Your local `experimental` branch is now up-to-date with any changes upstream.

### Doing Your Work

```shell
# Add 'upstream' repo to list of remotes
git remote add upstream https://github.com/UCSD/campus-mobile.git
```

```shell
# Fetch from upstream remote
git fetch upstream
```

#### Create a Feature Branch
When you begin working on a new feature or bugfix, it is important that you create a new branch. Not only is it proper git workflow, but it also keeps your changes organized and separated from the `experimental` branch so that you can easily submit and manage multiple pull requests for every task you complete.

To create a new branch and start working on it:

```shell
# Checkout the experimental branch
git checkout experimental

# Create and checkout a branch named newfeature
git checkout -b experimental
```

#### Using the Pre-Commit Hook
The pre-commit hook runs only `dart format` on staged Dart files under `lib/` and `test/`.
It does not rewrite comments, remove braces, or convert functions using text matching.
Formatter failures block the commit. When formatting changes files, review and stage
those changes, then retry the commit. The pinned Flutter SDK must be on your PATH.

To enable it:

```shell
# Install pre-commit hook (one-time on your machine)
pip install pre-commit==4.4.0

# Enable the repo's pre-commit hook
pre-commit install # or python -m pre_commit install
```

Check or format the whole Dart source tree manually:

```shell
bash scripts/auto_fix_all.sh --dry-run
bash scripts/auto_fix_all.sh
```

`--dry-run` does not modify files and returns a nonzero status when formatting is
needed. Both commands propagate formatter failures. The unsafe scripts formerly
under `scripts/styling/` have been removed. The legacy text-based style checker
is no longer part of CI. Arrow-function suggestions now come from the Dart
analyzer; review any IDE/analyzer-assisted fixes before applying them. Automatic
brace removal, comment spacing rewrites, and TODO dating are intentionally not
enforced.

Pull requests run the formatting safeguards, a read-only formatting check,
`flutter analyze`, and the full Flutter test suite using Flutter 3.44.6.
Analyzer errors and test failures block CI. Analyzer warnings and informational
lints remain visible but are temporarily non-fatal because the repository has
existing warnings; a green check is not a warning-free analysis. CI installs
dependencies with `flutter pub get --enforce-lockfile` and uses an empty `.env`
asset for isolated tests, without application secrets. The obsolete generated
counter test is replaced by actual snackbar widget tests; this is not a full
Firebase-backed application integration test.

Run the same checks locally after installing dependencies:

```shell
python -m unittest discover -s scripts/tests -v
bash scripts/auto_fix_all.sh --dry-run
flutter analyze --no-pub --no-fatal-warnings --no-fatal-infos
flutter test --no-pub
```

On a fresh checkout, create an empty `.env` file if you do not have local app
configuration; it is required by the asset manifest for widget tests. Do not
overwrite an existing local `.env`. Bash is required for the helper and its
regression tests (Git Bash on Windows); the pre-commit hook itself invokes Dart
directly and does not require Bash.

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

#### Update Your Feature Branch
From the time you created your new feature branch `newfeature`, to submitting a pull request, it is likely that your branch 

Branch `upstream/experimental` is updated often. Prior to submitting a pull request, update your `newfeature` branch from `upstream/experimental` so that merging it will be a simple process which won't require any conflict resolution work.
```shell
# Fetch upstream experimental and merge with your local experimental branch
git fetch upstream
git checkout experimental
git merge upstream/experimental

# If there were any new commits, merge them to your `newfeature` branch from the `experimental` branch
git checkout newfeature
git merge experimental
git push upstream newfeature
```


#### Submitting
Once you've committed and pushed your feature branch `newfeature` to GitHub, navigate to to your new feature branch on UCSD's Campus Mobile GitHub and click the 'New pull request' button.

If you need to make future updates to your pull request, push the new commit or commits to your feature branch `newfeature` on GitHub. Your pull request will automatically track the changes on your feature branch and generate new builds for iOS and Android.

## Platform
The goal of this platform is to provide responsive and intuitive mobile interactions for a personalized campus experience.

[UC San Diego](https://mobile.ucsd.edu/) uses this platform for its campus mobile app on iOS and Android.

## License
	MIT
