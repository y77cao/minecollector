// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Position, GridConfig, IsMine, Disabled} from "../src/codegen/Tables.sol";
import {IWorld} from "../src/codegen/world/IWorld.sol";
import {positionToEntityKey} from "../src/positionToEntityKey.sol";

contract PostDeploy is Script {
    function run(address worldAddress) external {
        // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        IWorld world = IWorld(worldAddress);
        console.log("Deployed world: ", worldAddress);

        // Start broadcasting transactions from the deployer account
        vm.startBroadcast(deployerPrivateKey);

        vm.stopBroadcast();
    }
}
