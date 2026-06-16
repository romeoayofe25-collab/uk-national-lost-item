# View: Automated Locker Biometric Collection (`LockerReleaseView`)

This view represents the mobile application flow presented to the **Owner** when retrieving their item from an unattended, automated locker (e.g. during weekends or Bank Holidays), satisfying Rule 19 ("Verification must be strong").

---

## UI Layout Wireframe (Owner App View)

```
+-------------------------------------------------------------+
|  [Back] Locker Collection                                   |
+-------------------------------------------------------------+
|  LOCKER SECURE ACCESS: Case #1034                           |
|  Location: Kings Cross Station External Bay                 |
|  Locker Box Assigned: [ Locker 14-B ] (Monospaced Badge)    |
|                                                             |
+-------------------------------------------------------------+
|  PROXIMITY CHECK                                            |
|  [GPS: Located within 3 metres of Locker Bay (OK)]          |
|                                                             |
+-------------------------------------------------------------+
|  BIOMETRIC AUTHENTICATION REQUIRED                          |
|  Scan Face ID or Fingerprint to authorize locker unlock.     |
|                                                             |
|                         +---------+                         |
|                         |  ( o )  |                         |
|                         |  FaceID |                         |
|                         +---------+                         |
|                                                             |
|           [ Scan Biometrics to Unlock Box ]                 |
|                (Electric Indigo Button)                     |
+-------------------------------------------------------------+
|  [i] Locker Handover Terms:                                 |
|  Unlocking the box will record physical handover. Closing the |
|  box door triggers the matched reward release to the finder. |
+-------------------------------------------------------------+
```

### Unlocked / Collected State (Success Overlay)
```
+-------------------------------------------------------------+
|  [Success Teal Check] LOCKER 14-B UNLOCKED                  |
|                                                             |
|  Please retrieve your iPhone 13 Pro from the locker box.    |
|                                                             |
|  [ ] I have retrieved my item and closed the locker door.   |
|                                                             |
+-------------------------------------------------------------+
|                  [ Complete Collection ]                    |
|                   (Success Teal Button)                     |
+-------------------------------------------------------------+
```

---

## Detailed Processing Logic & Transitions

### 1. Dual-Gated Security Checks
1. **GPS Proximity Validation:** The app checks the device's location. The unlock button is disabled unless the Owner is within a 10-meter geofenced radius of the locker bay, preventing accidental remote unlocks.
2. **Local Device Biometrics:** Pressing the button triggers standard system biometric API calls (iOS `LAContext` FaceID/TouchID or Android `BiometricPrompt`).

### 2. Locker Release Action
* If biometrics are verified, the client posts to the backend `unlockLockerBox(caseId)`. 
* The server sends an unlock signal to the IoT locker box and updates the Owner's screen to the "Unlocked/Collected" state.
* Once the Owner confirms collection and closes the door, the backend marks the case as `Returned` and transfers the escrowed reward to the Finder (Rule 14).

---

## Safety & Compliance Verification

* **Rule 19 (Strong Verification):** Biometric or facial verification acts as a digital proxy for the desk receptionist's manual ID card check, securing unattended weekend collection.
* **Rule 18 (Safe Drop-off):** External, CCTV-monitored locker bays offer flexible, secure pick-ups without direct stranger interaction.
