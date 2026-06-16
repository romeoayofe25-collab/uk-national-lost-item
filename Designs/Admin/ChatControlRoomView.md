# View: Chat Control Room (`ChatControlRoomView`)

The Chat Control Room enables the Administration Board to monitor active logistical chats, view automated PII filter alerts, and manage chat lifecycles, satisfying Rule 4 ("Chat must be controlled and monitored").

---

## UI Layout Wireframe (Widescreen Desk Split Panel)

```
+-------------------------------------------------------------------------------------------------------------------+
|  [Back] Chat Control Room                                                                                         |
+-------------------------------------------------------------------------------------------------------------------+
|  ACTIVE LOGISTICAL CHATS                           |  MONITORING CASE #1034 (Sarah Jenkins)                       |
|  * Case #1034: Sarah J. (Owner)     [Monitored]    |  Monitored Participants: Owner Sarah J. $\leftrightarrow$ Support Desk      |
|  * Case #1035: Marcus V. (Finder)   [Monitored]    |                                                              |
|  * Case #1029: David K. (Owner)     [Archived]     |  [System] 15/06 14:50: "Verification submitted."             |
|                                                    |  [Admin-James] 15/06 15:05: "Hi Sarah, wallpaper ok..."       |
|                                                    |  [Sarah J.] 15/06 15:10: "I uploaded the barcode barcode."    |
|                                                    |                                                              |
|  PII SECURITY ALERT LOGS                           +--------------------------------------------------------------+
|  * 15/06 15:11: Case #1034 - Sarah J. attempted    |  ADMIN CONTROL OVERRIDES (Rule 4)                            |
|    to share credit card numbers. Filtered.         |                                                              |
|  * 12/06 11:02: Case #1021 - Finder attempted      |    [ PAUSE CHAT ]        [ RESUME CHAT ]     [ TERMINATE ]    |
|    to share phone digits. Filtered.                |     (Amber Button)        (Teal Button)       (Red Button)    |
+-------------------------------------------------------------------------------------------------------------------+
```

---

## Detailed Components & Security Actions

### 1. Unified Chat Monitor Grid
* **Active List:** Displays all active support channels. Green dots indicate active messaging, grey dots indicate paused or archived states.
* **Live Feed:** Admin reads transcripts in real-time. Admins can type directly into the stream to act as the supporting representative.

### 2. PII Filter Alert Console
* **Log entries:** Displays details of attempts to bypass safety filters (e.g. typing telephone codes or external email addresses).
* **Alert Trigger:** If a user repeatedly triggers PII filters, the case is automatically flagged for fraud inspection.

### 3. Control Overrides (Rule 4)
* **[ PAUSE CHAT ] Action:** Temporarily locks text inputs on the user's mobile app. Display banner to user: *"This conversation has been temporarily paused by the Admin Board."*
* **[ RESUME CHAT ] Action:** Unlocks communication.
* **[ TERMINATE ] Action:** Instantly deletes the socket connection, hides the messaging screen on the client app, and archives the transcript to database storage.

---

## Safety & Compliance Verification

* **Rule 4 Enforced:** Admin has complete, override authority over the communication channels.
* **Rule 10 Enforced:** Facilitates support chat routing while ensuring Owner and Finder are never combined in a shared room.
