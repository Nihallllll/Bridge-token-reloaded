// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/mock.sol";

contract DeployMockToken is Script {
    function run() external {
        vm.startBroadcast();

        MockToken token = new MockToken();
        console.log("MockToken deployed at:", address(token));

        vm.stopBroadcast();
    }
}
