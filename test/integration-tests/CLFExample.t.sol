///SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { console } from "forge-std/Test.sol";

import { BaseTests } from "test/helpers/BaseTests.t.sol";

///@notice Protocol Base Contracts
import { CLFExample } from "src/CLFExample.sol";

contract CLFExampleTest is BaseTests {
    /**
        test work sessions
    */
    function test_workSessionRevert() public {
        vm.expectRevert(abi.encodeWithSelector(CLFExample.CLFExample_IsNotEmployee.selector, address(this), s_employee));
        s_example.startWork();
    }

    function test_workSessionStart() public {
        vm.startPrank(s_employee);
        vm.expectEmit();
        emit CLFExample.CLFExample_WorkingJourneyStarted(block.timestamp);
        s_example.startWork();

        vm.stopPrank();
    }

    /**
        work session ends
    */
    function test_workSessionEnd() public {
        uint256 timeToJump = block.timestamp + 3600;
        sessionStarterHelper();
        vm.warp(timeToJump);

        vm.startPrank(s_employee);
        vm.expectEmit();
        emit CLFExample.CLFExample_WorkingJourneyFinished(block.timestamp, 3600);
        s_example.endWork();
        vm.stopPrank();
    }

    /**
        payment calculation
    */
    function test_ownerCanPayTheUser() public {
        uint256 employeeBalance = s_employee.balance;

        sessionStarterHelper();
        sessionCloserHelper();

        vm.prank(s_owner);
        s_example.payEmployee();

        uint256 employeeNewBalance = s_employee.balance;
        console.log("Employee Balance After Payment:", employeeNewBalance);
        console.log("Expected Amount To be Paid:", calculationHelper());
        assertEq(employeeNewBalance, employeeBalance + calculationHelper());
    }
}