pragma solidity ^0.8.24;

contract MockOracleETH {
    function latestRoundData() external pure returns (uint256) {
        return 200; // Fixed price for ETH
    }
}
