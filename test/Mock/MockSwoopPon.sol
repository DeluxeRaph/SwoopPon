// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SwoopPon} from "../src/SwoopPon.sol";

import {MockOracleETH} from "./MockOracleETH.sol";
import {MockOracleBTC} from "./MockOracleBTC.sol";



contract MockSwoopPon is SwoopPon {
    MockOracleETH internal dataFeedETH;
    MockOracleBTC internal dataFeedBTC;

    constructor(IPoolManager _poolManager) SwoopPon(_poolManager) {
        dataFeedETH = new MockOracleETH();
        dataFeedBTC = new MockOracleBTC();
    }


  function getChainlinkDataFeedLatestAnswerETH() 
        public
        view
        override
        returns (uint256)
    {
        return 200; // Mocked value for ETH
    }

    function getChainlinkDataFeedLatestAnswerBTC()
        public
        view
        override
        returns (uint256)
    {
        return 100; // Mocked value for BTC
    }
} 