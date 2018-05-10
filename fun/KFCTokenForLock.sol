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
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping (address => uint) public addressToLockedKFC;
  uint public lockDeadLine;

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
    //锁仓结束
    if (now > lockDeadLine && addressToLockedKFC[msg.sender]>0){
    	balances[msg.sender]=addressToLockedKFC[msg.sender]+balances[msg.sender];
    	addressToLockedKFC[msg.sender]=0;
    }
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
    return balances[_owner]+addressToLockedKFC[_owner];
  }

}


contract KFCToken is BasicToken{
  // 所属人地址
  string public name="KFC";
  //1KFC = 10^8 MKFC
  string public symbol="KFC";
  uint8 public constant decimals = 8;

  uint public INITIAL_SUPPLY=1000000000000000000;


  address public beneficiary;
  uint public fundingGoal;
  uint public amountRaised;
  uint public deadline;
  uint public price;
  // 所属人地址
  address internal owner;
  bool public isStartICO = false;

  event GoalReached(address recipient, uint totalAmountRaised);
  event FundTransfer(address backer, uint amount, bool isContribution);


  function KFCToken(
    address ifSuccessfulSendTo,
    uint szaboCostOfEachKFC) public{
    totalSupply_=INITIAL_SUPPLY;
    balances[this]=totalSupply_/10*3;
    balances[msg.sender]=totalSupply_/10*7;
    beneficiary = ifSuccessfulSendTo;
    price = szaboCostOfEachKFC * 1 szabo;
    owner=msg.sender;
  }
  // 要求发起者是所属者
  modifier onlyOwner() {
      require(msg.sender == owner);
      _;
  }


  function () payable public{
      require(isStartICO && now < deadline);
      uint amount = msg.value;
      amountRaised += amount;
      this.transfer(msg.sender, (amount / price)* 10 ** uint256(decimals));
      emit FundTransfer(msg.sender, (amount / price)* 10 ** uint256(decimals), true);
  }

  modifier afterDeadline() { if ((now >= deadline) && isStartICO) _; }

  function safeWithdrawal() afterDeadline public {
      if ( beneficiary == msg.sender) {
          if (beneficiary.send(address(this).balance)) {
              emit FundTransfer(beneficiary, amountRaised, false);
          }
          isStartICO=false;
          amountRaised=0;
          fundingGoal=0;
          deadline=0;
      }
  }
  function startICO(uint fundingGoalInEthers,uint durationInMinutes) public onlyOwner {
    fundingGoal = fundingGoalInEthers * 1 ether;
    deadline = now + durationInMinutes * 1 minutes;
    isStartICO=true;
  }


  //锁仓交易
  function setLockTime(uint _lockMinutes) public onlyOwner {
    lockDeadLine= now + _lockMinutes * 1 minutes;
  }

  //锁仓交易
  function transferAndLock(address _to,uint _value) public onlyOwner {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    addressToLockedKFC[_to]=addressToLockedKFC[_to].add(_value);
  }

}
