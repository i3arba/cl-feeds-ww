// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Setup} from "./Setup.sol";

import "src/CLFExample.sol";

// ghost variables for tracking state variable values before and after function calls
abstract contract BeforeAfter is Setup {
    struct Vars {
        uint256 __ignore__;
        uint256 contractBalance;
        uint8 contractStatus;
        uint8 workStatus;
    }

    Vars internal _before;
    Vars internal _after;

    modifier updateGhosts {
        __before();
        _;
        __after();
    }

    function __before() internal {
        _before.contractBalance = address(clf).balance;
        _before.contractStatus = uint8(clf.s_contractStatus());
        _before.workStatus = uint8(clf.s_workStatus());
    }

    function __after() internal {
        _after.contractBalance = address(clf).balance;
        _after.contractStatus = uint8(clf.s_contractStatus());
        _after.workStatus = uint8(clf.s_workStatus());
    }
}