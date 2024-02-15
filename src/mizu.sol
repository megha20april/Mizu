// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract mizu {
    // New state variables to store the contract owner's address, total supply, and paused status
    uint public totalSupply;
    string public name = "MIZU";
    string public symbol = "MIZU";
    uint8 public decimals = 8;
    address public owner;
    bool public paused;

    // Mapping to store balances and allowances
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    // Mapping to store stake balances and rewards
    mapping(address => uint) public stakedBalance;
    mapping(address => uint) public rewards;

    // Modifier: Restricts certain functions to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // Modifier: Prevents certain functions from executing when the contract is paused
    modifier notPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    // Constructor: Initializes the contract with an initial supply
    constructor(uint initialSupply) {
        owner = msg.sender;
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;
        emit Transfer(address(0), msg.sender, initialSupply);
    }

    // Event: Fired when tokens are transferred
    event Transfer(address indexed from, address indexed to, uint value);

    // Event: Fired when an allowance is approved
    event Approval(address indexed owner, address indexed spender, uint value);

    // Event: Fired when new tokens are minted
    event Mint(address indexed minter, uint value);

    // Event: Fired when tokens are burned
    event Burn(address indexed burner, uint value);

    // Event: Fired when the contract is paused
    event Pause();

    // Event: Fired when the contract is unpaused
    event Unpause();

    // Event: Fired when tokens are staked
    event Staked(address indexed staker, uint amount);

    // Event: Fired when staked tokens are withdrawn
    event Withdrawn(address indexed staker, uint amount);

    // Event: Fired when tokens are sent to multiple recipients
    event MultiSend(address indexed sender, address[] recipients, uint[] amounts);

    // Function: Transfers tokens from one address to another
    function transfer(address recipient, uint amount) external notPaused returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // Function: Approves spending of tokens by another address
    function approve(address spender, uint amount) external notPaused returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // Function: Transfers tokens from one address to another on behalf of the owner
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external notPaused returns (bool) {
        require(balanceOf[sender] >= amount, "Insufficient balance");
        require(allowance[sender][msg.sender] >= amount, "Not enough allowance");
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Function: Mints (creates) new tokens and adds them to the owner's balance
    function mint(uint amount) external onlyOwner notPaused {
        totalSupply += amount;
        balanceOf[msg.sender] += amount;
        emit Mint(msg.sender, amount);
        emit Transfer(address(0), msg.sender, amount);
    }

    // Function: Burns (destroys) tokens from the caller's balance
    function burn(uint amount) external onlyOwner notPaused {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Burn(msg.sender, amount);
        emit Transfer(msg.sender, address(0), amount);
    }

    // Function: Pauses the contract, preventing certain functionalities
    function pause() external onlyOwner {
        paused = true;
        emit Pause();
    }

    // Function: Unpauses the contract, allowing normal functionalities
    function unpause() external onlyOwner {
        paused = false;
        emit Unpause();
    }

    // Function: Stakes tokens to earn rewards
    function stake(uint amount) external notPaused {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        stakedBalance[msg.sender] += amount;
        emit Staked(msg.sender, amount);
    }

    // Function: Withdraws staked tokens and rewards
    function withdraw(uint amount) external {
        require(stakedBalance[msg.sender] >= amount, "Insufficient staked balance");
        stakedBalance[msg.sender] -= amount;
        balanceOf[msg.sender] += amount;
        emit Withdrawn(msg.sender, amount);
    }

    // Function: Sends tokens to multiple recipients in a single transaction
    function multiSend(address[] memory recipients, uint[] memory amounts) external notPaused returns (bool) {
        require(recipients.length == amounts.length, "Length mismatch between recipients and amounts");

        for (uint i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Invalid recipient address");
            require(balanceOf[msg.sender] >= amounts[i], "Insufficient balance");

            balanceOf[msg.sender] -= amounts[i];
            balanceOf[recipients[i]] += amounts[i];
            emit Transfer(msg.sender, recipients[i], amounts[i]);
        }

        emit MultiSend(msg.sender, recipients, amounts);
        return true;
}

}