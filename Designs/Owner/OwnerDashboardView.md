# View: Owner Dashboard (`OwnerDashboardView`)

The Dashboard is the central hub for the lost-item owner. It provides access to active reports, trust levels, and notifications.

---

## UI Layout Wireframe

```
+-------------------------------------------------------------+
|  [Profile Image]  Hello, Sarah!             [Alerts Icon]   |
|  Trust Level: Excellent (98 Pts)                            |
+-------------------------------------------------------------+
|                                                             |
|  [!] Action Required:                                       |
|  Verify ownership for your "iPhone 13 Pro" to proceed.      |
|  [ Provide Proof ] (Sunset Amber Button)                    |
|                                                             |
+-------------------------------------------------------------+
|  ACTIVE LOST ITEMS                                          |
|                                                             |
|  +-------------------------------------------------------+  |
|  | [Item Thumbnail]  iPhone 13 Pro                       |  |
|  | Category: Electronics | Lost: 2 hrs ago               |  |
|  | STATUS: [ Match Found ] (Sunset Amber Pill)           |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  +-------------------------------------------------------+  |
|  | [Item Thumbnail]  Leather Bi-fold Wallet              |  |
|  | Category: Personal Accessories | Lost: 1 day ago      |  |
|  | STATUS: [ Searching... ] (Cool Grey Pill)             |  |
|  +-------------------------------------------------------+  |
|                                                             |
+-------------------------------------------------------------+
|                                                             |
|               +-----------------------------+               |
|               |    +  Report a Lost Item    |               |
|               +-----------------------------+               |
|                    (Electric Indigo CTA)                    |
|                                                             |
+-------------------------------------------------------------+
|   [Home Icon]        [Search Icon]        [Messages Icon]   |
|     (Active)                                (Secured Chat)  |
+-------------------------------------------------------------+
```

---

## Detailed Components

### 1. Header & Trust Banner
* **Avatar & Greeting:** Standard rounded avatar with greeting text in `Title Large` (`#FFFFFF`).
* **Trust Indicator Badge:** A capsule-shaped chip indicating user rating level (e.g., `Excellent (98 Pts)` in Emerald Teal `#30D158`).
  * *Rationale:* Motivates compliant behavior (Rule 11).

### 2. Action Required Banner (Conditional)
* **Visual:** Orange surface (`#FF9F0A` at 15% opacity) with a solid Orange left border.
* **Content:** Alert message notifying the user of pending items (e.g., "Verify ownership for your iPhone 13 Pro").
* **CTA Button:** Small solid-orange button (`#FF9F0A`) styled as a standard `Button` labeled "Provide Proof".
  * *Interaction:* Navigates to [OwnerVerificationView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Owner/OwnerVerificationView.md).

### 3. Active Reports List
* **Section Title:** `Headline` style ("ACTIVE LOST ITEMS" in secondary grey `#8E8E93`).
* **Report Cards:**
  * **Image Thumbnail:** Left-aligned. Displays the user's uploaded image, or a generic category icon if no image was provided.
  * **Text Details:** Item Name (`#FFFFFF`), Category + relative time elapsed (`#8E8E93`).
  * **Status Pills:** Standardized pills representing the workflow state:
    * `Searching...` (Cool Grey `#8E8E93` background)
    * `Match Found` (Sunset Amber `#FF9F0A` background)
    * `Ready for Collection` (Emerald Teal `#30D158` background)
  * *Interaction:* Tapping a card routes to [LostItemDetailsView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Owner/LostItemDetailsView.md).

### 4. Primary CTA Button
* **Visual:** Positioned at the bottom center. Styled as a prominent capsule button.
* **Color:** Electric Indigo background (`#5E5CE6`), Text: Pure White (`#FFFFFF`), bold.
* **Interaction:** Navigates to the [ReportLostItemView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Owner/ReportLostItemView.md) wizard.

### 5. Tab Bar
* Includes standard icons: Home (Active), Search Reports, and Messages.
  * *Interaction:* Messages icon routes to the list of active secured support chats ([OwnerAdminChatView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Owner/OwnerAdminChatView.md)).

---

## Safety & Compliance Verification

* **Rule 10 (No Direct Chat):** The Messages tab routes *only* to admin-controlled chats. There are no links, buttons, or entry points to finders.
* **Rule 13 (Protect Privacy):** No PII (phone number, address) is displayed anywhere on the dashboard.
* **Rule 16 (Owner Cannot Set Reward):** No reward totals, wallet amounts, or potential cash estimates are visible on the dashboard.
