# View: Finder Dashboard (`FinderDashboardView`)

The Dashboard is the central workspace for the finder. It provides quick access to found-item reports, trust statistics, and the simulated platform wallet.

---

## UI Layout Wireframe

```
+-------------------------------------------------------------+
|  [Profile Image]  Hello, Marcus!            [Alerts Icon]   |
|  Trust Level: Very Reliable (95 Pts)                        |
+-------------------------------------------------------------+
|  SIMULATED PLATFORM WALLET                                  |
|  Available: £ 45.00               Pending Escrow: £ 20.00   |
|                                                             |
|  [ View Wallet & Claims History ] (Electric Indigo Text)    |
+-------------------------------------------------------------+
|                                                             |
|  [!] Action Required:                                       |
|  Please drop off the "Blue Backpack" at a verified centre.   |
|  [ Select Drop-off Location ] (Sunset Amber Button)         |
|                                                             |
+-------------------------------------------------------------+
|  ACTIVE FOUND POSTS                                         |
|                                                             |
|  +-------------------------------------------------------+  |
|  | [Item Thumbnail]  iPhone 13 Pro                       |  |
|  | Location: Kings Cross | Found: 1 day ago              |  |
|  | STATUS: [ Deposited at Centre ] (Success Teal Pill)   |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  +-------------------------------------------------------+  |
|  | [Item Thumbnail]  Blue Canvas Backpack                |  |
|  | Location: Hyde Park | Found: 2 hrs ago                |  |
|  | STATUS: [ Held by Finder ] (Sunset Amber Pill)        |  |
|  +-------------------------------------------------------+  |
|                                                             |
+-------------------------------------------------------------+
|                                                             |
|               +-----------------------------+               |
|               |    +  Report a Found Item   |               |
|               +-----------------------------+               |
|                    (Electric Indigo CTA)                    |
|                                                             |
+-------------------------------------------------------------+
|   [Home Icon]        [Search Icon]        [Wallet Icon]     |
|     (Active)                               (Simulated)      |
+-------------------------------------------------------------+
```

---

## Detailed Components

### 1. Simulated Platform Wallet Card
* **Visual:** Premium metallic-glass surface style (`#162032` with an subtle Indigo `#5E5CE6` inner glow).
* **Balances:** Available Balance (`#FFFFFF` large text) and Pending Escrow (`#8E8E93` secondary text).
  * *Rationale:* Rewards are kept in escrow until the drop-off and collection handovers are verified, preventing extortion (Rule 14).
* **CTA link:** Navigates directly to [FinderClaimsView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Finder/FinderClaimsView.md).

### 2. Action Required Banner (Conditional)
* **Visual:** Sunset Amber card surface (`#FF9F0A` at 15% opacity).
* **Content:** Appears if a found report is marked as "With Finder" and requires drop-off.
* **CTA Button:** **[ Select Drop-off Location ]**
  * *Interaction:* Routes to [DropOffSelectionView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Finder/DropOffSelectionView.md).

### 3. Active Found Posts Card List
* **Status Pills:**
  * `Held by Finder` (Sunset Amber `#FF9F0A` background): Requires action to select drop-off centre.
  * `Deposited at Centre` (Success Teal `#30D158` background): Safe drop-off complete, awaiting owner collection.
  * `Matched & Verified` (Electric Indigo `#5E5CE6` background): Reward released to wallet.
  * *Interaction:* Tapping a card opens a detailed status progress panel with a button to contact support or view drop-off voucher records.

---

## Safety & Compliance Verification

* **Rule 10 (No Direct Communication):** No entry points exist for finders to search for matching owners or message them.
* **Rule 9 (No Bidding/Negotiation):** Finders cannot set reward expectations or list items for "sale". The dashboard focuses on standard returning procedures.
* **Rule 11 (Prevent Misuse):** Trust score reflects compliance with drop-off protocols, discouraging users from holding onto items.
