# View: Drop-off Selection & Instructions (`DropOffSelectionView`)

This view assists the finder in depositing the found item at an approved partner centre. It uses auto-recommendations and provides a secure voucher handshake.

---

## UI Layout Wireframe

### Selection State
```
+-------------------------------------------------------------+
|  [Back] Select Drop-off Point                               |
+-------------------------------------------------------------+
|  Item: Blue Canvas Backpack                                 |
|                                                             |
|  RECOMMENDED CENTRES (Based on found location: Hyde Park)    |
|                                                             |
|  +-------------------------------------------------------+  |
|  | South Kensington Library (0.5 mi)           [Select]  |  |
|  | Address: Queens Gate, SW7 2AZ                         |  |
|  | Hours: Open until 20:00                               |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  SEARCH OTHER LOCATIONS                                     |
|  [ Search by city, postcode, or store name...             ] |
|                                                             |
|  +-------------------------------------------------------+  |
|  |                                                       |  |
|  |                   [ Map View ]                        |  |
|  |             (Pins for nearby Centres)                 |  |
|  |                                                       |  |
|  +-------------------------------------------------------+  |
+-------------------------------------------------------------+
```

### Voucher Confirmed State
```
+-------------------------------------------------------------+
|  [Back] Deposit Voucher                                     |
+-------------------------------------------------------------+
|  DEPOSIT SLIP: Case #1035                                   |
|  Centre: South Kensington Library                           |
|  Address: Queens Gate, SW7 2AZ                              |
|                                                             |
+-------------------------------------------------------------+
|  SECURE DEPOSIT CODE                                        |
|  Present this code to the receptionist upon handover.        |
|                                                             |
|                   +-------------------+                     |
|                   |                   |                     |
|                   |  [ QR CODE IMAGE ]|                     |
|                   |                   |                     |
|                   +-------------------+                     |
|                                                             |
|                     DEPOSIT PIN: DEP-83021                  |
|                                                             |
+-------------------------------------------------------------+
|  [i] What happens next?                                     |
|  Once scanned, the item status updates to "Deposited". the   |
|  Admin Board will confirm the owner match and authorize     |
|  escrow reward release.                                      |
+-------------------------------------------------------------+
```

---

## Technical Flow & Safety Actions

### 1. Auto-Recommendation Engine
* **Logic:** The UI retrieves the GPS coordinates saved in Step 2 of the found report. It queries the database for approved Intermediary Centres and sorts them by geodesic distance.
* **Fallback Search:** The search bar triggers a standard text query to the database coordinates index, allowing the user to search any destination (e.g. "Manchester Station").

### 2. Deposit Verification Handshake
* **The Deposit Token:** Tapping "Select" on a centre generates a temporary database entry linking the found item to that centre, creating a secure single-use `Deposit QR Code` and `DEP PIN`.
* **The Scan Event:**
  1. The Finder arrives at the verified reception.
  2. The receptionist logs into their Intermediary console, scans the QR code, and accepts physical custody of the item.
  3. The API changes the status of the item report to `Deposited at Centre`.
  4. The Finder's active post updates, their Trust points increment, and the escrow reward status transitions to `Pending Owner Collection`.

---

## Safety & Compliance Verification

* **Rule 18 (Safe Drop-off):** Handover occurs inside a partner facility with verified personnel, removing the need for finders to meet claimants directly.
* **Rule 14 (Controlled Payments):** Marks the start of the return audit. The escrow wallet locks the reward value, ensuring no private pay arrangements can bypass the platform.
* **Rule 11 (Fraud Prevention):** Since drop-off is recorded by a third-party intermediary scanning the voucher, finders cannot falsely claim they returned an item they still possess.
