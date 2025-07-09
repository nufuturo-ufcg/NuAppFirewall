# Architecture & Data Flow

This document describes the architecture of **NuAppFirewall**, highlighting its structural components and the data flow involved in intercepting network traffic, extracting flow metadata, evaluating rules, and applying verdicts. It also covers the logging strategy used for observability and the test suite designed to ensure correctness and reliability.

---

## Components Overview

NuAppFirewall is composed of two main components:

- **App Container**: Required by macOS, this component is responsible for initializing and activating the network extension. It does not participate in rule processing after startup.
- **Network Extension**: The core of NuAppFirewall. It intercepts network flows, extracts relevant information, evaluates rules, and decides whether to allow or block the connection.

---

## Extension Initialization

The app container is responsible for starting the extension. This is managed by `ExtensionManager.swift`, which configures and activates the extension.

Once initialized, all processing transitions to the network extension process.

---

## Flow Interception and Analysis

The entry point of the extension is the `FilterDataProvider` class, which inherits from `NEFilterDataProvider`. This class overrides two main methods:

- `startFilter`: Called during initialization.
- `handleNewFlow`: Invoked for every new intercepted network flow.

When a flow is intercepted, `handleNewFlow` forwards it to the `FlowManager`, which is responsible for extracting all necessary data from the flow (such as IP, port, URL, host, process path, and bundle ID). 

Once the data is extracted, it is passed to the `RulesManager`, which handles rule evaluation and decision-making.

---

## Extracting Flow Information

In `FlowManager`, the function `extractFlowInfo` is first called to extract high-level data from the flow using the Network Extension framework. This includes:

- IP
- Port
- URL
- Host
- auditToken

Since this data is insufficient for precise rule matching, the `FlowManager` proceeds with a deeper extraction phase. This stage relies on types and system calls that are remnants of C and Objective-C interoperability commonly found in macOS internals.

1. **`pidFromAuditToken`** – Extracts the `pid_t` process identifier from the `audit_token_t`.
2. **`pathForProcess`** – Obtains the executable path of the process using the `pid`, leveraging `proc_pidpath`, a C function from the Darwin system.
3. **`getBundleID`** – Retrieves the application's unique bundle identifier based on the path. If the standard `Bundle` API fails, it falls back to manually reading the `Info.plist` to extract the `CFBundleIdentifier`.

These functions are all part of the `FlowManager`, which encapsulates the logic required to identify the origin application of a network connection.

At this point, we have the necessary data to evaluate rules:
- `bundleID`
- `appPath`
- `url`
- `host`
- `ip`
- `port`

---

## Rule Evaluation Strategy

Rules are evaluated by the `getRule` function in `RulesManager`, which checks for applicable rules across multiple levels of application specificity, in the following order:

1. `any` – A general rule applied to all applications (system-wide);
2. `bundleID` – Rule specific to the app’s bundle identifier;
3. `appPath` – Rule matching the exact path of the executable;
4. `subpath` – Rule matching partial paths when no exact match is found (fallback only).

### How Rule Matching Works

At each level, the function `findRules` retrieves all potentially applicable rules for a given application and network context. It collects rules matching any of the following destinations:

- `any:any` — matches any endpoint on any port (effectively applies to all connections of the app).
- `any:port` — matches any endpoint on a specific port.
- `url:any` — matches a specific URL on any port.
- `url:port` — matches a specific URL on a specific port.
- `host:any` — matches a specific host on any port.
- `host:port` — matches a specific host on a specific port.
- `ip:any` — matches a specific IP on any port.
- `ip:port` — matches a specific IP on a specific port.

This design uses an internal rule store represented as a nested dictionary:

```swift
var rules: [String: [String: Rule]]
```

Where:

The outer key is the app identifier (`any`, bundle ID, full path, etc.)

The inner key is the destination string (`endpoint:port`)

The function `findRules` retrieves all candidate rules for a given application and network context in a single batch. After collecting these candidates, the system applies prioritization to select the most appropriate rule.

### Subpath Lookup (Fallback)

If no rules are found for a given application identifier, and `fallbackToSubpath` is enabled, the system attempts a subpath search via `getRulesBySubpath`. This is a linear scan across all app identifiers.

Because this approach is more expensive — it checks whether each registered path is contained in the application path — it is only used as a last resort when no match is found by bundle ID or full path.

