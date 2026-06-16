# View: Reward Wallet & Claims Tracker (`FinderClaimsView`)

The Reward Wallet & Claims Tracker is a simulated ledger showing verified item returns, pending escrow funds, and cumulative earnings, conforming to Rule 14 ("Reward payment must be controlled").

---

## UI Layout Wireframe

```
+-------------------------------------------------------------+
|  [Back] Wallet & Claims Tracker                             |
+-------------------------------------------------------------+
|  SIMULATED BALANCE                                          |
|                                                             |
|  Available: £ 45.00               Pending Escrow: £ 20.00   |
|                                                             |
|               [ Cash Out Available Funds ]                  |
|                 (Electric Indigo Button)                    |
+-------------------------------------------------------------+
|  CLAIMS & RETURNS HISTORY                                   |
|                                                             |
|  +-------------------------------------------------------+  |
|  | Case #1034: iPhone 13 Pro                             |  |
|  | Status: [ Escrow Locked ] (Sunset Amber Pill)         |  |
|  | Reward: £ 20.00                                       |  |
|  | Note: Awaiting owner verification & collection at     |  |
|  | Kings Cross Station.                                  |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  +-------------------------------------------------------+  |
|  | Case #1021: Leather Wallet                            |  |
|  | Status: [ Reward Released ] (Success Teal Pill)       |  |
|  | Reward: £ 15.00                                       |  |
|  | Processed: 12/06/2026                                 |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  +-------------------------------------------------------+  |
|  | Case #1035: Nike Blue Backpack                        |  |
|  | Status: [ Reviewing Match ] (Cool Grey Pill)          |  |
|  | Reward: TBD (Under Admin Assessment)                  |  |
|  | Note: Verification pending.                           |  |
|  +-------------------------------------------------------+  |
+-------------------------------------------------------------+
```

---

## Component States & Logistical Logic

### 1. The Escrow Wallet Lifecycle
The reward amount follows strict system-controlled transitions:

1. **`Reviewing Match` (Pending):** System displays `Reward: TBD (Under Admin Assessment)`. Admin is evaluating the value and match accuracy. Finders cannot set or propose this amount.
2. **`Escrow Locked` (Pending Owner Pickup):** The Admin has confirmed the match and approved a reward of `£X.XX` based on item value estimates (Rule 16). The funds are locked in platform escrow.
3. **`Reward Released` (Available):** Triggered automatically when the Intermediary Centre scans the Owner's collection QR code. The reward moves from `Pending Escrow` to `Available Balance` (`#FFFFFF`).

### 2. Simulated Cashout Button
* **Interaction:** Clicking "Cash Out" displays a detailed dialog modal:
  * *Modal Text:* *"Simulated Cashout Action. In a production build, this will initiate secure Stripe/BACS transfer to your verified identity-checked bank account in compliance with UK Anti-Money Laundering (AML) standards."*

---

## Safety & Compliance Verification

* **Rule 14 (Controlled Reward Payment):** The wallet ledger highlights that funds cannot be released until physical handover is confirmed by the third-party intermediary.
* **Rule 16 (Owner Never Sets Reward):** No reward totals are customizable. Rewards are assessed by the Admin Board, removing bidding systems.
* **Rule 12 (Professional Mindset):** The wallet interface models real-world escrow patterns and documents planned compliance with AML standards.
