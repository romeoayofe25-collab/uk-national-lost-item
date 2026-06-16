# View: Report Lost Item Wizard (`ReportLostItemView`)

The Report Lost Item view is a structured, multi-step flow that collects high-fidelity information about the lost item. 

---

## Wizard Step Flow Layouts

### Step 1: Item Details
```
+-------------------------------------------------------------+
|  [Back] Step 1 of 4: Item Details                 [Cancel]  |
+-------------------------------------------------------------+
|  What did you lose?                                         |
|  * Item Title                                               |
|  [ Type name, e.g. iPhone 13 Pro                          ] |
|                                                             |
|  * Category                                                 |
|  [ Electronics (Smartphone)                            [V] ] |
|                                                             |
|  Brand (Optional)          Colour                           |
|  [ Apple                 ] [ Graphite                     ] |
|                                                             |
|  Unique Marks or Engravings (Optional)                      |
|  [ Small scratch on the top-left corner, blue case.       ] |
|                                                             |
|  Estimated Value (Used internally for Admin verification)   |
|  [ £ 800.00                                               ] |
+-------------------------------------------------------------+
|                       [ Next Step ]                         |
+-------------------------------------------------------------+
```

### Step 2: Date & Location
```
+-------------------------------------------------------------+
|  [Back] Step 2 of 4: Date & Location              [Cancel]  |
+-------------------------------------------------------------+
|  Where and when was it lost?                                |
|                                                             |
|  * Date Lost                 * Approximate Time             |
|  [ 15 / 06 / 2026      [O] ] [ 14 : 30                    ] |
|                                                             |
|  * Last Known Location                                      |
|  [ Search local station, park, cafe, etc.                 ] |
|  +-------------------------------------------------------+  |
|  |                                                       |  |
|  |                   [ Map Preview ]                     |  |
|  |                  (Pin Last Location)                  |  |
|  |                                                       |  |
|  +-------------------------------------------------------+  |
+-------------------------------------------------------------+
|                       [ Next Step ]                         |
+-------------------------------------------------------------+
```

### Step 3: Verification Evidence
```
+-------------------------------------------------------------+
|  [Back] Step 3 of 4: Verification                 [Cancel]  |
+-------------------------------------------------------------+
|  Provide ownership proof to help Admin verify your claim.   |
|                                                             |
|  Item Photos (Optional)                                     |
|  +--------------+  +--------------+                         |
|  |  [+] Upload  |  | [Image]  (X) |                         |
|  +--------------+  +--------------+                         |
|                                                             |
|  Proof of Ownership / Serial Number (Highly Recommended)    |
|  (Upload receipts, insurance documents, or box serials)     |
|  +--------------+                                           |
|  |  [+] Upload  |                                           |
|  +--------------+                                           |
|                                                             |
|  Serial Number / IMEI (If applicable)                       |
|  [ Enter serial/IMEI (kept secret from public view)        ] |
+-------------------------------------------------------------+
|                       [ Next Step ]                         |
+-------------------------------------------------------------+
```

### Step 4: Review & Submit
```
+-------------------------------------------------------------+
|  [Back] Step 4 of 4: Review & Submit              [Cancel]  |
+-------------------------------------------------------------+
|  Review your report details:                                |
|  * Item: iPhone 13 Pro (Electronics)                        |
|  * Location: Kings Cross Station, London                    |
|  * Date: 15/06/2026 at 14:30                                |
|  * Uploads: 1 Item Image, 1 Receipt Image                   |
|                                                             |
|  [ ] I confirm that the details provided are accurate.      |
|      Filing repeated false claims can impact my Trust       |
|      Score and platform access.                             |
+-------------------------------------------------------------+
|                   [ Submit Lost Report ]                    |
+-------------------------------------------------------------+
```

---

## Detailed Component Rules & Behaviors

### 1. Estimated Value Field (Step 1)
* **Purpose:** The user inputs an estimated value of the item. 
* **Internal Routing:** This value is used strictly by the **Admin Board** to calculate a fair, standardized reward based on platform criteria (Rule 14).
* **Guarantees:** The value field has a footnote text: *"This value is used internally by the Admin Board to assess return safety and standardized reward options. It is not shared with finders or open to negotiation."*

### 2. Verification Evidence Field (Step 3)
* **Rationale:** The inclusion of serial numbers, receipts, and photos immediately supports Rule 19 ("Verification must be strong").
* **Security:** Any uploaded proof documents or entered Serial/IMEI strings are flagged as **Private**. They are visible only to the Admin Board during match verification and are never exposed to finders or intermediaries.

---

## Safety & Compliance Verification

* **Rule 16 Enforced:** There are **no inputs or prompts for a reward amount** anywhere in the wizard. The owner does not offer a reward. The platform manages this later.
* **Rule 9 Enforced:** By removing reward configuration from the poster, we eliminate bidding and bargaining from the outset.
* **Rule 11 Enforced:** The confirmation check on Step 4 warns the user of Trust Score degradation for false reporting, mitigating fraudulent claims (Rule 11).
