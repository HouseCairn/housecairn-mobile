# 0006. Subscription: purchases checked by the relay, minimal data, no link to content

- Status: proposed
- Date: 2026-11-14

## Context

The app is free; family sync on the hosted relay is paid by an auto-renewable subscription
bought in the App Store or Google Play. The relay must know that a space is paid, and nothing
more: not who paid, not what the family stores. A family on a self-hosted relay pays nothing.

## Decision

**One subscription product, "Family sync"**, monthly and yearly, on both stores, bought through
`in_app_purchase` ([ADR 0001](0001-flutter-stack-and-packages.md)). One purchase covers one
space, that is one home, whatever the number of phones within the quota.

**The relay verifies the purchase, never the app alone.**

- **Apple**: the phone sends the signed transaction (JWS) of StoreKit. The relay verifies it with
  Apple's App Store Server Library (signature chain to Apple's root, bundle id, environment)
  and later reads its state through the App Store Server API (*Get All Subscription Statuses*,
  <https://developer.apple.com/documentation/appstoreserverapi>). Renewals, refunds and expiries
  arrive by App Store Server Notifications V2.
- **Google**: the phone sends the purchase token. The relay reads
  `purchases.subscriptionsv2.get` and acknowledges the purchase. Changes arrive by Real-time
  developer notifications through Cloud Pub/Sub, which only say that something changed: the
  relay then calls the API again, as Google requires
  (<https://developer.android.com/google/play/billing/rtdn-reference>).

**Data kept by the relay, per space**: store (`apple` or `google`), a SHA-256 of the original
transaction id or of the purchase token chain, product, expiry, state (active, grace, expired,
refunded), date of last check. **Not kept**: price, currency, country or storefront, Apple or
Google account, e-mail, receipt bodies after verification.

**No link from the purchase to the content, and none from the store to the family**: the
content is ciphertext the relay cannot read, so no purchase can be tied to a title or an
amount. The app sets neither `appAccountToken` (Apple) nor `obfuscatedAccountId` (Google), so
the stores never learn the space id. The one link that exists, transaction to space, is held by
the relay only, as a hash. Unlinkable tokens (blind signatures) would remove it too; not in v1.

**End of a subscription**: the space stays readable 30 days (phones can download, not upload),
then the relay deletes it, after a notice in the app at 7 days and at 1 day. Local data on the
phones is never touched.

**Self-hosted relay**: no entitlement check; the app lets the person type a relay address in
Settings at no cost, and the hosted relay is the default.

## Consequences

- Store credentials (App Store Connect API key, Google service account) are secrets of the
  hosted relay only; they are not in either repository.
- Restoring a purchase on a new phone re-sends the transaction; the relay recognises the hash
  and attaches the same space.
- Whether pointing a free app at a self-hosted relay meets the App Store rules on unlocking
  features is not verified (see open questions).
- Price, trial and family sharing of the subscription are product choices left to the
  maintainer.
