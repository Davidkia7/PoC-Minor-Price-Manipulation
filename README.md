# PoC-Minor-Price-Manipulation
PoC Execution Steps
Preparation:
Deploy your token contract (Token) on a testnet (e.g. BSC Testnet or Sepolia).
Add liquidity to the token-WETH pair on PancakeSwap/Uniswap with a small amount (e.g. 1000 tokens and 1 ETH) for easy manipulation.
Deploy the PriceManipulationAttack contract with the following parameters:
_targetToken: Your token contract address.
_uniswapRouter: PancakeSwap/Uniswap router address (e.g. 0x10ED43C718714eb63d5aA57B78B54704E256024E for BSC).
_uniswapPair: The address of the token-WETH pair created in the token contract constructor.
Attacker Preparation:
Transfer some tokens to the attacker contract (e.g. 10% of lpThreshold).
Send BNB to the attacker contract for price manipulation (e.g. 1 BNB).
Attack Execution:
Call the attack function with:
thresholdAmount: The amount of tokens close to lpThreshold (e.g. 90% of lpThreshold).
manipulateAmount: The amount of BNB to manipulate the price (e.g. 0.5 BNB).
Attack steps:
ManipulatePriceUp: The attacker buys tokens with BNB to increase the price in the pool.
TriggerSwapInTarget: The attacker sells a small token (1 token) to trigger swapAndLiquify in the target contract, which swaps the tokens to BNB at a high price.
UnwindManipulation: The attacker sells the tokens back to decrease the price and takes profit in BNB.
Result:
The token contract loses BNB because the swap is executed at an unreasonable price.
The attacker gains additional BNB from the price difference.
Simulation Example
Initial Setup:
lpThreshold = 1000 tokens.
Pool: 1000 tokens + 1 BNB (initial price: 1 token = 0.001 BNB).
Attacker has 900 tokens and 1 BNB.
Attack:
Attacker buys 500 tokens for 0.5 BNB → Price rises to 1 token = 0.003 BNB (due to low liquidity).
Attacker sells 1 token → lpCurrentAmount reaches 1000, triggering swapAndLiquify.
Contract swaps 500 tokens for ~0.15 BNB (high price).
Attacker sells 1400 tokens back, gaining ~1.4 BNB.
Profit:
Attacker: Starts with 1 BNB → Finishes with 1.4 BNB (profit of 0.4 BNB).
Contract: Loses value due to swap at bad price.
Important Notes
Low Liquidity: This attack is more effective on pools with low liquidity, which is often the case with new tokens.
Flash Loan: In a real attack, an attacker could use a flash loan to scale the manipulation without a large capital outlay.
Testnet: Test this PoC on a testnet to see its impact without financial risk.
