import { useComponentValue, useEntityQuery } from "@latticexyz/react";
import { SyncState } from "@latticexyz/network";
import { useMUD } from "./MUDContext";
import { GameBoard } from "./GameBoard";
import { Entity } from "@latticexyz/recs";

export const App = () => {
  const {
    components: { LoadingState, GridConfig },
    network: { playerEntity, singletonEntity, roomId },
    systemCalls: { start },
  } = useMUD();

  const gridConfig = useComponentValue(GridConfig, roomId as Entity);

  const loadingState = useComponentValue(LoadingState, singletonEntity, {
    state: SyncState.CONNECTING,
    msg: "Connecting",
    percentage: 0,
  });

  return (
    <div className="w-screen h-screen flex items-center justify-center">
      {loadingState.state !== SyncState.LIVE ? (
        <div>
          {loadingState.msg} ({Math.floor(loadingState.percentage)}%)
        </div>
      ) : gridConfig ? (
        <GameBoard gridConfig={gridConfig} />
      ) : (
        <button onClick={() => start()}>START</button>
      )}
    </div>
  );
};
