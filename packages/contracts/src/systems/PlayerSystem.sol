// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {console} from "forge-std/console.sol";
import {System} from "@latticexyz/world/src/System.sol";
import {addressToEntityKey} from "../addressToEntityKey.sol";
import {positionToEntityKey} from "../positionToEntityKey.sol";
import {getKeysWithValue} from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import {Position, GridConfig, Disabled, IsMine, OwnedBy, Points, MineCount, IsMarked} from "../codegen/Tables.sol";

contract PlayerSystem is System {
    function click(bytes32 roomId, uint32 x, uint32 y) public {
        bytes32 player = addressToEntityKey(address(_msgSender()));

        require(Disabled.get(player) == false, "player disabled");

        (uint32 width, uint32 height,) = GridConfig.get(roomId);
        require(x >= 0 && x < width, "x out of bounds");
        require(y >= 0 && y < height, "y out of bounds");

        bytes32 position = positionToEntityKey(roomId, x, y);
        require(!Disabled.get(position), "position clicked");

        bool isMine = IsMine.get(position);

        if (isMine) {
            lose(player);
        } else {
            IsMarked.set(position, false);
            expand(roomId, player, x, y, width, height, 0);
        }
    }

    function mark(bytes32 roomId, uint32 x, uint32 y) public {
        bytes32 player = addressToEntityKey(address(_msgSender()));

        require(Disabled.get(player) == false, "player disabled");

        (uint32 width, uint32 height,) = GridConfig.get(roomId);
        require(x >= 0 && x < width, "x out of bounds");
        require(y >= 0 && y < height, "y out of bounds");

        bytes32 position = positionToEntityKey(roomId, x, y);
        require(!Disabled.get(position), "position clicked");

        bool isMarked = IsMarked.get(position);
        if (isMarked) return;
        IsMarked.set(position, true);

        bool isMine = IsMine.get(position);
        if (isMine) {
            uint32 points = Points.get(player);
            Points.set(player, points + 2);
            MineCount.set(player, MineCount.get(player) + 1);
            IsMine.set(position, false);
        }
    }

    function placeMine(bytes32 roomId, uint32 x, uint32 y) public {
        bytes32 player = addressToEntityKey(address(_msgSender()));

        require(Disabled.get(player) == false, "player disabled");
        // TODO check joined

        (uint32 width, uint32 height,) = GridConfig.get(roomId);
        require(x >= 0 && x < width, "x out of bounds");
        require(y >= 0 && y < height, "y out of bounds");

        bytes32 position = positionToEntityKey(roomId, x, y);
        uint32 mineCount = MineCount.get(player);
        bool isMine = IsMine.get(position);
        bool disabled = Disabled.get(position);
        require(!isMine, "mine already there");
        require(mineCount > 0, "no mines left");

        if (disabled) {
            Disabled.set(position, false);
            // blow up area around, clear cell state
            clear(roomId, x - 1, y - 1, width, height);
            clear(roomId, x - 1, y, width, height);
            clear(roomId, x - 1, y + 1, width, height);
            clear(roomId, x, y - 1, width, height);
            clear(roomId, x, y + 1, width, height);
            clear(roomId, x + 1, y - 1, width, height);
            clear(roomId, x + 1, y, width, height);
            clear(roomId, x + 1, y + 1, width, height);
        } else {
            IsMine.set(position, true);
        }

        MineCount.set(player, mineCount - 1);
    }

    function purchase() public {}

    function lose(bytes32 player) public {
        if (Disabled.get(player)) return;
        Disabled.set(player, true);
    }

    function expand(bytes32 roomId, bytes32 player, uint32 x, uint32 y, uint32 width, uint32 height, uint32 expandCount)
        public
    {
        bytes32 position = positionToEntityKey(roomId, x, y);
        // expandCount limiting gas, only go 3 levels deep
        if (Disabled.get(position) || IsMine.get(position) || expandCount > 3) {
            return;
        }
        uint32 count = countMines(roomId, x, y, width, height);
        Disabled.set(position, true);
        OwnedBy.set(position, player);

        uint32 points = Points.get(player);
        Points.set(player, points + 1);

        if (count == 0) {
            // Top Left
            if (x > 0 && y > 0) {
                expand(roomId, player, x - 1, y - 1, width, height, expandCount + 1);
            }
            // Top
            if (y > 0) {
                expand(roomId, player, x, y - 1, width, height, expandCount + 1);
            }
            // Top Right
            if (x < width - 1 && y > 0) {
                expand(roomId, player, x + 1, y - 1, width, height, expandCount + 1);
            }
            // Right
            if (x < width - 1) {
                expand(roomId, player, x + 1, y, width, height, expandCount + 1);
            }
            // Bottom Right
            if (x < width - 1 && y < height - 1) {
                expand(roomId, player, x + 1, y + 1, width, height, expandCount + 1);
            }
            // Bottom
            if (y < height - 1) {
                expand(roomId, player, x, y + 1, width, height, expandCount + 1);
            }
            // Bottom Left
            if (x > 0 && y < height - 1) {
                expand(roomId, player, x - 1, y + 1, width, height, expandCount + 1);
            }
            // Left
            if (x > 0) {
                expand(roomId, player, x - 1, y, width, height, expandCount + 1);
            }
        }
    }

    function clear(bytes32 roomId, uint32 x, uint32 y, uint32 width, uint32 height) public {
        if (x < 0 || x >= width || y < 0 || y >= height) return;
        bytes32 position = positionToEntityKey(roomId, x, y);
        Disabled.set(position, false);
        OwnedBy.deleteRecord(position);
        IsMine.deleteRecord(position);
        IsMarked.deleteRecord(position);
    }

    function countMines(bytes32 roomId, uint32 x, uint32 y, uint32 width, uint32 height) public view returns (uint32) {
        uint32 count = 0;

        // Top Left
        if (x > 0 && y > 0 && IsMine.get(positionToEntityKey(roomId, x - 1, y - 1))) {
            count++;
        }
        // Top
        if (y > 0 && IsMine.get(positionToEntityKey(roomId, x, y - 1))) {
            count++;
        }
        // Top Right
        if (x < width - 1 && y > 0 && IsMine.get(positionToEntityKey(roomId, x + 1, y - 1))) {
            count++;
        }
        // Right
        if (x < width - 1 && IsMine.get(positionToEntityKey(roomId, x + 1, y))) {
            count++;
        }
        // Bottom Right
        if (x < width - 1 && y < height - 1 && IsMine.get(positionToEntityKey(roomId, x + 1, y + 1))) {
            count++;
        }
        // Bottom
        if (y < height - 1 && IsMine.get(positionToEntityKey(roomId, x, y + 1))) {
            count++;
        }
        // Bottom Left
        if (x > 0 && y < height - 1 && IsMine.get(positionToEntityKey(roomId, x - 1, y + 1))) {
            count++;
        }
        // Left
        if (x > 0 && IsMine.get(positionToEntityKey(roomId, x - 1, y))) {
            count++;
        }

        return count;
    }
}
