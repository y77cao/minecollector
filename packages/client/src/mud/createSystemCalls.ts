import { Has, HasValue, getComponentValue, runQuery } from "@latticexyz/recs";
import { uuid, awaitStreamValue } from "@latticexyz/utils";
import { ClientComponents } from "./createClientComponents";
import { SetupNetworkResult } from "./setupNetwork";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
  { playerEntity, singletonEntity, worldSend, txReduced$ }: SetupNetworkResult,
  { Player, Position, Disabled, IsMine }: ClientComponents
) {
  const isCellDisabled = (x: number, y: number) => {
    return runQuery([Has(Disabled), HasValue(Position, { x, y })]).size > 0;
  };

  const click = async (x: number, y: number) => {
    if (isCellDisabled(x, y)) {
      console.warn("Cell is disabled");
      return;
    }

    try {
      const tx = await worldSend("click", [x, y]);
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
      const tx = await worldSend("mark", [x, y]);
      await awaitStreamValue(txReduced$, (txHash) => txHash === tx.hash);
    } catch (e) {
      console.error(e);
    }
  };

  const place = async (x: number, y: number) => {
    try {
      const tx = await worldSend("placeMine", [x, y]);
      await awaitStreamValue(txReduced$, (txHash) => txHash === tx.hash);
    } catch (e) {
      console.error(e);
    }
  };

  return {
    click,
    mark,
    place,
  };
}
