# View: Lost Item Details & Progress (`LostItemDetailsView`)

This view allows the owner to track the recovery lifecycle of their lost item. It changes dynamically depending on the current status of the report.

---

## UI Layout Wireframe

```
+-------------------------------------------------------------+
|  [Back] Lost Item Details                                   |
+-------------------------------------------------------------+
|                                                             |
|  iPhone 13 Pro                                              |
|  Reported on: 15/06/2026 at 14:45                           |
|                                                             |
+-------------------------------------------------------------+
|  STATUS TIMELINE                                            |
|                                                             |
|  (x) Reported                                               |
|   |                                                         |
|  (x) Matching & Searching                                   |
|   |                                                         |
|  (*) Match Found & Under Review (Sunset Amber Active)       |
|   |                                                         |
|  ( ) Drop-off Centre Received                               |
|   |                                                         |
|  ( ) Ready for Collection                                   |
|                                                             |
+-------------------------------------------------------------+
|  [!] ACTION REQUIRED                                        |
|  Admin needs verification to confirm ownership.             |
|                                                             |
|  [ Open Verification Center ] (Sunset Amber Button)         |
|                                                             |
+-------------------------------------------------------------+
|  ITEM DETAILS                                               |
|  Category: Electronics (Smartphone)                         |
|  Brand/Model: Apple / iPhone 13 Pro                         |
|  Colour: Graphite                                           |
|  Unique Marks: Small scratch on top-left                    |
|  Lost Location: Kings Cross Station, London                 |
+-------------------------------------------------------------+
|                                                             |
|               [ Secure Chat with Admin ]                    |
|                (Electric Indigo Button)                     |
|                                                             |
+-------------------------------------------------------------+
```

---

## Interactive Components & States

### 1. Dynamic Status Timeline
The timeline visualizes the item's progression. Each step has a distinct visual appearance based on the state:

1. **`Reported`:** Completed. Displayed in Emerald Teal (`#30D158`).
2. **`Matching & Searching`:** Completed. Displayed in Emerald Teal (`#30D158`).
3. **`Match Found & Under Review`:** Active/Pending Admin Review. Displayed in Sunset Amber (`#FF9F0A`).
4. **`Drop-off Centre Received`:** Inactive/Upcoming. Displayed in Cool Grey (`#8E8E93`).
5. **`Ready for Collection`:** Inactive/Upcoming. Displayed in Cool Grey (`#8E8E93`).
6. **`Returned`:** Inactive/Upcoming. Displayed in Cool Grey (`#8E8E93`).

### 2. Conditional Action Panels
The view rendering varies by status:

* **State: `Matching & Searching`**
  * *UI Panel:* Shows a loading skeleton or secondary text: *"We are comparing your report against found items. We will notify you if a potential match is identified."*
* **State: `Match Found & Under Review`**
  * *UI Panel:* Renders an "Action Required" notice with a button to **[ Open Verification Center ]**.
  * *Interaction:* Routes to [OwnerVerificationView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Owner/OwnerVerificationView.md).
* **State: `Ready for Collection`**
  * *UI Panel:* Renders a green success card: *"Your item has been verified! You can now collect it from the designated drop-off centre."*
  * *CTA Button:* **[ Get Collection Code & Map ]**
  * *Interaction:* Routes to [CollectionDetailsView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Owner/CollectionDetailsView.md).

### 3. Contact Support Button
* **Visual:** Secondary outline style with Electric Indigo border (`#5E5CE6`) and white text.
* **Interaction:** Routes directly to a dedicated chat channel for this case: [OwnerAdminChatView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Owner/OwnerAdminChatView.md).

---

## Safety & Compliance Verification

* **Rule 10 (No Direct Chat):** The only chat trigger is "Secure Chat with Admin". The owner cannot contact the finder of the matching item.
* **Rule 13 (Protect Privacy):** The Finder's identity (name, profile picture, location) is completely hidden. The timeline simply states "Match Found" without exposing who found it.
* **Rule 18 (Safe Drop-off):** In the "Ready for Collection" state, details about the intermediary collection location are provided, redirecting the user away from any direct physical exchange.
