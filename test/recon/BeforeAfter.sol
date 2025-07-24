// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Setup} from "./Setup.sol";

// ghost variables for tracking state variable values before and after function calls
abstract contract BeforeAfter is Setup {
    struct Vars {
        uint256 __ignore__;
        uint256 contractBalance;
    }

    Vars internal _before;
    Vars internal _after;

    modifier updateGhosts {
        __before();
        _;
        __after();
    }

    function __before() internal {
        _before.contractBalance = address(cLFExample).balance;
    }

    function __after() internal {
        _after.contractBalance = address(cLFExample).balance;
        assert(_after.contractBalance == _before.contractBalance);
    }
}