# Advanced nominator pool contract
The contract allows node owner willing to become a validator lend coins from so-called nominators in exchange for part of the income safely for both node owner and nominators (aka stakers). Reward distribution and other financial accounting are done completely on-chain.

## Interaction with the pool
Almost all of the interaction with the pool is done via internal messages. Some requests are allowed to be done only by node owner, and the owner is authorized by checking message sender address.

## Odd and even rounds
Note that the validator is expected to partipate in every second elections (that is, only in even or only in odd elections, unless he skips some). It's necessary for correct reward distribution and greatly simplifies contract logic.

To use the node at every round, validator may deploy two pool contracts.

## Contract states
At any given time pool is in one of the following states:
### in_limbo
Stakers can loosely make deposits or withdraw their stakes. Node owner is expected to collect postponed (aka pending) deposits and process postponed withdrawal requests, and then put the pool into the `elections` state by calling special pool method. Also node owner can withdraw some of the validator profit or even essentialy freeze the pool by withdrawing large portion of the validator balance.

At any other state deposit or withdrawal request isn't processed immediately, but rather is postponed to be processed later, when the pool is returned into the `in_limbo` state.

### elections
At that state node owner can (and should) send one or several partipication requests to the elector in order to became a validator. The pool is waiting for elector responses and recalculates the `total_sent` stake to the elector. Pool (virtually) switches to the next state after elections end and all of the messages sent to elector got their responses (by calling `~update_state` function in appropriate places, cf. `get_state` and `get_state_after_update` get-methods). Number of messages sent to elector is restricted by a constant (to prevent loosing all of the pool balance on fwd fees).

### stake_held
It's the state pool switches into after elections. At that state node owner can _at any time_ call request-stake pool method. It's expected that honest node owner would call this method when the stake is unfrozen (due to some corner cases, it's almost impossible to check this in the pool code), including the case when he hadn't won the elections. However, there is a protecion from dishonest node owner.

### stake_requested
Stake was requested by node owner request and pool is waiting for elector response.
On response pool calculates round profit (by subtracting `total_sent` from `msg_value`). If the profit is positive, pool simply distributes the reward. If the profit is negative, but can be compensated by validator balance, then pool substracts the loss from validator balance. In both cases pool switches to the `in_limbo` state. If the loss is large, then pool goes to `wait_for_unfreeze` state.

### wait_for_unfreeze
At that state anyone can request stake from elector, but after some sufficiently long time has passed. Node owner can't request stake before this time. On stake request pool goes into `finally_requested` state.

### finally_requested
It's a state analogous to `stake_requested` state, but at that state even large loss is accepted.

## Shares and reward distribution
When a staker makes a deposit, the amount of coins isn't just stored in a hashmap. The staker rather receives so-called shares tokens corresponding to the current share price. It's not a real tokens however (mainly because currently there is no standard for tokens in TON). When she wants to withdraw her balance, she asks pool to convert shares to coins corresponding to the current price. The price is calculated as `total_staked / total_shares` nanocoins per share (if there is no shares yet, it's `1/256` nanocoin per share). When pool distributes a reward, it simply increases `total_staked` by stakers profit part.

## Text interface
Pool is designed to work with binary messages, but text messages are also supported. If pool receives a text message, it parses the text as hex-represenation of corresponding binary message, but assuming `query_id` equal to zero. Also the first 4 hex-digits of the text is expected to be the represenation of 16 lower bits of the `cell_hash` of the binary message. In this way, the user is protected from typos.

## Elector proxy
Elector accepts messages only from addresses reside in masterchain, but it's better to store large map of user balances in the basechain. So the pool is actually resides in basechain and sends messages to a dedicated proxy contract, which resends them to the elector and resends elector responses to the pool.
