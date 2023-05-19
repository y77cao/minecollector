import { useComponentValue, useEntityQuery } from "@latticexyz/react";
import { GameMap } from "./GameMap";
import { useMUD } from "./MUDContext";
import { useKeyboardMovement } from "./useKeyboardMovement";
import { hexToArray } from "@latticexyz/utils";
import { TerrainType, terrainTypes } from "./terrainTypes";
import { EncounterScreen } from "./EncounterScreen";
import { Entity, Has, getComponentValueStrict } from "@latticexyz/recs";
import { MonsterType, monsterTypes } from "./monsterTypes";

export const GameBoard = () => {
  useKeyboardMovement();

  const {
    components: { GridConfig, Player, Position },
    network: { playerEntity, singletonEntity },
    systemCalls: { spawn },
  } = useMUD();

  const canSpawn = useComponentValue(Player, playerEntity)?.value !== true;

  const players = useEntityQuery([Has(Player), Has(Position)]).map((entity) => {
    const position = getComponentValueStrict(Position, entity);
    return {
      entity,
      x: position.x,
      y: position.y,
      emoji: entity === playerEntity ? "🤠" : "🥸",
    };
  });

  const gridConfig = useComponentValue(GridConfig, singletonEntity);
  if (gridConfig == null) {
    throw new Error(
      "map config not set or not ready, only use this hook after loading state === LIVE"
    );
  }

  const { width, height, cellType: cellTypes } = gridConfig;
  const cells = Array.from(hexToArray(cellTypes)).map((value, index) => {
    const { emoji } =
      value in TerrainType ? terrainTypes[value as TerrainType] : { emoji: "" };
    return {
      x: index % width,
      y: Math.floor(index / width),
      emoji,
    };
  });
  return (
    <GameMap
      width={width}
      height={height}
      cells={cells}
      onTileClick={() => {}}
      players={players}
    />
  );
};
