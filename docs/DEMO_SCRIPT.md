# Demo video script

A two-minute walkthrough in six scenes, for a screen recording of the web demo or an Android emulator. Every step below was checked against the running app.

## Before recording

- Open a fresh copy of the demo. Reloading the web page (or restarting the app) resets all demo data.
- A desktop browser window shows the app in a phone-width column; a phone-sized window (about 375 × 812) fills the frame and looks more natural on video.
- Any text works in the form fields. The collection PIN is always `491-032`.
- The identity scan takes about seven seconds; keep talking over it.
- Sign out with the arrow icon at the top right of each dashboard.

## Order matters

The scenes follow the order the app needs: the admin can only review a claim after the owner has submitted proof, and the desk can only hand an item over after the admin has approved it.

## Scenes

### 1. Sign-in and About (0:00–0:15)

- Show the sign-in screen: the PROTOTYPE ribbon and the "Explore the demo as" buttons.
- Tap **About this prototype**, let it sit for a moment, go back.
- Say: "This is a portfolio prototype of a lost-property service where the owner and the finder never deal with each other. Everything you'll see runs on demo data in memory."

### 2. Owner proves ownership (0:15–0:45)

- Tap **Owner**. Point at the "Action Required" card for the iPhone 13 Pro.
- Optional, two seconds: tap **Demo Partner Desks** to show the drawn desk map, then go back.
- Tap **Provide Proof**, then **Start Biometric Face Scan**, then **Start Biometric Face Scan** again on the scan screen. Point at the SIMULATED tag and the line "Simulated scan. The camera is not used."
- When it finishes, tap **Confirm & Attach Biometric Token**.
- Fill in the two answers and the serial number, then **Submit Verification Proof**. The status now says the proof is under review.
- Say: "Proof of ownership goes to an admin board, not to the finder."

### 3. Admin reviews and sets the reward (0:45–1:05)

- Sign out, tap **Admin**. Open the claim under "Pending claims verification review".
- Scroll to **Reward & decision controls**: the reward is pre-filled (£20.00). Tap **APPROVE CLAIM**.
- Optional: open **Supervised Chats** to show pause and terminate, or **Disputes & Fraud → Stolen Check** to show the example stolen-property panel.
- Say: "The board sets the reward. Nobody negotiates it."

### 4. Owner gets the collection PIN (1:05–1:20)

- Sign out, tap **Owner**. Open the iPhone 13 Pro (status "Ready") and tap **Get Collection Code & Map**.
- Point at the PIN `491-032` and its SIMULATED QR code.
- Optional: profile icon, scroll to the **GDPR Data Rights Centre** with its SIMULATED tag.

### 5. Desk hands the item over (1:20–1:40)

- Sign out, tap **Intermediary**. Tap **Scan QR / PIN**, enter `491-032` on the keypad, tap **ENTER**.
- Tick both checklist boxes, type `491-032` in the PIN field, tap **Complete Handover & Release Escrow**. Point at "SIMULATED REWARD RELEASE".
- Say: "The hand-over happens at a partner desk, against a one-time PIN."

### 6. Finder is paid (1:40–2:00)

- Sign out, tap **Finder**. The wallet shows £65.00 available and £0.00 pending: the £20 reward has been released.
- Tap **View Wallet & Claims History**, then **Withdraw Available Funds**. The message says the withdrawal is simulated.
- Close with: "Owner and finder never met or messaged. Code and README are on GitHub."

## If there is time for one more shot

- **Finder:** **Select Drop-off Centre → Deposit at this Centre** shows the deposit voucher `DEP-173` with its SIMULATED QR code. As **Intermediary**, enter `DEP-173` in **Scan QR / PIN** to check the backpack in to a locker.
- **Owner:** **Report Lost Item** walks through the four-step report form.
