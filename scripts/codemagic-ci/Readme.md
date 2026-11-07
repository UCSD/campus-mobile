# Codemagic CI/CD Workflow Setup
## i. Build Triggers

1. Select desired build triggers, i.e. include target experimental, trigger on push


## ii. Environment variables (6)
1. **APP_VERSION**
    - Major, minor, and patch version number
    - Accepted: `7.3.0`, `8.1.15`, etc.
2. **BUILD_ENV**
    - Build environment
    - Accepted: `QA`, `PROD-TEST`, `PROD`
3. **APP_CONFIG**
    - Build configuration settings for campus mobile
    - Value: Encrypted and secured `app-config.js`
4. **SP_CONFIG**
    - Sharepoint integration configuration
    - Value: Encrypted and secured `sp-config.json`
5. **FIREBASE_IOS**
    - Firebase config for iOS
    - Value: Encrypted and secured `FIREBASE_IOS_QA.plist` or `FIREBASE_IOS_PROD.plist`
6. **FIREBASE_ANDROID**
    - Firebase config for Android
    - Value: Encrypted and secured `FIREBASE_ANDROID_QA.json` or `FIREBASE_ANDROID_PROD.json`
7. **BUILD_PLATFORM**
    - Build platform
    - Accepted: `IOS`, `ANDROID`


**_Encrypting Environment Variables_**
1. Click the text link `Encrypt environment variables` under `Configuration as code` in the right pane
2. Drag and drop the file to encrypt
3. Copy the encrypted value, and paste it into the `Variable value` field in the `Environment variables` section
4. Click the `Secure` checkbox to hide and secure the encrypted value


## iii. Post-Clone Script
1. In Codemagic's Workflow Editor, set the Post-clone script to invoke the
   checked-in script directly:

   ```sh
   sh ./scripts/codemagic-ci/post-clone.sh
   ```

   Invoking the repository file ensures future script changes are used by
   Codemagic without copying them into the Workflow Editor again.
2. Save the workflow and confirm the next build log contains
   `Start: post-clone.sh` before dependency resolution begins.


## iv. Build for Platforms
1. Select the desired build platform OS (Android and/or iOS)
2. Choose the build mode (Release)
3. Add build arguements: `--build-name=$APP_VERSION --build-number=$PROJECT_BUILD_NUMBER`


## v. Publish

### Code Signing
1. Enable Android code signing
    - Required:
      - Keystore file
      - Keystore password
      - Key alias
      - Key password

2. Enable iOS code signing
    - Select code signing method: Manual
    - Required:
      - Code signing certificate (`UCSDDistribution_2020-12-08.p12`)
      - Certificate password
      - Provisioning profiles (`UC_San_Diego.mobileprovision`)

### Publishing (Optional)
1. Google Play
    - Check `Enable Google Play publishing`
    - Required: Credentials.json
    - Select Track:
      - Internal
      - Alpha
      - Beta

2. App Store Connect
    - Check `Enable App Store Connect publishing`
    - Required:
      - Apple ID
      - App-specific password

## vi. Post-Publish Script
1. Copy and paste the contents of `post-publish.sh` from `campus-mobile/scripts/codemagic-ci`


















