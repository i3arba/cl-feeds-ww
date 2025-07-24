// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {FoundryAsserts} from "@chimera/FoundryAsserts.sol";

import "forge-std/console2.sol";

import {Test} from "forge-std/Test.sol";
import {TargetFunctions} from "./TargetFunctions.sol";


// forge test --match-contract CryticToFoundry -vv
contract CryticToFoundry is Test, TargetFunctions, FoundryAsserts {
    function setUp() public {
        setup();
    }

    // forge test --match-test test_crytic -vvv
    function test_crytic() public {
        // TODO: add failing property tests here for debugging
    }   		
   		

// forge test --match-test test_cLFExample_setRate_ysv1 -vvv
    
    function test_cLFExample_setRate_ysv1() public {
      
       vm.roll(2);
       vm.warp(7);
       cLFExample_endWork(5);
      
       vm.roll(2);
       vm.warp(7);
       cLFExample_setRate(750000000);
    }
   		
}