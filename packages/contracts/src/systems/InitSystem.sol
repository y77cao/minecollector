// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {console} from "forge-std/console.sol";
import {System} from "@latticexyz/world/src/System.sol";
import {addressToEntityKey} from "../addressToEntityKey.sol";
import {positionToEntityKey} from "../positionToEntityKey.sol";
import {CellType} from "../codegen/Types.sol";
import {getKeysWithValue} from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import {
    Position,
    GridConfig,
    Disabled,
    IsMine,
    OwnedBy,
    Points,
    MineCount,
    IsMarked,
    RoomMap
} from "../codegen/Tables.sol";

interface IRoomSystem {
    function getPlayers(bytes32 room) external view returns (bytes32[] memory);
}

contract InitSystem is System {
    function start(bytes32 roomId) public {
        CellType O = CellType.None;
        CellType E = CellType.Empty;
        CellType B = CellType.Mine;

        CellType[16][16] memory grid = [
            [O, O, O, O, O, O, E, O, O, O, O, O, O, O, O, O],
            [O, O, E, O, E, E, E, E, E, O, O, O, O, B, O, O],
            [O, E, E, E, E, B, E, E, B, E, E, E, E, E, E, O],
            [E, E, E, E, E, E, E, B, E, E, E, E, E, B, E, E],
            [O, E, B, E, E, E, E, E, E, E, E, E, E, E, E, O],
            [O, E, E, E, E, E, E, E, E, E, B, E, E, E, E, O],
            [O, E, E, E, E, E, E, E, E, E, E, E, E, E, O, O],
            [E, E, E, E, E, E, E, E, E, E, E, E, E, O, O, O],
            [E, E, E, E, B, E, E, E, E, E, E, E, E, E, O, O],
            [O, E, E, E, E, E, E, B, E, E, E, E, E, B, E, O],
            [O, E, E, E, E, E, E, E, E, E, E, E, E, E, E, O],
            [O, E, B, E, E, E, E, E, E, E, E, E, E, E, E, E],
            [O, E, E, E, E, E, E, E, E, E, B, E, E, E, E, E],
            [O, E, E, E, E, B, E, E, E, E, E, E, E, E, O, O],
            [O, E, E, E, E, E, E, E, E, E, E, E, B, E, E, O],
            [O, E, E, O, O, E, E, E, O, E, E, E, E, E, O, O]
        ];

        uint32 height = uint32(grid.length);
        uint32 width = uint32(grid[0].length);
        bytes memory gridContent = new bytes(width * height);

        console.log("InitSystem.start", width, height);

        for (uint32 y = 0; y < height; y++) {
            for (uint32 x = 0; x < width; x++) {
                CellType cellType = grid[y][x];

                gridContent[(y * width) + x] = bytes1(uint8(cellType));

                bytes32 entity = positionToEntityKey(roomId, x, y);
                RoomMap.set(entity, roomId);

                if (cellType == CellType.None) {
                    Disabled.set(entity, true);
                } else if (cellType == CellType.Empty) {
                    Position.set(entity, x, y);
                } else if (cellType == CellType.Mine) {
                    IsMine.set(entity, true);
                    Position.set(entity, x, y);
                }
            }
        }

        console.log("InitSystem.start", "Done");

        GridConfig.set(roomId, width, height, gridContent);
    }
}
