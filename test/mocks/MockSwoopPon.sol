// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SwoopPon} from "../../src/SwoopPon.sol";

import {MockOracleETH} from "./MockOracleETH.sol";
import {MockOracleBTC} from "./MockOracleBTC.sol";
import {IPoolManager} from "../../lib/uniswap-hooks/lib/v4-core/src/interfaces/IPoolManager.sol";
import {StateLibrary} from "../../lib/uniswap-hooks/lib/v4-core/src/libraries/StateLibrary.sol";
import {TokenVault} from "../../src/TokenVault.sol";







contract MockSwoopPon is SwoopPon {


    MockOracleETH internal dataFeedETH;
    MockOracleBTC internal dataFeedBTC;

    constructor(
       
    IPoolManager _poolManager,
    TokenVault _vault,
    string memory _name,
    string memory _symbol  
    ) SwoopPon(_poolManager, _vault, _name, _symbol) {
    dataFeedETH = new MockOracleETH();
    dataFeedBTC = new MockOracleBTC();
    
    }


  function getChainlinkDataFeedLatestAnswerETH() 
        public
        virtual
        override
        returns (int256)
    {
        return 200; // Mocked value for ETH
    }

    function getChainlinkDataFeedLatestAnswerBTC()
        public
        virtual
        override
        returns (int256)
    {
        return 100; // Mocked value for BTC
    }



    
} 