// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SmartBank {
    address public owner;
    bool public paused;

    // User balances
    mapping(address => uint256) public balances;

    // Events
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Paused(bool status);

    constructor() {
        owner = msg.sender;
    }

    // -------- Modifiers --------
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract paused");
        _;
    }

    // -------- Core Functions --------

    // Deposit Ether into your bank account
    function deposit() public payable whenNotPaused {
        require(msg.value > 0, "Must send Ether");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Withdraw Ether from your bank account
    function withdraw(uint256 amount) public whenNotPaused {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    // Transfer Ether between users (within the contract)
    function transfer(address to, uint256 amount) public whenNotPaused {
        require(to != address(0), "Invalid address");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    // View balance
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    // -------- Owner Controls --------
    function pause(bool state) public onlyOwner {
        paused = state;
        emit Paused(state);
    }

    // Fallback to receive Ether directly
    receive() external payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
}