// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/*///////////////////////////////////
            Imports
///////////////////////////////////*/
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract CLFExample is Ownable{

    /*///////////////////////////////////
                Variables
    ///////////////////////////////////*/
    enum ContractStatus{
        valid,
        paused,
        terminated
    }
    ContractStatus s_contractStatus;

    enum WorkStatus{
        working,
        endWorking
    }
    WorkStatus s_workStatus;

    struct WorkSession{
        uint256 startTime;
        uint256 endTime;
    }
    WorkSession s_session;

    ///@notice immutable variable to store the Feeds Address - DON'T DO THIS IN PRODUCTION
    AggregatorV3Interface immutable i_feed;
    ///@notice immutable variable to store employer address
    address immutable i_employer;
    ///@notice immutable variable to store employee address
    address immutable i_employee;

    ///@notice constant variable to store the Feed's heartbeat
    uint256 constant HEARTBEAT = 3600;
    ///@notice constant variable to store the minimum rate per hour value
    uint256 constant MIN_RATE = 750; //$ 7.50
    ///@notice constant to store the precision multiplier
    uint256 constant PRECISION_HELPER = 1*10**18;

    ///@notice rate per hour
    uint256 internal s_rate;
    ///@notice variable to store the total unpaid worked hours
    uint256 internal s_unpaidWorkTime;

    /*///////////////////////////////////
                Events
    ///////////////////////////////////*/
    ///@notice event emitted when the rate is updated
    event CLFExample_RatePerHourUpdated(uint256 oldRate, uint256 newRate);
    ///@notice event emitted when the working journey start
    event CLFExample_WorkingJourneyStarted(uint256 startTime);
    ///@notice event emitted when the working journey is ended
    event CLFExample_WorkingJourneyFinished(uint256 endTime, uint256 timeWorked);

    /*///////////////////////////////////
                Errors
    ///////////////////////////////////*/
    ///@notice error emitted when the rate per hour is too low
    error CLFExample_RatePerHourIsToLow(uint256 newRate, uint256 rateMin);
    ///@notice error emitted when the caller is not the employee
    error CLFExample_IsNotEmployee(address caller, address employee);
    ///@notice error emitted when the contract is paused and the employee shouldn't start working
    error CLFExample_ThisContractIsPaused(ContractStatus status);
    ///@notice error emitted when the contract was terminated
    error CLFExample_ThisContractWasTerminated(ContractStatus contractStatus);
    ///@notice error emitted when the working journey was already started
    error CLFExample_AlreadyStarted(WorkStatus workStatus);
    ///@notice error emitted when the price feeds answer is stale
    error CLFExample_StalePrice();
    ///@notice error emitted when the employee tries to end a not started journey
    error CLFExample_WorkingJourneyNotStarted(WorkStatus status);
    ///@notice error emitted when the employee salary was already paid
    error CLFExample_NothingLeftToPay();
    ///@notice error emitted when the transfer fails
    error CLFExample_TransferFailed(bytes data);
    ///@notice error emitted when the Feeds price is wrong
    error CLFExample_WrongPrice();

    /*///////////////////////////////////
                Modifiers
    ///////////////////////////////////*/
    modifier onlyEmployee(){
        if(msg.sender != i_employee) revert CLFExample_IsNotEmployee(msg.sender, i_employee);
        _;
    }

    /*///////////////////////////////////
                Functions
    ///////////////////////////////////*/
    receive() external payable{}

    /*///////////////////////////////////
                constructor
    ///////////////////////////////////*/
    constructor(
        address _feeds,
        address _owner,
        address _employee
    ) Ownable(_owner){
        i_feed = AggregatorV3Interface(_feeds);
        i_employer = _owner;
        i_employee = _employee;
        s_workStatus = WorkStatus.endWorking;
    }

    /*///////////////////////////////////
                external
    ///////////////////////////////////*/
    /**
        *@notice Function for employee to start the working journey
        *@dev only the employee can call it
    */
    function startWork() external onlyEmployee {
        if(s_contractStatus == ContractStatus.paused) revert CLFExample_ThisContractIsPaused(s_contractStatus);
        if(s_contractStatus == ContractStatus.terminated) revert CLFExample_ThisContractWasTerminated(s_contractStatus);
        if(s_workStatus == WorkStatus.working) revert  CLFExample_AlreadyStarted(s_workStatus);

        s_workStatus = WorkStatus.working;
        s_session = WorkSession(block.timestamp, 0);

        emit CLFExample_WorkingJourneyStarted(block.timestamp);
    }

    /**
        *@notice Function for Employee to end the working journey
        *@dev only the employee should be able to end the journey
    */
    function endWork() external onlyEmployee {
        if(s_workStatus != WorkStatus.working) revert CLFExample_WorkingJourneyNotStarted(WorkStatus.working);

        s_workStatus = WorkStatus.endWorking;

        s_session.endTime = block.timestamp;

        s_unpaidWorkTime = s_unpaidWorkTime + (block.timestamp - s_session.startTime);

        emit CLFExample_WorkingJourneyFinished(block.timestamp, block.timestamp - s_session.startTime);
    }

    /**
        *@notice administrative function to updated the employee rate perHour
        *@param _newRate the rate to calculate employee salary perHour
    */
    function setRate(uint256 _newRate) external onlyOwner{
        if(_newRate < MIN_RATE) revert CLFExample_RatePerHourIsToLow(_newRate, MIN_RATE);

        uint256 oldRate = s_rate;
        s_rate = _newRate;

        emit CLFExample_RatePerHourUpdated(oldRate, _newRate);
    }

    /**
        *@notice function to end and employee contract
    */
    function endContract() external onlyOwner {
        s_contractStatus = ContractStatus.terminated;
        payEmployee();
    }

    /*///////////////////////////////////
                public
    ///////////////////////////////////*/
    /**
        *@notice function to pay the employee salary
    */
    function payEmployee() public onlyOwner {
        if(s_unpaidWorkTime == 0) revert CLFExample_NothingLeftToPay();

        uint256 amountToPay = _calculateSalary();
        s_unpaidWorkTime = 0;

        _transferAmount(amountToPay);
    }

    /*///////////////////////////////////
                internal
    ///////////////////////////////////*/

    /**
        *@notice internal function to perform eth transfers
        *@param _value the amount to be transferred
    */
    function _transferAmount(uint256 _value) internal {
        (bool success, bytes memory data) = i_employee.call{value: _value}("");
        if(!success) revert CLFExample_TransferFailed(data);
    }

    /**
        *@notice Function to query the most recent price for a feed
        *@return answer_ Feed's received answer
        *@dev should be only called internally
    */
    function _getFeedLastAnswer() internal view returns(int answer_){
        uint256 updatedAt;

        ///@notice handle it with a try-catch block
        (
                ,
                answer_,
                ,
                updatedAt,

        ) = i_feed.latestRoundData();
        
        ///@notice validation example
        if(block.timestamp - updatedAt > HEARTBEAT) revert CLFExample_StalePrice();
        if(answer_ <= 0) revert CLFExample_WrongPrice();
    }

    /*///////////////////////////////////
            View & Pure
    ///////////////////////////////////*/
    /**
        *@notice internal function to calculate the employee salary
        *@return salary_ the amount to be paid
        *@dev the returned value must be based on 18 decimals.
    */
    function _calculateSalary() internal view returns(uint256 salary_){
        ///@notice convert seconds to hours
        uint256 workedHours = (s_unpaidWorkTime * PRECISION_HELPER) / 3600;

        uint256 totalInUSD = (workedHours * s_rate);
        
        salary_ = totalInUSD / uint256(_getFeedLastAnswer());
    }
}
