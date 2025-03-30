// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {SwoopPon} from "../src/SwoopPon.sol";
import {Currency} from "v4-core/src/types/Currency.sol";
import {BaseOverrideFee} from "../lib/uniswap-hooks/src/fee/BaseOverrideFee.sol";
import {PoolKey} from "../lib/uniswap-hooks/lib/v4-core/src/types/PoolKey.sol";
import {IPoolManager} from "../lib/uniswap-hooks/lib/v4-core/src/interfaces/IPoolManager.sol";
import {CurrencyLibrary, Currency} from "../lib/uniswap-hooks/lib/v4-core/src/types/Currency.sol";
import {BalanceDeltaLibrary, BalanceDelta} from "../lib/uniswap-hooks/lib/v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "../lib/uniswap-hooks/lib/v4-core/src/types/BeforeSwapDelta.sol";
import {Hooks} from "../lib/uniswap-hooks/lib/v4-core/src/libraries/Hooks.sol";
import {Deployers} from "v4-core/test/utils/Deployers.sol";
import {BaseOverrideFeeMock} from "../lib/uniswap-hooks/test/mocks/BaseOverrideFeeMock.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {LPFeeLibrary} from "v4-core/src/libraries/LPFeeLibrary.sol";
import {MockOracleBTC} from "test/Mockoracle/MockOracleBTC.sol";
import {MockOracleETH} from "test/Mockoracle/MockOracleETH.sol";

contract SwoopPonTest is Test, Deployers {
    BaseOverrideFeeMock swoopPon;

     MockOracleETH oracle;

     MockOracleBTC oracle2;

    function setUp() public {
        deployFreshManagerAndRouters();



        swoopPon = BaseOverrideFeeMock(address(uint160(Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_INITIALIZE_FLAG)));
        deployCodeTo(
            "test/mocks/BaseOverrideFeeMock.sol:BaseOverrideFeeMock", abi.encode(manager), address(swoopPon)
        );

        deployMintAndApprove2Currencies();
        (key,) = initPoolAndAddLiquidity(
            currency0, currency1, IHooks(address(swoopPon)), LPFeeLibrary.DYNAMIC_FEE_FLAG, SQRT_PRICE_1_1
        );

        vm.label(Currency.unwrap(currency0), "currency0");
        vm.label(Currency.unwrap(currency1), "currency1");


          oracle = new MockOracleETH();

          oracle2 = new MockOracleBTC();





    }

    function test_setFee() public {
        uint24 fee = 500; // Example fee value
        swoopPon.setFee(fee); // Assuming setFee is a function in SwoopPon
        assertEq(swoopPon.fee(), fee); // Assuming fee() retrieves the current fee
    }



    function test_ETHoracle () public {
       uint256 p = oracle.latestRoundData();

        assert p = 200;


    }


    function test_BTCoracle() public {
        uint p = oracle.latestRoundData();
        assert p = 100;
    }
}
