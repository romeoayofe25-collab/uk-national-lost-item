# UK National Lost-Item - Owner UI/UX Designs

This directory contains the detailed wireframe layouts, visual states, and interaction flows for the **Owner** role. These designs are platform-agnostic but structure layouts to map easily to SwiftUI and Android Compose components.

## Core Design System & Theme

To ensure the app feels modern, premium, and reassuring during stressful situations, we use a **Deep Obsidian Glassmorphism** theme. 

### Harmonious Color Palette
| Color Role | Hex Value | SwiftUI System Equivalent | Purpose / Mood |
| :--- | :--- | :--- | :--- |
| **Canvas Background** | `#0B0F19` | `Color(.systemBackground)` / Dark | Deep, high-contrast obsidian background to reduce eye strain. |
| **Card Surface** | `#162032` (80% opacity) | `Color(.secondarySystemBackground)` | Semi-transparent card style with a backing backdrop blur (glass effect). |
| **Border / Stroke** | `#2C3A50` | `Color(.separator)` | Thin, crisp borders to define structures on the dark background. |
| **Primary Accent** | `#5E5CE6` | `Color.indigo` | Electric Indigo. Used for primary CTA buttons, active flows, and navigation. |
| **Secondary Accent** | `#A2A1F7` | `Color.indigo` (light) | Light indigo. Used for secondary actions, subtle highlights, and tags. |
| **Success Alert** | `#30D158` | `Color.green` | Emerald Teal. Used for verified status, recovered notifications, and PIN approvals. |
| **Pending / Match Alert** | `#FF9F0A` | `Color.orange` | Sunset Amber. Used for "Match Found", "Action Required", or "Under Review". |
| **Danger / Block Alert** | `#FF453A` | `Color.red` | Coral Red. Used for errors, failed verification, or reported issues. |
| **Text Primary** | `#FFFFFF` | `Color.primary` | Pure Snow. Maximum legibility for main headers and details. |
| **Text Secondary** | `#8E8E93` | `Color.secondary` | Cool grey. Used for metadata labels, timestamps, and placeholder text. |

### Typography Hierarchy (SF Pro / Inter / Outfit)
* **Title Large (34pt, Bold):** For main screen headers (e.g., "Dashboard", "Report an Item").
* **Headline (20pt, Semibold):** For card titles and section headers.
* **Body (16pt, Regular, Line height 22pt):** For text readability.
* **Subheadline / Callout (14pt, Medium):** For secondary details, status pills, and metadata.
* **Caption (12pt, Regular):** For timestamp labels and footnote notifications.

---

## Folder Map & Navigation Flow

The following designs define the lifecycle of a Lost Item from initial reporting to secure drop-off collection:

1. **[OwnerDashboardView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Owner/OwnerDashboardView.md)** - Main landing interface displaying active reports, trust stats, and quick actions.
2. **[ReportLostItemView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Owner/ReportLostItemView.md)** - The multi-step wizard for reporting a new lost item. **Enforces No-Reward rules**.
3. **[LostItemDetailsView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Owner/LostItemDetailsView.md)** - Tracks retrieval progress through an interactive status timeline.
4. **[OwnerVerificationView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Owner/OwnerVerificationView.md)** - Flow where owners provide proof to the Admin Board.
5. **[OwnerAdminChatView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Owner/OwnerAdminChatView.md)** - Controlled communication channel restricted to Admin and Intermediaries.
6. **[CollectionDetailsView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Owner/CollectionDetailsView.md)** - Generates secure pin/QR access code for verified centre pick-up.
