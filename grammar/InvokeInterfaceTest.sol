pragma solidity ^0.4.0;


contract TestInterface {
    function add(uint a,uint b) public pure returns (uint);
  }
contract InvokeInterFace001{
    address public owner;
    TestInterface public ti;
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function InvokeInterFace001() public {
      owner = msg.sender;
    }
    function setTestFunc(address _address) public onlyOwner {
      ti = TestInterface(_address);
    }
    function invoke(uint a,uint b) public view returns(uint){
        uint c =ti.add(a,b);
        return c;
    }
}
