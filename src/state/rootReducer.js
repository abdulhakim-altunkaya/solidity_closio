import { combineReducers } from '@reduxjs/toolkit';
import accountReducer from "./sliceAccount";

const rootReducer = combineReducers({
    userAccount: accountReducer,
})
export default rootReducer;