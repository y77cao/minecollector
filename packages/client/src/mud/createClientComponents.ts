import { overridableComponent } from "@latticexyz/recs";
import { SetupNetworkResult } from "./setupNetwork";

export type ClientComponents = ReturnType<typeof createClientComponents>;

export function createClientComponents({ components }: SetupNetworkResult) {
  return {
    ...components,
    Player: overridableComponent(components.Player),
    Position: overridableComponent(components.Position),
    Disabled: overridableComponent(components.Disabled),
    IsMine: overridableComponent(components.IsMine),
    IsMarked: overridableComponent(components.IsMarked),
    OwnedBy: overridableComponent(components.OwnedBy),
    MineCount: overridableComponent(components.MineCount),
    Points: overridableComponent(components.Points),
  };
}
