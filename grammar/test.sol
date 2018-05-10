pragma solidity ^0.4.14;


//定义符合ERC-721的接口：不可分割的token
//@author Dieter Shirley <dete@axiomzen.co> (https://github.com/dete)
contract ERC721 {
    // 需要的方法
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    // 事件
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    // Optional
    // function name() public view returns (string name);
    // function symbol() public view returns (string symbol);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}

/// @title 生成迷恋猫元数据的外部协议
///  产生数据的byte结果
contract ERC721Metadata {
    /// @dev 输入Token的Id，返回byte数组
    function getMetadata(uint256 _tokenId, string) public pure returns (bytes32[4] buffer, uint256 count) {
        if (_tokenId == 1) {
            buffer[0] = "Hello World! :D";
            count = 15;
        } else if (_tokenId == 2) {
            buffer[0] = "I would definitely choose a medi";
            buffer[1] = "um length string.";
            count = 49;
        } else if (_tokenId == 3) {
            buffer[0] = "Lorem ipsum dolor sit amet, mi e";
            buffer[1] = "st accumsan dapibus augue lorem,";
            buffer[2] = " tristique vestibulum id, libero";
            buffer[3] = " suscipit varius sapien aliquam.";
            count = 128;
        }
    }
}



// 修改人 ：汪雷
// 遗传基因接口
contract GeneScienceInterface {
    /// @dev simply a boolean to indicate this is the contract we expect to be
    function isGeneScience() public pure returns (bool);

    /// @dev given genes of kitten 1 & 2, return a genetic combination - may have a random factor
    /// @param genes1 genes of mom
    /// @param genes2 genes of sire
    /// @return 1: the genes
    /// @return 2: 性别
    /// @return 3: 速度
    /// @return 4: 繁殖速度
    /// @return 5: 版本号
    function mixGenes(uint256 genes1, uint256 genes2, uint256 targetBlock,uint8 verson) public returns (uint256,uint8,uint8,uint8,uint8);
}

//提供关于主人的基本权限认证
contract Ownable {
  //所属人地址
  address public owner;
  //所属人设置为发起者
  function Ownable() public {
    owner = msg.sender;
  }
  //要求发起者是所属者
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  //允许当前所属者转换新的所属者
  function transferOwnership(address newOwner) public onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
}

//允许紧急暂停协议的机制
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

  //在没有暂停时可以执行
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  //在暂停时可以执行
  modifier whenPaused {
    require(paused);
    _;
  }

  //主人可以开启暂定
  function pause() onlyOwner whenNotPaused public returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  //主人可以取消暂停
  function unpause() onlyOwner whenPaused public returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}


// @title KittyCore协议中管理特殊权限的功能群
// @author Axiom Zen (https://www.axiomzen.co)
// @dev 查看KittyCore来了解协议之间的关系
contract KittyAccessControl {
    // CryptoKitties的核心角色的权限管理
    //     - CEO：能够调整其他角色和修改协议地址，唯一能够重启协议；
    //       初始值是KittyCore的创建者
    //
    //     - The CFO：能够从KittyCore和拍卖协议中取资金
    //     - The COO：能够生成和拍卖0代猫
    //
    // 这些角色是按照职能划分的，每个角色仅有以上能力。
    // 特别是CEO能够指派每一个角色的地址，但他不能履行这些角色的能力。
    // 这能够限制我们让CEO成为一个“超级用户”，从而增加了安全性。
    // @dev 协议升级时的事件
    event ContractUpgrade(address newContract);

    // 执行每个角色的协议地址
    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;

    // @dev 管理协议是否被暂定，暂停时大多数行动都会被阻塞
    bool public paused = false;

    // @dev 提供只有CEO能够使用的功能的权限检查
    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    // @dev 提供只有CFO能够使用的功能的权限检查
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }

    // @dev 提供只有COO能够使用的功能的权限检查
    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }
	// @dev 提供只有C?O能够使用的功能的权限检查
    modifier onlyCLevel() {
        require(
            msg.sender == cooAddress ||
            msg.sender == ceoAddress ||
            msg.sender == cfoAddress
        );
        _;
    }

    // @dev 让当前CEO指派一名新的CEO
    // @param _newCEO 新的CEO的地址
    function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }

    // @dev 让CEO指派一名新的CFO
    // @param _newCFO 新的CFO的地址
    function setCFO(address _newCFO) external onlyCEO {
        require(_newCFO != address(0));

        cfoAddress = _newCFO;
    }

    // @dev 让CEO指派一名新的COO
    // @param _newCOO 新的COO的地址
    function setCOO(address _newCOO) external onlyCEO {
        require(_newCOO != address(0));

        cooAddress = _newCOO;
    }

    /*** Pausable功能的设计方法来自于OpenZeppelin ***/

    // @dev 提供没有被暂定的状态检查
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    // @dev 提供被暂定的状态检查
    modifier whenPaused {
        require(paused);
        _;
    }

    /// @dev "C-level"能够启动暂定操作，用以应对潜在的bug和缺陷，以降低损失
    function pause() external onlyCLevel whenNotPaused {
        paused = true;
    }

    /// @dev 只有CEO能够取消暂停状态，用来规避当CFO或COO被攻破的情况
    /// @notice 把功能设置为public，可以让衍生的协议也能发起操作
    function unpause() public onlyCEO whenPaused {
        // can't unpause if contract was upgraded
        paused = false;
    }
}


