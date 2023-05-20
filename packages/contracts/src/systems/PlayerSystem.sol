// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {console} from "forge-std/console.sol";
import {System} from "@latticexyz/world/src/System.sol";
import {addressToEntityKey} from "../addressToEntityKey.sol";
import {positionToEntityKey} from "../positionToEntityKey.sol";
import {getKeysWithValue} from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import {Player, Position, GridConfig, Disabled, IsMine} from "../codegen/Tables.sol";

contract PlayerSystem is System {
    function click(uint32 x, uint32 y) public {
        bytes32 player = addressToEntityKey(address(_msgSender()));
        console.log(address(_msgSender()));

        require(Disabled.get(player) == false, "player disabled");
        // TODO check joined

        (uint32 width, uint32 height,) = GridConfig.get();

        console.log("width", width, "height", height);

        require(x >= 0 && x < width, "x out of bounds");
        require(y >= 0 && y < height, "y out of bounds");

        bytes32 position = positionToEntityKey(x, y);
        require(!Disabled.get(position), "position clicked");

        bool isMine = IsMine.get(position);

        if (isMine) {
            lose(player);
        } else {
            expand(player, x, y, width, height, 0);
        }
    }

    function mark(uint32 x, uint32 y) public {}

    function purchase() public {}

    function lose(bytes32 player) public {
        Disabled.set(player, true);
    }

    function expand(bytes32 player, uint32 x, uint32 y, uint32 width, uint32 height, uint32 expandCount) public {
        console.log("expand");
        bytes32 position = positionToEntityKey(x, y);
        // expandCount limiting gas, only go 3 levels deep
        if (Disabled.get(position) || IsMine.get(position) || expandCount > 3) {
            return;
        }
        uint32 count = countMines(x, y, width, height);
        Disabled.set(position, true);
        console.log("count", count, x, y);

        if (count == 0) {
            // Top Left
            if (x > 0 && y > 0) {
                expand(player, x - 1, y - 1, width, height, expandCount + 1);
            }
            // Top
            if (y > 0) {
                expand(player, x, y - 1, width, height, expandCount + 1);
            }
            // Top Right
            if (x < width - 1 && y > 0) {
                expand(player, x + 1, y - 1, width, height, expandCount + 1);
            }
            // Right
            if (x < width - 1) {
                expand(player, x + 1, y, width, height, expandCount + 1);
            }
            // Bottom Right
            if (x < width - 1 && y < height - 1) {
                expand(player, x + 1, y + 1, width, height, expandCount + 1);
            }
            // Bottom
            if (y < height - 1) {
                expand(player, x, y + 1, width, height, expandCount + 1);
            }
            // Bottom Left
            if (x > 0 && y < height - 1) {
                expand(player, x - 1, y + 1, width, height, expandCount + 1);
            }
            // Left
            if (x > 0) {
                expand(player, x - 1, y, width, height, expandCount + 1);
            }
        }
    }

    function countMines(uint32 x, uint32 y, uint32 width, uint32 height) public view returns (uint32) {
        uint32 count = 0;

        // Top Left
        if (x > 0 && y > 0 && IsMine.get(positionToEntityKey(x - 1, y - 1))) {
            count++;
        }
        // Top
        if (y > 0 && IsMine.get(positionToEntityKey(x, y - 1))) {
            count++;
        }
        // Top Right
        if (x < width - 1 && y > 0 && IsMine.get(positionToEntityKey(x + 1, y - 1))) {
            count++;
        }
        // Right
        if (x < width - 1 && IsMine.get(positionToEntityKey(x + 1, y))) {
            count++;
        }
        // Bottom Right
        if (x < width - 1 && y < height - 1 && IsMine.get(positionToEntityKey(x + 1, y + 1))) {
            count++;
        }
        // Bottom
        if (y < height - 1 && IsMine.get(positionToEntityKey(x, y + 1))) {
            count++;
        }
        // Bottom Left
        if (x > 0 && y < height - 1 && IsMine.get(positionToEntityKey(x - 1, y + 1))) {
            count++;
        }
        // Left
        if (x > 0 && IsMine.get(positionToEntityKey(x - 1, y))) {
            count++;
        }

        return count;
    }
}
