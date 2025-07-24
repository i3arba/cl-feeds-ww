# Invariants

1. Worker can't receive a different amount of ETH than it's due to him. Which means, he cannot receive more or less than the result of:

```
    salary = (((unpaidWorkTime * 1e18) * rateHours)/3600) / lastETH/USD price
```

2. User shouldn't be able to start working after the end of the contract

3. The contract should'not be terminate while there is salary pendent to be paid

# Properties

1. Contract balance should only decrease if transfer amount is called

2. A new contract rate can only be set after everything is due was paid.

3. Worker cannot start a new work session while the previous is still valid.