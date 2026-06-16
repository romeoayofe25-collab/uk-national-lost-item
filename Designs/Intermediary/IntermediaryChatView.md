# View: Intermediary Secured Chat (`IntermediaryChatView`)

This chat view allows the Intermediary Desk staff to message the Owner or Finder associated with an active item stored at their location, satisfying Rule 4 ("Chat must be controlled and monitored").

---

## UI Layout Wireframe

```
+-------------------------------------------------------------+
|  [Back] Logistical Support: Sarah J.              [Pause]   |
|         Regarding: Case #1034 (iPhone 13 Pro)               |
+-------------------------------------------------------------+
|  [i] Security Warning:                                      |
|  This channel is restricted to collection logistics.        |
|  Sharing private payment links or negotiating fees is a     |
|  breach of project rules.                                   |
+-------------------------------------------------------------+
|                                                             |
|  [Sarah Jenkins] 16/06/2026 13:10                           |
|  "Hi, I won't be able to make it to the desk before you      |
|   close at 22:00 tonight. Can you help?"                    |
|                                                             |
|                         [Desk Staff (You)] 16/06/2026 13:15 |
|                         "Hello Sarah. I can transfer the     |
|                          phone to Locker 14-B outside."     |
|                                                             |
|  [Sarah Jenkins] 16/06/2026 13:16                           |
|  "That would be perfect! Can I collect it during the night?"|
|                                                             |
|                         [Desk Staff (You)] 16/06/2026 13:18 |
|                         "Yes. You will see Locker 14-B on    |
|                          your app. Scan your Face ID to unlock|
|                          it when you arrive."                |
|                                                             |
+-------------------------------------------------------------+
|  [Type message...]                                   [Send] |
+-------------------------------------------------------------+
```

---

## Safety & Compliance Verification

* **Rule 10 (No Direct Communication):** This chat replaces any direct Owner-to-Finder connection. The desk receptionist acts as the safe mediator.
* **Rule 4 (Controlled & Monitored):** All messages are logged for the Admin Board. Standard local filters block card numbers and phone digits. The chat automatically expires and locks 24 hours after the handover is marked complete.
