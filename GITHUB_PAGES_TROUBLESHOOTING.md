# GitHub Pages 404 Error - Troubleshooting Guide

## Current Issue: 404 Error

If you're seeing "There isn't a GitHub Pages site here", follow these steps:

## Step-by-Step Fix

### Step 1: Enable GitHub Pages (CRITICAL)

1. Go to: https://github.com/mohagy/IRTA_Forms/settings/pages
2. You'll see a section titled **"Build and deployment"**
3. Under **Source**, you should see options:
   - If it says "None" or "Deploy from a branch", you need to change it
   - Select: **"GitHub Actions"** (this is the new way)
   - If "GitHub Actions" is not available, select **"Deploy from a branch"** → **"main"** → **"/ (root)"** → Save

4. Click **Save**

### Step 2: Check if Workflow has Run

1. Go to: https://github.com/mohagy/IRTA_Forms/actions
2. Look for a workflow run called "Deploy Flutter Web to GitHub Pages"
3. If there's no run, the workflow needs to be triggered
4. If there's a run:
   - Green checkmark ✅ = Success (wait 1-2 minutes for site to be available)
   - Yellow circle ⏳ = Still running (wait for it to finish)
   - Red X ❌ = Failed (click to see error logs)

### Step 3: Manually Trigger Workflow (If Needed)

1. Go to: https://github.com/mohagy/IRTA_Forms/actions
2. Click on **"Deploy Flutter Web to GitHub Pages"** workflow (left sidebar)
3. Click **"Run workflow"** button (top right)
4. Select branch: **main**
5. Click **"Run workflow"**

### Step 4: Wait for Deployment

- First build takes 5-10 minutes
- Check Actions tab to see progress
- Once green ✅, wait 1-2 minutes for DNS to propagate
- Refresh the page: https://mohagy.github.io/IRTA_Forms/

## Alternative: Quick Manual Deploy (If Workflow Fails)

If the workflow is having issues, you can manually build and push the web build:

```bash
cd irta_forms_app
flutter build web --release --base-href "/IRTA_Forms/"
```

Then create a `gh-pages` branch and push the build/web folder there.

But let's try the automated way first!

## Common Issues

### Issue 1: "GitHub Actions" Option Not Available

**Solution:** Make sure:
- You're using a personal account (not organization with restrictions)
- Repository is not in "Draft" state
- You have admin access to the repository

### Issue 2: Workflow Fails with Permission Error

**Solution:**
1. Go to Settings → Actions → General
2. Under "Workflow permissions", select **"Read and write permissions"**
3. Check ✅ "Allow GitHub Actions to create and approve pull requests"
4. Save

### Issue 3: Workflow Succeeds but Still 404

**Solution:**
- Wait 2-5 minutes for DNS propagation
- Clear browser cache
- Try incognito/private browsing
- Check if the site URL is correct: https://mohagy.github.io/IRTA_Forms/ (note the `/IRTA_Forms/` path)

### Issue 4: Build Fails with Firebase Error

**Solution:**
- Make sure `firebase_options.dart` is committed
- Check that all dependencies in `pubspec.yaml` are valid
- Review the workflow logs for specific error messages

## Quick Check Command

You can verify if GitHub Pages is enabled by checking:
- Repository Settings → Pages section should show the site URL
- Actions tab should show workflow runs

## Need Help?

Check the workflow logs:
1. Go to Actions tab
2. Click on the failed workflow run
3. Expand "Build" or "Deploy" job
4. Look for error messages in red

---

**Remember:** After enabling GitHub Pages and the workflow completes successfully, it may take 1-5 minutes for the site to be accessible due to DNS caching.



