export enum CellType {
  Null = 0,
  Empty,
  Mine,
  Disabled,
  Marked,
}

export const cellContent: Record<CellType, string> = {
  [CellType.Null]: "",
  [CellType.Empty]: "⬜",
  [CellType.Mine]: "💣",
  [CellType.Disabled]: "🟦",
  [CellType.Marked]: "🚩",
};

export const playerColors = ["🟥", "🟨", "🟩", "🟦"];
