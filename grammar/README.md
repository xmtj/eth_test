# solidity语法小记

- InterfaceTest.sol:声明接口，以及接口的实现
- InvokeInterfaceTest.sol:声明接口，但不实例化，利用传入的合约地址实例化（结合InterfaceTest.sol使用），先发布合约InterfaceTest.sol，然后再发布合约InvokeInterfaceTest.sol,再把InterfaceTest.sol地址当成参数传给InvokeInterfaceTest.sol。