// @title CryptoKitties的基础，保存了公用的结构体、事件、基本变量
// @author Axiom Zen (https://www.axiomzen.co)
// @dev 查看KittyCore来了解协议之间的关系
contract KittyBase is KittyAccessControl {
    /*** EVENTS ***/

    /// @dev 小猫出生时的事件，包括giveBirth和0代猫的创建
    event Birth(address owner, uint256 kittyId, uint256 matronId, uint256 sireId, uint256 genes);

    /// @dev ERC721定义的转让事件，当kitty的主人变换时调用（包括出生）
    event Transfer(address from, address to, uint256 tokenId);

    /*** 数据类型 ***/

    /// @dev 迷恋猫的数据结构，因为这是每只猫的基本结构，所以设计为恰好两个256位的字
    ///  因为以太坊的编码方案，所以成员的顺序也很重要
    ///  参考资料：http://solidity.readthedocs.io/en/develop/miscellaneous.html
    struct Kitty {

        // 迷恋猫的基因是256-bits，并且不会改变
        uint256 genes;

        // 迷恋猫创建时来自区块的时间戳
        uint64 birthTime;

        // 这只猫可以再次生育的最小时间戳
        uint64 cooldownEndBlock;

        // 双亲的ID，0代的双亲ID是0
        // 32位无符号整数看似只能有40亿只猫
        // 但是以太坊每年只能支持5亿次交易，因此未来几年不会出问题
        uint32 matronId;
        uint32 sireId;

        // 当这只猫是雌性时的雄性的ID，0表示没有怀孕，非0表示已经怀孕
        // 主要在生成小猫时获得父亲的基因数据
        uint32 siringWithId;

        // 修养时长的编号，初始值为遗传所得
        // 每次生育不变，但是冷却时间加倍
        uint8 cooldownIndex;

        // 猫的代，创始团队创建的猫是0代，其她猫是双亲最大的代加一
        // 也就是，max(matron.generation, sire.generation) + 1
        uint16 generation;

        // 性别 0 ： 母   1: 公
        uint8 sex;

        //版本号
        uint8 version;

        //速度（初始速度）
        uint16 speed;

        //马繁殖次数
        uint8 sireTimes
    }

    /*** 常量 ***/

    /// @dev 不同编号的修养时间
    ///  每次生育后差不多翻一倍，从而规避主人不断的用同一只猫生育，最长是1周
    uint32[14] public cooldowns = [
        uint32(5 minutes),
        uint32(15 minutes),
        uint32(30 minutes),
        uint32(60 minutes),
        uint32(2 hours),
        uint32(12 hours),
        uint32(1 days),
        uint32(2 days)
    ];

    // 对块之间时间差的估算，大概15秒 以太坊挖出一个区块的时间间隔大概17s
    uint256 public secondsPerBlock = 15;

    /*** 持久存储 ***/

    /// @dev 保存所有迷恋猫的数组，ID是索引，
    ///  ID为0是不存在的生物，但又是0代猫的双亲
    Kitty[] kitties;

    /// @dev 从猫的ID到主人的地址的映射
    ///  所有猫都有一个非0地址的主人，包括0代猫
    mapping (uint256 => address) public kittyIndexToOwner;

    // @dev 从主人地址到他拥有的猫的个数的映射
    //  在函数balanceOf()中使用
    mapping (address => uint256) ownershipTokenCount;

    /// @dev 从猫的ID到被允许领养的主人地址的映射，在transferFrom()中使用
    ///  每只猫在任何时候只能有一个被允许的领养者的地址
    ///  0表示没有人被批准
    mapping (uint256 => address) public kittyIndexToApproved;

    /// @dev 从猫的ID到能被一起生育的主人的地址的映射，在breedWith()中使用
    ///  每只猫在任何时候只能有一个被允许一起生育的主人的地址
    ///  0表示没有人被批准
    mapping (uint256 => address) public sireAllowedToAddress;

    /// @dev ClockAuction协议的地址，用来买卖猫
    ///  这个协议处理了用户之间的买卖以及0代猫的初始买卖
    ///  每15分钟被调用一次

    //TODO
    //SaleClockAuction public saleAuction;

    /// @dev ClockAuction协议的地址，用来交易生育服务
    ///  需要两个交易服务是因为买卖和生育有很多不同

    //TODO
    //SiringClockAuction public siringAuction;

    //马地址到马繁殖次数的映射
    //mapping (uint256 => uint8) public ponyIndexSireTimes;

    //马地址到最后一次繁殖时间的映射
    mapping (uint256 => uint64) public ponyIndexLastSiringTime;

    //马地址到最后一次比赛时间的映射
    mapping (uint256 => uint64) public ponyIndexLastRaceTime;

    //马地址到参赛次数的映射
    mapping (uint256 => uint8) public ponyIndexRaceTimes;

    //马地址到冠军次数的映射
    mapping (uint256 => uint8) public ponyIndexChampion;

    //马地址到亚军次数的映射
    mapping (uint256 => uint8) public ponyIndexSecond;

    //马地址到季军次数的映射
    mapping (uint256 => uint8) public ponyIndexThird;



    /// @dev 设置一只猫的主人地址
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        // 因为猫的数量最大是2^32，我们不会溢出
        ownershipTokenCount[_to]++;
        // 设置主人
        kittyIndexToOwner[_tokenId] = _to;
        // 需要规避原来主人是0x0的情况，尽管这个不应该发生
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            // 同时清空允许生育的主人地址
            delete sireAllowedToAddress[_tokenId];
            // 同时清空允许领养的主人地址
            delete kittyIndexToApproved[_tokenId];
        }
        // 发出主人转换事件
       	emit Transfer(_from, _to, _tokenId);
    }

    /// @dev 内部方法，创建一只猫，它不做安全检查，因此输入数据要保证正确
    ///  会产生Birth事件和Transfer事件
    /// @param _matronId 母亲ID（0代的母亲是0）
    /// @param _sireId 父亲ID（0代的父亲是0）
    /// @param _generation 这只猫的代，有调用者计算
    /// @param _genes 基因编码
    /// @param _owner 初始主人的地址，非0
    /// 性别 uint8 sex;
    /// 版本号 uint8 version;
    /// 速度（初始速度） uint16 speed;
    function _createKitty(
        uint256 _matronId,
        uint256 _sireId,
        uint256 _generation,
        uint256 _genes,
        address _owner,
        uint8 _sex,
        uint16 _speed,
        uint8 _cooldownIndex,
        uint8 _version
    )
        internal
        returns (uint)
    {
        // 这些require并非必要，因为调用者需要保证正确
        // 但是因为_createKitty()的存储相对昂贵，因此增加检查也有价值
        require(_matronId == uint256(uint32(_matronId)));
        require(_sireId == uint256(uint32(_sireId)));
        require(_generation == uint256(uint16(_generation)));
        require(_sex == uint256(uint8(_sex)));
        require(_version == uint256(uint8(_version)));
        require(_speed == uint256(uint16(_speed)));
        require(_cooldownIndex == uint256(uint8(_cooldownIndex)));

        Kitty memory _kitty = Kitty({
            genes: _genes,
            birthTime: uint64(now),
            cooldownEndBlock: 0,
            matronId: uint32(_matronId),
            sireId: uint32(_sireId),
            cooldownIndex: _cooldownIndex,
            siringWithId: 0,
            generation: uint16(_generation),
            sex:uint8(_sex),
            version:uint8(_version),
            speed:uint16(_speed),
            sireTimes:0

        });
        // ID是递增的
        uint256 newKittenId = kitties.push(_kitty) - 1;

        // 虽然超过40亿只猫不太会发生，但是还是检查一下
        require(newKittenId == uint256(uint32(newKittenId)));

        // 发出Birth事件
        emit Birth(
            _owner,
            newKittenId,
            uint256(_kitty.matronId),
            uint256(_kitty.sireId),
            _kitty.genes
        );

        // 设置主人，并且发出Transfer事件
        // 遵循ERC721草案
        _transfer(0, _owner, newKittenId);

        return newKittenId;
    }

    // C?O可以调整每块多少秒
    function setSecondsPerBlock(uint256 secs) external onlyCLevel {
        require(secs < cooldowns[0]);
        secondsPerBlock = secs;
    }
}


