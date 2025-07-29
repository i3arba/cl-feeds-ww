// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "../BeforeAfter.sol";
import {Properties} from "../Properties.sol";
// Chimera deps
import {vm} from "@chimera/Hevm.sol";

// Helpers
import {Panic} from "@recon/Panic.sol";

import "src/CLFExample.sol";

abstract contract CLFExampleTargets is
    BaseTargetFunctions,
    Properties
{
    /// CUSTOM TARGET FUNCTIONS - Add your own target functions here ///

    /// AUTO GENERATED TARGET FUNCTIONS - WARNING: DO NOT DELETE OR MODIFY THIS LINE ///

    function cLFExample_startWork() public asActor updateGhosts {
        functionCalled = 1;
        clf.startWork();
    }

    function cLFExample_endWork(uint256 _workedTime) public asActor updateGhosts{
        functionCalled = 0;

        uint256 unpaidWork = clf.s_unpaidWorkTime();
        
        between(_workedTime, 10, type(uint120).max);

        clf.startWork();

        vm.warp(block.timestamp + _workedTime);

        clf.endWork();

        // ⚠️ Unpaid work should always increase after the work ends.
        gt(clf.s_unpaidWorkTime(), unpaidWork, "The Unpaid Work Time Haven't Increased When the Work Ends");
    }

    function cLFExample_endContract() public asAdmin {
        functionCalled = 0;

        clf.endContract();

        // 3. The contract should'not be terminate while there is salary pendent to be paid
        eq(clf.s_unpaidWorkTime(), 0, "Rate was updated without paying the amount due");
    }

    function cLFExample_payEmployee() public asAdmin updateGhosts {
        functionCalled = 0;
        // 1. Worker can't receive a different amount of ETH than it's due to him.
        // Which means, he cannot receive more or less than the result of:
        // salary = (((unpaidWorkTime * 1e18) * rateHours)/3600) / lastETH/USD price
        uint256 amountToReceive = (((clf.s_unpaidWorkTime() * PRECISION_HELPER) * clf.s_rate()) / SECONDS_IN_A_HOUR) / INITIAL_ORACLE_ANSWER;
        uint256 employeeInitialBalance = _getActor().balance;

        clf.payEmployee();

        eq(employeeInitialBalance + amountToReceive, _getActor().balance, "The Amount Paid Is Incorrect");
    }

    function cLFExample_setRate(uint256 _newRate) public asAdmin {
        functionCalled = 0;

        clf.setRate(_newRate);

        gte(clf.s_rate(), clf.MIN_RATE(), "Rate was not updated to a valid value");
        eq(clf.s_unpaidWorkTime(), 0, "Rate was updated without paying the amount due");
    }
}