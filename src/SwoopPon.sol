// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {BaseOverrideFee} from "../lib/uniswap-hooks/src/fee/BaseOverrideFee.sol";
import {PoolKey} from "../lib/uniswap-hooks/lib/v4-core/src/types/PoolKey.sol";
import {IPoolManager} from "../lib/uniswap-hooks/lib/v4-core/src/interfaces/IPoolManager.sol";
import {CurrencyLibrary, Currency} from "../lib/uniswap-hooks/lib/v4-core/src/types/Currency.sol";
import {BalanceDeltaLibrary, BalanceDelta} from "../lib/uniswap-hooks/lib/v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "../lib/uniswap-hooks/lib/v4-core/src/types/BeforeSwapDelta.sol";
import {AggregatorV3Interface} from "../lib/foundry-chainlink-toolkit/src/interfaces/feeds/AggregatorV3Interface.sol";
import {PoolId, PoolIdLibrary} from "../lib/uniswap-hooks/lib/v4-core/src/types/PoolId.sol";
import {StateLibrary} from "../lib/uniswap-hooks/lib/v4-core/src/libraries/StateLibrary.sol";
import {TokenVault} from "./TokenVault.sol";
import {ERC20} from "solmate/src/tokens/ERC20.sol";
import {LPFeeLibrary} from "lib/uniswap-hooks/lib/v4-core/src/libraries/LPFeeLibrary.sol";



contract SwoopPon is BaseOverrideFee, ERC20 {
    using CurrencyLibrary for Currency;
    using BalanceDeltaLibrary for BalanceDelta;
    using StateLibrary for IPoolManager;

    TokenVault public vault;

    AggregatorV3Interface internal dataFeed;
    AggregatorV3Interface internal dataFeed2;

    uint256 poolfee;

    constructor(IPoolManager _poolManager, 
        TokenVault _vault,
        string memory _name,
        string memory _symbol) BaseOverrideFee(_poolManager) ERC20(_name, _symbol, 18) {
        vault = TokenVault(_vault);

        dataFeed = AggregatorV3Interface(0xd9c93081210dFc33326B2af4C2c11848095E6a9a);
        dataFeed2 = AggregatorV3Interface(0x2AF69319fACBbc1ad77d56538B35c1f9FFe86dEF);
    }

    uint24 public _fee = 30000;


        IPoolManager manager;

    function setManager(IPoolManager _manager) external {
        manager = _manager;
    }

    // Function to dynamically change the LP fee
    //Changed from internal to external
    function setFee(uint24 newFee) external {
        _fee = newFee;
    }

    function _beforeSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        bytes calldata hookData
    ) internal virtual override returns (bytes4, BeforeSwapDelta, uint24) {
        // did swapper deposit into dev wallet
      //  uint24 lpFee = _getFee(sender, key, params, hookData);
        bool paid = false;
      //  paid = vault.chargeUser(sender);

        if (paid == false) { 
        
            this.setFee(0);
        }
        return (this.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, _fee | LPFeeLibrary.OVERRIDE_FEE_FLAG);
    }



    function _afterSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        BalanceDelta delta,
        bytes calldata hookData
    ) internal virtual override returns (bytes4, int128) {
        // if fee is 0, set it to 30000
        if (_fee == 0) {
            this.setFee(30000);
        }
        
        // mint 1 token to sender
        _mint(sender, 1);        
        return (this.afterSwap.selector, 0);
    }

    function _getFee(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        bytes calldata hookData
    ) internal virtual override returns (uint24) {
        // Return the current fee
        uint24 lpFee;
        (,,, lpFee) = poolManager.getSlot0(key.toId());
        return lpFee;
    }

    function getChainlinkDataFeedLatestAnswerETH() virtual public returns (int256) {
        // prettier-ignore
        (
            /* uint80 roundID */
            ,
            int256 answer,
            /*uint startedAt*/
            ,
            /*uint timeStamp*/
            ,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    function getChainlinkDataFeedLatestAnswerBTC() virtual public returns (int256) {
        // prettier-ignore
        (
            /* uint80 roundID */
            ,
            int256 answer,
            /*uint startedAt*/
            ,
            /*uint timeStamp*/
            ,
            /*uint80 answeredInRound*/
        ) = dataFeed2.latestRoundData();
        return answer;
    }
}
