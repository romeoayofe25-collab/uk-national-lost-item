# View: Confirm Item Deposit Form (`ConfirmDepositForm`)

This form is loaded by the receptionist to document the receipt of a found item from a Finder, assign a physical storage location tag, and update the item's database status.

---

## UI Layout Wireframe

```
+-------------------------------------------------------------+
|  [Back] Confirm Item Deposit                                |
+-------------------------------------------------------------+
|  DEPOSIT RECORD: Case #1035                                 |
|  Matched Report: Nike Blue Canvas Backpack                  |
|  Finder: Marcus Vance (Trust Rating: 95)                    |
|                                                             |
+-------------------------------------------------------------+
|  * 1. Match Verification Check                              |
|  [ ] I confirm the physical item matches the description    |
|      (Nike Blue Backpack, good condition).                  |
|                                                             |
|  * 2. Physical Storage Location Tag                         |
|  [ Shelf B-12                                             ] |
|  (Enter exact shelf, drawer, or storage room number)        |
|                                                             |
|  [x] Store in external 24/7 automated locker?               |
|      (Enables weekend/holiday pickup for the owner)         |
|      * Locker Number: [ Locker 14-B                       ] |
|                                                             |
|  3. Reception Notes (Optional)                              |
|  [ Contains 1 black umbrella, 1 water bottle inside.      ] |
+-------------------------------------------------------------+
|               [ Complete Item Deposit ]                     |
|                 (Success Teal Button)                       |
+-------------------------------------------------------------+
```

---

## Component Details & Behaviors

### 1. Physical Storage Location Tag
* **Text Input:** Receptionist enters a descriptive location identifier (e.g., `Shelf B-12`). This is stored in the database and displayed on the Owner's "Collection Info" card and the Intermediary's "Inventory Ledger".
* **Locker Toggle:** checking "Store in external automated locker" flags the item in the database as eligible for **Automated Collection** and prompts entry of a locker identifier (e.g., `Locker 14-B`). This adjusts the collection flow for the Owner (switching from manual receptionist handover to mobile biometric locker release).

### 2. Physical Match Checkbox
* **Behavior:** A mandatory binary checkbox. The receptionist must visually inspect the item to verify it matches the Finder's description before checking it, preventing the intake of incorrect or fraudulent items.

### 3. Submission Action
* **Database Updates:**
  * Changes item status from `Pending Deposit` to `Deposited at Centre`.
  * Triggers database event: Notifies the matched Owner that their item is safely stored and ready for collection.
  * Triggers database event: Locks the Finder's reward into the simulated platform escrow wallet, displaying the status "Awaiting Owner Collection" (Rule 14).

---

## Safety & Compliance Verification

* **Rule 11 (Fraud Prevention):** Third-party inspection of the physical item at drop-off prevents finders from submitting empty boxes or incorrect goods to claim rewards.
* **Rule 18 (Safe Drop-off):** Tagging the location ensures proper custody tracking during physical storage.
