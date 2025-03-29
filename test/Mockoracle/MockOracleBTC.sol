


pragma solidity ^0.8.24;

contract MockOracleBTC {
    function getFixed() external pure returns (uint256) {
        return 100;
    }
}
