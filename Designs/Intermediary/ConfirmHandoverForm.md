# View: Desk Confirm Handover Form (`ConfirmHandoverForm`)

This form is loaded by the receptionist to authorize the physical release of an item to the Owner at the service desk, satisfying Rule 19 ("Verification must be strong").

---

## UI Layout Wireframe

```
+-------------------------------------------------------------+
|  [Back] Confirm Item Handover                               |
+-------------------------------------------------------------+
|  HANDOVER RECORD: Case #1034                                |
|  Item to Retrieve: iPhone 13 Pro (Storage Location: Shelf B-12)|
|  Claimant: Sarah Jenkins                                    |
|                                                             |
+-------------------------------------------------------------+
|  * 1. Manual Photo ID Check (Required)                      |
|  Select ID Document Type:                                   |
|  [ UK Driver's License                                 [V] ] |
|                                                             |
|  [ ] I confirm that I have manually inspected the claimant's|
|      physical Photo ID, and the name and photo match the     |
|      details on file.                                       |
|                                                             |
|  * 2. Physical Proof / Device Unlock (Required)             |
|  [ ] I confirm the owner successfully unlocked the device   |
|      or correctly described unique hidden details on file.  |
|                                                             |
|  * 3. Owner Signature                                       |
|  +-------------------------------------------------------+  |
|  |                                                       |  |
|  |                  [ Signature Pad ]                    |  |
|  |             (Sign inside the box to accept)           |  |
|  |                                                       |  |
|  +-------------------------------------------------------+  |
+-------------------------------------------------------------+
|             [ Confirm Handover & Release Item ]             |
|                    (Success Teal Button)                    |
+-------------------------------------------------------------+
```

---

## Detailed Component Rules & Behaviors

### 1. Manual Photo ID Checklist
* **Document Picker:** Drop-down menu options: *UK Passport, UK Driver's License, CitizenCard, University Photo ID, National Identity Card*.
* **Validation Checkbox:** A mandatory tick. Desk staff must physically hold and inspect the identity document to prevent fraudulent pickups (Rule 19).

### 2. Physical / Device Unlock Validation
* **Behavior:** Staff must verify the owner's knowledge of the item. For electronics, the owner should unlock the device with their passcode in front of staff. For non-electronic items, staff should confirm a unique hidden detail (e.g. "What was inside the side pocket?").

### 3. Handover Handshake Submission
* **Database Updates on Submit:**
  * Status updates to `Returned`.
  * Triggers database event: Releases the escrowed reward to the Finder's available balance in their platform wallet (Rule 14).
  * Automatically disables the collection PIN/QR code.
  * Archives the support chat case.

---

## Safety & Compliance Verification

* **Rule 19 Enforced:** Physical ID check and device unlock validation are mandatory gating steps before the handover button is enabled.
* **Rule 14 Enforced:** Finder reward release is programmatically bound to the successful submission of this signed handover form, ensuring no payment occurs until return is complete.
