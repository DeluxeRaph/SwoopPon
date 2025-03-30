// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {SwoopPon} from "../src/SwoopPon.sol";
import {Currency} from "../lib/uniswap-hooks/lib/v4-core/src/types/Currency.sol";
import {BaseOverrideFee} from "../lib/uniswap-hooks/src/fee/BaseOverrideFee.sol";
import {PoolKey} from "../lib/uniswap-hooks/lib/v4-core/src/types/PoolKey.sol";
import {IPoolManager} from "../lib/uniswap-hooks/lib/v4-core/src/interfaces/IPoolManager.sol";
import {CurrencyLibrary, Currency} from "../lib/uniswap-hooks/lib/v4-core/src/types/Currency.sol";
import {BalanceDeltaLibrary, BalanceDelta} from "../lib/uniswap-hooks/lib/v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "../lib/uniswap-hooks/lib/v4-core/src/types/BeforeSwapDelta.sol";
import {Hooks} from "../lib/uniswap-hooks/lib/v4-core/src/libraries/Hooks.sol";
import {Deployers} from "../lib/uniswap-hooks/lib/v4-core/test/utils/Deployers.sol";
import {BaseOverrideFeeMock} from "../lib/uniswap-hooks/test/mocks/BaseOverrideFeeMock.sol";
import {IHooks} from "../lib/uniswap-hooks/lib/v4-core/src/interfaces/IHooks.sol";
import {LPFeeLibrary} from "../lib/uniswap-hooks/lib/v4-core/src/libraries/LPFeeLibrary.sol";
import {MockSwoopPon} from "test/Mock/MockSwoopPon.sol";

contract SwoopPonTest is Test, Deployers {

    using PoolIdLibrary for PoolKey;
    BaseOverrideFeeMock swoopPon;

    MockSwoopPon mockSwoopPon;

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

           // Initialize a pool
        (key, ) = initPool(
            currency0,
            currency1,
            hook,
            LPFeeLibrary.DYNAMIC_FEE_FLAG, // Set the `DYNAMIC_FEE_FLAG` in place of specifying a fixed fee
            SQRT_PRICE_1_1
        );



        




    }




    function test_swapWorks() public {
        modifyLiquidityRouter.modifyLiquidity(
            key,
            IPoolManager.ModifyLiquidityParams({
                tickLower: -60,
                tickUpper: 60,
                liquidityDelta: 100 ether,
                salt: bytes32(0)
            }),
            ZERO_BYTES
        );

          IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: -0.00001 ether,
            sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
        });

          uint256 balanceOfToken1Before = currency1.balanceOfSelf();

         swapRouter.swap(key, params, testSettings, ZERO_BYTES);

         uint256  balanceOfToken1After = currency1.balanceOfSelf();

        assertGt(balanceOfToken1After, balanceOfToken1Before);


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
