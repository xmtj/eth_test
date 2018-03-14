pragma solidity ^0.4.0;

contract TestInterface {
    function add(uint a,uint b) public pure returns (uint);
}
contract InvokeInterFace{
    function invoke(address _address) public pure returns(uint){
        TestInterface ti = TestInterface(_address);
        uint c =ti.add(1,2);
        return c;
    }
}
