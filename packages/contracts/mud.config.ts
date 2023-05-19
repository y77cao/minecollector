import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  enums: {
    CellType: ["None", "Empty", "Bomb"],
  },
  tables: {
    GridConfig: {
      keySchema: {},
      dataStruct: false,
      schema: {
        width: "uint32",
        height: "uint32",
        cellType: "bytes",
      },
    },
    Player: "bool",
    Position: {
      dataStruct: false,
      schema: {
        x: "uint32",
        y: "uint32",
      },
    },
  },
});
