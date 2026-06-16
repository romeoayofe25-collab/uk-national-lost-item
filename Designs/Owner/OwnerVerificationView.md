# View: Owner Verification Center (`OwnerVerificationView`)

The Verification Center is loaded when a potential match is found. It facilitates the submission of private verification details to the Admin Board, satisfying Rule 19 ("Verification must be strong").

---

## UI Layout Wireframe

```
+-------------------------------------------------------------+
|  [Back] Verification Center                                 |
+-------------------------------------------------------------+
|  VERIFY OWNERSHIP: iPhone 13 Pro                            |
|                                                             |
|  Admin has flagged a matching found item. Please complete   |
|  the fields below to verify your claim.                     |
|                                                             |
+-------------------------------------------------------------+
|  * 1. Describe the Lock Screen Wallpaper                    |
|  [ It is a picture of a white dog sitting on green grass.  ] |
|                                                             |
|  * 2. Describe any Unique External Marks or Accessories     |
|  [ Clear plastic case with a yellow sticker on the back.    ] |
|                                                             |
|  3. Upload Additional Proof of Purchase (Optional)          |
|  (PDF or image of receipt, carrier contract, or box barcode) |
|  +--------------+                                           |
|  |  [+] Upload  |                                           |
|  +--------------+                                           |
|                                                             |
|  * 4. Confirm Serial Number or IMEI                         |
|  [ 357283109482716                                        ] |
+-------------------------------------------------------------+
|  [!] LEGAL & ETHICAL RESPONSIBILITY WARNING:                |
|  Filing false claims is an offense under the UK Theft Act   |
|  1968. Suspicious activity is immediately reported to matching |
|  intermediary centres and the Administration Board.         |
+-------------------------------------------------------------+
|               [ Submit Verification Proof ]                 |
|                   (Sunset Amber Button)                     |
+-------------------------------------------------------------+
```

---

## Component Details & Interactions

### 1. Dynamic Admin Security Questions
* **Mechanism:** Rather than static inputs, the questions are retrieved from the database, having been formulated by the Admin Board based on details from the Finder's report.
  * *Example:* If the finder reported a phone with a unique cover, Admin asks the Owner: "What color/design is the protective case?"
* **Input Elements:** Multi-line text boxes with character counts.

### 2. Private Serial / IMEI Validation
* **Behavior:** If the owner did not input a serial number in the initial report, they must supply it here.
* **Backend Checking:** The Admin Board compares this against serial numbers visible in the finder's photos or drop-off centre physical inspection.

### 3. Legal Responsibility Badge
* **Styling:** Red/Amber text background, high-contrast border.
* **Content:** Mentions specific legal frameworks (e.g., *UK Theft Act 1968* / *Fraud Act 2006*) to deter dishonest claims and satisfy Rule 2 ("Always consider legal and ethical responsibility") and Rule 11 ("Prevent fraud and criminal misuse").

---

## Safety & Compliance Verification

* **Rule 19 (Strong Verification):** Direct and specific questions must be answered before the item can progress to the drop-off collection state.
* **Rule 13 (Protect Privacy):** The inputs in this form are sent directly to the Admin DB using encryption. They are completely hidden from the Finder.
* **Rule 1 (Admin Board has Highest Control):** This verification does not trigger automatic approval. It changes the status to "Under Admin Review". Admin must manually review the answers and authorize release.
