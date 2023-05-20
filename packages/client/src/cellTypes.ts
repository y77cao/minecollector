export enum CellType {
  Empty = 1,
  Mine,
  Disabled,
  Marked,
}

type CellConfig = {
  emoji: string;
};

export const cellTypes: Record<CellType, CellConfig> = {
  [CellType.Empty]: {
    emoji: "🟦",
  },
  [CellType.Mine]: {
    emoji: "💣",
  },
  [CellType.Disabled]: {
    emoji: "⬜",
  },
  [CellType.Marked]: {
    emoji: "🚩",
  },
};
