# View: Admin Dashboard (`AdminDashboardView`)

The Admin Dashboard is the central widescreen landing console, summarizing system health, matching queues, and security alerts.

---

## UI Layout Wireframe (Widescreen Desktop Grid)

```
+-------------------------------------------------------------------------------------------------------------------+
|  [Logo] UK National Lost-Item Admin Console                                  [Search cases, users, IMEI] [Admin o] |
+-------------------------------------------------------------------------------------------------------------------+
|  (Menu)       |  SYSTEM QUEUE STATS                                                                               |
|               |  +--------------------+  +--------------------+  +--------------------+  +--------------------+   |
|  [x] Dash     |  | Pending Matches    |  | Pending Verif.     |  | Open Disputes      |  | Suspended Accounts |   |
|  [ ] Matches  |  |     12  (Amber)    |  |     8  (Amber)     |  |     3  (Red)       |  |     5  (Red)       |   |
|  [ ] Cases    |  +--------------------+  +--------------------+  +--------------------+  +--------------------+   |
|  [ ] Verif    |                                                                                                   |
|  [ ] Chats    |  MATCH REVIEW QUEUE                                                                               |
|  [ ] Disputes |  * Case #1034: iPhone 13 Pro vs. Found #F-4903 | [ 92% Match ] (Green Badge)  | [ Compare Match ]  |
|  [ ] Centres  |  * Case #1035: Nike Backpack vs. Found #F-5012 | [ 84% Match ] (Green Badge)  | [ Compare Match ]  |
|  [ ] Settings |                                                                                                   |
|  -------------+  -------------------------------------------------------------------------------------------------|
|               |  SECURITY & DISPUTE ALERTS                                                                        |
|  [Log Out]    |  * [!] User "m_vance99" automatically suspended. Reason: 3 failed claim attempts.   | [ Inspect ]  |
|               |  * [!] Centre "Kings Cross" flagged dispute: Case #1021. Reason: Item damaged claim. | [ Resolve ]  |
+-------------------------------------------------------------------------------------------------------------------+
```

---

## Detailed Components

### 1. Unified Sidebar Navigation
* **Dashboard (Active):** High-level summary views.
* **Matches:** Navigates to the Match Review Center.
* **Cases:** Detailed database of all items (active, matching, returned).
* **Verif:** Navigates to the Verification Review Portal.
* **Chats:** The support chat control center.
* **Disputes:** Navigates to the Dispute and blacklisted accounts manager.

### 2. Operational Metrics Cards
* Color-coded to highlight urgency:
  * **Matches & Verifications:** Sunset Amber (`#FF9F0A`) represents active operational workflow queues.
  * **Disputes & Suspended Accounts:** Crimson Red (`#FF453A`) represents security blocks requiring immediate attention.

### 3. Match Review Queue Panel
* Lists active unmatched candidates sorted by similarity percentages.
* **[ Compare Match ] Button:** Loads the side-by-side verification pane.
  * *Interaction:* Navigates to [MatchCenterView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Admin/MatchCenterView.md).

### 4. Security Alerts Panel
* Automatically pulls high-severity system logs:
  * **Automatic Suspensions:** Alerts Admins of automated account locks.
    * *Interaction:* Clicking **[ Inspect ]** routes to [DisputeCenterView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Admin/DisputeCenterView.md).
  * **Disputes Flagged by Centres:** Lists conflicts flagged by receptionist desks.
    * *Interaction:* Clicking **[ Resolve ]** opens the case details panel.

---

## Safety & Compliance Verification

* **Rule 1 (Admin Board has Highest Control):** Brings all high-priority disputes and account suspensions immediately to the Admin's landing workspace.
* **Rule 11 (Prevent Misuse):** The security panel handles automatic locks for repeated failed claims, preventing brute-force item claiming.
