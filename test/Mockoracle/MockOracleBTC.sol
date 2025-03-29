


pragma solidity ^0.8.24;

contract MockOracleBTC {
    function getFixedPrice() external pure returns (uint256) {
        return 100;
    }
}