### Rule Prioritization

Once candidate rules are collected, the selectRule function prioritizes them based on the destination and action:

```swift
let destinations = [
    "\(Consts.any):\(Consts.any)",
    "\(Consts.any):\(port)",
    "\(url):\(Consts.any)",
    "\(url):\(port)",
    "\(host):\(Consts.any)",
    "\(host):\(port)",
    "\(ip):\(Consts.any)",
    "\(ip):\(port)",
]
```

- Destinations are matched following the order in the list, from generality to specificity.

- Among matching rules, those with action `block` are always preferred over `allow`.

If no rule matches at the current application level, the evaluation continues to the next level in the hierarchy, which follows this order:

1. `any` — general rules applied system-wide (all applications);
2. `bundleID` — rules specific to the application’s bundle identifier;
3. `appPath` — rules matching the full executable path;
4. `subpath` — rules matching partial paths, used as a fallback only.

### Example Rule Resolution Flow

Here is a simplified view of how the resolution happens inside getRule:

1. Call findRules(app: "any", ...)

  - Apply selectRule(...)

  - If rule found → return it

2. Call findRules(app: bundleID, ...)

  - Apply selectRule(...)

  - If rule found → return it

3. Call findRules(app: appPath, ...)

  - Apply selectRule(...)

  - If rule found → return it

4. If none match, optionally fall back to subpath search (controlled by fallbackToSubpath)

## Verdict Decision Logic

Once a matching rule is found, its verdict is returned to `handleNewFlow` in `FilterDataProvider`, which enforces the decision.

NuAppFirewall operates in **passive allow mode**:

> If no rule matches the flow, the default behavior is to **allow** it.

---

## Logging Strategy

NuAppFirewall uses structured logging to aid debugging, observability, and traceability during runtime. The logging system is centralized via `LogManager`, and logs are classified by category and severity.

Some examples include:

```swift
LogManager.logManager.log("Application not found: \(app)", level: .debug)
```

This helps track application-level resolution failures.

```swift
LogManager.logManager.logNewFlow(
    category: Consts.categoryConnection,
    flowID: flowID,
    auditToken: auditToken,
    endpoint: endpoint,
    port: port,
    mode: Consts.modePassive,
    url: url,
    verdict: rule.action,
    process: path,
    ruleID: rule.ruleID
)
```

This info-level log captures detailed metadata of every intercepted flow and the verdict applied. It is used both for debugging and validating runtime behavior.

## Testing Strategy

NuAppFirewall is supported by a comprehensive suite of unit and system tests to ensure correctness, and predictable behavior.

### Unit Tests (XCTest)

The unit tests cover the full lifecycle of rules and their application to flows. Test cases include:

- **Rule Initialization**  
  Validates that all possible combinations of rules are correctly initialized with accurate properties.

- **Rule Addition**  
  Ensures all possible rule combinations can be added successfully and validates their addition.

- **Duplicate Rule Detection**  
  Verifies that attempting to add duplicate rules results in an error.

- **Rule Retrieval**  
  Ensures that all added rule combinations can be retrieved accurately.

- **Rule Removal**  
  Ensures all rule combinations can be removed and verifies their absence afterward.

- **Rule Precedence**  
  Validates that `block` rules take precedence over `allow` rules when multiple rules exist for the same app identification (e.g., bundle ID, path, or subpath).

- **Flow Resolution Logic**  
  Validates that intercepted flows are processed correctly by the `RulesManager`, matching the right rule among all possible combinations.

These tests are fully automated and use table-driven strategies to systematically cover all combinations of:

- App identifiers: `any`, `bundleID`, `appPath`, `subpath`
- Destinations: `url`, `host`, `ip`, `port`, and all `endpoint:port` combinations

### System Tests

System-level tests simulate real-world usage by:

- Performing actual network requests using **`URLSession`**
- Triggering flow interception by the Network Extension
- Searching the log output to confirm that:
  - The correct rule was matched
  - The verdict was applied as expected
  - Metadata such as process, port, and endpoint were captured accurately

This setup ensures the integrity of the full data path — from flow capture to rule matching and verdict enforcement — under production-like conditions.

---

This layered testing strategy gives NuAppFirewall a strong foundation for correctness, regressions, and future evolution, ensuring confidence in both internal logic and external behavior.
