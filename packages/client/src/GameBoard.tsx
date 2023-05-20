import { useComponentValue, useEntityQuery } from "@latticexyz/react";
import { useMUD } from "./MUDContext";
import { useKeyboardMovement } from "./useKeyboardMovement";
import { hexToArray } from "@latticexyz/utils";
import { CellType, cellContent } from "./constants";
import { Entity, Has, getComponentValueStrict } from "@latticexyz/recs";

export const GameBoard = () => {
  useKeyboardMovement();

  const {
    components: { GridConfig, Player, Position, Disabled },
    network: { playerEntity, singletonEntity },
    systemCalls: { click },
  } = useMUD();

  const gridConfig = useComponentValue(GridConfig, singletonEntity);
  if (gridConfig == null) {
    throw new Error(
      "map config not set or not ready, only use this hook after loading state === LIVE"
    );
  }

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

  const disabledCoords = useEntityQuery([Has(Disabled), Has(Position)]).map(
    (entity) => {
      const position = getComponentValueStrict(Position, entity);
      const key = `${position.x},${position.y}`;
      return key;
    }
  );
  const disabledCoordsSet = new Set(disabledCoords);

  const finalGridState = new Array(width)
    .fill(0)
    .map((_) => new Array(height).fill(0));

  for (let i = 0; i < height; i++) {
    for (let j = 0; j < width; j++) {
      const key = `${j},${i}`;
      finalGridState[i][j] = coordToType[key];
      if (disabledCoordsSet.has(key)) {
        finalGridState[i][j] = CellType.Disabled;
      }
    }
  }

  console.log({ coordToType, disabledCoords, finalGridState });

  return (
    <div className="inline-grid p-2 bg-gray-500 relative overflow-hidden">
      {finalGridState.map((row, y) =>
        row.map((cell, x) => {
          return (
            <div
              key={`${x},${y}`}
              className={
                "w-8 h-8 flex items-center justify-center cursor-pointer hover:ring"
              }
              style={{
                gridColumn: x + 1,
                gridRow: y + 1,
              }}
              onClick={() => click(x, y)}
            >
              {cellContent[cell]}
            </div>
          );
        })
      )}
    </div>
  );
};
