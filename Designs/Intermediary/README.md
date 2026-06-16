# UK National Lost-Item - Intermediary UI/UX Designs

This directory contains the detailed wireframe layouts, visual states, and interaction flows for the **Intermediary / Drop-off Centre** role. 

Intermediaries represent the physical nodes of the platform (e.g., reception desks, libraries, and locker bays). The UI is designed to accommodate tablet screens (iPad/Android tablets) commonly used at reception desks, as well as mobile devices used by staff on the floor.

## Core Design System & Theme

The Intermediary interface uses the **Deep Obsidian Glassmorphism** theme, styled for maximum legibility in variable lighting conditions at active reception desks.

### Visual Accents & UI Priorities
* **Storage Location Accents:** Physical storage locations (e.g., `Shelf B-12`, `Locker 3`) are styled with highly readable monospaced font blocks (`#8E8E93` background, `#FFFFFF` text) to ensure rapid matching.
* **Scan Targets:** Scan targets use a prominent green indicator (`#30D158`) when successful, or orange (`#FF9F0A`) for pending reviews.
* **Responsive Scaling:** Grid layouts are designed to adapt from mobile sizes to 10-inch tablets.

---

## Folder Map & Navigation Flow

1. **[IntermediaryDashboardView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Intermediary/IntermediaryDashboardView.md)** - Home page displaying daily summaries, active deposits, pending collections, and scanner shortcut.
2. **[IntermediaryScanView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Intermediary/IntermediaryScanView.md)** - Tablet camera-based QR scanner or manual PIN keyboard.
3. **[ConfirmDepositForm.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Intermediary/ConfirmDepositForm.md)** - Receipt verification flow for incoming items from Finders, including physical storage tag entry.
4. **[IntermediaryInventoryView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Intermediary/IntermediaryInventoryView.md)** - Searchable database of items currently stored at this specific location.
5. **[ConfirmHandoverForm.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Intermediary/ConfirmHandoverForm.md)** - Desk checklist for releasing items to Owners, enforcing manual photo ID checks.
6. **[LockerReleaseView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Intermediary/LockerReleaseView.md)** - Design representing the Owner-facing automated locker flow with mobile biometric unlock overrides.
7. **[IntermediaryChatView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Intermediary/IntermediaryChatView.md)** - Logistical chat system for resolving collection dates/times.
8. **[RuleValidationReport.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Intermediary/RuleValidationReport.md)** - Compliance evaluation against the 20 project rules.
