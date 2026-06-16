# View: Dispute & Fraud Center (`DisputeCenterView`)

The Dispute & Fraud Center manages flagged transactions, physical item discrepancies reported by drop-off centres, and automated account suspensions, satisfying Rule 11 ("Prevent fraud and criminal misuse").

---

## UI Layout Wireframe

```
+-------------------------------------------------------------------------------------------------------------------+
|  [Back] Dispute & Fraud Center                                                                                    |
+-------------------------------------------------------------------------------------------------------------------+
|  SUSPENDED & FLAGGED ACCOUNTS                      |  ACCOUNT INSPECTION: m_vance99                               |
|  * Marcus Vance (m_vance99)        [Auto-Locked]   |  User Profile: Marcus Vance (Finder)                         |
|  * Peter Smith (p_smith33)         [Auto-Locked]   |  Trust Score: [ 45 Pts ] (Low - Red Badge)                   |
|  * Centre Desk Kings Cross         [Active Alert]  |  Suspension Trigger: 3 failed claim attempts.                |
|                                                    |                                                              |
|  ACTIVE CONFLICT QUEUE                             |  ACTIVITY AUDIT LOGS:                                        |
|  * Case #1021: Euston Desk reported physical       |  * 15/06 14:02: Attempted claim on Case #1021. Incorrect     |
|    item damaged during pickup.                     |    serial number entered twice.                              |
|  * Case #1008: Dual claims filed on same laptop.   |  * 15/06 14:05: Failed device biometric validation.           |
|                                                    |  * 15/06 14:06: [System Event] Automated lock triggered.     |
+-------------------------------------------------------------------------------------------------------------------+
|  RESOLUTION ACTION BAR                                                                                            |
|                                                                                                                   |
|       [ Manually Reactivate Account ]      [ Demote Trust Score ]      [ Permanently Blacklist Account ]          |
|            (Success Teal Button)               (Amber Dropdown)             (Crimson Red Button)                  |
+-------------------------------------------------------------------------------------------------------------------+
```

---

## Detailed Components & Overrides

### 1. Automated Account Suspension Audits
* **Trigger:** The system locks accounts automatically if user behaviors cross safety thresholds (e.g. 3 consecutive failed verification answers, or matching photo biometric checks failing).
* **Logs Panel:** Admins review exactly which security flags (GPS spoofing, serial code errors, biometric mismatches) triggered the automated locking action.

### 2. Manual Re-activation & Blacklist Overrides
* **[ Manually Reactivate Account ] Button:** Reactivates account status to `Active`, allowing the user to log in again. Admins must enter a justification note to complete reactivation, ensuring audit integrity.
* **[ Permanently Blacklist Account ] Button:** Permanently bans the user ID, phone number, and facial biometric signature from register databases (Rule 2).
* **[ Resolve Centre Conflicts ] Action:** For physical item disputes, Admins can coordinate with the Centre reception and Matched users, manually adjusting reward allocations or matching parameters.

---

## Safety & Compliance Verification

* **Rule 1 (Admin Board has Highest Control):** Reactivation is restricted to Admin Board authorization. Auto-suspended accounts are completely locked from performing actions until manually cleared.
* **Rule 11 (Prevent Misuse):** Auto-locking blocks rogue actors from repeatedly attempting fake claims or harassing intermediary desks.
