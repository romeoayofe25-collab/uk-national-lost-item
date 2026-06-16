# UK National Lost-Item - Finder UI/UX Designs

This directory contains the detailed wireframe layouts, visual states, and interaction flows for the **Finder / Poster** role. These designs are platform-agnostic but structure layouts to map easily to SwiftUI and Android Compose components.

## Core Design System & Theme

The Finder role uses the same **Deep Obsidian Glassmorphism** theme defined in the [Owner Style Guide](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Owner/README.md), but introduces specific components to handle reward claims tracking and safe centre drop-offs.

### Distinct Finder UI Themes
* **Wallet Balance Accents:** Primary Indigo (`#5E5CE6`) represents confirmed/active claims, and secondary Light Indigo (`#A2A1F7`) is used for pending escrow status.
* **Drop-off Navigation Markers:** Standard maps utilize Electric Indigo to highlight the Finder's current location, and Success Teal (`#30D158`) represents verified drop-off points.

---

## Folder Map & Navigation Flow

The following designs define the lifecycle of a Found Item from reporting to safe drop-off and reward collection:

1. **[FinderDashboardView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Finder/FinderDashboardView.md)** - Main landing interface displaying active found postings, trust points, and wallet balance.
2. **[ReportFoundItemView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Finder/ReportFoundItemView.md)** - The multi-step wizard for reporting a new found item. **Hides sensitive owner identification fields**.
3. **[DropOffSelectionView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Finder/DropOffSelectionView.md)** - List of recommended Drop-off Centres near the found location with automated recommendations and manual search.
4. **[FinderAdminChatView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Finder/FinderAdminChatView.md)** - Monitored support chat restricted to Admin and Intermediaries (no direct owner contact).
5. **[FinderClaimsView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Finder/FinderClaimsView.md)** - Platform wallet tracking earnings, pending transactions, and return verification.
6. **[RuleValidationReport.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Finder/RuleValidationReport.md)** - Compliance checklist validating designs against the 20 project rules.
