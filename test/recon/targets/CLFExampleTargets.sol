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

    function cLFExample_startWork() public asActor updateGhosts{
        // 2. User shouldn't be able to start working after the end of the contract
        cLFExample.startWork();
    }

    function cLFExample_endWork(uint256 _workedTime) public asActor updateGhosts{
        cLFExample.startWork();

        vm.warp(block.timestamp + _workedTime);

        cLFExample.endWork();
    }

    function cLFExample_endContract() public asAdmin {
        // 3. The contract should'not be terminate while there is salary pendent to be paid
        cLFExample.endContract();
    }

    function cLFExample_payEmployee() public asAdmin {
        // 1. Worker can't receive a different amount of ETH than it's due to him.
        // Which means, he cannot receive more or less than the result of:
        // salary = (((unpaidWorkTime * 1e18) * rateHours)/3600) / lastETH/USD price
        cLFExample.payEmployee();
    }

    function cLFExample_renounceOwnership() public asActor updateGhosts{
        cLFExample.renounceOwnership();
    }

    function cLFExample_setRate(uint256 _newRate) public asAdmin {
        cLFExample.setRate(_newRate);

        gte(cLFExample.s_rate(), cLFExample.MIN_RATE(), "Rate was not updated to a valid value");
        eq(cLFExample.s_unpaidWorkTime(), 0, "Rate was updated without paying the amount due");
    }

    function cLFExample_transferOwnership(address newOwner) public asAdmin updateGhosts{
        cLFExample.transferOwnership(newOwner);
    }
}