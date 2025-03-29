// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {BaseDynamicAfterFee} from "../lib/uniswap-hooks/src/fee/BaseDynamicAfterFee.sol";
import {PoolKey} from "../lib/uniswap-hooks/lib/v4-core/src/types/PoolKey.sol";
import {IPoolManager} from "../lib/uniswap-hooks/lib/v4-core/src/interfaces/IPoolManager.sol";
import {CurrencyLibrary, Currency} from "../lib/uniswap-hooks/lib/v4-core/src/types/Currency.sol";
import {BalanceDeltaLibrary, BalanceDelta} from "../lib/uniswap-hooks/lib/v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "../lib/uniswap-hooks/lib/v4-core/src/types/BeforeSwapDelta.sol";


contract SwoopPon is BaseDynamicAfterFee {
    using CurrencyLibrary for Currency;
    using BalanceDeltaLibrary for BalanceDelta;
    constructor(IPoolManager _poolManager) BaseDynamicAfterFee(_poolManager) {
        
    }

    uint24 public _fee = 30000;

    // Function to dynamically change the LP fee
    function setFee(uint24 newFee) external {
        _fee = newFee;
    }

    function _beforeSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        bytes calldata hookData
    ) internal virtual override returns (bytes4, BeforeSwapDelta, uint24) {
        // Your logic here
        return (this.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
    }

    function _afterSwap(
        address,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        BalanceDelta delta,
        bytes calldata hookData
    ) internal virtual override returns (bytes4, int128) {
        // Your logic here
        return (this.afterSwap.selector, 0);
    }

    function _getTargetOutput(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        bytes calldata hookData
    ) internal virtual override returns (uint256 targetOutput, bool applyTargetOutput) {
        // For now, we're not modifying the output, so we return false
        return (0, false);
    }

    function _afterSwapHandler(
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        BalanceDelta delta,
        uint256 targetOutput,
        uint256 feeAmount
    ) internal virtual override {
        // Here you can implement your token minting logic
        // For example:
        // rewardToken.mint(params.recipient, 1 ether);
    }
      
    
}
