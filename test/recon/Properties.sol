// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Asserts} from "@chimera/Asserts.sol";
import {BeforeAfter} from "./BeforeAfter.sol";

import "src/CLFExample.sol";

abstract contract Properties is BeforeAfter, Asserts {

    function invariant_balanceShouldOnlyDecreaseAfterATransfer() public {
        if(functionCalled == 1){
            eq(_before.contractBalance, _after.contractBalance, "Contract Balance Decreased After no Transfer Call");
        }
    }

    // 3. Worker cannot start a new work session while the previous is still running.
    //TODO: Need to improve
    function invariant_userShouldNotStartANewSessionIfThePreviousIsRunning() public view {
        if (_before.workStatus == uint8(CLFExample.WorkStatus.working)) {
            assert(block.timestamp > clf.s_currentWorkingSession());
        }
    }

    // 4. User should not be able to start a work session after the contract was terminated
    function invariant_userCannotStartAWorkSessionAfterTheContractWasTerminated() public {
        if (_before.contractStatus == uint8(CLFExample.ContractStatus.terminated)) {
            eq(uint256(_after.workStatus), uint256(CLFExample.WorkStatus.endWorking), "New Work Session Was Initialized");
        }
    }
}