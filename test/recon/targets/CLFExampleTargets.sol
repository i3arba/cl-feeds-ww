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

    function cLFExample_endContract() public asActor {
        cLFExample.endContract();
    }

    function cLFExample_endWork() public asActor {
        cLFExample.endWork();
    }

    function cLFExample_payEmployee() public asActor {
        cLFExample.payEmployee();
    }

    function cLFExample_renounceOwnership() public asActor {
        cLFExample.renounceOwnership();
    }

    function cLFExample_setRate(uint256 _newRate) public asAdmin {
        cLFExample.setRate(_newRate);
    }

    function cLFExample_startWork() public asActor {
        cLFExample.startWork();
    }

    function cLFExample_transferOwnership(address newOwner) public asAdmin {
        cLFExample.transferOwnership(newOwner);
    }
}