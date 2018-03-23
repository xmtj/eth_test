pragma solidity ^0.4.0;

contract MutiInterface {
    function add(uint a,uint b) public pure returns (uint,uint,uint,uint);
}

contract MutiInterfaceInstance is MutiInterface {
    function add(uint a,uint b) public pure returns (uint,uint,uint,uint){
      return (a+b,a-b,a*a,b*b);
    }
}
