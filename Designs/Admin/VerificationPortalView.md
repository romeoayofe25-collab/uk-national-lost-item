# View: Verification Review Portal (`VerificationPortalView`)

The Verification Review Portal is the workshop where Admins inspect submitted documents, compare serial codes, and authorize items for collection.

---

## UI Layout Wireframe

```
+-------------------------------------------------------------------------------------------------------------------+
|  [Back] Verification Review: Case #1034                                                                           |
+-------------------------------------------------------------------------------------------------------------------+
|  VERIFICATION CHECKS: iPhone 13 Pro                                              Status: [ Verification Pending ] |
+-------------------------------------------------------------------------------------------------------------------+
|  OWNER SUBMITTED PROOFS                            |  FOUND ITEM CHECKS & IMAGES                                  |
|  * Lock Screen wallpaper description:               |  * Physical serial code from intake form:                   |
|    "White dog sitting on green grass"              |    "IMEI: 357283109482716" (Auto-Matched)                  |
|                                                    |                                                              |
|  * Serial / IMEI Code:                             |  * Finder Photo Check:                                       |
|    "357283109482716"                               |    [Photo Preview: Grey iPhone, blue cover]                  |
|                                                    |                                                              |
|  * Verification Files:                             |  * Intermediary Reception Notes:                             |
|    - [receipt_purchase.pdf] (Stripe invoice)       |    "Intake OK. Checked serial code on SIM tray."             |
|    - [box_barcode.jpg] (Retail box photo)          |                                                              |
+-------------------------------------------------------------------------------------------------------------------+
|  VERIFICATION RESOLUTION                                                                                          |
|  * Match Assessment: [ IMEI CODES MATCH EXACTLY ] (Green Success Alert)                                           |
|                                                                                                                   |
|            [ Reject Claims / Flag Fraud ]                   [ Approve Verification & Release ]                    |
|                (Crimson Red Button)                               (Success Teal Button)                           |
+-------------------------------------------------------------------------------------------------------------------+
```

---

## Component Details & Verification Steps

### 1. Proof Cross-Referencing Panel
* **Lost vs. Found Columns:** The Admin reviews the Owner's detailed text descriptions and uploads side-by-side with data captured during the Intermediary's deposit intake.
* **Auto-Matched Indicators:** If the Owner's entered Serial/IMEI string matches the code transcribed by receptionist staff, a green matching banner is automatically rendered.

### 2. Resolution Actions
* **[ Reject Claims / Flag Fraud ] Button:** Tapping this rejects the claim.
  * *System Action:* Suspends the claim, flags the Owner's account, and prompts the Admin to specify the rejection reason (e.g. "Receipt does not match item specifications").
* **[ Approve Verification & Release ] Button:** Tapping this confirms ownership.
  * *System Action:* Updates the Case Status to `Ready for Collection`.
  * *Notification:* Triggers notifications to the Owner containing their Collection QR Voucher.
  * *Centre Update:* Updates the Intermediary's ledger, flagging the item as available for retrieval on their shelf grid.

---

## Safety & Compliance Verification

* **Rule 19 (Strong Verification):** Ensures that claim release is guarded by multiple validation details (device serial codes, receipts, and custom visual questions).
* **Rule 11 (Fraud Prevention):** Rejects invalid claims instantly. Rejecting triggers a fraud review option, satisfying security expectations before releasing valuable property.
