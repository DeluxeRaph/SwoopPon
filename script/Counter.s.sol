// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SwoopPon} from "../src/SwoopPon.sol";

contract SwoopPonScript is Script {
    SwoopPon public swoopPon;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        swoopPon = new SwoopPon();

        vm.stopBroadcast();
    }
}
