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


contract SwoopPonTest is Test, Deployers {
    BaseOverrideFeeMock swoopPon;

    MockERC20 token;

    Currency ethCurrency = Currency.wrap(address(0));
    Currency tokenCurrency;

    MockOracleETH oracle;
    MockOracleBTC oracle2;

    function setUp() public {
        deployFreshManagerAndRouters();

        // Deploy our TOKEN contract
        token = new MockERC20("SwoopPon", "Sp", 18);
        tokenCurrency = Currency.wrap(address(token));

        // Mint a bunch of TOKEN to ourselves and to address(1)
        token.mint(address(this), 1000 ether);
        token.mint(address(1), 1000 ether);

        swoopPon = BaseOverrideFeeMock(address(uint160(Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_INITIALIZE_FLAG)));
        deployCodeTo("test/mocks/BaseOverrideFeeMock.sol:BaseOverrideFeeMock", abi.encode(manager), address(swoopPon));

        deployMintAndApprove2Currencies();
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

    function test_setFee() public {
        uint24 fee = 500; // Example fee value
        swoopPon.setFee(fee); // Assuming setFee is a function in SwoopPon
        assertEq(swoopPon.fee(), fee); // Assuming fee() retrieves the current fee
    }

    // function test_swap_with_no_deposit() public {
    //     PoolSwapTest.TestSettings memory testSettings = PoolSwapTest
    //         .TestSettings({takeClaims: false, settleUsingBurn: false});

    //     IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
    //         zeroForOne: true,
    //         amountSpecified: -0.00001 ether,
    //         sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
    //     });

    //     vm.startPrank(user);
    //     manager.swap(currency0, currency1, 100, 0);
    //     vm.stopPrank();
    // }

    function test_ETHoracle() public {
        uint256 p = oracle.latestRoundData();

        assertEq(p, 200);
    }

    function test_BTCoracle() public {
        uint256 p = oracle.latestRoundData();
        assertEq(p, 100);
    }
}
