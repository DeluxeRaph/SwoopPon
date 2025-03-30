


pragma solidity ^0.8.24;

contract MockOracleBTC {
    function latestRoundData() external pure returns (uint256) {
        return 100;
    }
}