/// @title 基于ERC-721草案，管理猫的所有权
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev Ref: https://github.com/ethereum/EIPs/issues/721
///  查看KittyCore来了解协议之间的关系
contract KittyOwnership is KittyBase, ERC721 {

    /// @notice 基于ERC721，Name和symbol都是不可分割的Token
    string public constant name = "CryptoKitties";
    string public constant symbol = "CK";

    // 返回猫的元数据
    ERC721Metadata public erc721Metadata;

    bytes4 constant InterfaceSignature_ERC165 =
        bytes4(keccak256('supportsInterface(bytes4)'));

    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(keccak256('name()')) ^
        bytes4(keccak256('symbol()')) ^
        bytes4(keccak256('totalSupply()')) ^
        bytes4(keccak256('balanceOf(address)')) ^
        bytes4(keccak256('ownerOf(uint256)')) ^
        bytes4(keccak256('approve(address,uint256)')) ^
        bytes4(keccak256('transfer(address,uint256)')) ^
        bytes4(keccak256('transferFrom(address,address,uint256)')) ^
        bytes4(keccak256('tokensOfOwner(address)')) ^
        bytes4(keccak256('tokenMetadata(uint256,string)'));

    /// @notice ERC-165相关接口 (https://github.com/ethereum/EIPs/issues/165)
    ///  判断是否是自己支持的ERC721或ERC165接口
    function supportsInterface(bytes4 _interfaceID) external view returns (bool)
    {
        // DEBUG ONLY
        //require((InterfaceSignature_ERC165 == 0x01ffc9a7) && (InterfaceSignature_ERC721 == 0x9a20483d));

        return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));
    }

    /// @dev 设置跟踪元数据的协议地址
    ///  只能CEO操作
    function setMetadataAddress(address _contractAddress) public onlyCEO {
        erc721Metadata = ERC721Metadata(_contractAddress);
    }

    // 内部函数：假设所有输入参数有效
    // 公共方法负责验证数据

    /// @dev 判断一个地址是否是猫的主人
    /// @param _claimant 判断的用户的地址
    /// @param _tokenId 猫的ID，需要大于0
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return kittyIndexToOwner[_tokenId] == _claimant;
    }

    /// @dev 判断一个地址能否领养一个猫
    /// @param _claimant 判断的用户的地址
    /// @param _tokenId 猫的ID，需要大于0
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return kittyIndexToApproved[_tokenId] == _claimant;
    }

    /// @dev 设置transferFrom()函数用到的可以领养的地址
    ///  设为0，可以清除之前的设置
    ///  NOTE: _approve() 仅是内部使用，并不发送Approval事件
    ///  因为_approve()和transferFrom()共同用于拍卖
    ///  没有必要额外多加事件
    function _approve(uint256 _tokenId, address _approved) internal {
        kittyIndexToApproved[_tokenId] = _approved;
    }

    /// @notice 返回一个地址拥有的猫的数量
    /// @param _owner 判断的地址
    /// @dev 用于兼容ERC-721
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }

    /// @notice 把猫转到另一个地址，要确保ERC-721兼容，否则可能丢失猫
    /// @param _to 接受者地址
    /// @param _tokenId 猫的ID
    /// @dev 用于兼容ERC-721
    function transfer(
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        // 放置转移到0x0
        require(_to != address(0));
        // 不能把猫转给协议本身
        // 协议不拥有猫（特例是，0代猫刚被创建，进入拍卖前）
        require(_to != address(this));
        // Disallow transfers to the auction contracts to prevent accidental
        // misuse. Auction contracts should only take ownership of kitties
        // through the allow + transferFrom flow.

        //TODO
        //require(_to != address(saleAuction));
        //require(_to != address(siringAuction));

        // 你只能转让自己的猫
        require(_owns(msg.sender, _tokenId));

        // 修改主人，清除领养列表，发出Transfer事件
        _transfer(msg.sender, _to, _tokenId);
    }

    /// @notice 赋予一个地址通过transferFrom()获得猫的权利
    /// @param _to 被授权的地址，ID为0是取消授权
    /// @param _tokenId 猫的ID
    /// @dev 用于兼容ERC-721
    function approve(
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        // 只有主人能够给予授权
        require(_owns(msg.sender, _tokenId));

        // 注册授权
        _approve(_tokenId, _to);

        // 发出Approval事件
       	emit Approval(msg.sender, _to, _tokenId);
    }

    /// @notice 从另一个主人手上获得他的一只猫的所有权，需要通过approval授权
    /// @param _from 猫的当前主人的地址
    /// @param _to 猫的新主人的地址
    /// @param _tokenId 猫的ID
    /// @dev 用于兼容ERC-721
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        // 安全检查，防止转给地址0
        require(_to != address(0));
        // 不能把猫转给协议本身
        // 协议不拥有猫（特例是，0代猫刚被创建，进入拍卖前）
        require(_to != address(this));
        // Check for approval and valid ownership
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));

        // 修改主人，清除领养列表，发出Transfer事件
        _transfer(_from, _to, _tokenId);
    }

    /// @notice 返回当前猫的总数
    /// @dev 兼容ERC-721
    function totalSupply() public view returns (uint) {
        return kitties.length - 1;
    }

    /// @notice 返回一个猫的主人
    /// @dev 兼容ERC-721
    function ownerOf(uint256 _tokenId)
        external
        view
        returns (address owner)
    {
        owner = kittyIndexToOwner[_tokenId];

        require(owner != address(0));
    }

    /// @notice 返回一个主人的猫的列表
    /// @param _owner 主人的地址
    /// @dev 这个方法不要被协议调用，因为过于昂贵
    ///  需要遍历所有的猫，而且结果的长度是动态的
    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            // 如果没有猫，则为空
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalCats = totalSupply();
            uint256 resultIndex = 0;

            // 猫的ID从1开始自增
            uint256 catId;

            for (catId = 1; catId <= totalCats; catId++) {
                if (kittyIndexToOwner[catId] == _owner) {
                    result[resultIndex] = catId;
                    resultIndex++;
                }
            }

            return result;
        }
    }

    /// @dev 源自memcpy() @arachnid (Nick Johnson <arachnid@notdot.net>)
    ///  这个方法遵循Apache License.
    ///  参考资料： https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol
    function _memcpy(uint _dest, uint _src, uint _len) private pure{
        // 尽量32位的拷贝
        for(; _len >= 32; _len -= 32) {
            assembly {
                mstore(_dest, mload(_src))
            }
            _dest += 32;
            _src += 32;
        }

        // 拷贝剩余内容
        uint256 mask = 256 ** (32 - _len) - 1;
        assembly {
            let srcpart := and(mload(_src), not(mask))
            let destpart := and(mload(_dest), mask)
            mstore(_dest, or(destpart, srcpart))
        }
    }

    /// @dev 源自toString(slice) @arachnid (Nick Johnson <arachnid@notdot.net>)
    ///  这个方法遵循Apache License.
    ///  参考资料： https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol

    //TODO
    // function _toString(bytes32[4] _rawBytes, uint256 _stringLength) private pure returns (string) {
    //     var outputString = new string(_stringLength);
    //     uint256 outputPtr;
    //     uint256 bytesPtr;

    //     assembly {
    //         outputPtr := add(outputString, 32)
    //         bytesPtr := _rawBytes
    //     }

    //     _memcpy(outputPtr, bytesPtr, _stringLength);

    //     return outputString;
    // }

    /// @notice 返回一个URI，指向该token遵循的ERC-721的元数据包
    ///  (https://github.com/ethereum/EIPs/issues/721)
    /// @param _tokenId 猫的ID

    //TODO
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) external view returns (string infoUrl) {
    //     require(erc721Metadata != address(0));
    //     bytes32[4] memory buffer;
    //     uint256 count;
    //     (buffer, count) = erc721Metadata.getMetadata(_tokenId, _preferredTransport);

    //     return _toString(buffer, count);
    // }
}



