# View: Intermediary Dashboard (`IntermediaryDashboardView`)

The Dashboard is the home screen for reception staff, designed for rapid processing of item drop-offs and owner collections.

---

## UI Layout Wireframe (Tablet Landscape Grid)

```
+---------------------------------------------------------------------------------------------------+
|  [Logo] Kings Cross Station Desk - Intermediary Hub                           [Staff: John Miller] |
+---------------------------------------------------------------------------------------------------+
|  DAILY METRICS SUMMARY                                                                            |
|  +--------------------+  +--------------------+  +--------------------+  +--------------------+   |
|  | Stored Items       |  | Locker Safe Items  |  | Pending Drop-offs  |  | Pending Pickups    |   |
|  |     14             |  |     5              |  |     3              |  |     2              |   |
|  +--------------------+  +--------------------+  +--------------------+  +--------------------+   |
+---------------------------------------------------------------------------------------------------+
|  QUICK ACTIONS                                                                                    |
|  +--------------------------------------------------+  +---------------------------------------+  |
|  |           [ SCAN QR / ENTRY PIN ]                |  |      [ OPEN INVENTORY LEDGER ]        |  |
|  |            (Success Teal Button)                 |  |       (Electric Indigo Button)        |  |
|  +--------------------------------------------------+  +---------------------------------------+  |
+---------------------------------------------------------------------------------------------------+
|  TODAY'S SCHEDULED EVENTS                                                                         |
|                                                                                                   |
|  [Pending Collection] Case #1034: iPhone 13 Pro                                                   |
|  Owner: Sarah Jenkins | Location: [ Shelf B-12 ] (Monospaced Badge)                               |
|  Status: Verified | Expected Collection: Today, 16:00                                             |
|                                                                                                   |
|  [Pending Deposit] Case #1035: Nike Blue Backpack                                                 |
|  Finder: Marcus Vance | Status: Pending Finder Drop-off                                           |
+---------------------------------------------------------------------------------------------------+
|  [Dashboard (Active)]      [Inventory]      [Logistical Messages]      [Centre Profile]           |
+---------------------------------------------------------------------------------------------------+
```

---

## Detailed Components

### 1. Daily Metrics Summary Cards
* Displays four stat blocks representing the current physical vault capacity:
  * **Stored Items:** Items physically in the main safety deposit lockers inside the office.
  * **Locker Safe Items:** Items stored in the external 24/7 automated lockers (accessible for weekend/Bank Holiday collection).
  * **Pending Drop-offs / Pickups:** Scheduled transfers to help staff prepare items in advance.

### 2. Double Quick Action CTAs
* **[ SCAN QR / ENTRY PIN ] Button:** Opens the tablet/phone camera capture overlay immediately. Styled in Success Teal (`#30D158`) with high contrast.
  * *Interaction:* Navigates to [IntermediaryScanView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Intermediary/IntermediaryScanView.md).
* **[ OPEN INVENTORY LEDGER ] Button:** Navigates directly to the comprehensive searchable vault listing. Styled in Electric Indigo (`#5E5CE6`).
  * *Interaction:* Navigates to [IntermediaryInventoryView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Intermediary/IntermediaryInventoryView.md).

### 3. Today's Scheduled Events List
* Shows active claims filtered to the current calendar day. 
* Displays the exact physical storage location tag (e.g. `Shelf B-12`) in a clear monospaced box, allowing the clerk to fetch the item prior to scanning the code.

---

## Safety & Compliance Verification

* **Rule 17 (Clear User Roles):** The Intermediary cannot access system dashboards, set/change reward amounts, or review owner proofs of purchase. They can only record physical receipt and release of items.
* **Rule 18 (Safe Drop-off):** Centering all daily tasks around a verified physical office establishes safe, staff-attended locations as the default item return pathway.
