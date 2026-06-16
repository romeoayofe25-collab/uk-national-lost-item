# View: Report Found Item Wizard (`ReportFoundItemView`)

The Report Found Item wizard is a multi-step flow that records general descriptors and spatial coordinates of a found item, keeping sensitive identifying marks protected.

---

## Wizard Step Flow Layouts

### Step 1: General Details
```
+-------------------------------------------------------------+
|  [Back] Step 1 of 4: General Details              [Cancel]  |
+-------------------------------------------------------------+
|  Describe what you found:                                   |
|                                                             |
|  * Item Category                                            |
|  [ Personal Accessories (Backpack)                     [V] ] |
|                                                             |
|  Primary Colour            Brand (If visible)               |
|  [ Blue                  ] [ Nike                         ] |
|                                                             |
|  Condition                                                  |
|  [ Good / Clean                                        [V] ] |
|                                                             |
|  [i] Note: Do not describe highly specific identifiers in    |
|  your description (e.g. "contains a driver's license for    |
|  John Doe"). These will be verified privately by Admin.     |
+-------------------------------------------------------------+
|                       [ Next Step ]                         |
+-------------------------------------------------------------+
```

### Step 2: Time & Location
```
+-------------------------------------------------------------+
|  [Back] Step 2 of 4: Time & Location              [Cancel]  |
+-------------------------------------------------------------+
|  Where and when was it found?                               |
|                                                             |
|  [GPS Automatically Saved: Hyde Park Area, London]           |
|                                                             |
|  * Found Address / Location (Manual Override)               |
|  [ Hyde Park, near Serpentine Gallery                     ] |
|                                                             |
|  +-------------------------------------------------------+  |
|  |                                                       |  |
|  |                 [ Auto-GPS Map Pin ]                  |  |
|  |               (Drag to adjust location)               |  |
|  |                                                       |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  * Date Found                * Approximate Time             |
|  [ 15 / 06 / 2026      [O] ] [ 15 : 10                    ] |
+-------------------------------------------------------------+
|                       [ Next Step ]                         |
+-------------------------------------------------------------+
```

### Step 3: Photo & Verification Upload
```
+-------------------------------------------------------------+
|  [Back] Step 3 of 4: Photo & Proof                [Cancel]  |
+-------------------------------------------------------------+
|  Upload a photo of the item:                                |
|                                                             |
|  +--------------+                                           |
|  |  [+] Photo   |                                           |
|  +--------------+                                           |
|                                                             |
|  [i] Privacy Protection:                                    |
|  Upload photos showing the item clearly. Any sensitive PII   |
|  contained in the image (like names or credit card numbers) |
|  will be blurred automatically or masked in the public feed  |
|  and visible only to the Admin Board.                       |
+-------------------------------------------------------------+
|                       [ Next Step ]                         |
+-------------------------------------------------------------+
```

### Step 4: Submission & Drop-off Preference
```
+-------------------------------------------------------------+
|  [Back] Step 4 of 4: Return Choice                [Cancel]  |
+-------------------------------------------------------------+
|  How will you return the item?                              |
|                                                             |
|  (*) Drop off at a verified partner centre (Recommended)    |
|      (Protects your privacy and speeds up reward release)   |
|                                                             |
|  ( ) Keep with me until contacted by Admin                  |
|                                                             |
|  [ ] I confirm that the details are true, and I will not     |
|      seek private negotiation with any claimant.            |
+-------------------------------------------------------------+
|                    [ Submit Found Item ]                    |
+-------------------------------------------------------------+
```

---

## Detailed Component Rules & Behaviors

### 1. Auto-Location & Manual Override (Step 2)
* **Default Behavior:** Upon loading Step 2, the app requests device GPS coordinates. It matches the longitude/latitude to a readable address and updates the `Location Input` box. The user sees an interactive `Auto-GPS Map Pin` showing their current position.
* **Manual Override:** The user can tap the text input to enter details manually (e.g., "Under seat 4B on the train") or drag the map pin to manually reposition the found location marker.

### 2. Privacy Redaction & Strong Verification (Step 3)
* **Goal:** Satisfies Rule 19 ("Verification must be strong") and Rule 13 ("Protect privacy").
* **Implementation:** Finders are prompted to take clear photos. The app flags that detailed private marks (e.g. a specific engraving on the back of an iPad) must not be written in the public text area. These are kept on the encrypted Admin dashboard, ensuring only the true owner can correctly claim them.

---

## Safety & Compliance Verification

* **Rule 16 & Rule 9 Enforced:** No inputs or fields exist for entering a "finder's fee" or reward demand.
* **Rule 10 Enforced:** No owner communication tags are linked. The submit event sends the report to the Admin queue for match processing.
