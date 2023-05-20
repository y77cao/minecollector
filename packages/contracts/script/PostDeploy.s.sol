// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { CellType } from "../src/codegen/Types.sol";
import { Position, GridConfig, IsMine } from "../src/codegen/Tables.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { positionToEntityKey } from "../src/positionToEntityKey.sol";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    IWorld world = IWorld(worldAddress);
    console.log("Deployed world: ", worldAddress);

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);


    CellType O = CellType.None;
    CellType E = CellType.Empty;
    CellType B = CellType.Mine;

    CellType[20][20] memory grid = [
      [O, O, O, O, O, O, E, O, O, O, O, O, O, O, O, O, O, O, O, O],
      [O, O, E, O, E, E, E, E, E, O, O, O, O, B, O, O, O, O, O, O],
      [O, E, E, E, E, B, E, E, E, E, E, E, E, E, E, E, E, O, O, O],
      [O, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, O, O],
      [O, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, O, O],
      [O, E, E, E, E, E, E, E, E, E, B, E, E, E, E, E, E, O, O, O],
      [O, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, O, O, O],
      [O, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, O, O, O],
      [O, E, E, E, B, E, E, E, E, E, E, E, E, E, E, E, E, O, O, O],
      [O, E, E, E, E, E, E, B, E, E, E, E, E, E, E, E, E, O, O, O],
      [O, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, O, O, O],
      [O, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, O, O, O],
      [O, E, E, E, E, E, E, E, E, E, B, E, E, E, E, E, E, O, O, O],
      [O, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, O, O, O],
      [O, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, O, O, O],
      [O, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, O, O, O],
      [O, E, E, B, E, E, E, E, E, E, E, E, E, B, E, E, E, O, O, O],
      [O, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, O, O],
      [O, O, O, E, E, E, E, O, O, O, O, E, O, O, O, E, O, O, O, O],
      [O, O, O, O, O, E, O, O, O, O, O, O, O, O, O, O, O, O, O, O]
    ];

    uint32 height = uint32(grid.length);
    uint32 width = uint32(grid[0].length);
    bytes memory gridContent = new bytes(width * height);

    for (uint32 y = 0; y < height; y++) {
      for (uint32 x = 0; x < width; x++) {
        CellType cellType = grid[y][x];
        if (cellType == CellType.None) continue;

        gridContent[(y * width) + x] = bytes1(uint8(cellType));

        bytes32 entity = positionToEntityKey(x, y);
        if (cellType == CellType.Empty) {
          Position.set(world, entity, x, y);
        } else if (cellType == CellType.Mine) {
          IsMine.set(world, entity, true);
          Position.set(world, entity, x, y);
        }
      }
    }

    GridConfig.set(world, width, height, gridContent);

    vm.stopBroadcast();
  }
}
