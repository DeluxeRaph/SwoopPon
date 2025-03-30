// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract TokenVault {
    IERC20 public immutable token;
    address public owner;

    mapping(address => uint256) public userBalances;

    event Deposit(address indexed user, uint256 amount);
    event Charge(address indexed user, uint256 amount);
    event Withdraw(address indexed owner, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _token) {
        token = IERC20(_token);
        owner = msg.sender;
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        userBalances[msg.sender] += amount;
        emit Deposit(msg.sender, amount);
    }

    function chargeUser(address user) external onlyOwner returns (bool) {
    uint256 chargeAmount = 5 * 10 ** 18;

    // check if user is in the list


    if (userBalances[user] >= chargeAmount) {
        userBalances[user] -= chargeAmount;
        emit Charge(user, chargeAmount);
        return true;
    }
    return false;
}

    function withdraw(uint256 amount) external onlyOwner {
        require(token.transfer(msg.sender, amount), "Withdraw failed");
        emit Withdraw(msg.sender, amount);
    }
}
