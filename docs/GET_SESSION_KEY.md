# How to Get Your Claude sessionKey

The `sessionKey` is a browser cookie that authenticates you with Claude.ai. Here's how to get it:

## Method 1: Browser Developer Tools (Recommended)

### Chrome / Edge / Brave

1. Open your browser and go to **https://claude.ai**
2. **Log in** to your Claude account (if not already logged in)
3. Press **F12** to open Developer Tools
4. Click the **Application** tab
5. In the left sidebar, expand **Cookies** and click **https://claude.ai**
6. Find the cookie named **`sessionKey`** in the list
7. Double-click the **Value** column to select it
8. Copy the value (it starts with `sk-ant-sid01-`)

![Chrome DevTools Cookie](https://i.imgur.com/example.png)

### Firefox

1. Open Firefox and go to **https://claude.ai**
2. **Log in** to your Claude account
3. Press **F12** to open Developer Tools
4. Click the **Storage** tab
5. In the left sidebar, expand **Cookies** and click **https://claude.ai**
6. Find the cookie named **`sessionKey`**
7. Right-click and select **Copy Value**

### Safari

1. Enable Developer Tools: Safari → Preferences → Advanced → "Show Develop menu"
2. Go to **https://claude.ai** and log in
3. Click **Develop** → **Show Web Inspector**
4. Click the **Storage** tab
5. Click **Cookies** → **https://claude.ai**
6. Find `sessionKey` and copy its value

---

## Method 2: Browser Extension (Quick Copy)

You can use a browser extension like **EditThisCookie** or **Cookie-Editor** to quickly view and copy cookies:

1. Install the extension
2. Visit https://claude.ai (logged in)
3. Click the extension icon
4. Find `sessionKey` cookie
5. Copy the value

---

## What to Do With It

Once you have the `sessionKey`:

1. Create a `.env` file in the `src/` directory (if it doesn't exist)
2. Add this line:
   ```
   CLAUDE_SESSION_KEY=sk-ant-sid01-YOUR_SESSION_KEY_HERE
   ```
3. Also add your organization ID (find it in the URL when you visit https://claude.ai):
   ```
   CLAUDE_ORG_ID=your-org-id-here
   ```

---

## Finding Your Organization ID

1. Log in to https://claude.ai
2. Look at the URL in your browser
3. You'll see something like: `https://claude.ai/chat/YOUR-ORG-ID`
4. Or go to Settings → Usage, and look at the URL: `https://claude.ai/settings/usage?organization=YOUR-ORG-ID`
5. Copy the UUID (format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)

---

## Security Note

⚠️ **Important:** Your `sessionKey` is like a password. Never share it publicly or commit it to version control.

- Keep it in your `.env` file
- Add `.env` to your `.gitignore`
- Regenerate it by logging out and back in if you think it's been compromised

---

## Session Key Expires

Session keys can expire. If your usage tracking stops working:

1. Check if you're still logged in to Claude.ai
2. If not, log back in
3. Extract a new `sessionKey` using the steps above
4. Update your `.env` file
