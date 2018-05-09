pragma solidity ^0.4.11;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}


contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }


  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }


  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }


  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }


  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


contract KFCToken is StandardToken{
  // 所属人地址
  string public name="KFC";
  string public symbol="KFC";
  uint public INITIAL_SUPPLY=10000000000;

  address public beneficiary;
  uint public fundingGoal;
  uint public amountRaised;
  uint public deadline;
  uint public price;
  mapping(address => uint256) public balanceOfForCrow;
  bool fundingGoalReached = false;
  bool crowdsaleClosed = false;

  event GoalReached(address recipient, uint totalAmountRaised);
  event FundTransfer(address backer, uint amount, bool isContribution);


  function KFCToken(
    address ifSuccessfulSendTo,
    uint fundingGoalInEthers,
    uint durationInMinutes,
    uint szaboCostOfEachToken) public{
    balances[this]=INITIAL_SUPPLY;
    totalSupply_=INITIAL_SUPPLY;

    beneficiary = ifSuccessfulSendTo;
    fundingGoal = fundingGoalInEthers * 1 ether;
    deadline = now + durationInMinutes * 1 minutes;
    price = szaboCostOfEachToken * 1 szabo;
  }


  function () payable public{
      if(!crowdsaleClosed){
        uint amount = msg.value;
        balanceOfForCrow[msg.sender] += amount;
        amountRaised += amount;
        this.transfer(msg.sender, amount / price);
        emit FundTransfer(msg.sender, amount, true);
      }
  }

  modifier afterDeadline() { if (now >= deadline) _; }

  /**
   * Check if goal was reached
   *
   * Checks if the goal or time limit has been reached and ends the campaign
   */
  function checkGoalReached() afterDeadline public {
      if (amountRaised >= fundingGoal){
          fundingGoalReached = true;
          emit GoalReached(beneficiary, amountRaised);
      }
      crowdsaleClosed = true;
  }


  /**
   * Withdraw the funds
   *
   * Checks to see if goal or time limit has been reached, and if so, and the funding goal was reached,
   * sends the entire amount to the beneficiary. If goal was not reached, each contributor can withdraw
   * the amount they contributed.
   */
  function safeWithdrawal() afterDeadline public {
      if (!fundingGoalReached) {
          uint amount = balanceOfForCrow[msg.sender];
          balanceOfForCrow[msg.sender] = 0;
          if (amount > 0) {
              if (msg.sender.send(amount)) {
                  emit FundTransfer(msg.sender, amount, false);
              } else {
                  balanceOfForCrow[msg.sender] = amount;
              }
          }
      }

      if (fundingGoalReached && beneficiary == msg.sender) {
          if (beneficiary.send(amountRaised)) {
              emit FundTransfer(beneficiary, amountRaised, false);
          } else {
              //If we fail to send the funds to beneficiary, unlock funders balance
              fundingGoalReached = false;
          }
      }
  }

}
