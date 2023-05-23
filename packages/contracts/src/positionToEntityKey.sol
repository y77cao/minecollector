// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

function positionToEntityKey(bytes32 roomId, uint32 x, uint32 y) pure returns (bytes32) {
    return keccak256(abi.encode(roomId, x, y));
}
