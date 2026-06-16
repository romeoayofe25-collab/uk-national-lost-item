# View: Case & Reward Management (`CaseManagementView`)

The Case Details view is the primary operational dashboard for managing active cases, setting reward values, and overriding return parameters.

---

## UI Layout Wireframe

```
+-------------------------------------------------------------------------------------------------------------------+
|  [Back] Case Manager: Case #1034                                                                                  |
+-------------------------------------------------------------------------------------------------------------------+
|  CASE INFORMATION: iPhone 13 Pro                                              Status: [ Match Found - Under Review ]|
+-------------------------------------------------------------------------------------------------------------------+
|  ASSOCIATED USERS                                  |  ITEM CUSTODY & TRACKING                                     |
|  * Owner: Sarah Jenkins (Trust Score: 98)          |  * Current Custody: Intermediary Centre                      |
|  * Finder: Marcus Vance (Trust Score: 95)          |  * Location: Kings Cross Service Desk                        |
|  * Intermediary: Kings Cross Service Desk          |  * Storage Tag: [ Shelf B-12 ]                               |
+-------------------------------------------------------------------------------------------------------------------+
|  ADMIN REWARD CONTROL PANEL (EXCLUSIVELY CONTROLLED BY ADMIN BOARD)                                                |
|  * Owner's Estimated Value: £ 800.00                                                                              |
|  * Recommended Reward Range: £ 20.00 - £ 40.00 (Standard 5% guidelines)                                           |
|                                                                                                                   |
|  * Set Standardized Reward:  [ £ 20.00 ]                                                                          |
|  * Platform Service Fee:     [ £  5.00 ]                                                                          |
|  * Total Escrow Hold:        £ 25.00                                                                              |
|                                                                                                                   |
|                         [ Approve & Lock Escrow Reward ] (Electric Indigo Button)                         |
+-------------------------------------------------------------------------------------------------------------------+
|  CASE ACTION DESK                                                                                                 |
|                                                                                                                   |
|     [ Open Monitored Chat Room ]     [ Move to Locker safe ]     [ Manually Release Escrow ] (Red Override)       |
|                                                                                                                   |
+-------------------------------------------------------------------------------------------------------------------+
```

---

## Detailed Components & Financial Controls

### 1. Exclusive Reward-Setting Panel
* **Rationale:** Satisfies Rule 16 ("The owner must never set the reward") and Rule 14 ("Reward payment must be controlled").
* **Inputs:** Admins input the precise `Standardized Reward` and `Platform Service Fee`.
* **Lock Action:** Clicking **[ Approve & Lock Escrow Reward ]** saves these values to the case record. 
  * *System Action:* Triggers a charge to the Owner's account for the total escrow hold (£25.00) and displays the reward amount in the Finder's claims tracker as `Escrow Locked`. The Finder cannot edit or negotiate this amount (Rule 9).

### 2. Case Action Desk
* **[ Open Monitored Chat Room ] Button:** Navigates directly to the chat dashboard: [ChatControlRoomView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Admin/ChatControlRoomView.md).
* **[ Move to Locker Safe ] Action:** Updates custody status from the desk vault shelf to external locker safes.
* **[ Manually Release Escrow ] Button (Red Override):** Emergency override. Allows Admin to release the reward to the Finder's balance in case of physical collection confirmation issues (e.g. if the receptionist forgot to scan the Owner's collection QR code). Requires entering an Admin log justification text.

---

## Safety & Compliance Verification

* **Rule 16 Enforced:** All reward parameters are input on the Admin Console. The Owner has no UI elements in their application to offer, adjust, or negotiate rewards.
* **Rule 14 Enforced:** Escrow holding is enforced inside the platform database. Manual overrides require logging, providing full visibility and audit control to the Admin Board.
