# View: Admin-Monitored Chat (`OwnerAdminChatView`)

The Chat View provides the Owner with a safe, direct line of communication to the Admin Board regarding a specific lost item claim, adhering to Rule 4 ("Chat must be controlled and monitored").

---

## UI Layout Wireframe

```
+-------------------------------------------------------------+
|  [Back] Admin Support: Case #1034                 [Pause]   |
|         Regarding: iPhone 13 Pro                            |
+-------------------------------------------------------------+
|  [i] Security Warning:                                      |
|  This chat is recorded and audited by the Administration     |
|  Board. Sharing phone numbers, addresses, or private payment |
|  links will trigger account restriction.                    |
+-------------------------------------------------------------+
|                                                             |
|  [System] 15/06/2026 14:50                                  |
|  "Verification submitted. Admin has been notified."         |
|                                                             |
|  [Admin - James] 15/06/2026 15:05                           |
|  "Hi Sarah, I see your wallpaper description. Do you have    |
|   the serial number from the original box?"                 |
|                                                             |
|                            [Sarah (You)] 15/06/2026 15:10   |
|                            "Yes, I just uploaded the photo  |
|                             of the box barcode."            |
|                                                             |
|  [Admin - James] 15/06/2026 15:12                           |
|  "Perfect. Match confirmed. Releasing details for drop-off  |
|   collection at Kings Cross Support Desk."                  |
|                                                             |
+-------------------------------------------------------------+
|  [Type message...]                                   [Send] |
+-------------------------------------------------------------+
```

---

## Layout Controls & State Adjustments

### 1. Active Chat Mode
* **Header:** Displays Case ID, Item name, and Admin representative name.
* **Safety Banner:** Top-anchored persistent alert: *"Monitored Support Channel. No PII sharing allowed."*
* **Message Bubbles:**
  * **Admin / System Message:** Left-aligned, dark background (`#162032`), thin grey border.
  * **User Message:** Right-aligned, Electric Indigo background (`#5E5CE6`), white text.

### 2. Locked/Terminated Chat Mode (Conditional)
* **Trigger:** Admin closes the case or pauses the chat due to suspicious activity.
* **UI Action:** The bottom text field and keyboard trigger are disabled and replaced by:
```
+-------------------------------------------------------------+
|  [X] This support channel has been closed.                  |
|  Please refer to your dashboard status for details.         |
+-------------------------------------------------------------+
```

---

## Safety & Compliance Verification

* **Rule 10 (No Direct Chat):** The chat runs strictly to the Administration Board. No Finder data is linked.
* **Rule 4 (Controlled & Monitored):** Admin has programmatic controls to pause, review transcripts, or terminate the chat instantly via their dashboard.
* **Rule 13 (Protect Privacy):** Automated PII filters scrub out phone numbers, email addresses, and payment details if a user attempts to type them, warning the user: *"System alert: Sharing personal contact info is restricted."*
