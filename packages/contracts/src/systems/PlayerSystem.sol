// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { addressToEntityKey } from "../addressToEntityKey.sol";
import { positionToEntityKey } from "../positionToEntityKey.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { Player, Position, GridConfig } from "../codegen/Tables.sol";

contract PlayerSystem is System {
    function click(uint32 x, uint32 y) public {
    // bytes32 player = addressToEntityKey(address(_msgSender()));
    // require(!Player.get(player), "already spawned");

    // // Constrain position to map size, wrapping around if necessary
    // (uint32 width, uint32 height, ) = MapConfig.get();
    // x = x + (width % width);
    // y = y + (height % height);

    // Player.set(player, true);
    // Position.set(player, x, y);
  }
}