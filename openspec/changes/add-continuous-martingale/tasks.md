# Tasks: Continuous Martingale Implementation

## 1. Configuration Parameters
- [x] 1.1 Add `EnableContinuousMartingale` input parameter (bool, default: false)
- [x] 1.2 Add `MartingaleMultiplier` input parameter (double, default: 1.5)
- [x] 1.3 Update OnInit() to log new martingale configuration

## 2. State Tracking
- [x] 2.1 Add `lastBuyLotSize` global variable (double)
- [x] 2.2 Add `lastSellLotSize` global variable (double)
- [x] 2.3 Add `buyMartingaleLevel` and `sellMartingaleLevel` variables
- [x] 2.4 Update `ResetGridState()` to reset lot size tracking

## 3. Lot Calculation Logic
- [x] 3.1 Create `GetLastLotSize(string direction)` function
- [x] 3.2 Create `UpdateLastLotSize(string direction, double lot)` function
- [x] 3.3 Modify `CalculateVolume()` to support continuous martingale mode
- [x] 3.4 Add validation to prevent lots exceeding broker maximum

## 4. Order Execution Updates
- [x] 4.1 Update `ExecuteGridOrder()` to track lot size after execution
- [x] 4.2 Update `ExecuteGridOrderWithMultiplier()` for continuous martingale
- [x] 4.3 Add logging for martingale progression (1x → 1.5x → 2.25x...)
- [x] 4.4 Handle direction-specific lot tracking (buy vs sell)
- [x] 4.5 Add hedge mode martingale reset for new direction

## 5. Hedge Mode Integration
- [x] 5.1 Ensure hedge mode uses continuous martingale per direction
- [x] 5.2 Track separate lot sizes for old vs new direction during hedge
- [x] 5.3 Update hedge exit logic to reset lot tracking (via ResetGridState)

## 6. Testing & Validation
- [x] 6.1 Verify lot progression: 0.01 → 0.015 → 0.0225 → 0.03375...
- [x] 6.2 Test with EnableContinuousMartingale=false (backwards compatibility)
- [x] 6.3 Test signal reversal with proper lot reset
- [x] 6.4 Verify broker max lot protection

## 7. Documentation
- [x] 7.1 Update input parameter descriptions
- [x] 7.2 Add comments explaining continuous martingale logic
- [x] 7.3 Log martingale state on heartbeat
