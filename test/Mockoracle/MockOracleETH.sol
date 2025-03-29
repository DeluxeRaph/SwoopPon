pragma solidity ^0.8.24;

contract MockOracleETH {
    function getFixedPrice() external pure returns (uint256) {
        return 200; // Fixed price for ETH
    }
}
