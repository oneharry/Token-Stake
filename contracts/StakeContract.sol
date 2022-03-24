// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC20Token.sol";

contract StakeContract is ERC20, Ownable {
    using SafeMath for uint256;

     //owner visible in this contract only
    ERC20Token private ercToken;
    uint public _time;
    //array of everyone who has a stake. 
    //Holds the addresses
    
    address[] internal stakeHolders;

    mapping(address => uint256) public stakeBalance;
    mapping(address => bool) public isStakeholder;
    mapping(address => uint256) public rewards;
    
    constructor() ERC20("StakeContract", "STK") {
        _mint(msg.sender, 1000 * 10 ** 18);
       
        _time = block.timestamp;
    }

    //Changes the price of the token per ETH
    function modifyTokenBuyPrice(uint256 amount) public view onlyOwner returns(uint) {
        uint price = amount * 10 ** 18;
        return price;
    }

    //buys ercToken token when called
    function buyToken(uint _quantity) public {
        _mint(msg.sender, _quantity);
    }

    //stakes a certain amount of the token
    //transferred from the senders, to the contract
    function stake(uint256 _amount) public {
        require(_amount > 0, "You can't stake 0");

        _burn(msg.sender, _amount);

        if(stakeBalance[msg.sender] == 0) stakeHolders.push(msg.sender);

        stakeBalance[msg.sender] = stakeBalance[msg.sender].add(_amount);
        isStakeholder[msg.sender] = true;
    }

    //unstake the token
    function unStake(uint _amount) public  {
        //gets the balance of the sender from the balance stake mapping 
        uint _balance = stakeBalance[msg.sender];

        //transaction can only continue if the balance is nkit zero
        require(_balance > 0, "You can't unstake more than your stake");

        //substract unstaked value of the user from the staked amount
        stakeBalance[msg.sender] = stakeBalance[msg.sender].sub(_amount);

        //mint the token to the users account

        _mint(msg.sender, _amount);


        if(stakeBalance[msg.sender] == 0) {
            isStakeholder[msg.sender] = false;
        }
    }

    //only the owner can transfer token to stakeholders
    function transferToken(uint _amount) public onlyOwner payable {
        

        for(uint i = 0; i < stakeHolders.length; i++) {
            address stakeHolder = stakeHolders[i];

            uint balance = stakeBalance[stakeHolder];
            if(balance > 0) {

                transfer(stakeHolder, _amount);
            }
        }
    }

    //claim reward
    function claimReward() public {
        //Reward can only be claimed if its within one week
        require(_time < 7 days, "Reward expired after 1 week");

        //calculate the value of users reward
        //which is 1% of total stake
        rewards[msg.sender] = stakeBalance[msg.sender] / 100;

        //the reward of the user
        uint reward = rewards[msg.sender];

        // rewards the user
        _mint(msg.sender, reward);

        //sets reward to zero
        rewards[msg.sender] = 0;
        
        //sets time to zero
        _time = 0;

        
    }

}
