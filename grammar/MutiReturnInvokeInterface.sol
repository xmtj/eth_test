pragma solidity ^0.4.0;


contract MutiInterface {
    function add(uint a,uint b) public pure returns (uint,uint,uint,uint);
  }
contract InvokeMutiInterFace{
    address public owner;
    MutiInterface public ti;
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function InvokeInterFace001() public {
      owner = msg.sender;
    }
    function setTestFunc(address _address) public onlyOwner {
      ti = MutiInterface(_address);
    }
    function invoke(uint a,uint b) public view returns(uint,uint,uint,uint){
        return ti.add(a,b);
    }
}
