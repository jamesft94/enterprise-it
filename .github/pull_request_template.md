## 🛡️ Enterprise IT Change Request (ISO 27001 Annex A.8.32)

### 1. What is changing and why?
<!-- Brief 1-2 sentence description of the policy, group, or FreeIPA change -->

### 2. Operational Safety & "Monitor-First" Checklist
- [ ] **Monitor-First Verified:** Any new Conditional Access or Intune rule is set to `enabledForReportingButNotEnforced` (or 7-day grace period) for a 14-day burn-in.
- [ ] **Break-Glass Protected:** Emergency group `SG-Sec-BreakGlass-Accounts` is excluded from any blocking policy.
- [ ] **24/7 Care Operations Impact:** Checked sign-in logs / blast radius to ensure zero disruption to round-the-clock staff.
- [ ] **Rollback Plan:** Reverting this commit (`git revert`) cleanly restores previous state.