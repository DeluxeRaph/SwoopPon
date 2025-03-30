// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {BaseOverrideFee} from "../lib/uniswap-hooks/src/fee/BaseOverrideFee.sol";
import {PoolKey} from "../lib/uniswap-hooks/lib/v4-core/src/types/PoolKey.sol";
import {IPoolManager} from "../lib/uniswap-hooks/lib/v4-core/src/interfaces/IPoolManager.sol";
import {CurrencyLibrary, Currency} from "../lib/uniswap-hooks/lib/v4-core/src/types/Currency.sol";
import {BalanceDeltaLibrary, BalanceDelta} from "../lib/uniswap-hooks/lib/v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "../lib/uniswap-hooks/lib/v4-core/src/types/BeforeSwapDelta.sol";
import {AggregatorV3Interface} from "../lib/foundry-chainlink-toolkit/src/interfaces/feeds/AggregatorV3Interface.sol";
import {CalcLib} from "src/lib/CalcLib.sol";

contract SwoopPon is BaseOverrideFee {
    using CurrencyLibrary for Currency;
    using BalanceDeltaLibrary for BalanceDelta;

    AggregatorV3Interface internal dataFeedETH;
    AggregatorV3Interface internal dataFeed2BTC;

    uint256 poolfee;

    
    constructor(IPoolManager _poolManager) BaseOverrideFee(_poolManager) {

        dataFeed = AggregatorV3Interface(
            0xd9c93081210dFc33326B2af4C2c11848095E6a9a
        );

        dataFeed2 = AggregatorV3Interface(
            0x2AF69319fACBbc1ad77d56538B35c1f9FFe86dEF
        );
        
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
        uint24 fee = _getFee(sender, key, params, hookData);

    //We get the oracle 

        uint256 ETHprice =  getChainlinkDataFeedLatestAnswerETH();

        uint256 BTCprice = getChainlinkDataFeedLatestAnswerBTC();


        


  



        return (this.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, fee);
    }

    function _afterSwap(
        address,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        BalanceDelta delta,
        bytes calldata hookData
    ) internal virtual override returns (bytes4, int128) {
        // Your logic here
        



          //We get the oracle 

        uint256 ETHprice =  getChainlinkDataFeedLatestAnswerETH();

        uint256 BTCprice = getChainlinkDataFeedLatestAnswerBTC();


          //this logic is to calculate swoopon cost 

          
          //We use the swapParams to determine which oracle to use 

        if (params.amountspecified > 0){

        uintETHSwoopReward = CalcLib.calculateTI(ETHprice * amountspecified);

        } else if (params.amountspecified < 0){

        uintBTCSwoopReward = CalcLib.calculateTI(BTCprice * amountspecified);

        } else {

            revert("Invalid amount specified");
        }

        //Here we mint the swoopon reward for the user 

        


        // Mint tokens to 
        return (this.afterSwap.selector, 0);
    }

    function _getFee(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        bytes calldata hookData
    ) internal virtual override returns (uint24) {
        // Return the current fee

        return _fee;
    }

    //The ETH/USD chainlink oracle price on Unichain 
   function getChainlinkDataFeedLatestAnswerETH() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeedETH.latestRoundData();
        return answer;
    }


        //The BTC/USD chainlink oracle price on Unichain
       function getChainlinkDataFeedLatestAnswerBTC() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed2BTC.latestRoundData();
        return answer;
    }


    function getpoolstate(PoolKey calldata key) external view returns (uint160 sqrtPriceX96, int24 tick,
     uint24 protocolFee, uint24 lpFee){


        (,,,lpFee) = _poolManager.getPoolState(key.toId());


        uint24 poolFee = lpFee;

        return (sqrtPriceX96, tick, poolFee, lpFee);
     }

    
}
