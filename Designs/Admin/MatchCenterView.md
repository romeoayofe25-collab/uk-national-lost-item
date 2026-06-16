# View: Match Review Center (`MatchCenterView`)

This view allows Admins to evaluate potential matches side-by-side and authorize the case to progress to Owner verification.

---

## UI Layout Wireframe (Split-screen Widescreen Compare)

```
+-------------------------------------------------------------------------------------------------------------------+
|  [Back] Match Review Center: Case Match #MC-932                                                                    |
+-------------------------------------------------------------------------------------------------------------------+
|  SYSTEM SIMILARITY ASSESSMENT: [ 92% CONFIDENCE MATCH ] (Emerald Teal Badge)                                      |
+-------------------------------------------------------------------------------------------------------------------+
|  LOST REPORT (#L-8390)                             |  FOUND REPORT (#F-4903)                                      |
|  Reporter: Sarah Jenkins (Trust Score: 98)         |  Finder: Marcus Vance (Trust Score: 95)                      |
|                                                    |                                                              |
|  * Category: Electronics (Smartphone)              |  * Category: Electronics (Smartphone)                        |
|  * Brand: Apple                                    |  * Brand: Apple                                              |
|  * Model: iPhone 13 Pro                            |  * Model: iPhone (unspecified)                               |
|  * Colour: Graphite                                |  * Colour: Grey / Graphite                                   |
|  * Date Lost: 15/06/2026 at 14:30                  |  * Date Found: 15/06/2026 at 15:10                           |
|  * Location: Kings Cross Station, London           |  * Location: Kings Cross Station, Platform 9                 |
|  * Description:                                    |  * Description:                                              |
|    "Graphite iPhone, has a blue leather cover,     |    "Found a grey iPhone on the platform bench.               |
|     screen is slightly scratched."                 |     Has a blue cover."                                       |
|                                                    |                                                              |
|  [Photo Thumbnail: Owner's stock photo]            |  [Photo Thumbnail: Finder's device photo]                   |
+-------------------------------------------------------------------------------------------------------------------+
|                                                                                                                   |
|            [ Reject Match ] (Red Outline Button)          [ Approve Match ] (Success Teal Button)                 |
|                                                                                                                   |
+-------------------------------------------------------------------------------------------------------------------+
```

---

## Detailed Components & Matching Mechanics

### 1. Similarity Engine Highlights
* **Category Match:** Enforced matching (app only matches items of identical categories).
* **Location Geofencing Match:** Calculates distance between `Lost Location` and `Found Location`. In this case, both are geolocated at Kings Cross Station coordinates.
* **Temporal Proximity Match:** Confirms the chronological overlap (lost at 14:30, found at 15:10 on the same date).
* **Attribute Match:** Core keywords matching ("blue cover/case", "graphite/grey").
* **Score Badge:** Displays a prominent matching score (`92% Confidence`) based on these matching indices.

### 2. Matching Action Controls
* **[ Reject Match ] Button:** Tapping this breaks the temporary link. Both reports are returned to the active matching search pool. The Finder's report remains unmatched, and the Owner is not notified.
* **[ Approve Match ] Button:** Tapping this confirms the connection. 
  * *System Action:* Creates a permanent Case ID (`Case #1034`). 
  * *Notification:* Sends an automated notification to the Owner: *"A potential match has been verified by Admin. Please provide proof of ownership in the app."* 
  * *Status:* Moves Case Status to `Match Found - Under Review`.

---

## Safety & Compliance Verification

* **Rule 10 (No Direct Communication):** Approving a match does *not* open a chat between Sarah (Owner) and Marcus (Finder). It moves the case into the Admin review queue.
* **Rule 11 (Fraud Prevention):** Forcing manual Admin approval of potential matches prevents malicious users from automatically receiving matches on items simply by matching keywords.
* **Rule 13 (Protect Privacy):** Contact info (phone numbers, email) is omitted from this view to prevent accidental copy/paste leaks.
