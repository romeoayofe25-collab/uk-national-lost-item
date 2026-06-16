# UK National Lost-Item - Administration Board UI/UX Designs

This directory contains the detailed wireframe layouts, visual states, and interaction flows for the **Administration Board** role.

The Admin interface is designed as a widescreen desktop web application (Admin Console) to accommodate high data density, side-by-side verification documents, real-time chat monitoring, and user management ledgers.

## Core Design System & Theme

The Admin Console extends the **Deep Obsidian Glassmorphism** style, optimizing it for long hours of desk operations.

### Visual Accents & UI Priorities
* **Metric Accents:** Outstanding alerts are categorized by color:
  * Crimson Red (`#FF453A`) for disputes, fraud alerts, and automatic account suspensions.
  * Sunset Amber (`#FF9F0A`) for pending matches and verification files.
  * Emerald Teal (`#30D158`) for completed returns, active centres, and reactivated accounts.
* **Match Confidence Indicators:** Percentage scores (e.g. `92% Match`) are highlighted in bold badges, colored from red (low) to green (high) depending on the score threshold.
* **Data Density:** Layouts utilize compact grids, sidebar menus, split-screen compare panels, and contextual modals.

---

## Folder Map & Navigation Flow

1. **[AdminDashboardView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Admin/AdminDashboardView.md)** - Operational console landing page showing key queue counts, active matches, open disputes, and statistics.
2. **[MatchCenterView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Admin/MatchCenterView.md)** - Side-by-side matching compare pane showing automated confidence scores.
3. **[CaseManagementView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Admin/CaseManagementView.md)** - Detailed case manager. The exclusive interface for setting and approving reward values.
4. **[VerificationPortalView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Admin/VerificationPortalView.md)** - Document and credential evaluation desk.
5. **[ChatControlRoomView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Admin/ChatControlRoomView.md)** - Monitor logs for logistical chats, featuring pause/terminate overrides and PII warning logs.
6. **[DisputeCenterView.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Admin/DisputeCenterView.md)** - Vault for automatic account suspensions, blacklist reviews, and reactivation tools.
7. **[RuleValidationReport.md](file:///c:/Users/romeo/Documents/AntiGravity/UK%20National%20LostItem/Designs/Admin/RuleValidationReport.md)** - Compliance evaluation against the 20 project rules.
