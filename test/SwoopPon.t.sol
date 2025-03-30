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
import {MockOracleBTC} from "test/mocks/MockOracleBTC.sol";
import {MockOracleETH} from "test/mocks/MockOracleETH.sol";
import {PoolSwapTest} from "../lib/uniswap-hooks/lib/v4-core/src/test/PoolSwapTest.sol";
import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";
import {TickMath} from "../lib/uniswap-hooks/lib/v4-core/src/libraries/TickMath.sol";

contract SwoopPonTest is Test, Deployers {
    SwoopPon swoopPon;

    MockERC20 token;

    Currency ethCurrency = Currency.wrap(address(0));
    Currency tokenCurrency;

    MockOracleETH oracle;
    MockOracleBTC oracle2;

    address swapper;

    function setUp() public {
        deployFreshManagerAndRouters();

        // Deploy our TOKEN contract
        token = new MockERC20("SwoopPon", "SP", 18);
        tokenCurrency = Currency.wrap(address(token));

        swapper = address(1);

        // Mint a bunch of TOKEN to ourselves and to address(1)
        token.mint(address(this), 1000 ether);
        token.mint(swapper, 1000 ether);

        deployMintAndApprove2Currencies();

        // Deploy our hook with the proper flags
        address hookAddress = address(
            uint160(
                Hooks.AFTER_INITIALIZE_FLAG |
                    Hooks.BEFORE_SWAP_FLAG |
                    Hooks.AFTER_SWAP_FLAG
            )
        );

        deployCodeTo("SwoopPon", abi.encode(manager), hookAddress);

        (key,) = initPoolAndAddLiquidity(
            currency0, currency1, IHooks(address(swoopPon)), LPFeeLibrary.DYNAMIC_FEE_FLAG, SQRT_PRICE_1_1
        );

        vm.label(Currency.unwrap(currency0), "currency0");
        vm.label(Currency.unwrap(currency1), "currency1");

        // Initialize a pool
        (key, ) = initPool(
            ethCurrency, // Currency 0 = ETH
            tokenCurrency, // Currency 1 = TOKEN
            swoopPon, // Hook Contract
            LPFeeLibrary.DYNAMIC_FEE_FLAG, // Swap Fees
            SQRT_PRICE_1_1 // Initial Sqrt(P) value = 1
        );

        oracle = new MockOracleETH();
        oracle2 = new MockOracleBTC();
    }

    function test_swap_after_deposit() public {
        PoolSwapTest.CallbackData memory callbackData = PoolSwapTest.CallbackData({
            sender: swapper,
            testSettings: PoolSwapTest.TestSettings({takeClaims: false, settleUsingBurn: false}),
            key: key,
            params: IPoolManager.SwapParams({zeroForOne: true, amountSpecified: -0.00001 ether, sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1}),
            hookData: ZERO_BYTES
        });

        PoolSwapTest.TestSettings memory testSettings = PoolSwapTest
            .TestSettings({takeClaims: false, settleUsingBurn: false});

        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: 1 ether, //  swapper wants to swap 0.00001 ETH
            sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
        });

        swapRouter.swap(key, params, testSettings, ZERO_BYTES);
    }

    function test_ETHoracle() public {
        uint256 p = oracle.latestRoundData();

        assertEq(p, 200);
    }

    function test_BTCoracle() public {
        uint256 p = oracle2.latestRoundData();
        assertEq(p, 100);
    }
}
