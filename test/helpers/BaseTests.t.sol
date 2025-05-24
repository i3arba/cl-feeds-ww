// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

///@notice Foundry Stuff
import {Test, console} from "forge-std/Test.sol";

///@notice Protocol Base Contracts
import { CLFExample } from "src/CLFExample.sol";

///@notice Data Feeds Mock
import { MockV3Aggregator } from "@chainlink-local/src/data-feeds/MockV3Aggregator.sol";


contract BaseTests is Test {    
    ///@notice Instantiate Protocol Contracts
    CLFExample public s_example;

    ///@notice Chainlink mocks
    MockV3Aggregator public s_aggregator;

    //Testing variables
    address constant s_owner = address(77);
    address constant s_employee = address(2);

    uint256 constant INITIAL_AMOUNT = 100e18;

    //Chainlink Mock info
    uint8 constant FEED_DECIMALS = 8;
    int256 constant ORACLE_INITIAL_RETURN = 2_500e8;
    uint256 constant UNPAID_WORK_TIME = 3600;

    function setUp() public virtual {
        s_aggregator = new MockV3Aggregator(
            FEED_DECIMALS,
            ORACLE_INITIAL_RETURN
        );

        s_example = new CLFExample(
            address(s_aggregator),
            s_owner,
            s_employee
        );

        ///@notice initiate contract rate
        vm.startPrank(s_owner);
        s_example.setRate(s_example.MIN_RATE());
        vm.stopPrank();

        ///@notice distribute ETH
        vm.deal(address(s_example), INITIAL_AMOUNT);

        ///@notice labeling addresses for verbosity purpose
        vm.label(address(this), "TEST CONTRACT");
    }

    function sessionStarterHelper() public {
        vm.startPrank(s_employee);
        vm.expectEmit();
        emit CLFExample.CLFExample_WorkingJourneyStarted(block.timestamp);
        s_example.startWork();

        vm.stopPrank();
    }

    function sessionCloserHelper() public {
        uint256 timeToJump = block.timestamp + UNPAID_WORK_TIME;
        vm.warp(timeToJump);

        vm.startPrank(s_employee);
        vm.expectEmit();
        emit CLFExample.CLFExample_WorkingJourneyFinished(block.timestamp, UNPAID_WORK_TIME);
        s_example.endWork();
        vm.stopPrank();
    }

    function calculationHelper() public returns(uint256 salary_){
        uint256 workedHours = UNPAID_WORK_TIME * s_example.PRECISION_HELPER();

        salary_ = ((workedHours * s_example.s_rate()) / UNPAID_WORK_TIME) / uint256(ORACLE_INITIAL_RETURN);
    }
}
