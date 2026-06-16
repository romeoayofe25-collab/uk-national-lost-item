# View: Safe Collection Details (`CollectionDetailsView`)

This view is unlocked once the Admin Board has verified ownership and the item has been safely deposited by the Finder at a Drop-off Centre. It facilitates the safe handover of the item.

---

## UI Layout Wireframe

```
+-------------------------------------------------------------+
|  [Back] Collection Desk Info                                |
+-------------------------------------------------------------+
|  ITEM READY FOR COLLECTION                                  |
|  Item: iPhone 13 Pro                                        |
|  Location: Kings Cross Station - Customer Support Desk      |
|                                                             |
+-------------------------------------------------------------+
|  YOUR SECURE COLLECTION CODE                                |
|  Present this code to the desk representative.              |
|                                                             |
|                   +-------------------+                     |
|                   |                   |                     |
|                   |  [ QR CODE IMAGE ]|                     |
|                   |                   |                     |
|                   +-------------------+                     |
|                                                             |
|                       PIN: 491-032                          |
|                                                             |
+-------------------------------------------------------------+
|  CENTRE DETAILS                                             |
|  +-------------------------------------------------------+  |
|  | [Map Preview]                                         |  |
|  | Location: Euston Rd, London N1 9AL                    |  |
|  | Hours: Mon-Sun | 08:00 - 22:00                        |  |
|  | Directions: Located next to ticket gates, Platform 9. |  |
|  +-------------------------------------------------------+  |
+-------------------------------------------------------------+
|               [ Secure Chat with Centre Desk ]              |
|                   (Secondary Outline CTA)                   |
+-------------------------------------------------------------+
```

---

## Technical Flow & Security Actions

### 1. The Verification Handshake
* **The QR Code / PIN:** Generates a secure, cryptographically hashed, single-use token tied to the specific lost item report.
* **The Handover Action:**
  1. The Owner arrives at the drop-off desk and presents the QR code or PIN.
  2. The Intermediary (desk staff) logs into their dedicated portal and scans the QR code or enters the PIN.
  3. The system matches the token, validates the Owner's identity, and prompts the representative to hand over the physical item.
  4. The representative clicks "Confirm Handover" on their interface.
  5. The Owner's app updates immediately to `Returned`.
  6. The Finder is notified that the item has been returned, and the Admin releases the pending reward (Rule 14).

### 2. Monitored Intermediary Chat
* **Purpose:** Allows the Owner to coordinate pickup directly with the desk staff (e.g., "I will be 15 minutes late, please keep the item safe").
* **Restrictions:** The chat is limited to administrative logistical messages and is automatically archived 24 hours after the handover is marked complete.

---

## Safety & Compliance Verification

* **Rule 18 (Safe Drop-off):** Handover is restricted to a physical, verified partner centre with CCTV and staff, avoiding unsafe dark-alley meetings or direct contact between Owner and Finder.
* **Rule 14 (Controlled Reward Release):** The reward is locked in the system's escrow wallet and cannot be released until this collection event is digitally marked "Confirmed Handover" by the Intermediary.
