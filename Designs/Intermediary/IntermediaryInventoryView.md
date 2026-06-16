# View: Storage Inventory Ledger (`IntermediaryInventoryView`)

The Inventory Ledger allows staff to view, search, and manage all physical lost property currently stored in the centre's vaults or external locker boxes.

---

## UI Layout Wireframe (Tablet Screen Grid)

```
+---------------------------------------------------------------------------------------------------+
|  [Back] Storage Inventory Ledger                                                  [Search Bar...] |
+---------------------------------------------------------------------------------------------------+
|  FILTERS: [ All (14) ]   [ Vault Stored (9) ]   [ Locker Safes (5) ]   [ Matches Pending (2) ]     |
+---------------------------------------------------------------------------------------------------+
|  INVENTORY LEDGER                                                                                 |
|                                                                                                   |
|  Case ID | Item Name            | Storage Location | Date Deposited | Status         | Action     |
|  --------+----------------------+------------------+----------------+----------------+----------- |
|  #1034   | iPhone 13 Pro        | Shelf B-12       | 15/06/2026     | Ready Pick-up  | [Manage]   |
|  #1035   | Nike Blue Backpack   | Locker 14-B      | 15/06/2026     | Locker Ready   | [Manage]   |
|  #1029   | Keys (Silver Ring)   | Drawer A-4       | 12/06/2026     | Stored         | [Manage]   |
|  #1015   | Leather Wallet       | - (Locker 2)     | 10/06/2026     | Returned       | [View Log] |
|                                                                                                   |
+---------------------------------------------------------------------------------------------------+
```

### Action Modal overlay (Tapping "[Manage]")
```
+---------------------------------------------------------------------------------------------------+
|  MANAGE CASE #1034: iPhone 13 Pro                                                      [Close X]  |
|  +--------------------------------------------------+------------------------------------------+  |
|  | * Status: Ready for Pickup (Owner Verified)       | Current Location: Shelf B-12             |  |
|  | * Deposited: 15/06/2026 by Marcus Vance          |                                          |  |
|  | * Notes: Scratch on screen.                      | [ Transfer to Locker ] (Indigo Outline)  |  |
|  +--------------------------------------------------+ [ Logistical Chat ] (Indigo Outline)    |  |
|  | [Item Photo Thumbnail]                           | [ Flag for Admin review ] (Coral Red)    |  |
|  +--------------------------------------------------+------------------------------------------+  |
+---------------------------------------------------------------------------------------------------+
```

---

## Component Details & Behaviors

### 1. Ledger Search & Filter Controls
* **Search Field:** Dynamically filters the grid contents by matches on Case ID, Item name, Colour, or location tag.
* **Filter Capsule Buttons:** Toggles lists between main office vault shelves and external lockers.

### 2. Manage Case Dialog Overlay
* **[ Transfer to Locker ] Action:** Allows moving an item from the main vault shelf to a locker box for weekend pickup (updates the storage tag and triggers a locker key update for the Owner).
* **[ Flag for Admin Review ] Action:** Renders if a physical dispute arises (e.g. Owner arrives and claims the item is damaged, or the wrong item was matched). Suspends the case and escalates it to the Admin dispute board (Rule 1).

---

## Safety & Compliance Verification

* **Rule 13 (Protect Privacy):** The ledger displays only the item name and case number. No phone numbers, email addresses, or personal credentials of either the owner or finder are visible in the ledger grids or manage details.
* **Rule 1 (Admin Board highest control):** If staff identify suspicious matches or claims during ledger review, they can click "Flag for Admin Review" to instantly halt proceedings.
