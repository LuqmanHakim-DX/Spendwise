import { ConnectorConfig, DataConnect, QueryRef, QueryPromise, ExecuteQueryOptions, DataConnectSettings } from 'firebase/data-connect';

export const connectorConfig: ConnectorConfig;
export const dataConnectSettings: DataConnectSettings;

export type TimestampString = string;
export type UUIDString = string;
export type Int64String = string;
export type DateString = string;




export interface Budget_Key {
  id: UUIDString;
  __typename?: 'Budget_Key';
}

export interface Category_Key {
  id: UUIDString;
  __typename?: 'Category_Key';
}

export interface Expense_Key {
  id: UUIDString;
  __typename?: 'Expense_Key';
}

export interface GetExpensesData {
  expenses: ({
    id: UUIDString;
    amount: number;
    date: TimestampString;
    description: string;
    category: {
      name: string;
      icon: string;
    };
  } & Expense_Key)[];
}

export interface MonthlySummary_Key {
  id: UUIDString;
  __typename?: 'MonthlySummary_Key';
}

export interface User_Key {
  id: UUIDString;
  __typename?: 'User_Key';
}

interface GetExpensesRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<GetExpensesData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<GetExpensesData, undefined>;
  operationName: string;
}
export const getExpensesRef: GetExpensesRef;

export function getExpenses(options?: ExecuteQueryOptions): QueryPromise<GetExpensesData, undefined>;
export function getExpenses(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<GetExpensesData, undefined>;

