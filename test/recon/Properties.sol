// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Asserts} from "@chimera/Asserts.sol";
import {BeforeAfter} from "./BeforeAfter.sol";

abstract contract Properties is BeforeAfter, Asserts {

    // 1. Contract balance should only decrease if transfer amount is called

    // 2. A new contract rate can only be set after everything is due was paid.

    // 3. Worker cannot start a new work session while the previous is still valid.
}