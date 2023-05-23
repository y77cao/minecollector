import { useComponentValue, useEntityQuery } from "@latticexyz/react";
import { useMUD } from "./MUDContext";
import { useKeyboardMovement } from "./useKeyboardMovement";
import { hexToArray } from "@latticexyz/utils";
import { CellType, cellContent, playerColors } from "./constants";
import {
  Entity,
  Has,
  HasValue,
  getComponentValue,
  getComponentValueStrict,
} from "@latticexyz/recs";
import { useEffect, useState } from "react";

export const GameBoard = ({
  gridConfig,
}: {
  gridConfig: {
    width: number;
    height: number;
    cellType: string[];
  };
}) => {
  useKeyboardMovement();

  const [placeMine, setPlaceMine] = useState(false);
  const {
    components: {
      Position,
      Disabled,
      IsMarked,
      Points,
      MineCount,
      OwnedBy,
      RoomMap,
    },
    network: { playerEntity, singletonEntity, roomId },
    systemCalls: { click, mark, place },
  } = useMUD();

  const { width, height, cellType: cells } = gridConfig;

  const coordToType = Array.from(hexToArray(cells)).reduce(
    (result, value, index) => {
      const type = value as CellType;
      const key = `${index % width},${Math.floor(index / width)}`;
      return {
        ...result,
        [key]: type,
      };
    },
    {}
  );

  const disabledCoords = useEntityQuery([
    HasValue(Disabled, { value: true }),
    Has(Position),
    HasValue(RoomMap, { value: roomId }),
  ]).reduce((keyToOwnedBy: Record<string, string>, entity: Entity) => {
    const position = getComponentValueStrict(Position, entity);
    const ownedBy = getComponentValue(OwnedBy, entity)?.value;
    const key = `${position.x},${position.y}`;
    keyToOwnedBy[key] = ownedBy;
    return keyToOwnedBy;
  }, {});

  const markedCoords = useEntityQuery([
    HasValue(IsMarked, { value: true }),
    Has(Position),
    HasValue(RoomMap, { value: roomId }),
  ]).map((entity) => {
    const position = getComponentValueStrict(Position, entity);
    const key = `${position.x},${position.y}`;
    return key;
  });

  const players = [...new Set(Object.values(disabledCoords))];
  const markedCoordsSet = new Set(markedCoords);

  const finalGridState = new Array(width)
    .fill(0)
    .map((_) => new Array(height).fill(0));

  for (let i = 0; i < height; i++) {
    for (let j = 0; j < width; j++) {
      const key = `${j},${i}`;
      finalGridState[i][j] = cellContent[coordToType[key]];
      if (disabledCoords[key]) {
        finalGridState[i][j] =
          playerColors[players.indexOf(disabledCoords[key])];
      }
      if (markedCoordsSet.has(key)) {
        finalGridState[i][j] = cellContent[CellType.Marked];
      }
    }
  }

  return (
    <div>
      <div className="inline-grid p-2 bg-gray-500 relative overflow-hidden">
        {finalGridState.map((row, y) =>
          row.map((cell, x) => {
            return (
              <div
                key={`${x},${y}`}
                className={
                  "w-8 h-8 flex items-center justify-center cursor-pointer hover:ring text-xl"
                }
                style={{
                  gridColumn: x + 1,
                  gridRow: y + 1,
                }}
                onClick={(e) => {
                  if (e.type === "click") {
                    if (placeMine) {
                      place(x, y);
                      setPlaceMine(false);
                    }

                    click(x, y);
                  } else if (e.type === "contextmenu") {
                    // right click
                    mark(x, y);
                  }
                }}
                onContextMenu={(e) => {
                  e.preventDefault();
                  if (e.type === "click") {
                    if (placeMine) {
                      place(x, y);
                      setPlaceMine(false);
                    }

                    click(x, y);
                  } else if (e.type === "contextmenu") {
                    // right click
                    mark(x, y);
                  }
                }}
              >
                {cell}
              </div>
            );
          })
        )}
      </div>
      <div>
        Points: {useComponentValue(Points, playerEntity)?.value || 0}, Mine:{" "}
        {useComponentValue(MineCount, playerEntity)?.value || 0}
      </div>
      <button onClick={() => setPlaceMine(!placeMine)}>Place Mine</button>
      <div className="cursor">💣</div>
    </div>
  );
};
