# View: Scan Voucher & PIN Entry (`IntermediaryScanView`)

This view initiates the deposit or collection flow by scanning a user's QR code or verifying a manual PIN code.

---

## UI Layout Wireframe

```
+-------------------------------------------------------------+
|  [Back] Scan Code                                           |
+-------------------------------------------------------------+
|  PROCESS ITEM TRANSFER                                      |
|  Position the user's QR code in the frame below.            |
|                                                             |
|  +-------------------------------------------------------+  |
|  |                                                       |  |
|  |             [ Camera Scan Window ]                    |  |
|  |            (Success Teal Box Overlay)                 |  |
|  |                                                       |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  - OR -                                                     |
|                                                             |
|  Enter Deposit or Collection PIN manually:                  |
|  [ DEP-83021                                              ] |
|                                                             |
|  +---------+   +---------+   +---------+   +--------------+ |
|  |    1    |   |    2    |   |    3    |   |   [ Clear ]  | |
|  +---------+   +---------+   +---------+   +--------------+ |
|  |    4    |   |    5    |   |    6    |   |   [  Back ]  | |
|  +---------+   +---------+   +---------+   +--------------+ |
|  |    7    |   |    8    |   |    9    |   |   [Submit]   | |
|  +---------+   +---------+   +---------+   |   (Teal Button)|
|  |    -    |   |    0    |   |    -    |   |              | |
|  +---------+   +---------+   +---------+   +--------------+ |
+-------------------------------------------------------------+
```

---

## Detailed Processing Logic & Transitions

### 1. Camera QR Scanner Action
* **Success Event:** The camera reads a QR code. The app parses the payload string. 
* **API Handshake:** The app queries the database.
  * If the payload maps to an approved **Deposit Voucher** (issued to a Finder): The app transitions to [ConfirmDepositForm.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Intermediary/ConfirmDepositForm.md).
  * If the payload maps to an approved **Collection Voucher** (issued to an Owner): The app transitions to [ConfirmHandoverForm.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Intermediary/ConfirmHandoverForm.md).

### 2. Manual PIN Keyboard Input
* **Behavior:** A customized numeric keypad for entering 6-digit codes. The keyboard supports prefix detection (e.g. automatically adds the `DEP-` or `COL-` text when entered).
* **Validation:** Clicking **[Submit]** triggers the database lookup event.

### 3. Error State (Invalid Code)
* **Trigger:** Code is expired, belongs to another drop-off centre, or does not exist in the database.
* **UI Action:** Display a pop-up dialog in Danger Coral Red (`#FF453A`) stating: *"Invalid Code. This voucher is either expired, associated with a different Drop-off location, or has been suspended by Admin. Contact Admin Support."*

---

## Safety & Compliance Verification

* **Rule 19 (Strong Verification):** Physical possession changes cannot be manually entered without a token match, preventing unauthorized releases or incorrect drop-off reports.
* **Rule 13 (Protect Privacy):** The scan screen only parses the token payload. No user contact information, full names, or home addresses are exposed on the scanner view.
* **Rule 18 (Safe Drop-off):** Centering handovers on a validated token match ensures that the physical exchange matches the digital platform state.
