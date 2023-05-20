import { useComponentValue, useEntityQuery } from "@latticexyz/react";
import { GameMap } from "./GameMap";
import { useMUD } from "./MUDContext";
import { useKeyboardMovement } from "./useKeyboardMovement";
import { hexToArray } from "@latticexyz/utils";
import { CellType, cellTypes } from "./cellTypes";
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
      const type = CellType[value];
      const key = `${index % width},${Math.floor(index / width)}`;
      return {
        ...result,
        [key]: type,
      };
    },
    {}
  );

  const rows = new Array(width).fill(0).map((_, i) => i);
  const columns = new Array(height).fill(0).map((_, i) => i);

  const disabledCoords = useEntityQuery([Has(Disabled), Has(Position)]).map(
    (entity) => {
      const position = getComponentValueStrict(Position, entity);
      const key = `${position.x},${position.y}`;
      return key;
    }
  );

  console.log({ coordToType, disabledCoords });

  return (
    <div className="inline-grid p-2 bg-lime-500 relative overflow-hidden">
      {rows.map((y) =>
        columns.map((x) => {
          return (
            <div
              key={`${x},${y}`}
              className={twMerge(
                "w-8 h-8 flex items-center justify-center",
                onTileClick ? "cursor-pointer hover:ring" : null
              )}
              style={{
                gridColumn: x + 1,
                gridRow: y + 1,
              }}
              onClick={() => {
                onTileClick?.(x, y);
              }}
            ></div>
          );
        })
      )}
    </div>
  );
};
