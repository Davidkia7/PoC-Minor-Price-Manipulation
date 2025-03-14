# PoC-Minor-Price-Manipulation

This repository contains a Proof-of-Concept (PoC) demonstrating a price manipulation attack on low liquidity token pools. It highlights vulnerabilities present in automated market makers (AMMs) like PancakeSwap or Uniswap under specific conditions.

---

## PoC Execution Steps

### Preparation
1. **Deploy the Token Contract:**
   - Deploy your token contract (e.g., `Token`) on a testnet such as BSC Testnet or Sepolia.

2. **Add Liquidity:**
   - Add liquidity for the token-WETH pair on PancakeSwap/Uniswap.
   - Example: Add 1000 tokens and 1 ETH for easy manipulation (low liquidity).

3. **Deploy the `PriceManipulationAttack` Contract:**
   - Use the following parameters:
     - `_targetToken`: Address of your token contract.
     - `_uniswapRouter`: Address of the PancakeSwap/Uniswap router (e.g., `0x10ED43C718714eb63d5aA57B78B54704E256024E` for BSC).
     - `_uniswapPair`: Address of the token-WETH pair created during the token contract deployment.

---

### Attacker Preparation
1. **Transfer Tokens:**
   - Send some tokens to the attacker contract (e.g., 10% of `lpThreshold`).

2. **Fund the Contract:**
   - Send BNB (or ETH) to the attacker contract for price manipulation (e.g., 1 BNB).

---

### Attack Execution
1. **Call the `attack` Function:**
   - Parameters:
     - `thresholdAmount`: Token amount close to `lpThreshold` (e.g., 90% of `lpThreshold`).
     - `manipulateAmount`: Amount of BNB/ETH to manipulate the price (e.g., 0.5 BNB).

2. **Attack Steps:**
   - **ManipulatePriceUp:**
     - Buy tokens with BNB to increase the price in the pool.
   - **TriggerSwapInTarget:**
     - Sell a small token amount (e.g., 1 token) to trigger `swapAndLiquify` in the target contract. This swaps tokens to BNB at a high price.
   - **UnwindManipulation:**
     - Sell the tokens back to lower the price and take profit in BNB.

---

## Result
1. **Token Contract:**
   - Loses value as swaps are executed at unreasonable prices.
2. **Attacker:**
   - Gains profit by exploiting price differences.

---

## Simulation Example
### Initial Setup
- **lpThreshold:** 1000 tokens.
- **Pool:** 1000 tokens + 1 BNB (initial price = 1 token = 0.001 BNB).
- **Attacker:** Holds 900 tokens + 1 BNB.

### Attack Steps
1. Attacker buys 500 tokens for 0.5 BNB → Price rises to 1 token = 0.003 BNB (due to low liquidity).
2. Attacker sells 1 token → `lpCurrentAmount` reaches 1000, triggering `swapAndLiquify`.
   - Contract swaps 500 tokens for ~0.15 BNB.
3. Attacker sells 1400 tokens → Gains ~1.4 BNB.

### Profit
- **Attacker:**
  - Starts with 1 BNB → Ends with 1.4 BNB (Profit = 0.4 BNB).
- **Contract:**
  - Loses BNB due to swaps at inflated prices.

---

## Important Notes
1. **Low Liquidity:**
   - This attack is more effective on pools with low liquidity, commonly found in new token pairs.
   
2. **Flash Loans:**
   - An attacker could use a flash loan to scale the manipulation without requiring large initial capital.

3. **Testnet Deployment:**
   - Perform these tests on a testnet to avoid financial risk.

---

## Disclaimer
This repository is for educational purposes only. The goal is to highlight vulnerabilities in AMMs and encourage improved security measures. Misuse of this knowledge is strictly discouraged.
