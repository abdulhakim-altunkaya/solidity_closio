import {createSlice} from "@reduxjs/toolkit";

const sliceAccount = createSlice({
    name: "userAccount",
    initialState: "",
    reducers: {
        setUserAccount: (state, action) => {
          return action.payload;
        }
    },
});

export const { setUserAccount } = sliceAccount.actions;
export default sliceAccount.reducer;