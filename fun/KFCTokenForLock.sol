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
  uint256 public lockDeadLine;
  uint256 public fundDeadLine ;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  //每个月只能释放自己私募金额的5%
  //用户私募的总金额
  mapping (address => uint256) public addressToUserFundTotal;

  uint256 minutesInMonth = 30 * 24 * 60 * 1 minutes;

  //计算私募用户可以提取多少kfc
  function checkFundUserCanTransfer(address funderAddress)  internal view returns(uint256) {
      uint256 timeDifferent = now - lockDeadLine;
      return addressToUserFundTotal[funderAddress]*(timeDifferent / minutesInMonth + 1) / 20 - (addressToUserFundTotal[funderAddress]-addressToLockedKFC[funderAddress]);
  }

  function getYouCanTransferFund() public view returns(uint256) {
      if (now > lockDeadLine && addressToLockedKFC[msg.sender]>0){
          uint256 timeDifferent = now - lockDeadLine;
      return addressToUserFundTotal[msg.sender]*(timeDifferent / minutesInMonth + 1) / 20 - (addressToUserFundTotal[msg.sender]-addressToLockedKFC[msg.sender]);
        }else{
          return 0 ;
        }
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    //锁仓结束
    if (lockDeadLine != 0 && now > lockDeadLine && now > fundDeadLine && addressToLockedKFC[msg.sender]>0){
      uint256 canTransfer = checkFundUserCanTransfer(msg.sender);
      balances[msg.sender]=balances[msg.sender]+canTransfer;
      addressToLockedKFC[msg.sender]=addressToLockedKFC[msg.sender]-canTransfer;
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

  //10% 的私募 
  uint256 restFund = 10000 ether;
  //30%  的ico
  uint256 restICO = 30000 ether;
  
  

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
    balances[this]=totalSupply_/10*4;
    balances[msg.sender]=totalSupply_/10*6;
    beneficiary = ifSuccessfulSendTo;
    price = szaboCostOfEachKFC * 1 szabo;
    owner=msg.sender;
    fundDeadLine=now + 4 * 30 * 24 * 60 * 1 minutes;
  }
  // 要求发起者是所属者
  modifier onlyOwner() {
      require(msg.sender == owner);
      _;
  }


  function () payable public{
    require (now < fundDeadLine);
    require (restFund > 0);
    uint amount = msg.value;
    //记录邀请人的金额
    restFund-=amount;
    uint256 _value =  (amount / price)* 10 ** uint256(decimals);
    //私募限制
    addressToUserFundTotal[msg.sender] = addressToUserFundTotal[msg.sender].add(_value);

    balances[this] = balances[this].sub(_value);
    addressToLockedKFC[msg.sender]=addressToLockedKFC[msg.sender].add(_value) ;
    emit GetFundTokenByEth(address(0),msg.sender,amount);
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
    lockDeadLine= fundDeadLine + _lockMinutes * 1 minutes ;
  }

  mapping (address => uint256) addressToInviteICOMoney;
  mapping (address => uint256) addressToInviteFundMoney;

  event GetFundTokenByEth(address inviteAddress,address whoGetToken,uint256 payETh);
  event GetICOTokenByEth(address inviteAddress,address whoGetToken,uint256 payETh);


  //私募交易
  function getFundToken(address inviteAddress) public payable {
    require (inviteAddress != address(0));
    require (now < fundDeadLine);
    require (restFund > 0);
    uint amount = msg.value;
    require (restFund >= amount);
    
    //记录邀请人的金额
    addressToInviteFundMoney[inviteAddress] += amount;
    restFund-=amount;
    uint256 _value =  (amount / price)* 10 ** uint256(decimals);
    //私募限制
    addressToUserFundTotal[msg.sender] = addressToUserFundTotal[msg.sender].add(_value);

    balances[this] = balances[this].sub(_value);
    addressToLockedKFC[msg.sender]=addressToLockedKFC[msg.sender].add(_value) ;
    emit GetFundTokenByEth(inviteAddress,msg.sender,amount);
  }

  function getICOToken(address inviteAddress) public payable {
    require (inviteAddress != address(0));
    require(isStartICO && now < deadline);
    //ico金额要大于已经ico的金额
    require(fundingGoal>amountRaised);
    require (restICO > 0);
    uint amount = msg.value;

    require (fundingGoal >= amount);
    
    addressToInviteICOMoney[inviteAddress] += amount;
    restICO-=amount;
    amountRaised += amount;
    //this.transfer(msg.sender, (amount / price)* 10 ** uint256(decimals));
    uint256 _value =(amount / price)* 10 ** uint256(decimals);
    balances[this] = balances[this].sub(_value);
    balances[msg.sender]=balances[msg.sender].add(_value);
    emit GetICOTokenByEth(inviteAddress,msg.sender,amount);
  }

  function getICOInviteAmount(address inviteAddress)public view returns(uint256)  {
    require (inviteAddress != address(0) );
    return addressToInviteICOMoney[inviteAddress];
  }
  function getFundInviteAmount(address inviteAddress)public view returns(uint256)  {
    require (inviteAddress != address(0) );
    return addressToInviteFundMoney[inviteAddress];
  }
  
}
