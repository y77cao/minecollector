import { Has, HasValue, getComponentValue, runQuery } from "@latticexyz/recs";
import { uuid, awaitStreamValue } from "@latticexyz/utils";
import { ClientComponents } from "./createClientComponents";
import { SetupNetworkResult } from "./setupNetwork";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
  {
    playerEntity,
    singletonEntity,
    worldSend,
    roomId,
    txReduced$,
  }: SetupNetworkResult,
  { Position, Disabled, RoomMap }: ClientComponents
) {
  const isCellDisabled = (x: number, y: number) => {
    return (
      runQuery([
        Has(Disabled),
        HasValue(Position, { x, y }),
        HasValue(RoomMap, { value: roomId }),
      ]).size > 0
    );
  };

  const start = async () => {
    try {
      const tx = await worldSend("start", [roomId]);
      await awaitStreamValue(txReduced$, (txHash) => txHash === tx.hash);
    } catch (e) {
      console.error(e);
    }
  };

  const click = async (x: number, y: number) => {
    if (isCellDisabled(x, y)) {
      console.warn("Cell is disabled");
      return;
    }

    try {
      const tx = await worldSend("click", [roomId, x, y]);
      await awaitStreamValue(txReduced$, (txHash) => txHash === tx.hash);
    } catch (e) {
      console.error(e);
    }
  };

  const mark = async (x: number, y: number) => {
    if (isCellDisabled(x, y)) {
      console.warn("Cell is disabled");
      return;
    }

    try {
      const tx = await worldSend("mark", [roomId, x, y]);
      await awaitStreamValue(txReduced$, (txHash) => txHash === tx.hash);
    } catch (e) {
      console.error(e);
    }
  };

  const place = async (x: number, y: number) => {
    try {
      const tx = await worldSend("placeMine", [roomId, x, y]);
      await awaitStreamValue(txReduced$, (txHash) => txHash === tx.hash);
    } catch (e) {
      console.error(e);
    }
  };

  return {
    start,
    click,
    mark,
    place,
  };
}
