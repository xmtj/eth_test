pragma solidity ^0.4.0;

contract TestInterface {
    function add(uint a,uint b) public pure returns (uint);
}

contract TestInterfaceInstance is TestInterface {
    function add(uint a,uint b) public pure returns (uint){
      return a+b;
    }
}
