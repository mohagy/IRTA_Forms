# GitHub Pages Setup for IRTA Forms Web App

## ✅ Code Uploaded to GitHub

Your code has been successfully pushed to: **https://github.com/mohagy/IRTA_Forms**

## 🚀 Enable GitHub Pages

### Step 1: Enable GitHub Pages in Repository Settings

1. Go to your repository: https://github.com/mohagy/IRTA_Forms
2. Click **Settings** tab (top right)
3. Scroll down to **Pages** section (left sidebar)
4. Under **Source**, select:
   - **Source**: `GitHub Actions`
5. Click **Save**

### Step 2: Enable GitHub Actions (if needed)

1. In the same repository, go to **Settings**
2. Click **Actions** → **General**
3. Under **Workflow permissions**, select:
   - **Read and write permissions**
   - Check ✅ **Allow GitHub Actions to create and approve pull requests**
4. Click **Save**

### Step 3: Verify GitHub Actions Workflow

The workflow will automatically:
1. Build your Flutter web app when you push to `main` branch
2. Deploy it to GitHub Pages

## 📱 Access Your Web App

After the first workflow run completes (usually takes 5-10 minutes):

**Your live web app will be available at:**
```
https://mohagy.github.io/IRTA_Forms/
```

## 🔄 Automatic Deployment

The GitHub Actions workflow (`.github/workflows/deploy-web.yml`) will automatically:

- ✅ Build your Flutter web app on every push to `main` branch
- ✅ Deploy to GitHub Pages
- ✅ Update the live site automatically

## 📝 Manual Deployment (Optional)

If you want to manually trigger a deployment:

1. Go to **Actions** tab in your repository
2. Select **Deploy Flutter Web to GitHub Pages**
3. Click **Run workflow** → **Run workflow**

## 🔍 Monitor Deployment Status

1. Go to **Actions** tab in your repository
2. You'll see workflow runs with build status
3. Green checkmark ✅ = Successfully deployed
4. Red X ❌ = Build failed (check logs)

## ⚙️ Firebase Configuration

**Important:** Make sure your Firebase project allows the GitHub Pages domain:

1. Go to Firebase Console
2. Navigate to **Authentication** → **Settings** → **Authorized domains**
3. Add: `mohagy.github.io`
4. Save

This allows Firebase Auth to work on your GitHub Pages site.

## 🐛 Troubleshooting

### Build Fails

- Check the **Actions** tab for error logs
- Ensure Flutter dependencies are correct in `pubspec.yaml`
- Verify `firebase_options.dart` is committed (it's needed for Firebase)

### App Doesn't Load

- Check browser console for errors
- Verify Firebase configuration
- Ensure authorized domains include GitHub Pages domain

### Firebase Not Working

- Add `mohagy.github.io` to Firebase authorized domains
- Check Firebase project settings match `firebase_options.dart`

## 📚 Next Steps

1. ✅ Code is on GitHub
2. ✅ GitHub Actions workflow is set up
3. ⏳ Enable GitHub Pages (Step 1 above)
4. ⏳ Wait for first build (5-10 minutes)
5. ✅ Access your live app!

## 🔗 Useful Links

- Repository: https://github.com/mohagy/IRTA_Forms
- Actions: https://github.com/mohagy/IRTA_Forms/actions
- Settings: https://github.com/mohagy/IRTA_Forms/settings
- Pages: https://github.com/mohagy/IRTA_Forms/settings/pages

---

**Note:** The first build may take longer. Subsequent builds are faster. The app will be automatically updated every time you push to the `main` branch.

