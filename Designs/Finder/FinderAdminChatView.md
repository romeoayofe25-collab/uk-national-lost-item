# View: Finder Secure Support Chat (`FinderAdminChatView`)

This view allows the finder to communicate with the Admin Board or the designated Drop-off Centre to resolve logistical questions, satisfying Rule 4 ("Chat must be controlled and monitored").

---

## UI Layout Wireframe

```
+-------------------------------------------------------------+
|  [Back] Admin Support: Case #1035                 [Pause]   |
|         Regarding: Nike Blue Backpack                       |
+-------------------------------------------------------------+
|  [i] Security Warning:                                      |
|  This support channel is monitored. Demanding rewards,      |
|  offering private handovers, or sharing private details     |
|  will result in account termination.                        |
+-------------------------------------------------------------+
|                                                             |
|  [System] 15/06/2026 15:20                                  |
|  "Found report submitted. Admin is searching for matches."  |
|                                                             |
|  [Admin - James] 15/06/2026 15:45                           |
|  "Hi Marcus, we have verified an owner match. Please drop    |
|   the bag off at South Kensington Library when you can."    |
|                                                             |
|                          [Marcus (You)] 15/06/2026 15:48    |
|                          "Perfect. I am going there now. Is |
|                           the reception desk open?"         |
|                                                             |
|  [Admin - James] 15/06/2026 15:50                           |
|  "Yes, the desk is open until 20:00. Show them the deposit  |
|   QR voucher from your dashboard."                          |
|                                                             |
+-------------------------------------------------------------+
|  [Type message...]                                   [Send] |
+-------------------------------------------------------------+
```

---

## Safety Controls & Moderator Overrides

### 1. PII Scrubbing Filters
* **Behavior:** Like the Owner Chat, any numeric strings resembling phone numbers, email patterns, or third-party money sharing links (e.g. PayPal, bank accounts) are filtered out at the UI layer.
* **Notification Overlay:** If triggered, the input shows a warning: *"Contact details and external payment links are blocked for safety."*

### 2. Lock State
* **Implementation:** The chat is automatically disabled once the Intermediary Centre scans the drop-off voucher and confirm the deposit. The text field closes, displaying: *"This support chat has been archived. Thank you for returning the item safely!"*

---

## Safety & Compliance Verification

* **Rule 10 (No Direct Chat):** The Finder communicates only with Admin or Centre staff. They have no visibility of the Owner's identity or chat handles.
* **Rule 9 (No Bidding/Demands):** Chat monitoring logs are audited for extortion patterns. Any message attempting to demand ransom for the item is flagged for immediate Admin review and account freeze.
