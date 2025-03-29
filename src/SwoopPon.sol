// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {BaseDynamicFee} from "../lib/uniswap-hooks/src/fee/BaseDynamicFee.sol";
import {PoolKey} from "../lib/uniswap-hooks/lib/v4-core/src/types/PoolKey.sol";
import {IPoolManager} from "../lib/uniswap-hooks/lib/v4-core/src/interfaces/IPoolManager.sol";

contract SwoopPon is BaseDynamicFee {
    constructor(IPoolManager _poolManager) BaseDynamicFee(_poolManager) {
        
    }

    uint24 public _fee = 30000;

   
    function _getFee(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        bytes calldata hookData
    ) internal view override returns (uint24) {
        return _fee;
    }

    function _beforeSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        bytes calldata hookData
    ) internal virtual override returns (bytes, BeforeSwapDelta, uint24) {
        return (this.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, _fee | LPFeeLibrary.OVERRIDE_FEE_FLAG);
    }
      
    
}
