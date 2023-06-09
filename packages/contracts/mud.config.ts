import { mudConfig, resolveTableId } from "@latticexyz/world/register";

export default mudConfig({
  enums: {
    CellType: ["None", "Empty", "Mine"],
  },
  tables: {
    GridConfig: {
      dataStruct: false,
      schema: {
        width: "uint32",
        height: "uint32",
        cellType: "bytes",
      },
    },
    RoomMap: "bytes32",
    Disabled: "bool",
    IsMine: "bool",
    IsMarked: "bool",
    OwnedBy: "bytes32",
    MineCount: "uint32",
    Points: "uint32",
    Position: {
      dataStruct: false,
      schema: {
        x: "uint32",
        y: "uint32",
      },
    },
  },
});
