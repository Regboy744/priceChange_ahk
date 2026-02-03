export type LabelRecord = {
  description: string;
  price: number | null;
  ean: string | null;
  page: number;
};

export type TextItem = {
  text: string;
  x: number;
  y: number;
  width: number;
  height: number;
};

export type Line = {
  y: number;
  text: string;
  items: TextItem[];
};
