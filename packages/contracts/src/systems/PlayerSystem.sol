// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { addressToEntityKey } from "../addressToEntityKey.sol";
import { positionToEntityKey } from "../positionToEntityKey.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { Player, Position, GridConfig, Disabled, IsMine } from "../codegen/Tables.sol";

contract PlayerSystem is System {
    function click(uint32 x, uint32 y) public {
    bytes32 player = addressToEntityKey(address(_msgSender()));
    require(Disabled.get(player) == false, "player disabled");
    // TODO check joined

    (uint32 width, uint32 height, ) = GridConfig.get();
    require(x >= 0 && x < width, "x out of bounds");
    require(y >= 0 && y < height, "y out of bounds");

    bytes32 position = positionToEntityKey(x, y);
    require(!Disabled.get(position), "position clicked");

    bool isMine = IsMine.get(position);

    if (isMine) {
      lose(player);
    } else {
      expand(player, x, y, width, height);
    }
  }

  function mark(uint32 x, uint32 y) public {

  }

  function purchase() public {

  }

  function lose(bytes32 player) public {
    Disabled.set(player, true);
  }

  function expand(bytes32 player, uint32 x, uint32 y, uint32 width, uint32 height) public {
    bytes32 position = positionToEntityKey(x, y);
    uint32 count = countMines(int32(x), int32(y), int32(width), int32(height));
    Disabled.set(position, true);

    if (count == 0) {
      int32[8] memory dxs = [int32(1), 1, 0, -1, -1, -1, 0, 1];
      int32[8] memory dys = [int32(0), 1, 1, 1, 0, -1, -1, -1];

      for (uint256 i = 0; i < 8; i++) {
        int32 nx = int32(x) + dxs[i];
        int32 ny = int32(y) + dys[i];
        if (nx >= 0 && nx < int32(width) && ny >= 0 && ny < int32(height)) {
          bytes32 nposition = positionToEntityKey(uint32(nx), uint32(ny));
          if (!Disabled.get(nposition)) {
            expand(player, uint32(nx), uint32(ny), width, height);
          }
        }
      }
    }
  }

  function countMines(int32 x, int32 y, int32 width, int32 height) public view returns (uint32) {
    int32[8] memory dxs = [int32(1), 1, 0, -1, -1, -1, 0, 1];
    int32[8] memory dys = [int32(0), 1, 1, 1, 0, -1, -1, -1];

    uint32 count = 0;
    for (uint256 i = 0; i < 8; i++) {
      int32 nx = x + dxs[i];
      int32 ny = y + dys[i];
      if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
        bytes32 nposition = positionToEntityKey(uint32(nx), uint32(ny));
        if (IsMine.get(nposition)) {
          count++;
        }
      }
    }
    return count;
  }
}