/// @title 管理猫的交配、怀孕、出生
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev 查看KittyCore来了解协议之间的关系
contract KittyBreeding is KittyOwnership {

    /// @dev 当两只猫成功交配，母亲怀孕期设定后，发出Pregnant事件
    event Pregnant(address owner, uint256 matronId, uint256 sireId, uint256 cooldownEndBlock);

    /// @notice 交配方式breedWithAuto()的最小付款额
    ///  这是giveBirth()调用者支付的gas，可以由COO随时调整
    /// 1 eth = 1000 finney
    uint256 public autoBirthFee = 2 finney;

    // 记录多少只怀孕的猫
    uint256 public pregnantKitties;

    /// @dev 实现基因算法的协议
    GeneScienceInterface public geneScience;

    /// @dev 升级基因算法的地址，只能CEO调用
    /// @param _address 新的GeneScience协议实例的地址
    function setGeneScienceAddress(address _address) external onlyCEO {
        GeneScienceInterface candidateContract = GeneScienceInterface(_address);

        // NOTE: 确认协议是否符合标准 - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isGeneScience());

        // Set the new contract address
        geneScience = candidateContract;
    }

    /// @dev 检查一只猫能否生育，需要判断不在修养期，并且不在生育前
    function _isReadyToBreed(Kitty _kit) internal view returns (bool) {
        // 除了检查cooldownEndBlock的修养期，还要检查是否在等待出生
        return (_kit.siringWithId == 0) && (_kit.cooldownEndBlock <= uint64(block.number));
    }

    /// @dev 判断雄性是否被授权与雌性交配
    ///  条件是：是否是同一个主人，或者被授权 approveSiring()
    function _isSiringPermitted(uint256 _sireId, uint256 _matronId) internal view returns (bool) {
        address matronOwner = kittyIndexToOwner[_matronId];
        address sireOwner = kittyIndexToOwner[_sireId];

        // 是否是同一个主人，或者被授权
        return (matronOwner == sireOwner || sireAllowedToAddress[_sireId] == matronOwner);
    }

    /// @dev 基于修养指数cooldownIndex，设置修养时间cooldownEndTime
    ///  同时调整修养指数
    /// @param _kitten 需要调整的猫的状态
    function _triggerCooldown(Kitty storage _kitten) internal {
        // 基于cooldownIndex和secondsPerBlock，判断结束时的区块  cooldowns * 2 sireTimes 平方次
        _kitten.cooldownEndBlock = uint64((cooldowns[_kitten.cooldownIndex]*(2**_kitten.sireTimes)/secondsPerBlock) + block.number);

        // 增加修养指数，最大到13
        // 我们可以动态检查cooldowns的大小，但是硬编码来节省gas
        // if (_kitten.cooldownIndex < 13) {
        //     _kitten.cooldownIndex += 1;
        // }
    }

    /// @notice 允许另一个用户和你的猫交配
    /// @param _addr 另一个用户的地址，设置为0来清楚授权
    /// @param _sireId 你自己可以被交配的猫的地址
    function approveSiring(address _addr, uint256 _sireId)
        external
        whenNotPaused
    {
        require(_owns(msg.sender, _sireId));
        sireAllowedToAddress[_sireId] = _addr;
    }

    /// @dev 修改调用giveBirthAuto()的付费，只能COO调用
    ///  提供生育猫所必须的gas
    function setAutoBirthFee(uint256 val) external onlyCOO {
        autoBirthFee = val;
    }

    /// @dev 判断一个猫是否可以产出小猫
    function _isReadyToGiveBirth(Kitty _matron) private view returns (bool) {
        return (_matron.siringWithId != 0) && (_matron.cooldownEndBlock <= uint64(block.number));
    }

    /// @notice 判断一只猫能否交配
    /// @param _kittyId 猫的ID
    function isReadyToBreed(uint256 _kittyId)
        public
        view
        returns (bool)
    {
        require(_kittyId > 0);
        Kitty storage kit = kitties[_kittyId];
        return _isReadyToBreed(kit);
    }

    /// @dev 判断一只猫是否怀孕
    /// @param _kittyId 猫的ID
    function isPregnant(uint256 _kittyId)
        public
        view
        returns (bool)
    {
        require(_kittyId > 0);
        // 只有siringWithId被设置，才是怀孕中
        return kitties[_kittyId].siringWithId != 0;
    }

    /// @dev 检查能否符合伦理的交配，并不检查所有权
    /// @param _matron 潜在的母亲
    /// @param _matronId 目前的ID
    /// @param _sire A 潜在的父亲
    /// @param _sireId 父亲的ID
    function _isValidMatingPair(
        Kitty storage _matron,
        uint256 _matronId,
        Kitty storage _sire,
        uint256 _sireId
    )
        private
        view
        returns(bool)
    {
    	//同性别不可繁殖
    	if(_matron.sex == _sire.sex){
    		return false;
    	}
        // 不能和自己交配
        if (_matronId == _sireId) {
            return false;
        }

        // 不能和父母交配
        if (_matron.matronId == _sireId || _matron.sireId == _sireId) {
            return false;
        }
        if (_sire.matronId == _matronId || _sire.sireId == _matronId) {
            return false;
        }

        // 特殊处理0代猫
        if (_sire.matronId == 0 || _matron.matronId == 0) {
            return true;
        }

        // 不能和兄妹交配
        if (_sire.matronId == _matron.matronId || _sire.matronId == _matron.sireId) {
            return false;
        }
        if (_sire.sireId == _matron.matronId || _sire.sireId == _matron.sireId) {
            return false;
        }

        // 一切正常
        return true;
    }

    /// @dev 内部检查是否能够通过拍卖支持交配服务
    function _canBreedWithViaAuction(uint256 _matronId, uint256 _sireId)
        internal
        view
        returns (bool)
    {
        Kitty storage matron = kitties[_matronId];
        Kitty storage sire = kitties[_sireId];
        return _isValidMatingPair(matron, _matronId, sire, _sireId);
    }

    /// @notice 检查两只猫能否生育，包括所有权和授予权
    ///  并不检查猫是否可以生育
    /// @param _matronId 潜在母亲的ID
    /// @param _sireId 潜在父亲的ID
    function canBreedWith(uint256 _matronId, uint256 _sireId)
        external
        view
        returns(bool)
    {
        require(_matronId > 0);
        require(_sireId > 0);
        Kitty storage matron = kitties[_matronId];
        Kitty storage sire = kitties[_sireId];
        return _isValidMatingPair(matron, _matronId, sire, _sireId) &&
            _isSiringPermitted(_sireId, _matronId);
    }

    /// @dev 在所有检查通过后，内部发起生育的函数
    function _breedWith(uint256 _matronId, uint256 _sireId) internal {
        // Grab a reference to the Kitties from storage.
        Kitty storage sire = kitties[_sireId];
        Kitty storage matron = kitties[_matronId];

        // 标记母亲怀孕，以及父亲的ID
        matron.siringWithId = uint32(_sireId);

        // 设置修养期
        _triggerCooldown(sire);
        _triggerCooldown(matron);

        // 清除交配的授权
        // but it's likely to avoid confusion!
        delete sireAllowedToAddress[_matronId];
        delete sireAllowedToAddress[_sireId];

        // 增加怀孕的猫的数量
        pregnantKitties++;

        // 发出Pregnant事件
        emit Pregnant(kittyIndexToOwner[_matronId], _matronId, _sireId, matron.cooldownEndBlock);
    }

    /// @notice 用你的猫作为母亲与你的猫或者你被授权的猫交配
    ///  或者会成功，或者会彻底失败，需要giveBirth()的调用者预付gas
    /// @param _matronId 母亲的ID
    /// @param _sireId 父亲的ID
    function breedWithAuto(uint256 _matronId, uint256 _sireId)
        external
        payable
        whenNotPaused
    {
        // 检查费用
        require(msg.value >= autoBirthFee);

        // 调用者需要拥有母亲
        require(_owns(msg.sender, _matronId));

        // 怀孕中的父母不能再次参与交配服务的拍卖，但我们也不需要明确的检查
        // 因为拍卖时的主人是拍卖房
        // 因此我们不需要浪费gas来做检查

        // 检查是否是同一个主人，或者被授权
        require(_isSiringPermitted(_sireId, _matronId));

        // 获得潜在的母亲的数据
        Kitty storage matron = kitties[_matronId];

        //0 代表母
        require (matron.sex==0);


        // 确认母亲可以交配
        require(_isReadyToBreed(matron));

        // 获得潜在的父亲的数据
        Kitty storage sire = kitties[_sireId];

        //1代表公
        require (sire.sex==1);


        // 确认父亲可以交配
        require(_isReadyToBreed(sire));

        // 确认符合伦理
        require(_isValidMatingPair(
            matron,
            _matronId,
            sire,
            _sireId
        ));

        // 开始生育
        _breedWith(_matronId, _sireId);
    }

    /// @notice 生出一个小猫
    /// @param _matronId 母亲的ID
    /// @return 新的小猫的ID
    /// @dev 检查哦母亲是否可以生出小猫
    ///  计算小猫的基因，并且把小猫给予母亲的主人
    ///  任何人都可以调用生育，但是需要支付gas，尽管小猫只是归属母亲的主人
    function giveBirth(uint256 _matronId)
        external
        whenNotPaused
        returns(uint256)
    {
        // 获得母亲的数据
        Kitty storage matron = kitties[_matronId];

        //只有母马才能生产
        require (matron.sex==0);

        // 检查母亲数据是否有效
        require(matron.birthTime != 0);

        // 检查母亲是否可以生出小猫
        require(_isReadyToGiveBirth(matron));

        // 获得父亲的数据
        uint256 sireId = matron.siringWithId;
        Kitty storage sire = kitties[sireId];

        //必须是公马
        require (sire.sex==1);


        // 确认父母中最大的代
        uint16 parentGen = matron.generation;
        if (sire.generation > matron.generation) {
            parentGen = sire.generation;
        }

	    /// @return 1: the genes
	    /// @return 2: 性别
	    /// @return 3: 速度
	    /// @return 4: 繁殖速度
	    /// @return 5: 版本号

        uint256 childGenes;

        // 性别 0 ： 母   1: 公
        uint8 sex;

        //速度（初始速度）
        uint16 speed;
        //繁殖速度
        uint8 cooldownIndex;
        //版本号
        uint8 version;
        // 生成小猫的基因
        (childGenes,sex,speed,cooldownIndex,version) = geneScience.mixGenes(matron.genes, sire.genes, matron.cooldownEndBlock - 1,verson);

        // 生成新的小猫
        address owner = kittyIndexToOwner[_matronId];
        uint256 kittenId = _createKitty(_matronId, matron.siringWithId, parentGen + 1, childGenes, owner,sex,speed,cooldownIndex,version);

        // 清除怀孕中父亲的ID，从而标记能够交配
        delete matron.siringWithId;

        // 减少怀孕中猫的数量
        pregnantKitties--;

        // 把费用发给对应的地址
        msg.sender.transfer(autoBirthFee);

        // 返回小猫的ID
        return kittenId;
    }
}
